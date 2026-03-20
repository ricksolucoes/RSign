program RSign;

uses
  System.StartUpCopy,
  FMX.Forms,
  RSign.UI.Main in 'src\UI\RSign.UI.Main.pas' {RSignMainForm},
  RSign.UI.Frame.CertificateProfile in 'src\UI\Frame\RSign.UI.Frame.CertificateProfile.pas' {RSignFrameCertificateProfile: TFrame},
  RSign.UI.Frame.SigningSettings in 'src\UI\Frame\RSign.UI.Frame.SigningSettings.pas' {RSignFrameSigningSettings: TFrame},
  RSign.UI.Frame.Paths in 'src\UI\Frame\RSign.UI.Frame.Paths.pas' {RSignFramePaths: TFrame},
  RSign.Core.Constants in 'src\Core\RSign.Core.Constants.pas',
  RSign.Core.Interfaces in 'src\Core\RSign.Core.Interfaces.pas',
  RSign.Core.Orchestrator in 'src\Core\RSign.Core.Orchestrator.pas',
  RSign.Types.Common in 'src\Types\RSign.Types.Common.pas',
  RSign.Types.Certificate in 'src\Types\RSign.Types.Certificate.pas',
  RSign.Types.Signing in 'src\Types\RSign.Types.Signing.pas',
  RSign.Types.Config in 'src\Types\RSign.Types.Config.pas',
  RSign.Config.Manager in 'src\Config\RSign.Config.Manager.pas',
  RSign.Services.Logger in 'src\Services\RSign.Services.Logger.pas',
  RSign.App.Configuracao in 'src\App\RSign.App.Configuracao.pas',
  RSign.App.Log in 'src\App\RSign.App.Log.pas',
  RSign.App.Main in 'src\App\RSign.App.Main.pas',
  RSign.Utils.Custom.ComboBox in 'src\Utils\CustomComboBox\RSign.Utils.Custom.ComboBox.pas',
  RSign.Services.ProcessExecutor in 'src\Services\RSign.Services.ProcessExecutor.pas',
  RSign.Services.SignTool in 'src\Services\RSign.Services.SignTool.pas',
  RSign.Services.Certificate in 'src\Services\RSign.Services.Certificate.pas',
  RSign.Services.UserDecision in 'src\Services\RSign.Services.UserDecision.pas',
  RSign.Services.FileSigning in 'src\Services\RSign.Services.FileSigning.pas',
  RSign.Services.Signing in 'src\Services\RSign.Services.Signing.pas',
  RSign.Services.SigningVerification in 'src\Services\RSign.Services.SigningVerification.pas';

{$R *.res}

begin
  Run;
end.
