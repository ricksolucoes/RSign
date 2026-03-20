unit RSign.Core.Orchestrator;

interface

uses
  System.SysUtils,
  RSign.Core.Interfaces,

  RSign.Types.Common,
  RSign.Types.Config,
  RSign.Types.Signing,
  RSign.Types.Certificate,

  RSign.Services.Signing,
  RSign.Services.SignTool,
  RSign.Services.Certificate,
  RSign.Services.FileSigning,
  RSign.Services.ProcessExecutor;

type
  TOrchestrator = class(TInterfacedObject, IOrchestrator)
  private
    FConfigManager: IConfigManager;
    FLogger: ILoggerService;
    FUserDecisionService: IUserDecisionService;
  protected
    constructor Create(const AConfigManager: IConfigManager; const ALogger: ILoggerService; const AUserDecisionService: IUserDecisionService);

    procedure Initialize;
    function LoadConfiguration: TConfiguracaoAplicacao;
    procedure SaveConfiguration(const AConfiguracao: TConfiguracaoAplicacao);
    procedure ValidateConfiguration(const AConfiguracao: TConfiguracaoAplicacao);
    procedure Execute(const AConfiguracao: TConfiguracaoAplicacao);
  public
    class function New(const AConfigManager: IConfigManager; const ALogger: ILoggerService; const AUserDecisionService: IUserDecisionService) : IOrchestrator;
  end;

implementation

constructor TOrchestrator.Create(const AConfigManager: IConfigManager; const ALogger: ILoggerService; const AUserDecisionService: IUserDecisionService);
begin
  inherited Create;
  FConfigManager := AConfigManager;
  FLogger := ALogger;
  FUserDecisionService := AUserDecisionService;
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

