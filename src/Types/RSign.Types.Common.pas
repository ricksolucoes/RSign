unit RSign.Types.Common;

interface

uses
  System.SysUtils;

type
{$SCOPEDENUMS ON}
  TNivelLog = (Info, Warning, Error, Debug, Success);
  TTipoCertificado = (Autoassinado, PfxExterno, CodeSigningReal);
  TModoOperacaoArquivos = (Unico, Lote);
  TModoSaidaLog = (Tela, Arquivo, Ambos);
  TOrigemSignTool = (NaoDefinido, Manual, Automatico);
  TAcaoUsuarioFalha = (Cancelar, Continuar, Recriar, SelecionarOutro);
  TResultadoVerificacao = (NaoExecutada, Aprovada, Reprovada);
{$SCOPEDENUMS OFF}

  TResultadoProcessoExterno = record
    Sucesso: Boolean;
    CodigoSaida: Integer;
    SaidaPadrao: string;
    ErroPadrao: string;
    ComandoExecutado: string;
    class function Empty: TResultadoProcessoExterno; static;
  end;

  TNivelLogHelper = record helper for TNivelLog
    function ToString: string;
  end;

  TTipoCertificadoHelper = record helper for TTipoCertificado
    function ToString: string;
    class function FromString(const AValor: string): TTipoCertificado; static;
  end;

  TModoOperacaoArquivosHelper = record helper for TModoOperacaoArquivos
    function ToString: string;
    class function FromString(const AValor: string): TModoOperacaoArquivos; static;
  end;

  TModoSaidaLogHelper = record helper for TModoSaidaLog
    function ToString: string;
    class function FromString(const AValor: string): TModoSaidaLog; static;
  end;

  TOrigemSignToolHelper = record helper for TOrigemSignTool
    function ToString: string;
  end;

implementation

{ TResultadoProcessoExterno }

class function TResultadoProcessoExterno.Empty: TResultadoProcessoExterno;
begin
  Result.Sucesso := False;
  Result.CodigoSaida := -1;
  Result.SaidaPadrao := '';
  Result.ErroPadrao := '';
  Result.ComandoExecutado := '';
end;

{ TNivelLogHelper }

function TNivelLogHelper.ToString: string;
begin
  case Self of
    TNivelLog.Info:    Result := 'Info';
    TNivelLog.Warning: Result := 'Warning';
    TNivelLog.Error:   Result := 'Error';
    TNivelLog.Debug:   Result := 'Debug';
    TNivelLog.Success: Result := 'Success';
  else
    Result := 'Info';
  end;
end;

{ TTipoCertificadoHelper }

function TTipoCertificadoHelper.ToString: string;
begin
  case Self of
    TTipoCertificado.Autoassinado:    Result := 'Autoassinado';
    TTipoCertificado.PfxExterno:      Result := 'PFXExterno';
    TTipoCertificado.CodeSigningReal: Result := 'CodeSigningReal';
  else
    Result := 'Autoassinado';
  end;
end;

class function TTipoCertificadoHelper.FromString(const AValor: string): TTipoCertificado;
begin
  if SameText(AValor, 'PFXExterno') then
    Exit(TTipoCertificado.PfxExterno);
  if SameText(AValor, 'CodeSigningReal') then
    Exit(TTipoCertificado.CodeSigningReal);
  Result := TTipoCertificado.Autoassinado;
end;

{ TModoOperacaoArquivosHelper }

function TModoOperacaoArquivosHelper.ToString: string;
begin
  case Self of
    TModoOperacaoArquivos.Unico: Result := 'ArquivoUnico';
    TModoOperacaoArquivos.Lote:  Result := 'Lote';
  else
    Result := 'ArquivoUnico';
  end;
end;

class function TModoOperacaoArquivosHelper.FromString(const AValor: string): TModoOperacaoArquivos;
begin
  if SameText(AValor, 'Lote') then
    Exit(TModoOperacaoArquivos.Lote);
  Result := TModoOperacaoArquivos.Unico;
end;

{ TModoSaidaLogHelper }

function TModoSaidaLogHelper.ToString: string;
begin
  case Self of
    TModoSaidaLog.Tela:   Result := 'Tela';
    TModoSaidaLog.Arquivo: Result := 'Arquivo';
    TModoSaidaLog.Ambos:  Result := 'Ambos';
  else
    Result := 'Ambos';
  end;
end;

class function TModoSaidaLogHelper.FromString(const AValor: string): TModoSaidaLog;
begin
  if SameText(AValor, 'Tela') then
    Exit(TModoSaidaLog.Tela);
  if SameText(AValor, 'Arquivo') then
    Exit(TModoSaidaLog.Arquivo);
  Result := TModoSaidaLog.Ambos;
end;

{ TOrigemSignToolHelper }

function TOrigemSignToolHelper.ToString: string;
begin
  case Self of
    TOrigemSignTool.NaoDefinido: Result := 'NaoDefinido';
    TOrigemSignTool.Manual:      Result := 'Manual';
    TOrigemSignTool.Automatico:  Result := 'Automatico';
  else
    Result := 'NaoDefinido';
  end;
end;

end.
