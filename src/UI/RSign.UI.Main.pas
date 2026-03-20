unit RSign.UI.Main;

interface

uses
  System.SysUtils,
  System.Classes,
  System.UITypes,
  FMX.Types,
  FMX.Controls,
  FMX.Graphics,
  FMX.Forms,
  FMX.StdCtrls,
  FMX.TabControl,
  FMX.DialogService,
  FMX.Layouts,
  FMX.Memo,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  RSign.Core.Interfaces,
  RSign.Types.Common,
  RSign.Types.Config,
  RSign.UI.Frame.CertificateProfile,
  RSign.UI.Frame.SigningSettings,
  RSign.UI.Frame.Paths, FMX.ScrollBox, FMX.Objects;

type
  TRSignMainForm = class(TForm)
    FClientLayout: TLayout;
    FTabControl: TTabControl;
    FTabCertificado: TTabItem;
    FTabAssinatura: TTabItem;
    FTabCaminhos: TTabItem;
    FLayoutLogTitulo: TLayout;
    FLabelLog: TLabel;
    FMemoLog: TMemo;
    FFrameCertificateProfile: TRSignFrameCertificateProfile;
    FFrameSigningSettings: TRSignFrameSigningSettings;
    FFramePaths: TRSignFramePaths;
    FToolBar: TRectangle;
    FButtonCarregar: TSpeedButton;
    FButtonSalvar: TSpeedButton;
    FButtonValidar: TSpeedButton;
    FButtonExecutar: TSpeedButton;
    recButtonCarregar: TRectangle;
    lblButtonCarregar: TLabel;
    recButtonExecutar: TRectangle;
    lblButtonExecutar: TLabel;
    recButtonSalvar: TRectangle;
    lblButtonSalvar: TLabel;
    recButtonValidar: TRectangle;
    lblButtonValidar: TLabel;
    FButtonFechar: TSpeedButton;
    recButtonFechar: TRectangle;
    lblButtonFechar: TLabel;
    recLogTitulo: TRectangle;
    FButtomLayout: TLayout;
    StyleBook1: TStyleBook;
    lblTitulo: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private class var
    FOrchestratorClass: IOrchestrator;
    FLoggerClass: ILoggerService;
  private
    FConfiguracaoAtual: TConfiguracaoAplicacao;
    procedure RegistrarCallbackLog;
    procedure AdicionarLinhaLog(const ALinhaLog: string);
    procedure AplicarConfiguracaoNaTela(const AConfiguracao: TConfiguracaoAplicacao);
    function MontarConfiguracaoDaTela: TConfiguracaoAplicacao;
    procedure CarregarConfiguracao;
    procedure OnClickCarregar(Sender: TObject);
    procedure OnClickSalvar(Sender: TObject);
    procedure OnClickValidar(Sender: TObject);
    procedure OnClickExecutar(Sender: TObject);
    procedure OnChangeTabControl(Sender: TObject);
    procedure OnClickFechar(Sender: TObject);
  protected
    procedure DoCreate;
    procedure DoDestroy;
  public
    class procedure Configure(const AOrchestrator: IOrchestrator; const ALogger: ILoggerService);
  end;

var
  RSignMainForm: TRSignMainForm;

implementation

{$R *.fmx}

class procedure TRSignMainForm.Configure(const AOrchestrator: IOrchestrator; const ALogger: ILoggerService);
begin
  FOrchestratorClass := AOrchestrator;
  FLoggerClass := ALogger;
end;

procedure TRSignMainForm.DoCreate;
begin
  FTabControl.OnChange := OnChangeTabControl;
  FButtonCarregar.OnClick := OnClickCarregar;
  FButtonSalvar.OnClick := OnClickSalvar;
  FButtonValidar.OnClick := OnClickValidar;
  FButtonExecutar.OnClick := OnClickExecutar;
  FButtonFechar.OnClick := OnClickFechar;

  RegistrarCallbackLog;
  CarregarConfiguracao;

  TThread.Queue(nil,
    procedure
    begin
      FTabControl.ApplyStyleLookup;
      OnChangeTabControl(FTabControl);
    end
  );
end;

procedure TRSignMainForm.DoDestroy;
begin
  if Assigned(FLoggerClass) then
    FLoggerClass.SetOnLog(nil);
end;

procedure TRSignMainForm.FormCreate(Sender: TObject);
begin
  DoCreate;
end;

procedure TRSignMainForm.FormDestroy(Sender: TObject);
begin
  DoDestroy;
end;

procedure TRSignMainForm.OnChangeTabControl(Sender: TObject);
var
  I: Integer;
  LRectangle: TRectangle;
begin
  for I := 0 to TTabControl(Sender).TabCount - 1 do
  begin
    LRectangle := TTabControl(Sender).Tabs[I].FindStyleResource('Rectangle1Style') as TRectangle;

    if not Assigned(LRectangle) then
      Continue;

    LRectangle.Fill.Color := $FFE3E8DD;
    TTabControl(Sender).Tabs[I].TextSettings.FontColor := $FF243228;

    if not (I = TTabControl(Sender).TabIndex) then
      Continue;

    LRectangle.Fill.Color := $FF65734F;
    TTabControl(Sender).Tabs[I].TextSettings.FontColor := $FFFFFFFF;
  end;

  if not (TTabControl(Sender).ActiveTab = FTabCaminhos) then
    Exit;

  FFramePaths.FEditCaminhoArquivoEntrada.Enabled := (FFrameSigningSettings.ComboModoOperacao.SelectedIndex = 0);
  FFramePaths.FEditDiretorioEntradaLote.Enabled := (FFrameSigningSettings.ComboModoOperacao.SelectedIndex = 1);
