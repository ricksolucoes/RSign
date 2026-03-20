unit RSign.Services.Signing;

interface

uses
  System.SysUtils,
  System.IOUtils,

  RSign.Core.Interfaces,

  RSign.Types.Config,
  RSign.Types.Common,
  RSign.Types.Signing;

type
  TSigningService = class(TInterfacedObject, ISigningService)
  private
    FLogger: ILoggerService;
    FProcessExecutor: IProcessExecutor;
    FSignToolService: ISignToolService;
    function DelimitarParametro(const AValor: string): string;
    function MontarParametrosSignTool(const AConfiguracao: TConfiguracaoAplicacao; const ACaminhoArquivoAlvo: string; AUsarTimestamp: Boolean): string;
    function PrepararArquivosFisicos(const AItemArquivo: TItemArquivoAssinatura; out ACaminhoArquivoAlvo: string; out AMensagemErro: string): Boolean;
    procedure RestaurarArquivosAposFalha(const AItemArquivo: TItemArquivoAssinatura; const ACaminhoArquivoAlvo: string);
    function FalhaRelacionadaAoTimestamp(const AResultadoProcesso: TResultadoProcessoExterno): Boolean;
  protected
    constructor Create(const ALogger: ILoggerService; const AProcessExecutor: IProcessExecutor; const ASignToolService: ISignToolService);
    function Assinar(const AConfiguracao: TConfiguracaoAplicacao; const AItemArquivo: TItemArquivoAssinatura): TResultadoAssinatura;
  public
    class function New(const ALogger: ILoggerService; const AProcessExecutor: IProcessExecutor; const ASignToolService: ISignToolService): ISigningService;
  end;

implementation

function TSigningService.DelimitarParametro(const AValor: string): string;
begin
  Result := '"' + Trim(AValor) + '"';
end;

function TSigningService.FalhaRelacionadaAoTimestamp(
  const AResultadoProcesso: TResultadoProcessoExterno): Boolean;
var
  LTextoRetorno: string;
begin
  LTextoRetorno := UpperCase(
    Trim(AResultadoProcesso.SaidaPadrao + sLineBreak + AResultadoProcesso.ErroPadrao)
  );

  Result :=
    (Pos('TIMESTAMP', LTextoRetorno) > 0) or
    (Pos('TIME-STAMP', LTextoRetorno) > 0) or
    (Pos('TSA', LTextoRetorno) > 0) or
    (Pos('RFC3161', LTextoRetorno) > 0) or
    (Pos('/TR', LTextoRetorno) > 0);
end;

constructor TSigningService.Create(const ALogger: ILoggerService; const AProcessExecutor: IProcessExecutor; const ASignToolService: ISignToolService);
begin
  inherited Create;
  FLogger := ALogger;
  FProcessExecutor := AProcessExecutor;
  FSignToolService := ASignToolService;
end;

class function TSigningService.New(const ALogger: ILoggerService; const AProcessExecutor: IProcessExecutor; const ASignToolService: ISignToolService): ISigningService;
begin
  Result := Self.Create(ALogger, AProcessExecutor, ASignToolService);
end;

function TSigningService.MontarParametrosSignTool(const AConfiguracao: TConfiguracaoAplicacao; const ACaminhoArquivoAlvo: string; AUsarTimestamp: Boolean): string;
begin
  Result :=
    'sign ' +
    '/f ' + DelimitarParametro(AConfiguracao.Caminhos.CaminhoCompletoPfx) + ' ' +
    '/p ' + DelimitarParametro(AConfiguracao.Certificado.Senha) + ' ' +
    '/fd SHA256 ';

  if AUsarTimestamp and (Trim(AConfiguracao.Assinatura.UrlTimestamp) <> '') then
    Result := Result +
      '/tr ' + DelimitarParametro(AConfiguracao.Assinatura.UrlTimestamp) + ' ' +
      '/td SHA256 ';

  Result := Result + DelimitarParametro(ACaminhoArquivoAlvo);
end;

