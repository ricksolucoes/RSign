unit RSign.Types.Config;

interface

uses
  System.SysUtils,
  System.IOUtils,
  RSign.Core.Constants,
  RSign.Types.Common,
  RSign.Types.Certificate,
  RSign.Types.Signing;

type
  TConfiguracaoCaminhos = record
    DiretorioPfx: string;
    NomeArquivoPfx: string;
    CaminhoArquivoEntrada: string;
    DiretorioEntradaLote: string;
    DiretorioSaida: string;
    UsarMesmoDiretorioDoOriginal: Boolean;
    class function Default: TConfiguracaoCaminhos; static;
    function CaminhoCompletoPfx: string;
  end;

  TConfiguracaoLog = record
    ModoSaidaLog: TModoSaidaLog;
    CaminhoArquivoLog: string;
    class function Default: TConfiguracaoLog; static;
  end;

  TConfiguracaoUI = record
    UltimaAbaAtiva: Integer;
    class function Default: TConfiguracaoUI; static;
  end;

  TConfiguracaoAplicacao = record
    Certificado: TConfiguracaoCertificado;
    Assinatura: TConfiguracaoAssinatura;
    Caminhos: TConfiguracaoCaminhos;
    Log: TConfiguracaoLog;
    UI: TConfiguracaoUI;
    class function Default: TConfiguracaoAplicacao; static;
  end;

implementation

class function TConfiguracaoCaminhos.Default: TConfiguracaoCaminhos;
var
  LBasePath: string;
begin
  LBasePath := ExcludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  Result.DiretorioPfx := TPath.Combine(LBasePath, _DEFAULT_CERTIFICATE_FOLDER);
  Result.NomeArquivoPfx := _DEFAULT_CERTIFICATE_NAME + '.pfx';
  Result.CaminhoArquivoEntrada := '';
  Result.DiretorioEntradaLote := TPath.Combine(LBasePath, _DEFAULT_INPUT_FOLDER);
  Result.DiretorioSaida := TPath.Combine(LBasePath, _DEFAULT_OUTPUT_FOLDER);
  Result.UsarMesmoDiretorioDoOriginal := True;
end;

function TConfiguracaoCaminhos.CaminhoCompletoPfx: string;
begin
  Result := TPath.Combine(DiretorioPfx, NomeArquivoPfx);
end;

class function TConfiguracaoLog.Default: TConfiguracaoLog;
var
  LBasePath: string;
begin
  LBasePath := ExcludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  Result.ModoSaidaLog := TModoSaidaLog.Ambos;
  Result.CaminhoArquivoLog := TPath.Combine(TPath.Combine(LBasePath, _DEFAULT_LOG_FOLDER), _LOG_FILE_NAME);
end;

class function TConfiguracaoUI.Default: TConfiguracaoUI;
begin
  Result.UltimaAbaAtiva := 0;
end;

class function TConfiguracaoAplicacao.Default: TConfiguracaoAplicacao;
begin
  Result.Certificado := TConfiguracaoCertificado.Default;
  Result.Assinatura := TConfiguracaoAssinatura.Default;
  Result.Caminhos := TConfiguracaoCaminhos.Default;
  Result.Log := TConfiguracaoLog.Default;
  Result.UI := TConfiguracaoUI.Default;
end;

end.
