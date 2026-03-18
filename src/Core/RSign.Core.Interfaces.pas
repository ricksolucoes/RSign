unit RSign.Core.Interfaces;

interface

uses
  RSign.Types.Common,
  RSign.Types.Certificate,
  RSign.Types.Signing,
  RSign.Types.Config;

type
  TOnLogEvent = reference to procedure(const AMensagem: string);

  ILoggerService = interface
    ['{6299C291-520F-45E6-9B72-0A7F4F933001}']
    procedure SetOnLog(const AOnLog: TOnLogEvent);
    procedure SetLogFilePath(const ALogFilePath: string);
    procedure Log(ANivelLog: TNivelLog; const AOrigem: string; const AMensagem: string; const ADetalheTecnico: string = '');
    procedure Info(const AOrigem: string; const AMensagem: string);
    procedure Warning(const AOrigem: string; const AMensagem: string; const ADetalheTecnico: string = '');
    procedure Error(const AOrigem: string; const AMensagem: string; const ADetalheTecnico: string = '');
    procedure Debug(const AOrigem: string; const AMensagem: string);
    procedure Success(const AOrigem: string; const AMensagem: string);
  end;

  IConfigManager = interface
    ['{6299C291-520F-45E6-9B72-0A7F4F933002}']
    function GetConfigFilePath: string;
    procedure EnsureExists;
    function Load: TConfiguracaoAplicacao;
    procedure Save(const AConfiguracao: TConfiguracaoAplicacao);
  end;

  IProcessExecutor = interface
    ['{6299C291-520F-45E6-9B72-0A7F4F933003}']
    function Execute(const AExecutablePath: string; const AParameters: string; const AWorkingDirectory: string; ATimeoutMiliseconds: Cardinal): TResultadoProcessoExterno;
  end;

  ISignToolService = interface
    ['{6299C291-520F-45E6-9B72-0A7F4F933004}']
    function Localizar(const AConfiguracaoAssinatura: TConfiguracaoAssinatura): TStatusSignTool;
  end;

  ICertificateService = interface
    ['{6299C291-520F-45E6-9B72-0A7F4F933005}']
    function Validar(const AConfiguracaoCertificado: TConfiguracaoCertificado; const AConfiguracaoCaminhos: TConfiguracaoCaminhos): TStatusCertificado;
    function Criar(const AConfiguracaoCertificado: TConfiguracaoCertificado; const AConfiguracaoCaminhos: TConfiguracaoCaminhos): TResultadoCriacaoCertificado;
  end;

  IFileSigningService = interface
    ['{6299C291-520F-45E6-9B72-0A7F4F933006}']
    function PrepararArquivos(const AConfiguracao: TConfiguracaoAplicacao): TItensArquivoAssinatura;
  end;

  ISigningService = interface
    ['{6299C291-520F-45E6-9B72-0A7F4F933007}']
    function Assinar(const AConfiguracao: TConfiguracaoAplicacao; const AItemArquivo: TItemArquivoAssinatura): TResultadoAssinatura;
  end;

  ISigningVerificationService = interface
    ['{6299C291-520F-45E6-9B72-0A7F4F933008}']
    function Verificar(const AConfiguracao: TConfiguracaoAplicacao; const AResultadoAssinatura: TResultadoAssinatura): TResultadoAssinatura;
  end;

  IUserDecisionService = interface
    ['{6299C291-520F-45E6-9B72-0A7F4F933009}']
    function Confirmar(const ATitulo: string; const AMensagem: string; const ADetalheTecnico: string = ''): Boolean;
  end;

  IOrchestrator = interface
    ['{6299C291-520F-45E6-9B72-0A7F4F933010}']
    procedure Initialize;
    function LoadConfiguration: TConfiguracaoAplicacao;
    procedure SaveConfiguration(const AConfiguracao: TConfiguracaoAplicacao);
    procedure ValidateConfiguration(const AConfiguracao: TConfiguracaoAplicacao);
    procedure Execute(const AConfiguracao: TConfiguracaoAplicacao);
  end;

implementation

end.
