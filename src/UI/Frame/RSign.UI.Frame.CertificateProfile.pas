unit RSign.UI.Frame.CertificateProfile;

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

  RSign.Core.Constants,
  RSign.Types.Certificate,
  RSign.Utils.Custom.ComboBox;

type
  TRSignFrameCertificateProfile = class(TFrame)
    FScrollBox: TVertScrollBox;
    FContainer: TLayout;
    FPanelBackground: TRectangle;
    FEditNomeCertificado: TEdit;
    FEditNomeEmpresa: TEdit;
    FEditOrganizacao: TEdit;
    FEditDepartamento: TEdit;
    FEditCidade: TEdit;
    FEditEstado: TEdit;
    FEditPais: TEdit;
    FEditEmail: TEdit;
    FEditValidadeDias: TEdit;
    FEditSenha: TEdit;
    FEditConfirmacaoSenha: TEdit;
  private
    FComboTipoCertificado  : TRSignCustomComboBox;
    procedure CriarComboTipoCertificado;
  public
    procedure AfterConstruction; override;
    procedure ApplyConfiguration(const AConfiguracao: TConfiguracaoCertificado);
    function BuildConfiguration: TConfiguracaoCertificado;
  end;

implementation
uses
  RSign.Types.Common, System.UITypes;
{$R *.fmx}

procedure TRSignFrameCertificateProfile.AfterConstruction;
begin
  inherited;
  CriarComboTipoCertificado;
end;

procedure TRSignFrameCertificateProfile.ApplyConfiguration(const AConfiguracao: TConfiguracaoCertificado);
begin
  case AConfiguracao.TipoCertificado of
    TTipoCertificado.Autoassinado    : FComboTipoCertificado.SelectedIndex := 0;
    TTipoCertificado.PfxExterno      : FComboTipoCertificado.SelectedIndex := 1;
    TTipoCertificado.CodeSigningReal : FComboTipoCertificado.SelectedIndex := 2;
  end;

  FEditNomeCertificado.Text := AConfiguracao.NomeCertificado;
  FEditNomeEmpresa.Text := AConfiguracao.NomeEmpresa;
  FEditOrganizacao.Text := AConfiguracao.Organizacao;
  FEditDepartamento.Text := AConfiguracao.Departamento;
  FEditCidade.Text := AConfiguracao.Cidade;
  FEditEstado.Text := AConfiguracao.Estado;
  FEditPais.Text := AConfiguracao.Pais;
  FEditEmail.Text := AConfiguracao.Email;
  FEditValidadeDias.Text := IntToStr(AConfiguracao.ValidadeDias);
  FEditSenha.Text := AConfiguracao.Senha;
  FEditConfirmacaoSenha.Text := AConfiguracao.ConfirmacaoSenha;
end;

function TRSignFrameCertificateProfile.BuildConfiguration: TConfiguracaoCertificado;
begin
  Result := TConfiguracaoCertificado.Default;

  case FComboTipoCertificado.SelectedIndex of
    1 : Result.TipoCertificado := TTipoCertificado.PfxExterno;
    2 : Result.TipoCertificado := TTipoCertificado.CodeSigningReal;
  else
    Result.TipoCertificado := TTipoCertificado.Autoassinado;
  end;

  Result.NomeCertificado := Trim(FEditNomeCertificado.Text);
  Result.NomeEmpresa := Trim(FEditNomeEmpresa.Text);
  Result.Organizacao := Trim(FEditOrganizacao.Text);
  Result.Departamento := Trim(FEditDepartamento.Text);
  Result.Cidade := Trim(FEditCidade.Text);
  Result.Estado := Trim(FEditEstado.Text);
  Result.Pais := Trim(FEditPais.Text);
  Result.Email := Trim(FEditEmail.Text);
  Result.ValidadeDias := StrToIntDef(Trim(FEditValidadeDias.Text), 365);
  Result.Senha := FEditSenha.Text;
  Result.ConfirmacaoSenha := FEditConfirmacaoSenha.Text;
end;

procedure TRSignFrameCertificateProfile.CriarComboTipoCertificado;
begin
  FComboTipoCertificado := TRSignCustomComboBox.Create(Self);
  FComboTipoCertificado.Parent := FContainer;
  FComboTipoCertificado.SetBounds(
    { X    } 16,
    { Y    } 40,
    { W    } 705,
    { H    } 36
  );
  FComboTipoCertificado.HintText := 'Definição do tipo de certificado...';

  FComboTipoCertificado.BGColor     := _DEFAULT_CUSTOM_COMBOBOX_COLOR_BACKGROUND;
  FComboTipoCertificado.BorderColor := _DEFAULT_CUSTOM_COMBOBOX_COLOR_BORDER;
  FComboTipoCertificado.FontColor   := _DEFAULT_CUSTOM_COMBOBOX_COLOR_FONT;

  FComboTipoCertificado.AddItem('Autoassinado');      // indice 0 → TTipoCertificado.Autoassinado
  FComboTipoCertificado.AddItem('PFX Externo');       // indice 1 → TTipoCertificado.PfxExterno
  FComboTipoCertificado.AddItem('Code Signing Real'); // indice 2 → TTipoCertificado.CodeSigningReal
end;


end.