function TSigningService.PrepararArquivosFisicos(const AItemArquivo: TItemArquivoAssinatura; out ACaminhoArquivoAlvo: string; out AMensagemErro: string): Boolean;
begin
  Result := False;
  ACaminhoArquivoAlvo := '';
  AMensagemErro := '';

  if not AItemArquivo.ValidoParaAssinatura then
  begin
    AMensagemErro := AItemArquivo.MotivoBloqueio;
    Exit;
  end;

  if not TFile.Exists(AItemArquivo.CaminhoOriginal) then
  begin
    AMensagemErro := 'O arquivo original não foi encontrado para assinatura.';
    Exit;
  end;

  if SameText(AItemArquivo.CaminhoArquivoAssinadoFinal, AItemArquivo.CaminhoOriginal) then
  begin
    if Trim(AItemArquivo.CaminhoBackupOld) = '' then
    begin
      AMensagemErro := 'O caminho do backup _OLD não foi definido para assinatura na mesma pasta.';
      Exit;
    end;

    if TFile.Exists(AItemArquivo.CaminhoBackupOld) then
    begin
      AMensagemErro := 'Já existe um arquivo de backup _OLD para este item.';
      Exit;
    end;

    ForceDirectories(ExtractFilePath(AItemArquivo.CaminhoBackupOld));

    TFile.Move(AItemArquivo.CaminhoOriginal, AItemArquivo.CaminhoBackupOld);
    TFile.Copy(AItemArquivo.CaminhoBackupOld, AItemArquivo.CaminhoOriginal, False);

    ACaminhoArquivoAlvo := AItemArquivo.CaminhoOriginal;
    Result := True;
    Exit;
  end;

  if TFile.Exists(AItemArquivo.CaminhoArquivoAssinadoFinal) then
  begin
    AMensagemErro := 'Já existe um arquivo no destino final da assinatura.';
    Exit;
  end;

  ForceDirectories(ExtractFilePath(AItemArquivo.CaminhoArquivoAssinadoFinal));
  TFile.Copy(AItemArquivo.CaminhoOriginal, AItemArquivo.CaminhoArquivoAssinadoFinal, False);

  ACaminhoArquivoAlvo := AItemArquivo.CaminhoArquivoAssinadoFinal;
  Result := True;
end;

procedure TSigningService.RestaurarArquivosAposFalha(const AItemArquivo: TItemArquivoAssinatura; const ACaminhoArquivoAlvo: string);
begin
  try
    if (Trim(ACaminhoArquivoAlvo) <> '') and TFile.Exists(ACaminhoArquivoAlvo) then
      TFile.Delete(ACaminhoArquivoAlvo);
  except
  end;

  if SameText(AItemArquivo.CaminhoArquivoAssinadoFinal, AItemArquivo.CaminhoOriginal) then
  begin
    try
      if TFile.Exists(AItemArquivo.CaminhoBackupOld) and (not TFile.Exists(AItemArquivo.CaminhoOriginal)) then
        TFile.Move(AItemArquivo.CaminhoBackupOld, AItemArquivo.CaminhoOriginal);
    except
    end;
  end;
end;

function TSigningService.Assinar(const AConfiguracao: TConfiguracaoAplicacao; const AItemArquivo: TItemArquivoAssinatura): TResultadoAssinatura;
var
  LStatusSignTool: TStatusSignTool;
  LResultadoProcesso: TResultadoProcessoExterno;
  LParametrosSignTool: string;
  LCaminhoArquivoAlvo: string;
  LMensagemErro: string;
  LUsouTimestamp: Boolean;