class function TOrchestrator.New(const AConfigManager: IConfigManager; const ALogger: ILoggerService; const AUserDecisionService: IUserDecisionService) : IOrchestrator;
begin
  Result := Self.Create(AConfigManager, ALogger, AUserDecisionService);
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
  LCertificateService: ICertificateService;
  LStatusCertificado: TStatusCertificado;
  LResultadoCriacaoCertificado: TResultadoCriacaoCertificado;
  LFileSigningService: IFileSigningService;
  LItensArquivoAssinatura: TItensArquivoAssinatura;
  LItemArquivoAssinatura: TItemArquivoAssinatura;
  LQuantidadeArquivosValidos: Integer;
  LIdentificacaoArquivo : string;
  LSigningService: ISigningService;
  LResultadoAssinatura: TResultadoAssinatura;
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

  FLogger.Info('Orchestrator', 'Iniciando o teste operacional do Certificate.');

  LCertificateService := TCertificateService.New(FLogger, LProcessExecutor);
  LStatusCertificado := LCertificateService.Validar(AConfiguracao.Certificado, AConfiguracao.Caminhos);

  if not LStatusCertificado.ArquivoExiste then
  begin
    FLogger.Warning('Orchestrator', 'O certificado configurado ainda não foi encontrado.', LStatusCertificado.MensagemTecnica);

    if not Assigned(FUserDecisionService) then
    begin
      FLogger.Warning('Orchestrator', 'Não há serviço de decisão do usuário configurado para confirmar a criação do certificado.');
      Exit;
    end;

    if not FUserDecisionService.Confirmar(
      'Certificado não encontrado',
      'O certificado configurado não foi localizado no caminho informado.' + sLineBreak +
      'Deseja gerar um novo certificado agora?',
      LStatusCertificado.MensagemTecnica
    ) then
    begin
      FLogger.Warning('Orchestrator', 'O usuário optou por não gerar um novo certificado.');
      Exit;
    end;

    FLogger.Info('Orchestrator', 'O usuário confirmou a criação de um novo certificado.');

    LResultadoCriacaoCertificado := LCertificateService.Criar(AConfiguracao.Certificado, AConfiguracao.Caminhos);

    if not LResultadoCriacaoCertificado.Sucesso then
    begin
      FLogger.Error('Orchestrator', 'Falha ao criar o certificado.', LResultadoCriacaoCertificado.MensagemErro);
      raise Exception.Create('Falha ao criar o certificado. Verifique o log para detalhes.');
    end;

    FLogger.Success('Orchestrator', 'Novo certificado gerado com sucesso.');

    if Trim(LResultadoCriacaoCertificado.CaminhoPfxGerado) <> '' then
      FLogger.Debug('Orchestrator', 'Caminho do PFX gerado: ' + LResultadoCriacaoCertificado.CaminhoPfxGerado);

    if Trim(LResultadoCriacaoCertificado.Thumbprint) <> '' then
      FLogger.Debug('Orchestrator', 'Thumbprint do certificado gerado: ' + LResultadoCriacaoCertificado.Thumbprint);

    LStatusCertificado := LCertificateService.Validar(AConfiguracao.Certificado, AConfiguracao.Caminhos);
  end;

  if not LStatusCertificado.SenhaValida then
  begin
    FLogger.Error('Orchestrator', 'A validação do certificado falhou por senha inválida.', LStatusCertificado.MensagemTecnica);
    raise Exception.Create('Falha na validação do certificado. Verifique o log para detalhes.');
  end;

  if not LStatusCertificado.CertificadoIntegro then
  begin
    FLogger.Error('Orchestrator', 'A validação do certificado falhou porque o PFX está inválido.', LStatusCertificado.MensagemTecnica);
    raise Exception.Create('Falha na validação do certificado. Verifique o log para detalhes.');
  end;

  if not LStatusCertificado.PossuiChavePrivada then
  begin
    FLogger.Error('Orchestrator', 'O certificado não possui chave privada utilizável.', LStatusCertificado.MensagemTecnica);
    raise Exception.Create('Falha na validação do certificado. Verifique o log para detalhes.');
  end;

  if not LStatusCertificado.CompativelComAssinatura then
  begin
    FLogger.Error('Orchestrator', 'O certificado não é compatível com assinatura de código.', LStatusCertificado.MensagemTecnica);
    raise Exception.Create('Falha na validação do certificado. Verifique o log para detalhes.');
  end;

  if LStatusCertificado.Vencido then
  begin
    FLogger.Error('Orchestrator', 'O certificado está vencido.', LStatusCertificado.MensagemTecnica);
    raise Exception.Create('Falha na validação do certificado. Verifique o log para detalhes.');
  end;

  if LStatusCertificado.ProximoDoVencimento then
    FLogger.Warning('Orchestrator', 'O certificado está próximo do vencimento.', LStatusCertificado.MensagemTecnica)
  else
    FLogger.Success('Orchestrator', 'Teste operacional do Certificate concluído com sucesso.');

  FLogger.Info('Orchestrator', 'Iniciando a preparação dos arquivos para assinatura.');

  LFileSigningService := TFileSigningService.New(FLogger);
  LItensArquivoAssinatura := LFileSigningService.PrepararArquivos(AConfiguracao);
  LQuantidadeArquivosValidos := 0;

  for LItemArquivoAssinatura in LItensArquivoAssinatura do
  begin
    if LItemArquivoAssinatura.ValidoParaAssinatura then
    begin
      Inc(LQuantidadeArquivosValidos);

      FLogger.Success(
        'Orchestrator',
        'Arquivo preparado com sucesso: ' + LItemArquivoAssinatura.NomeArquivo
      );

      FLogger.Debug(
        'Orchestrator',
        'Origem: ' + LItemArquivoAssinatura.CaminhoOriginal
      );

      if Trim(LItemArquivoAssinatura.CaminhoBackupOld) <> '' then
        FLogger.Debug(
          'Orchestrator',
          'Backup _OLD: ' + LItemArquivoAssinatura.CaminhoBackupOld
        );

      FLogger.Debug(
        'Orchestrator',
        'Destino final: ' + LItemArquivoAssinatura.CaminhoArquivoAssinadoFinal
      );
    end
    else
    begin
      if Trim(LItemArquivoAssinatura.NomeArquivo) <> '' then
        LIdentificacaoArquivo := LItemArquivoAssinatura.NomeArquivo
      else if Trim(LItemArquivoAssinatura.CaminhoOriginal) <> '' then
        LIdentificacaoArquivo := LItemArquivoAssinatura.CaminhoOriginal
      else
        LIdentificacaoArquivo := '[arquivo não informado]';

      FLogger.Warning(
        'Orchestrator',
        'Arquivo bloqueado para assinatura: ' + LIdentificacaoArquivo,
        LItemArquivoAssinatura.MotivoBloqueio
      );
    end;
  end;

  if LQuantidadeArquivosValidos = 0 then
    raise Exception.Create('Nenhum arquivo válido foi encontrado para assinatura. Verifique o log para detalhes.');

  FLogger.Success(
    'Orchestrator',
    'Preparação dos arquivos concluída com sucesso. Total válido: ' + IntToStr(LQuantidadeArquivosValidos)
  );

  LSigningService := TSigningService.New(FLogger, LProcessExecutor, LSignToolService);

  for LItemArquivoAssinatura in LItensArquivoAssinatura do
  begin
    if not LItemArquivoAssinatura.ValidoParaAssinatura then
      Continue;

    FLogger.Info('Orchestrator', 'Iniciando a assinatura real do arquivo: ' + LItemArquivoAssinatura.NomeArquivo);

    LResultadoAssinatura := LSigningService.Assinar(AConfiguracao, LItemArquivoAssinatura);

    if not LResultadoAssinatura.Sucesso then
    begin
      FLogger.Error(
        'Orchestrator',
        'Falha na assinatura real do arquivo: ' + LItemArquivoAssinatura.NomeArquivo,
        LResultadoAssinatura.MensagemTecnica
      );

      if Trim(LResultadoAssinatura.MensagemAmigavel) <> '' then
        raise Exception.Create(LResultadoAssinatura.MensagemAmigavel);

      raise Exception.Create('Falha na assinatura real. Verifique o log para detalhes.');
    end;

    FLogger.Success(
      'Orchestrator',
      'Arquivo assinado com sucesso: ' + LItemArquivoAssinatura.NomeArquivo
    );

    if Trim(LResultadoAssinatura.ArquivoAlvo) <> '' then
      FLogger.Debug('Orchestrator', 'Arquivo assinado final: ' + LResultadoAssinatura.ArquivoAlvo);

    if Trim(LResultadoAssinatura.ComandoExecutado) <> '' then
      FLogger.Debug('Orchestrator', 'Comando executado: ' + LResultadoAssinatura.ComandoExecutado);
  end;
end;

end.

