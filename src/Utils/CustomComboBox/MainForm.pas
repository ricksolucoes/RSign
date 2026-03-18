unit MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Objects, FMX.StdCtrls, FMX.Layouts,
  CustomComboBox;

type
  TForm1 = class(TForm)
    RectBackground : TRectangle;
    LabelResult    : TLabel;
    LabelTitle     : TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Tres combos com estilos diferentes }
    FComboPadrao  : TMyComboBox;
    FComboVerde   : TMyComboBox;
    FComboDanger  : TMyComboBox;

    procedure OnComboChange(Sender: TObject);
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.FormCreate(Sender: TObject);
begin

  { =========================================================
      COMBO 1 — Estilo Azul (padrao)
    ========================================================= }
  FComboPadrao := TMyComboBox.Create(Self);
  FComboPadrao.Parent    := Self;
  FComboPadrao.SetBounds(40, 100, 260, 42);
  FComboPadrao.HintText  := 'Selecione um pais...';

  FComboPadrao.AddItem('Brasil');
  FComboPadrao.AddItem('Portugal');
  FComboPadrao.AddItem('Argentina');
  FComboPadrao.AddItem('Espanha');
  FComboPadrao.AddItem('Italia');

  FComboPadrao.OnChange := OnComboChange;

  { =========================================================
      COMBO 2 — Estilo Verde
    ========================================================= }
  FComboVerde := TMyComboBox.Create(Self);
  FComboVerde.Parent      := Self;
  FComboVerde.SetBounds(40, 170, 260, 42);
  FComboVerde.HintText    := 'Selecione uma fruta...';
  FComboVerde.BGColor     := $FF1E3A2F;   // fundo verde escuro
  FComboVerde.BorderColor := $FF2ECC71;   // borda verde
  FComboVerde.FontColor   := $FF2ECC71;   // texto verde

  FComboVerde.AddItem('Manga');
  FComboVerde.AddItem('Abacaxi');
  FComboVerde.AddItem('Maracuja');
  FComboVerde.AddItem('Goiaba');
  FComboVerde.AddItem('Graviola');

  FComboVerde.OnChange := OnComboChange;

  { =========================================================
      COMBO 3 — Estilo Vermelho / Danger
    ========================================================= }
  FComboDanger := TMyComboBox.Create(Self);
  FComboDanger.Parent      := Self;
  FComboDanger.SetBounds(40, 240, 260, 42);
  FComboDanger.HintText    := 'Nivel de urgencia...';
  FComboDanger.BGColor     := $FF3A1E1E;   // fundo vermelho escuro
  FComboDanger.BorderColor := $FFE74C3C;   // borda vermelha
  FComboDanger.FontColor   := $FFE74C3C;   // texto vermelho

  FComboDanger.AddItem('Baixo');
  FComboDanger.AddItem('Medio');
  FComboDanger.AddItem('Alto');
  FComboDanger.AddItem('Critico');

  FComboDanger.OnChange := OnComboChange;

end;

procedure TForm1.OnComboChange(Sender: TObject);
var
  CB: TMyComboBox;
begin
  CB := TMyComboBox(Sender);
  LabelResult.Text := 'Selecionado: ' + CB.SelectedText +
                      '  (indice ' + CB.SelectedIndex.ToString + ')';
end;

end.
