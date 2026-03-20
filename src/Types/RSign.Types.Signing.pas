unit RSign.Types.Signing;

interface

uses
  RSign.Core.Constants,
  RSign.Types.Common;

type
  TStatusSignTool = record
    Encontrado: Boolean;
    Origem: TOrigemSignTool;
    VersaoDetectada: string;
    CaminhoFinal: string;
    MensagemTecnica: string;
    MensagemAmigavel: string;
    class function Empty: TStatusSignTool; static;
  end;

  TItemArquivoAssinatura = record
    CaminhoOriginal: string;
    NomeArquivo: string;
    Extensao: string;
    CaminhoBackupOld: string;
    CaminhoArquivoAssinadoFinal: string;
    ValidoParaAssinatura: Boolean;
    MotivoBloqueio: string;
    class function Empty: TItemArquivoAssinatura; static;
  end;

  TItensArquivoAssinatura = array of TItemArquivoAssinatura;

  TConfiguracaoAssinatura = record
    LocalizarAutomaticamenteSignTool: Boolean;
    CaminhoManualSignTool: string;
    UsarVersaoMaisNova: Boolean;
    UrlTimestamp: string;
    VerificarAssinaturaAoFinal: Boolean;
    PermitirContinuarSemTimestamp: Boolean;
    ModoOperacaoArquivos: TModoOperacaoArquivos;
    ModoSaidaLog: TModoSaidaLog;
    class function Default: TConfiguracaoAssinatura; static;
  end;

  TResultadoAssinatura = record
    ArquivoAlvo: string;
    Sucesso: Boolean;
    ComandoExecutado: string;
    CodigoRetorno: Integer;
    SaidaPadrao: string;
    ErroPadrao: string;
    AssinaturaAplicada: Boolean;
    TimestampAplicado: Boolean;
    VerificacaoExecutada: Boolean;
    VerificacaoAprovada: Boolean;
    MensagemTecnica: string;
    MensagemAmigavel: string;
    class function Empty: TResultadoAssinatura; static;
  end;

implementation

class function TStatusSignTool.Empty: TStatusSignTool;
begin
  Result.Encontrado := False;
  Result.Origem := TOrigemSignTool.NaoDefinido;
  Result.VersaoDetectada := '';
  Result.CaminhoFinal := '';
  Result.MensagemTecnica := '';
  Result.MensagemAmigavel := '';
end;

class function TItemArquivoAssinatura.Empty: TItemArquivoAssinatura;
begin
  Result.CaminhoOriginal := '';
  Result.NomeArquivo := '';
  Result.Extensao := '';
  Result.CaminhoBackupOld := '';
  Result.CaminhoArquivoAssinadoFinal := '';
  Result.ValidoParaAssinatura := False;
  Result.MotivoBloqueio := '';
end;

class function TConfiguracaoAssinatura.Default: TConfiguracaoAssinatura;
begin
  Result.LocalizarAutomaticamenteSignTool := True;
  Result.CaminhoManualSignTool := '';
  Result.UsarVersaoMaisNova := True;
  Result.UrlTimestamp := _DEFAULT_TIMESTAMP_URL;
  Result.VerificarAssinaturaAoFinal := True;
  Result.PermitirContinuarSemTimestamp := True;
  Result.ModoOperacaoArquivos := TModoOperacaoArquivos.Lote;
  Result.ModoSaidaLog := TModoSaidaLog.Ambos;
end;

class function TResultadoAssinatura.Empty: TResultadoAssinatura;
begin
  Result.ArquivoAlvo := '';
  Result.Sucesso := False;
  Result.ComandoExecutado := '';
  Result.CodigoRetorno := -1;
  Result.SaidaPadrao := '';
  Result.ErroPadrao := '';
  Result.AssinaturaAplicada := False;
  Result.TimestampAplicado := False;
  Result.VerificacaoExecutada := False;
  Result.VerificacaoAprovada := False;
  Result.MensagemTecnica := '';
  Result.MensagemAmigavel := '';
end;

end.
