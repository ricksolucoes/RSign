unit RSign.Services.SigningVerification;

interface

uses
  System.SysUtils,
  System.IOUtils,
  RSign.Core.Interfaces,
  RSign.Types.Config,
  RSign.Types.Signing;

type
  TSigningVerificationService = class(TInterfacedObject, ISigningVerificationService)
  private
    FLogger: ILoggerService;
    FProcessExecutor: IProcessExecutor;
    FSignToolService: ISignToolService;
    function DelimitarParametro(const AValor: string): string;
    function MontarParametrosVerificacao(const AResultadoAssinatura: TResultadoAssinatura): string;
  protected
    constructor Create(const ALogger: ILoggerService; const AProcessExecutor: IProcessExecutor; const ASignToolService: ISignToolService);
    function Verificar(const AConfiguracao: TConfiguracaoAplicacao; const AResultadoAssinatura: TResultadoAssinatura): TResultadoAssinatura;
  public
    class function New(const ALogger: ILoggerService; const AProcessExecutor: IProcessExecutor; const ASignToolService: ISignToolService): ISigningVerificationService;
  end;

implementation

uses
  RSign.Types.Common;

function TSigningVerificationService.DelimitarParametro(const AValor: string): string;
begin
  Result := '"' + Trim(AValor) + '"';
end;

constructor TSigningVerificationService.Create(const ALogger: ILoggerService; const AProcessExecutor: IProcessExecutor; const ASignToolService: ISignToolService);
begin
  inherited Create;
  FLogger := ALogger;
  FProcessExecutor := AProcessExecutor;
  FSignToolService := ASignToolService;
end;

class function TSigningVerificationService.New(const ALogger: ILoggerService; const AProcessExecutor: IProcessExecutor; const ASignToolService: ISignToolService): ISigningVerificationService;
begin
  Result := Self.Create(ALogger, AProcessExecutor, ASignToolService);
end;

function TSigningVerificationService.MontarParametrosVerificacao(const AResultadoAssinatura: TResultadoAssinatura): string;
begin
  Result := 'verify /pa /v ' + DelimitarParametro(AResultadoAssinatura.ArquivoAlvo);
end;

function TSigningVerificationService.Verificar(const AConfiguracao: TConfiguracaoAplicacao; const AResultadoAssinatura: TResultadoAssinatura): TResultadoAssinatura;
var
  LStatusSignTool: TStatusSignTool;
  LResultadoProcesso: TResultadoProcessoExterno;
  LParametrosVerificacao: string;
  LTextoRetorno: string;
  LPossuiAssinatura: Boolean;
  LPossuiTimestamp: Boolean;
  LErroConfiancaCadeia: Boolean;
