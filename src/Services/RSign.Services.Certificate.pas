unit RSign.Services.Certificate;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.DateUtils,
  RSign.Core.Interfaces,
  RSign.Types.Common,
  RSign.Types.Certificate,
  RSign.Types.Config;

type
  TCertificateService = class(TInterfacedObject, ICertificateService)
  private
    FLogger: ILoggerService;
    FProcessExecutor: IProcessExecutor;
    function ObterCaminhoPfx(const AConfiguracaoCaminhos: TConfiguracaoCaminhos): string;
    function DelimitarTextoPowerShell(const AValor: string): string;
    function CriarArquivoTemporarioScript(const AConteudoScript: string): string;
    function ExecutarScriptPowerShell(const AConteudoScript: string; const AParametros: string; const ADiretorioTrabalho: string): TResultadoProcessoExterno;
    function ExtrairValor(const ATexto: string; const AChave: string): string;
    function TextoIndicaSenhaInvalida(const ATexto: string): Boolean;
    function MontarSubjectCertificado(const AConfiguracaoCertificado: TConfiguracaoCertificado): string;
  protected
    constructor Create(const ALogger: ILoggerService; const AProcessExecutor: IProcessExecutor);
    function Validar(const AConfiguracaoCertificado: TConfiguracaoCertificado; const AConfiguracaoCaminhos: TConfiguracaoCaminhos): TStatusCertificado;
    function Criar(const AConfiguracaoCertificado: TConfiguracaoCertificado; const AConfiguracaoCaminhos: TConfiguracaoCaminhos): TResultadoCriacaoCertificado;
  public
    class function New(const ALogger: ILoggerService; const AProcessExecutor: IProcessExecutor): ICertificateService;
  end;

implementation

uses
  RSign.Core.Constants;

constructor TCertificateService.Create(const ALogger: ILoggerService; const AProcessExecutor: IProcessExecutor);
begin
  inherited Create;
  FLogger := ALogger;
  FProcessExecutor := AProcessExecutor;
end;

class function TCertificateService.New(const ALogger: ILoggerService; const AProcessExecutor: IProcessExecutor): ICertificateService;
begin
  Result := Self.Create(ALogger, AProcessExecutor);
end;

function TCertificateService.ObterCaminhoPfx(const AConfiguracaoCaminhos: TConfiguracaoCaminhos): string;
begin
  Result := Trim(AConfiguracaoCaminhos.CaminhoCompletoPfx);
end;

function TCertificateService.DelimitarTextoPowerShell(const AValor: string): string;
begin
  Result := Format('"%s" ', [AValor]) ;
end;

function TCertificateService.CriarArquivoTemporarioScript(const AConteudoScript: string): string;
var
  LDiretorioTemporario: string;
  LCodificacaoUTF8: TUTF8Encoding;
begin
  LDiretorioTemporario := TPath.Combine(TPath.GetTempPath, 'RSign');
  ForceDirectories(LDiretorioTemporario);

  Result := TPath.Combine(LDiretorioTemporario, TPath.GetRandomFileName + '.ps1');

  LCodificacaoUTF8 := TUTF8Encoding.Create;
  try
    TFile.WriteAllText(Result, AConteudoScript, LCodificacaoUTF8);
  finally
    LCodificacaoUTF8.Free;
  end;
end;

function TCertificateService.ExecutarScriptPowerShell(const AConteudoScript: string; const AParametros: string; const ADiretorioTrabalho: string): TResultadoProcessoExterno;
var
  LCaminhoScript: string;
  LCaminhoPowerShell: string;
  LParametrosPowerShell: string;
