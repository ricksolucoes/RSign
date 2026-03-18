unit RSign.App.Configuracao;

interface

uses
  RSign.Types.Config;

type
  TAPPConfiguracao = class
  public
    class function ObterConfiguracaoPadrao: TConfiguracaoAplicacao; static;
  end;

implementation

class function TAPPConfiguracao.ObterConfiguracaoPadrao: TConfiguracaoAplicacao;
begin
  Result := TConfiguracaoAplicacao.Default;
end;

end.
