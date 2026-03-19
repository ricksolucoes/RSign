unit RSign.App.Main;

interface

procedure Run;

implementation

uses
  FMX.Forms,

  RSign.Config.Manager,

  RSign.Core.Interfaces,
  RSign.Core.Orchestrator,

  RSign.Services.Logger,
  RSign.Services.UserDecision,

  RSign.UI.Main;

procedure Run;
var
  LConfigManager: IConfigManager;
  LLogger: ILoggerService;
  LOrchestrator: IOrchestrator;
  LUserDecisionService: IUserDecisionService;
begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  Application.Initialize;

  LConfigManager := TConfigManager.New;
  LLogger := TLoggerService.New;
  LUserDecisionService := TUserDecisionService.New;
  LOrchestrator := TOrchestrator.New(LConfigManager, LLogger, LUserDecisionService);

  TRSignMainForm.Configure(LOrchestrator, LLogger);
  Application.CreateForm(TRSignMainForm, RSignMainForm);
  LOrchestrator.Initialize;
  Application.Run;
end;

end.