begin
  if not Assigned(FProcessExecutor) then
    raise Exception.Create('O ProcessExecutor não foi informado para a execução do PowerShell.');

  LCaminhoScript := CriarArquivoTemporarioScript(AConteudoScript);
  try
    LCaminhoPowerShell := Trim(GetEnvironmentVariable('WINDIR'));

    if LCaminhoPowerShell <> '' then
      LCaminhoPowerShell := TPath.Combine(LCaminhoPowerShell, 'System32\WindowsPowerShell\v1.0\powershell.exe');

    if (LCaminhoPowerShell = '') or (not TFile.Exists(LCaminhoPowerShell)) then
      LCaminhoPowerShell := 'powershell.exe';

    LParametrosPowerShell :=
      '-NoProfile -ExecutionPolicy Bypass -File "' + LCaminhoScript + '" ' + AParametros;

    Result := FProcessExecutor.Execute(
      LCaminhoPowerShell,
      LParametrosPowerShell,
      ADiretorioTrabalho,
      15000
    );
  finally
    if TFile.Exists(LCaminhoScript) then
      TFile.Delete(LCaminhoScript);
  end;
end;

function TCertificateService.ExtrairValor(const ATexto: string; const AChave: string): string;
var
  LLinhas: TStringList;
  LIndice: Integer;
  LPrefixo: string;
  LLinhaAtual: string;
begin
  Result := '';
  LPrefixo := UpperCase(Trim(AChave)) + '=';

  LLinhas := TStringList.Create;
  try
    LLinhas.Text := ATexto;

    for LIndice := 0 to LLinhas.Count - 1 do
    begin
      LLinhaAtual := Trim(LLinhas[LIndice]);

      if Pos(LPrefixo, UpperCase(LLinhaAtual)) = 1 then
      begin
        Result := Copy(LLinhaAtual, Length(LPrefixo) + 1, MaxInt);
        Exit;
      end;
    end;
  finally
    LLinhas.Free;
  end;
end;

function TCertificateService.TextoIndicaSenhaInvalida(const ATexto: string): Boolean;
var
  LTexto: string;
begin
  LTexto := UpperCase(ATexto);

  Result :=
    (Pos('PASSWORD', LTexto) > 0) or
    (Pos('SENHA', LTexto) > 0) or
    (Pos('NETWORK PASSWORD', LTexto) > 0) or
    (Pos('NOT CORRECT', LTexto) > 0) or
    (Pos('INCORRETA', LTexto) > 0);
end;

function TCertificateService.MontarSubjectCertificado(const AConfiguracaoCertificado: TConfiguracaoCertificado): string;
begin
  Result := 'CN=' + Trim(AConfiguracaoCertificado.NomeCertificado);

  if Trim(AConfiguracaoCertificado.Organizacao) <> '' then
    Result := Result + ', O=' + Trim(AConfiguracaoCertificado.Organizacao);

  if Trim(AConfiguracaoCertificado.Departamento) <> '' then
    Result := Result + ', OU=' + Trim(AConfiguracaoCertificado.Departamento);

  if Trim(AConfiguracaoCertificado.Cidade) <> '' then
    Result := Result + ', L=' + Trim(AConfiguracaoCertificado.Cidade);

  if Trim(AConfiguracaoCertificado.Estado) <> '' then
    Result := Result + ', S=' + Trim(AConfiguracaoCertificado.Estado);

  if Trim(AConfiguracaoCertificado.Pais) <> '' then
    Result := Result + ', C=' + Trim(AConfiguracaoCertificado.Pais);

  if Trim(AConfiguracaoCertificado.Email) <> '' then
    Result := Result + ', E=' + Trim(AConfiguracaoCertificado.Email);
end;

function TCertificateService.Validar(const AConfiguracaoCertificado: TConfiguracaoCertificado; const AConfiguracaoCaminhos: TConfiguracaoCaminhos): TStatusCertificado;
var
  LCaminhoPfx: string;
  LScriptPowerShell: string;
  LParametrosPowerShell: string;
  LResultadoProcesso: TResultadoProcessoExterno;
  LTextoRetorno: string;
  LDataValidade: TDateTime;
