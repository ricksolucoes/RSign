unit RSign.Core.Orchestrator;

interface

uses
  System.SysUtils,
  RSign.Core.Interfaces,
  RSign.Types.Config;

type
  TOrchestrator = class(TInterfacedObject, IOrchestrator)
  private
    FConfigManager: IConfigManager;
    FLogger: ILoggerService;
  protected
    constructor Create(const AConfigManager: IConfigManager; const ALogger: ILoggerService);
    procedure Initialize;
    function LoadConfiguration: TConfiguracaoAplicacao;
    procedure SaveConfiguration(const AConfiguracao: TConfiguracaoAplicacao);
    procedure ValidateConfiguration(const AConfiguracao: TConfiguracaoAplicacao);
    procedure Execute(const AConfiguracao: TConfiguracaoAplicacao);
  public
    class function New(const AConfigManager: IConfigManager; const ALogger: ILoggerService) : IOrchestrator;
  end;

implementation

constructor TOrchestrator.Create(const AConfigManager: IConfigManager; const ALogger: ILoggerService);
begin
  inherited Create;
  FConfigManager := AConfigManager;
  FLogger := ALogger;
end;

procedure TOrchestrator.Initialize;
var
  LConfiguracao: TConfiguracaoAplicacao;
begin
  FConfigManager.EnsureExists;
  LConfiguracao := FConfigManager.Load;
  FLogger.SetLogFilePath(LConfiguracao.Log.CaminhoArquivoLog);
  FLogger.Success('Orchestrator', 'Inicialização da aplicação concluída.');
end;

function TOrchestrator.LoadConfiguration: TConfiguracaoAplicacao;
begin
  Result := FConfigManager.Load;
  FLogger.SetLogFilePath(Result.Log.CaminhoArquivoLog);
  FLogger.Info('Orchestrator', 'Configuração carregada do arquivo .ini.');
end;

class function TOrchestrator.New(const AConfigManager: IConfigManager;
  const ALogger: ILoggerService): IOrchestrator;
begin
  Result := Self.Create(AConfigManager, ALogger);
end;

procedure TOrchestrator.SaveConfiguration(const AConfiguracao: TConfiguracaoAplicacao);
begin
  FConfigManager.Save(AConfiguracao);
  FLogger.SetLogFilePath(AConfiguracao.Log.CaminhoArquivoLog);
  FLogger.Success('Orchestrator', 'Configuração salva com sucesso.');
end;

procedure TOrchestrator.ValidateConfiguration(const AConfiguracao: TConfiguracaoAplicacao);
begin
  if Trim(AConfiguracao.Certificado.NomeCertificado) = '' then
    raise Exception.Create('Informe o nome do certificado antes de validar a configuração.');

  if Trim(AConfiguracao.Caminhos.DiretorioPfx) = '' then
    raise Exception.Create('Informe o diretório do PFX antes de validar a configuração.');

  if Trim(AConfiguracao.Log.CaminhoArquivoLog) = '' then
    raise Exception.Create('Informe o caminho do arquivo de log antes de validar a configuração.');

  FLogger.Info('Orchestrator', 'Validação inicial da configuração concluída.');
end;

procedure TOrchestrator.Execute(const AConfiguracao: TConfiguracaoAplicacao);
begin
  ValidateConfiguration(AConfiguracao);
  FLogger.Warning('Orchestrator', 'Execução operacional ainda não implementada nesta fase.', 'Nesta entrega foi criada a base do projeto com telas, frames e arquivo de configuração.');
end;

end.
