unit RSign.UI.Frame.SigningSettings;

interface

uses
  System.SysUtils,
  System.Classes,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.StdCtrls,
  FMX.Edit,
  FMX.ListBox,
  FMX.Layouts,
  FMX.Objects,
  FMX.ScrollBox,
  FMX.Controls.Presentation,

  RSign.Types.Common,
  RSign.Types.Signing,
  RSign.Core.Constants,
  RSign.Utils.Custom.ComboBox;

type
  TRSignFrameSigningSettings = class(TFrame)
    FScrollBox: TVertScrollBox;
    FContainer: TLayout;
    FPanelBackground: TRectangle;
    FCheckLocalizarAutomaticamente: TCheckBox;
    FEditCaminhoManualSignTool: TEdit;
    FCheckUsarVersaoMaisNova: TCheckBox;
    FEditUrlTimestamp: TEdit;
    FCheckVerificarAoFinal: TCheckBox;
    FCheckPermitirSemTimestamp: TCheckBox;
    procedure FCheckLocalizarAutomaticamenteChange(Sender: TObject);
  private
    FComboModoOperacao  : TRSignCustomComboBox;
    FComboModoLog       : TRSignCustomComboBox;

    procedure CriarComboModoOperacao;
    procedure CriarComboModoLog;

    procedure CriarComboBox;
  public
    procedure AfterConstruction; override;
    procedure ApplyConfiguration(const AConfiguracao: TConfiguracaoAssinatura);
    function BuildConfiguration: TConfiguracaoAssinatura;
  end;

implementation

{$R *.fmx}

procedure TRSignFrameSigningSettings.AfterConstruction;
begin
  inherited;
  CriarComboBox;
end;

procedure TRSignFrameSigningSettings.ApplyConfiguration(const AConfiguracao: TConfiguracaoAssinatura);
begin
  FCheckLocalizarAutomaticamente.IsChecked := AConfiguracao.LocalizarAutomaticamenteSignTool;
  FEditCaminhoManualSignTool.Text := AConfiguracao.CaminhoManualSignTool;
  FCheckUsarVersaoMaisNova.IsChecked := AConfiguracao.UsarVersaoMaisNova;
  FEditUrlTimestamp.Text := AConfiguracao.UrlTimestamp;
  FCheckVerificarAoFinal.IsChecked := AConfiguracao.VerificarAssinaturaAoFinal;
  FCheckPermitirSemTimestamp.IsChecked := AConfiguracao.PermitirContinuarSemTimestamp;
  FEditCaminhoManualSignTool.Enabled := not FCheckLocalizarAutomaticamente.IsChecked;
  FCheckUsarVersaoMaisNova.Enabled := FCheckLocalizarAutomaticamente.IsChecked;

  case AConfiguracao.ModoOperacaoArquivos of
    TModoOperacaoArquivos.Unico:
      FComboModoOperacao.SelectedIndex := 0;
    TModoOperacaoArquivos.Lote:
      FComboModoOperacao.SelectedIndex := 1;
  end;

  case AConfiguracao.ModoSaidaLog of
    TModoSaidaLog.Tela:
      FComboModoLog.SelectedIndex := 0;
    TModoSaidaLog.Arquivo:
      FComboModoLog.SelectedIndex := 1;
    TModoSaidaLog.Ambos:
      FComboModoLog.SelectedIndex := 2;
  end;

end;

function TRSignFrameSigningSettings.BuildConfiguration: TConfiguracaoAssinatura;
begin
  Result := TConfiguracaoAssinatura.Default;
  Result.LocalizarAutomaticamenteSignTool := FCheckLocalizarAutomaticamente.IsChecked;
  Result.CaminhoManualSignTool := Trim(FEditCaminhoManualSignTool.Text);
  Result.UsarVersaoMaisNova := FCheckUsarVersaoMaisNova.IsChecked;
  Result.UrlTimestamp := Trim(FEditUrlTimestamp.Text);
  Result.VerificarAssinaturaAoFinal := FCheckVerificarAoFinal.IsChecked;
  Result.PermitirContinuarSemTimestamp := FCheckPermitirSemTimestamp.IsChecked;

  if FComboModoOperacao.SelectedIndex = 1 then
    Result.ModoOperacaoArquivos := TModoOperacaoArquivos.Lote
  else
    Result.ModoOperacaoArquivos := TModoOperacaoArquivos.Unico;

  case FComboModoLog.SelectedIndex of
    0:
      Result.ModoSaidaLog := TModoSaidaLog.Tela;
    1:
      Result.ModoSaidaLog := TModoSaidaLog.Arquivo;
  else
    Result.ModoSaidaLog := TModoSaidaLog.Ambos;
  end;

end;

procedure TRSignFrameSigningSettings.CriarComboBox;
begin
  CriarComboModoOperacao;
  CriarComboModoLog;
end;

procedure TRSignFrameSigningSettings.CriarComboModoLog;
begin
  FComboModoLog := TRSignCustomComboBox.Create(Self);
  FComboModoLog.Parent := FContainer;
  FComboModoLog.SetBounds(
    { X    } 376,
    { Y    } 360,
    { W    } 350,
    { H    } 36
  );
  FComboModoLog.HintText := 'Seleção do formato de saída do log...';

  FComboModoLog.BGColor     := _DEFAULT_CUSTOM_COMBOBOX_COLOR_BACKGROUND;
  FComboModoLog.BorderColor := _DEFAULT_CUSTOM_COMBOBOX_COLOR_BORDER;
  FComboModoLog.FontColor   := _DEFAULT_CUSTOM_COMBOBOX_COLOR_FONT;

  FComboModoLog.AddItem('Tela');          // indice 0 → TModoSaidaLog.Tela
  FComboModoLog.AddItem('Arquivo');       // indice 1 → TModoSaidaLog.Arquivo
  FComboModoLog.AddItem('Ambos');         // indice 2 → TModoSaidaLog.Ambos
end;


procedure TRSignFrameSigningSettings.CriarComboModoOperacao;
begin
  FComboModoOperacao := TRSignCustomComboBox.Create(Self);
  FComboModoOperacao.Parent := FContainer;
  FComboModoOperacao.SetBounds(
    { X    } 16,
    { Y    } 360,
    { W    } 350,
    { H    } 36
  );
  FComboModoOperacao.HintText := 'Seleção do modo de operação...';

  FComboModoOperacao.BGColor     := _DEFAULT_CUSTOM_COMBOBOX_COLOR_BACKGROUND;
  FComboModoOperacao.BorderColor := _DEFAULT_CUSTOM_COMBOBOX_COLOR_BORDER;
  FComboModoOperacao.FontColor   := _DEFAULT_CUSTOM_COMBOBOX_COLOR_FONT;

  FComboModoOperacao.AddItem('Arquivo único');      // indice 0 → TModoOperacaoArquivos.Unico
  FComboModoOperacao.AddItem('Lote');               // indice 1 → TModoOperacaoArquivos.Lote
end;

procedure TRSignFrameSigningSettings.FCheckLocalizarAutomaticamenteChange(
  Sender: TObject);
begin
  FEditCaminhoManualSignTool.Enabled := not TCheckBox(Sender).IsChecked;
  FCheckUsarVersaoMaisNova.Enabled := TCheckBox(Sender).IsChecked;
  TThread.ForceQueue(nil, procedure
  begin
    if FEditCaminhoManualSignTool.CanFocus then
      FEditCaminhoManualSignTool.SetFocus;
  end);
end;

end.
