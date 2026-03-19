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
  RSign.UI.Main;

procedure Run;
var
  LConfigManager: IConfigManager;
  LLogger: ILoggerService;
  LOrchestrator: IOrchestrator;
begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  Application.Initialize;

  LConfigManager := TConfigManager.New;
  LLogger := TLoggerService.New;
  LOrchestrator := TOrchestrator.New(LConfigManager, LLogger);

  TRSignMainForm.Configure(LOrchestrator, LLogger);
  Application.CreateForm(TRSignMainForm, RSignMainForm);
  LOrchestrator.Initialize;
  Application.Run;
end;

end.
