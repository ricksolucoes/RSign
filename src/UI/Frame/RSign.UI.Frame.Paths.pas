unit RSign.UI.Frame.Paths;

interface

uses
  System.SysUtils,
  System.Classes,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.StdCtrls,
  FMX.Edit,
  FMX.Layouts,
  FMX.Objects,
  FMX.ScrollBox,
  RSign.Types.Config, FMX.Controls.Presentation;

type
  TRSignFramePaths = class(TFrame)
    FScrollBox: TVertScrollBox;
    FContainer: TLayout;
    FPanelBackground: TRectangle;
    FEditDiretorioPfx: TEdit;
    FEditNomeArquivoPfx: TEdit;
    FEditCaminhoArquivoEntrada: TEdit;
    FEditDiretorioEntradaLote: TEdit;
    FEditDiretorioSaida: TEdit;
    FCheckMesmoDiretorio: TCheckBox;
    procedure FCheckMesmoDiretorioChange(Sender: TObject);
  public
    procedure ApplyConfiguration(const AConfiguracao: TConfiguracaoCaminhos);
    function BuildConfiguration: TConfiguracaoCaminhos;
  end;

implementation

{$R *.fmx}

procedure TRSignFramePaths.ApplyConfiguration(const AConfiguracao: TConfiguracaoCaminhos);
begin
  FEditDiretorioPfx.Text := AConfiguracao.DiretorioPfx;
  FEditNomeArquivoPfx.Text := AConfiguracao.NomeArquivoPfx;
  FEditCaminhoArquivoEntrada.Text := AConfiguracao.CaminhoArquivoEntrada;
  FEditDiretorioEntradaLote.Text := AConfiguracao.DiretorioEntradaLote;
  FEditDiretorioSaida.Text := AConfiguracao.DiretorioSaida;
  FCheckMesmoDiretorio.IsChecked := AConfiguracao.UsarMesmoDiretorioDoOriginal;
  FEditDiretorioSaida.Enabled := not FCheckMesmoDiretorio.IsChecked;
end;

function TRSignFramePaths.BuildConfiguration: TConfiguracaoCaminhos;
begin
  Result := TConfiguracaoCaminhos.Default;
  Result.DiretorioPfx := Trim(FEditDiretorioPfx.Text);
  Result.NomeArquivoPfx := Trim(FEditNomeArquivoPfx.Text);
  Result.CaminhoArquivoEntrada := Trim(FEditCaminhoArquivoEntrada.Text);
  Result.DiretorioEntradaLote := Trim(FEditDiretorioEntradaLote.Text);
  Result.DiretorioSaida := Trim(FEditDiretorioSaida.Text);
  Result.UsarMesmoDiretorioDoOriginal := FCheckMesmoDiretorio.IsChecked;
end;

procedure TRSignFramePaths.FCheckMesmoDiretorioChange(Sender: TObject);
begin
  FEditDiretorioSaida.Enabled := not FCheckMesmoDiretorio.IsChecked;

  TThread.ForceQueue(nil, procedure
  begin
    if FEditDiretorioSaida.CanFocus then
      FEditDiretorioSaida.SetFocus;
  end);
end;

end.