end;

procedure TRSignMainForm.RegistrarCallbackLog;
begin
  if Assigned(FLoggerClass) then
    FLoggerClass.SetOnLog(AdicionarLinhaLog);
end;

procedure TRSignMainForm.AdicionarLinhaLog(const ALinhaLog: string);
begin
  if Assigned(FMemoLog) then
    FMemoLog.Lines.Add(ALinhaLog);
end;

procedure TRSignMainForm.AplicarConfiguracaoNaTela(const AConfiguracao: TConfiguracaoAplicacao);
begin
  FConfiguracaoAtual := AConfiguracao;
  FFrameCertificateProfile.ApplyConfiguration(AConfiguracao.Certificado);
  FFrameSigningSettings.ApplyConfiguration(AConfiguracao.Assinatura);
  FFramePaths.ApplyConfiguration(AConfiguracao.Caminhos);

  if (AConfiguracao.UI.UltimaAbaAtiva >= 0) and (AConfiguracao.UI.UltimaAbaAtiva < FTabControl.TabCount) then
    FTabControl.TabIndex := AConfiguracao.UI.UltimaAbaAtiva
  else
    FTabControl.TabIndex := 0;
end;

function TRSignMainForm.MontarConfiguracaoDaTela: TConfiguracaoAplicacao;
begin
  Result := FConfiguracaoAtual;
  Result.Certificado := FFrameCertificateProfile.BuildConfiguration;
  Result.Assinatura := FFrameSigningSettings.BuildConfiguration;
  Result.Caminhos := FFramePaths.BuildConfiguration;
  Result.Log.ModoSaidaLog := Result.Assinatura.ModoSaidaLog;
  Result.UI.UltimaAbaAtiva := FTabControl.TabIndex;
end;

procedure TRSignMainForm.CarregarConfiguracao;
begin
  if not Assigned(FOrchestratorClass) then
    Exit;

  FConfiguracaoAtual := FOrchestratorClass.LoadConfiguration;
  AplicarConfiguracaoNaTela(FConfiguracaoAtual);
end;

procedure TRSignMainForm.OnClickCarregar(Sender: TObject);
begin
  try
    CarregarConfiguracao;
  except
    on E: Exception do
      TDialogService.MessageDialog(
        'Falha ao carregar a configuração: ' + E.Message,
        TMsgDlgType.mtError,
        [TMsgDlgBtn.mbOK],
        TMsgDlgBtn.mbOK,
        0,
        nil
      );
  end;
end;

procedure TRSignMainForm.OnClickSalvar(Sender: TObject);
var
  LConfiguracao: TConfiguracaoAplicacao;
begin
  try
    LConfiguracao := MontarConfiguracaoDaTela;
    FOrchestratorClass.SaveConfiguration(LConfiguracao);
    FConfiguracaoAtual := LConfiguracao;

    TDialogService.MessageDialog(
      'Configuração salva com sucesso.',
      TMsgDlgType.mtInformation,
      [TMsgDlgBtn.mbOK],
      TMsgDlgBtn.mbOK,
      0,
      nil
    );
  except
    on E: Exception do
      TDialogService.MessageDialog(
        'Falha ao salvar a configuração: ' + E.Message,
        TMsgDlgType.mtError,
        [TMsgDlgBtn.mbOK],
        TMsgDlgBtn.mbOK,
        0,
        nil
      );
  end;
end;

procedure TRSignMainForm.OnClickValidar(Sender: TObject);
var
  LConfiguracao: TConfiguracaoAplicacao;
begin
  try
    LConfiguracao := MontarConfiguracaoDaTela;
    FOrchestratorClass.ValidateConfiguration(LConfiguracao);
    TDialogService.MessageDialog(
      'Validação inicial concluída com sucesso.',
      TMsgDlgType.mtInformation,
      [TMsgDlgBtn.mbOK],
      TMsgDlgBtn.mbOK,
      0,
      nil
    );
  except
    on E: Exception do
      TDialogService.MessageDialog(
        'Falha na validação: ' + E.Message,
        TMsgDlgType.mtError,
        [TMsgDlgBtn.mbOK],
        TMsgDlgBtn.mbOK,
        0,
        nil
      );
  end;
end;

procedure TRSignMainForm.OnClickFechar(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TRSignMainForm.OnClickExecutar(Sender: TObject);
var
  LConfiguracao: TConfiguracaoAplicacao;
begin
  try
    LConfiguracao := MontarConfiguracaoDaTela;
    FOrchestratorClass.Execute(LConfiguracao);
    FConfiguracaoAtual := LConfiguracao;
    TDialogService.MessageDialog(
      'Execução da fase inicial concluída. Verifique o log para detalhes.',
      TMsgDlgType.mtInformation,
      [TMsgDlgBtn.mbOK],
      TMsgDlgBtn.mbOK,
      0,
      nil
    );
  except
    on E: Exception do
      TDialogService.MessageDialog(
        'Falha ao executar a operação: ' + E.Message,
        TMsgDlgType.mtError,
        [TMsgDlgBtn.mbOK],
        TMsgDlgBtn.mbOK,
        0,
        nil
      );
  end;
end;

end.
