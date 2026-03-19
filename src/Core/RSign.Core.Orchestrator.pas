unit RSign.Core.Orchestrator;

interface

uses
  System.SysUtils,
  RSign.Core.Interfaces,
  RSign.Types.Common,
  RSign.Types.Config,
  RSign.Types.Signing,
  RSign.Services.ProcessExecutor,
  RSign.Services.SignTool;

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
var
  LProcessExecutor: IProcessExecutor;
  LResultadoProcesso: TResultadoProcessoExterno;
  LCaminhoExecutavel: string;
  LParametros: string;
  LDiretorioTrabalho: string;
  LSignToolService: ISignToolService;
  LStatusSignTool: TStatusSignTool;
begin
  ValidateConfiguration(AConfiguracao);

  LProcessExecutor := TProcessExecutorService.New(FLogger);
  LCaminhoExecutavel := Trim(GetEnvironmentVariable('ComSpec'));

  if LCaminhoExecutavel = '' then
    LCaminhoExecutavel := 'cmd.exe';

  LParametros := '/C echo RSign ProcessExecutor OK';
  LDiretorioTrabalho := ExcludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));

  FLogger.Info('Orchestrator', 'Iniciando o teste operacional do ProcessExecutor.');
  LResultadoProcesso := LProcessExecutor.Execute(LCaminhoExecutavel, LParametros, LDiretorioTrabalho, 5000);

  if not LResultadoProcesso.Sucesso then
  begin
    FLogger.Error(
      'Orchestrator',
      'Falha no teste operacional do ProcessExecutor.',
      'Código: ' + IntToStr(LResultadoProcesso.CodigoSaida) +
      ' | Comando: ' + LResultadoProcesso.ComandoExecutado +
      ' | STDERR: ' + LResultadoProcesso.ErroPadrao
    );

    raise Exception.Create('Falha no teste operacional do ProcessExecutor. Verifique o log para detalhes.');
  end;

  FLogger.Success('Orchestrator', 'Teste operacional do ProcessExecutor concluído com sucesso.');

  if Trim(LResultadoProcesso.SaidaPadrao) <> '' then
    FLogger.Debug('Orchestrator', 'Saída do teste: ' + LResultadoProcesso.SaidaPadrao);

  FLogger.Info('Orchestrator', 'Iniciando o teste operacional do SignTool.');

  LSignToolService := TSignToolService.New(FLogger, LProcessExecutor);
  LStatusSignTool := LSignToolService.Localizar(AConfiguracao.Assinatura);

  if not LStatusSignTool.Encontrado then
  begin
    FLogger.Error('Orchestrator', 'Falha no teste operacional do SignTool.', LStatusSignTool.MensagemTecnica);
    raise Exception.Create('Falha no teste operacional do SignTool. Verifique o log para detalhes.');
  end;

  FLogger.Success('Orchestrator', 'Teste operacional do SignTool concluído com sucesso.');
  FLogger.Debug('Orchestrator', 'Origem selecionada: ' + LStatusSignTool.Origem.ToString);

  if Trim(LStatusSignTool.VersaoDetectada) <> '' then
    FLogger.Debug('Orchestrator', 'Versão detectada: ' + LStatusSignTool.VersaoDetectada);

  if Trim(LStatusSignTool.CaminhoFinal) <> '' then
    FLogger.Debug('Orchestrator', 'Caminho selecionado: ' + LStatusSignTool.CaminhoFinal);
end;

end.