begin
  Result := TStatusCertificado.Empty;
  LCaminhoPfx := ObterCaminhoPfx(AConfiguracaoCaminhos);

  if LCaminhoPfx = '' then
  begin
    Result.MensagemAmigavel := 'O caminho do certificado não foi informado.';
    Result.MensagemTecnica := 'Não foi possível validar o certificado porque o caminho completo do PFX está vazio.';
    Exit;
  end;

  if Assigned(FLogger) then
    FLogger.Debug('Certificate', 'Validando certificado PFX: ' + LCaminhoPfx);

  Result.ArquivoExiste := TFile.Exists(LCaminhoPfx);

  if not Result.ArquivoExiste then
  begin
    Result.MensagemAmigavel := 'O certificado configurado não foi encontrado.';
    Result.MensagemTecnica := 'Arquivo não encontrado: ' + LCaminhoPfx;

    if Assigned(FLogger) then
      FLogger.Warning('Certificate', Result.MensagemAmigavel, Result.MensagemTecnica);

    Exit;
  end;

  LScriptPowerShell :=
    'param([string]$PfxPath,[string]$Password)' + sLineBreak +
    '$ErrorActionPreference = ''Stop''' + sLineBreak +
    'try {' + sLineBreak +
    '  $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force' + sLineBreak +
    '  $pfxData = Get-PfxData -FilePath $PfxPath -Password $securePassword -ErrorAction Stop' + sLineBreak +
    '  $cert = $pfxData.EndEntityCertificates[0]' + sLineBreak +
    '  $isCodeSigning = $false' + sLineBreak +
    '  foreach ($usage in $cert.EnhancedKeyUsageList) {' + sLineBreak +
    '    if ($usage.ObjectId -eq ''1.3.6.1.5.5.7.3.3'') { $isCodeSigning = $true; break }' + sLineBreak +
    '  }' + sLineBreak +
    '  Write-Output ''STATUS=OK''' + sLineBreak +
    '  Write-Output (''HASPRIVATEKEY='' + $cert.HasPrivateKey)' + sLineBreak +
    '  Write-Output (''NOTAFTER='' + $cert.NotAfter.ToString(''o''))' + sLineBreak +
    '  Write-Output (''CODESIGNING='' + $isCodeSigning)' + sLineBreak +
    '} catch {' + sLineBreak +
    '  Write-Output ''STATUS=ERROR''' + sLineBreak +
    '  Write-Output (''ERROR='' + $_.Exception.Message)' + sLineBreak +
    '}';

  LParametrosPowerShell :=
    '-PfxPath ' + DelimitarTextoPowerShell(LCaminhoPfx) +
    '-Password ' + DelimitarTextoPowerShell(AConfiguracaoCertificado.Senha);

  LResultadoProcesso := ExecutarScriptPowerShell(LScriptPowerShell, LParametrosPowerShell, ExtractFilePath(LCaminhoPfx));
  LTextoRetorno := Trim(LResultadoProcesso.SaidaPadrao + sLineBreak + LResultadoProcesso.ErroPadrao);

  if not SameText(ExtrairValor(LTextoRetorno, 'STATUS'), 'OK') then
  begin
    Result.SenhaValida := False;
    Result.CertificadoIntegro := False;
    Result.PossuiChavePrivada := False;
    Result.CompativelComAssinatura := False;
    Result.ProximoDoVencimento := False;

    if TextoIndicaSenhaInvalida(ExtrairValor(LTextoRetorno, 'ERROR')) then
    begin
      Result.MensagemAmigavel := 'O certificado foi encontrado, mas a senha informada não é válida.';
      Result.MensagemTecnica := ExtrairValor(LTextoRetorno, 'ERROR');
    end
    else
    begin
      Result.MensagemAmigavel := 'O certificado encontrado parece estar corrompido ou inválido.';
      Result.MensagemTecnica := ExtrairValor(LTextoRetorno, 'ERROR');
    end;

    if Assigned(FLogger) then
      FLogger.Warning('Certificate', Result.MensagemAmigavel, Result.MensagemTecnica);

    Exit;
  end;

  Result.SenhaValida := True;
  Result.CertificadoIntegro := True;
  Result.PossuiChavePrivada := SameText(ExtrairValor(LTextoRetorno, 'HASPRIVATEKEY'), 'True');
  Result.CompativelComAssinatura := SameText(ExtrairValor(LTextoRetorno, 'CODESIGNING'), 'True');

  if TryISO8601ToDate(ExtrairValor(LTextoRetorno, 'NOTAFTER'), LDataValidade, False) then
  begin
    Result.Vencido := LDataValidade < Now;
    Result.ProximoDoVencimento := (not Result.Vencido) and (LDataValidade <= IncDay(Now, _DEFAULT_CERTIFICATE_EXPIRATION_WARNING_DAYS));
  end
  else
  begin
    Result.Vencido := False;
    Result.ProximoDoVencimento := False;
  end;

  if not Result.PossuiChavePrivada then
  begin
    Result.MensagemAmigavel := 'O certificado não possui chave privada utilizável para assinatura.';
    Result.MensagemTecnica := 'O PFX foi aberto, mas não apresentou private key válida.';

    if Assigned(FLogger) then
      FLogger.Warning('Certificate', Result.MensagemAmigavel, Result.MensagemTecnica);

    Exit;
  end;

  if not Result.CompativelComAssinatura then
  begin
    Result.MensagemAmigavel := 'O certificado encontrado não é compatível com assinatura de código.';
    Result.MensagemTecnica := 'A validação do PFX não confirmou uso compatível com assinatura de código.';

    if Assigned(FLogger) then
      FLogger.Warning('Certificate', Result.MensagemAmigavel, Result.MensagemTecnica);

    Exit;
  end;

  if Result.Vencido then
  begin
    Result.MensagemAmigavel := 'O certificado está vencido.';
    Result.MensagemTecnica := 'A data final de vigência do certificado já foi ultrapassada.';

    if Assigned(FLogger) then
      FLogger.Warning('Certificate', Result.MensagemAmigavel, Result.MensagemTecnica);

    Exit;
  end;

  if Result.ProximoDoVencimento then
  begin
    Result.MensagemAmigavel := 'O certificado está próximo do vencimento.';
    Result.MensagemTecnica := 'A vigência do certificado termina em até ' + IntToStr(_DEFAULT_CERTIFICATE_EXPIRATION_WARNING_DAYS) + ' dias.';

    if Assigned(FLogger) then
      FLogger.Warning('Certificate', Result.MensagemAmigavel, Result.MensagemTecnica);

    Exit;
  end;

  Result.MensagemAmigavel := 'O certificado foi validado com sucesso.';
  Result.MensagemTecnica := 'O PFX está íntegro, com senha válida e pronto para uso.';

  if Assigned(FLogger) then
    FLogger.Success('Certificate', Result.MensagemAmigavel);