begin
  Result := TResultadoAssinatura.Empty;
  Result.ArquivoAlvo := AItemArquivo.CaminhoArquivoAssinadoFinal;

  if not Assigned(FProcessExecutor) then
  begin
    Result.MensagemTecnica := 'O ProcessExecutor não foi informado para a assinatura.';
    Result.MensagemAmigavel := 'Não foi possível iniciar a assinatura.';
    Exit;
  end;

  if not Assigned(FSignToolService) then
  begin
    Result.MensagemTecnica := 'O serviço de localização do SignTool não foi informado.';
    Result.MensagemAmigavel := 'Não foi possível iniciar a assinatura.';
    Exit;
  end;

  if not TFile.Exists(AConfiguracao.Caminhos.CaminhoCompletoPfx) then
  begin
    Result.MensagemTecnica := 'O arquivo PFX não foi encontrado: ' + AConfiguracao.Caminhos.CaminhoCompletoPfx;
    Result.MensagemAmigavel := 'O certificado configurado não foi encontrado para assinatura.';
    Exit;
  end;

  if not PrepararArquivosFisicos(AItemArquivo, LCaminhoArquivoAlvo, LMensagemErro) then
  begin
    Result.MensagemTecnica := LMensagemErro;
    Result.MensagemAmigavel := 'Já existe um arquivo com o mesmo nome na pasta de destino da assinatura.'
                                + sLineBreak + sLineBreak +
                                'Remova o arquivo existente ou escolha outra pasta de saída.';
    Exit;
  end;

  if Assigned(FLogger) then
    FLogger.Info('Signing', 'Iniciando a assinatura real do arquivo: ' + ExtractFileName(LCaminhoArquivoAlvo));

  LStatusSignTool := FSignToolService.Localizar(AConfiguracao.Assinatura);

  if not LStatusSignTool.Encontrado then
  begin
    Result.MensagemTecnica := LStatusSignTool.MensagemTecnica;
    Result.MensagemAmigavel := 'O SignTool não pôde ser localizado para executar a assinatura.';
    RestaurarArquivosAposFalha(AItemArquivo, LCaminhoArquivoAlvo);
    Exit;
  end;

  LUsouTimestamp := Trim(AConfiguracao.Assinatura.UrlTimestamp) <> '';
  LParametrosSignTool := MontarParametrosSignTool(AConfiguracao, LCaminhoArquivoAlvo, LUsouTimestamp);

  LResultadoProcesso := FProcessExecutor.Execute(
    LStatusSignTool.CaminhoFinal,
    LParametrosSignTool,
    ExtractFilePath(LCaminhoArquivoAlvo),
    60000
  );

  Result.CodigoRetorno := LResultadoProcesso.CodigoSaida;
  Result.ComandoExecutado := LResultadoProcesso.ComandoExecutado;
  Result.SaidaPadrao := LResultadoProcesso.SaidaPadrao;
  Result.ErroPadrao := LResultadoProcesso.ErroPadrao;
  Result.Sucesso := LResultadoProcesso.Sucesso;
  Result.AssinaturaAplicada := LResultadoProcesso.Sucesso;
  Result.TimestampAplicado := LResultadoProcesso.Sucesso and LUsouTimestamp;
  Result.MensagemTecnica := Trim(LResultadoProcesso.ErroPadrao);

  if Result.Sucesso then
  begin
    if Result.TimestampAplicado then
      Result.MensagemAmigavel := 'O arquivo foi assinado com sucesso e recebeu timestamp.'
    else
      Result.MensagemAmigavel := 'O arquivo foi assinado com sucesso.';

    if Assigned(FLogger) then
      FLogger.Success('Signing', Result.MensagemAmigavel);

    Exit;
  end;

  if LUsouTimestamp and
     AConfiguracao.Assinatura.PermitirContinuarSemTimestamp and
     FalhaRelacionadaAoTimestamp(LResultadoProcesso) then
  begin
    Result.MensagemAmigavel :=
      'Não foi possível concluir a assinatura com timestamp.' + sLineBreak + sLineBreak +
      'Deseja tentar novamente sem timestamp?';

    if Result.MensagemTecnica = '' then
      Result.MensagemTecnica := Trim(LResultadoProcesso.SaidaPadrao);

    if Assigned(FLogger) then
      FLogger.Warning(
        'Signing',
        'A assinatura com timestamp falhou e requer decisão do usuário.',
        Result.MensagemTecnica
      );

    RestaurarArquivosAposFalha(AItemArquivo, LCaminhoArquivoAlvo);
    Exit;
  end;

  Result.MensagemAmigavel := 'Falha ao assinar o arquivo.';
  RestaurarArquivosAposFalha(AItemArquivo, LCaminhoArquivoAlvo);

  if Assigned(FLogger) then
    FLogger.Error('Signing', Result.MensagemAmigavel, Result.MensagemTecnica);
end;

end.