begin
  Result := AResultadoAssinatura;
  Result.VerificacaoExecutada := False;
  Result.VerificacaoAprovada := False;

  if not Result.Sucesso then
  begin
    Result.MensagemAmigavel := 'A verificação pós-assinatura não foi executada porque a assinatura anterior falhou.';
    Exit;
  end;

  if not Assigned(FProcessExecutor) then
  begin
    Result.MensagemTecnica := 'O ProcessExecutor não foi informado para a verificação pós-assinatura.';
    Result.MensagemAmigavel := 'Não foi possível executar a verificação pós-assinatura.';
    Exit;
  end;

  if not Assigned(FSignToolService) then
  begin
    Result.MensagemTecnica := 'O serviço de localização do SignTool não foi informado para a verificação pós-assinatura.';
    Result.MensagemAmigavel := 'Não foi possível executar a verificação pós-assinatura.';
    Exit;
  end;

  if Trim(Result.ArquivoAlvo) = '' then
  begin
    Result.MensagemTecnica := 'Nenhum arquivo alvo foi informado para a verificação pós-assinatura.';
    Result.MensagemAmigavel := 'Não foi possível verificar a assinatura do arquivo.';
    Exit;
  end;

  if not TFile.Exists(Result.ArquivoAlvo) then
  begin
    Result.MensagemTecnica := 'O arquivo assinado não foi encontrado para verificação: ' + Result.ArquivoAlvo;
    Result.MensagemAmigavel := 'O arquivo assinado não foi encontrado para verificação.';
    Exit;
  end;

  if Assigned(FLogger) then
    FLogger.Info('SigningVerification', 'Iniciando a verificação pós-assinatura do arquivo: ' + ExtractFileName(Result.ArquivoAlvo));

  LStatusSignTool := FSignToolService.Localizar(AConfiguracao.Assinatura);

  if not LStatusSignTool.Encontrado then
  begin
    Result.MensagemTecnica := LStatusSignTool.MensagemTecnica;
    Result.MensagemAmigavel := 'O SignTool não pôde ser localizado para verificar a assinatura do arquivo.';
    Exit;
  end;

  LParametrosVerificacao := MontarParametrosVerificacao(Result);

  LResultadoProcesso := FProcessExecutor.Execute(
    LStatusSignTool.CaminhoFinal,
    LParametrosVerificacao,
    ExtractFilePath(Result.ArquivoAlvo),
    60000
  );

  Result.VerificacaoExecutada := True;
  Result.CodigoRetorno := LResultadoProcesso.CodigoSaida;
  Result.ComandoExecutado := LResultadoProcesso.ComandoExecutado;
  Result.SaidaPadrao := LResultadoProcesso.SaidaPadrao;
  Result.ErroPadrao := LResultadoProcesso.ErroPadrao;

  LTextoRetorno := UpperCase(Trim(LResultadoProcesso.SaidaPadrao + sLineBreak + LResultadoProcesso.ErroPadrao));

  LPossuiAssinatura :=
    (Pos('SIGNATURE INDEX: 0', LTextoRetorno) > 0) or
    (Pos('SIGNING CERTIFICATE CHAIN:', LTextoRetorno) > 0);

  LPossuiTimestamp := Pos('THE SIGNATURE IS TIMESTAMPED:', LTextoRetorno) > 0;

  LErroConfiancaCadeia :=
    (Pos('NOT TRUSTED BY THE TRUST PROVIDER', LTextoRetorno) > 0) or
    (Pos('CERTIFICATE CHAIN PROCESSED, BUT TERMINATED IN A ROOT', LTextoRetorno) > 0);

  if LResultadoProcesso.CodigoSaida = 0 then
  begin
    Result.VerificacaoAprovada := True;
    Result.MensagemAmigavel := 'A assinatura do arquivo foi verificada com sucesso.';
    Result.MensagemTecnica := '';

    if Assigned(FLogger) then
      FLogger.Success('SigningVerification', Result.MensagemAmigavel);

    Exit;
  end;

  if (AConfiguracao.Certificado.TipoCertificado = TTipoCertificado.Autoassinado) and
     LPossuiAssinatura and
     LErroConfiancaCadeia then
  begin
    Result.VerificacaoAprovada := True;

    if Result.TimestampAplicado and LPossuiTimestamp then
      Result.MensagemAmigavel := 'A assinatura e o timestamp foram encontrados, mas o certificado autoassinado não é confiado pelo Windows atual.'
    else
      Result.MensagemAmigavel := 'A assinatura foi encontrada, mas o certificado autoassinado não é confiado pelo Windows atual.';

    Result.MensagemTecnica := Trim(LResultadoProcesso.ErroPadrao);

    if Assigned(FLogger) then
      FLogger.Warning('SigningVerification', Result.MensagemAmigavel, Result.MensagemTecnica);

    Exit;
  end;

  Result.VerificacaoAprovada := False;
  Result.MensagemTecnica := Trim(LResultadoProcesso.ErroPadrao);

  if Result.MensagemTecnica = '' then
    Result.MensagemTecnica := Trim(LResultadoProcesso.SaidaPadrao);

  Result.MensagemAmigavel := 'A verificação pós-assinatura do arquivo falhou.';

  if Assigned(FLogger) then
    FLogger.Error('SigningVerification', Result.MensagemAmigavel, Result.MensagemTecnica);
end;

end.