end;

function TCertificateService.Criar(const AConfiguracaoCertificado: TConfiguracaoCertificado; const AConfiguracaoCaminhos: TConfiguracaoCaminhos): TResultadoCriacaoCertificado;
var
  LCaminhoPfx: string;
  LScriptPowerShell: string;
  LParametrosPowerShell: string;
  LResultadoProcesso: TResultadoProcessoExterno;
  LTextoRetorno: string;
  LSubject: string;
begin
  Result := TResultadoCriacaoCertificado.Empty;
  LCaminhoPfx := ObterCaminhoPfx(AConfiguracaoCaminhos);

  if AConfiguracaoCertificado.TipoCertificado <> TTipoCertificado.Autoassinado then
  begin
    Result.MensagemErro := 'A criação automática do certificado está disponível apenas para o tipo Autoassinado.';
    Exit;
  end;

  if LCaminhoPfx = '' then
  begin
    Result.MensagemErro := 'Não foi possível criar o certificado porque o caminho completo do PFX está vazio.';
    Exit;
  end;

  if Trim(AConfiguracaoCertificado.NomeCertificado) = '' then
  begin
    Result.MensagemErro := 'Informe o nome do certificado antes de criar o PFX.';
    Exit;
  end;

  if AConfiguracaoCertificado.Senha <> AConfiguracaoCertificado.ConfirmacaoSenha then
  begin
    Result.MensagemErro := 'A senha e a confirmação da senha do certificado não conferem.';
    Exit;
  end;

  ForceDirectories(ExtractFilePath(LCaminhoPfx));
  LSubject := MontarSubjectCertificado(AConfiguracaoCertificado);

  if Assigned(FLogger) then
    FLogger.Info('Certificate', 'Iniciando a criação do certificado autoassinado.');

  LScriptPowerShell :=
    'param([string]$Subject,[string]$PfxPath,[string]$Password,[int]$ValidityDays)' + sLineBreak +
    '$ErrorActionPreference = ''Stop''' + sLineBreak +
    '$thumbprint = ""' + sLineBreak +
    'try {' + sLineBreak +
    '  $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force' + sLineBreak +
    '  $cert = New-SelfSignedCertificate -Type CodeSigningCert -Subject $Subject -CertStoreLocation ''Cert:\CurrentUser\My'' -KeyExportPolicy Exportable -NotAfter (Get-Date).AddDays($ValidityDays)' + sLineBreak +
    '  $thumbprint = $cert.Thumbprint' + sLineBreak +
    '  Export-PfxCertificate -Cert (''Cert:\CurrentUser\My\'' + $thumbprint) -FilePath $PfxPath -Password $securePassword -Force | Out-Null' + sLineBreak +
    '  Write-Output ''STATUS=OK''' + sLineBreak +
    '  Write-Output (''THUMBPRINT='' + $thumbprint)' + sLineBreak +
    '  Write-Output (''PFXPATH='' + $PfxPath)' + sLineBreak +
    '} catch {' + sLineBreak +
    '  Write-Output ''STATUS=ERROR''' + sLineBreak +
    '  Write-Output (''ERROR='' + $_.Exception.Message)' + sLineBreak +
    '} finally {' + sLineBreak +
    '  if ($thumbprint -ne "") {' + sLineBreak +
    '    Remove-Item -Path (''Cert:\CurrentUser\My\'' + $thumbprint) -DeleteKey -ErrorAction SilentlyContinue' + sLineBreak +
    '  }' + sLineBreak +
    '}';

  LParametrosPowerShell :=
    '-Subject ' + DelimitarTextoPowerShell(LSubject) +
    '-PfxPath ' + DelimitarTextoPowerShell(LCaminhoPfx) +
    '-Password ' + DelimitarTextoPowerShell(AConfiguracaoCertificado.Senha) +
    '-ValidityDays ' + IntToStr(AConfiguracaoCertificado.ValidadeDias);

  LResultadoProcesso := ExecutarScriptPowerShell(LScriptPowerShell, LParametrosPowerShell, ExtractFilePath(LCaminhoPfx));
  Result.ComandosExecutados := LResultadoProcesso.ComandoExecutado;

  LTextoRetorno := Trim(LResultadoProcesso.SaidaPadrao + sLineBreak + LResultadoProcesso.ErroPadrao);

  if SameText(ExtrairValor(LTextoRetorno, 'STATUS'), 'OK') then
  begin
    Result.Sucesso := True;
    Result.CaminhoPfxGerado := ExtrairValor(LTextoRetorno, 'PFXPATH');
    Result.Thumbprint := ExtrairValor(LTextoRetorno, 'THUMBPRINT');

    if Assigned(FLogger) then
      FLogger.Success('Certificate', 'Certificado criado com sucesso.');

    Exit;
  end;

  Result.Sucesso := False;
  Result.MensagemErro := ExtrairValor(LTextoRetorno, 'ERROR');

  if Assigned(FLogger) then
    FLogger.Error('Certificate', 'Falha ao criar o certificado.', Result.MensagemErro);
end;

end.

