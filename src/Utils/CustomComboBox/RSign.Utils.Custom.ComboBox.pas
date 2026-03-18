unit RSign.Utils.Custom.ComboBox;

interface

uses
  System.Math,
  System.Types,
  System.Classes,
  System.UITypes,
  System.SysUtils,
  System.Generics.Collections,

  FMX.Text,
  FMX.Types,
  FMX.Objects,
  FMX.Layouts,
  FMX.Controls,
  FMX.Graphics,
  FMX.StdCtrls,
  FMX.Controls.Presentation;

type
  TRSignCustomComboBox = class(TLayout)
  private
    { Corpo principal }
    FBackground  : TRectangle;
    FLabel       : TLabel;
    FArrowRect   : TRectangle;
    FArrowPath   : TPath;

    { Popup }
    FPopup       : TPopup;
    FPopupBG     : TRectangle;
    FScroll      : TVertScrollBox;

    { Estado }
    FItems       : TList<string>;
    FSelectedIdx : Integer;
    FHoverColor  : TAlphaColor;

    { Propriedades }
    FOnChange    : TNotifyEvent;
    FBGColor     : TAlphaColor;
    FBorderColor : TAlphaColor;
    FFontColor   : TAlphaColor;
    FHintColor   : TAlphaColor;
    FHintText    : string;

    procedure ItemClick(Sender: TObject);
    procedure ItemMouseEnter(Sender: TObject);
    procedure ItemMouseLeave(Sender: TObject);
    procedure ArrowClick(Sender: TObject);

    procedure SetBGColor(const Value: TAlphaColor);
    procedure SetBorderColor(const Value: TAlphaColor);
    procedure SetFontColor(const Value: TAlphaColor);
    procedure SetHintText(const Value: string);
    procedure SetSelectedIndex(const Value: Integer);
    function  GetSelectedIndex: Integer;

    function  DarkenColor(AColor: TAlphaColor; AAmount: Byte): TAlphaColor;
    procedure RebuildItems;

    { Aplica cor no label liberando o StyledSettings }
    procedure ApplyLabelColor(ALabel: TLabel; AColor: TAlphaColor);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddItem(const AText: string);
    procedure Clear;
    function  SelectedText: string;

  published
    property BGColor       : TAlphaColor  read FBGColor        write SetBGColor;
    property BorderColor   : TAlphaColor  read FBorderColor    write SetBorderColor;
    property FontColor     : TAlphaColor  read FFontColor      write SetFontColor;
    property HintText      : string       read FHintText       write SetHintText;
    property SelectedIndex : Integer      read GetSelectedIndex write SetSelectedIndex;
    property OnChange      : TNotifyEvent read FOnChange       write FOnChange;
  end;

implementation

{ --------------------------------------------------------------------------- }

function TRSignCustomComboBox.DarkenColor(AColor: TAlphaColor; AAmount: Byte): TAlphaColor;
var
  A, R, G, B: Byte;
begin
  A := (AColor shr 24) and $FF;
  R := (AColor shr 16) and $FF;
  G := (AColor shr  8) and $FF;
  B :=  AColor         and $FF;
  R := Max(0, Integer(R) - AAmount);
  G := Max(0, Integer(G) - AAmount);
  B := Max(0, Integer(B) - AAmount);
  Result := (A shl 24) or (R shl 16) or (G shl 8) or B;
end;

{ Libera o FontColor do controle de estilo e aplica a cor desejada }
procedure TRSignCustomComboBox.ApplyLabelColor(ALabel: TLabel; AColor: TAlphaColor);
begin
  ALabel.StyledSettings := ALabel.StyledSettings - [TStyledSetting.FontColor];
  ALabel.TextSettings.FontColor := AColor;
end;

{ --------------------------------------------------------------------------- }

constructor TRSignCustomComboBox.Create(AOwner: TComponent);
begin
  inherited;

  FItems       := TList<string>.Create;
  FSelectedIdx := -1;
  FBGColor     := $FFF1F3ED;
  FBorderColor := $FF7A8570;
  FFontColor   := $FF1F281D;
  FHintText    := 'Selecione...';
  FHoverColor  := DarkenColor(FBGColor, 20);
  FHintColor   := DarkenColor(FBGColor, 100);

  { --- Fundo principal --- }
  FBackground := TRectangle.Create(Self);
  FBackground.Parent           := Self;
  FBackground.Align            := TAlignLayout.Client;
  FBackground.Fill.Color       := FBGColor;
  FBackground.Stroke.Color     := FBorderColor;
  FBackground.Stroke.Thickness := 1.5;
  FBackground.XRadius          := 6;
  FBackground.YRadius          := 6;
  FBackground.OnClick          := ArrowClick;
  FBackground.HitTest          := True;

  { --- Label do texto selecionado / hint --- }
  FLabel := TLabel.Create(Self);
  FLabel.Parent         := FBackground;
  FLabel.Align          := TAlignLayout.Client;
  FLabel.Margins.Left   := 12;
  FLabel.Margins.Right  := 36;
  FLabel.Margins.Top    := 2;
  FLabel.Margins.Bottom := 2;
  FLabel.Text           := FHintText;
  FLabel.TextSettings.Font.Size  := 13;
  FLabel.TextSettings.VertAlign  := TTextAlign.Center;
  FLabel.HitTest        := False;
  { --- CRITICO: libera o FontColor do estilo para aceitar cor programatica --- }
  FLabel.StyledSettings := FLabel.StyledSettings - [TStyledSetting.FontColor,
                                                     TStyledSetting.Size];
  FLabel.TextSettings.FontColor := FHintColor;

  { --- Container da seta --- }
  FArrowRect := TRectangle.Create(Self);
  FArrowRect.Parent      := FBackground;
  FArrowRect.Align       := TAlignLayout.Right;
  FArrowRect.Width       := 32;
  FArrowRect.Fill.Kind   := TBrushKind.None;
  FArrowRect.Stroke.Kind := TBrushKind.None;
  FArrowRect.HitTest     := False;

  { --- Seta --- }
  FArrowPath := TPath.Create(Self);
  FArrowPath.Parent      := FArrowRect;
  FArrowPath.Align       := TAlignLayout.Center;
  FArrowPath.Width       := 12;
  FArrowPath.Height      := 7;
  FArrowPath.Fill.Color  := FFontColor;
  FArrowPath.Stroke.Kind := TBrushKind.None;
  FArrowPath.Data.Data   := 'M 0 0 L 6 7 L 12 0 Z';
  FArrowPath.HitTest     := False;

  { --- Popup --- }
  FPopup := TPopup.Create(Self);
  FPopup.Parent          := Self;
  FPopup.Placement       := TPlacement.Bottom;
  FPopup.PlacementTarget := FBackground;
  FPopup.StyleLookup     := '';

  { --- Fundo do popup --- }
  FPopupBG := TRectangle.Create(FPopup);
  FPopupBG.Parent           := FPopup;
  FPopupBG.Align            := TAlignLayout.Client;
  FPopupBG.Fill.Color       := FBGColor;
  FPopupBG.Stroke.Color     := FBorderColor;
  FPopupBG.Stroke.Thickness := 1.5;
  FPopupBG.XRadius          := 6;
  FPopupBG.YRadius          := 6;

  { --- ScrollBox sem fundo branco --- }
  FScroll := TVertScrollBox.Create(FPopup);
  FScroll.Parent         := FPopupBG;
  FScroll.Align          := TAlignLayout.Client;
  FScroll.Margins.Left   := 4;
  FScroll.Margins.Right  := 4;
  FScroll.Margins.Top    := 4;
  FScroll.Margins.Bottom := 4;
  FScroll.ShowScrollBars := True;
end;

destructor TRSignCustomComboBox.Destroy;
begin
  FItems.Free;
  inherited;
end;

{ --------------------------------------------------------------------------- }

procedure TRSignCustomComboBox.ArrowClick(Sender: TObject);
begin
  FPopup.Width  := Self.Width;
  FPopup.Height := Min(220, FItems.Count * 36 + 12);
  FPopup.IsOpen := not FPopup.IsOpen;
end;

procedure TRSignCustomComboBox.ItemClick(Sender: TObject);
begin
  FSelectedIdx  := TRectangle(Sender).Tag;
  FLabel.Text   := FItems[FSelectedIdx];
  { CRITICO: libera e aplica cor ao selecionar }
  ApplyLabelColor(FLabel, FFontColor);
  FPopup.IsOpen := False;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TRSignCustomComboBox.ItemMouseEnter(Sender: TObject);
begin
  TRectangle(Sender).Fill.Color := FHoverColor;
end;

procedure TRSignCustomComboBox.ItemMouseLeave(Sender: TObject);
begin
  TRectangle(Sender).Fill.Color := FBGColor;
end;

{ --------------------------------------------------------------------------- }

procedure TRSignCustomComboBox.AddItem(const AText: string);
var
  ItemRect  : TRectangle;
  ItemLabel : TLabel;
  Idx       : Integer;
begin
  Idx := FItems.Count;
  FItems.Add(AText);

  ItemRect := TRectangle.Create(FScroll);
  ItemRect.Parent       := FScroll.Content;
  ItemRect.Align        := TAlignLayout.Top;
  ItemRect.Height       := 36;
  ItemRect.Fill.Color   := FBGColor;
  ItemRect.Stroke.Kind  := TBrushKind.None;
  ItemRect.XRadius      := 4;
  ItemRect.YRadius      := 4;
  ItemRect.Tag          := Idx;
  ItemRect.HitTest      := True;
  ItemRect.OnClick      := ItemClick;
  ItemRect.OnMouseEnter := ItemMouseEnter;
  ItemRect.OnMouseLeave := ItemMouseLeave;

  ItemLabel := TLabel.Create(ItemRect);
  ItemLabel.Parent         := ItemRect;
  ItemLabel.Align          := TAlignLayout.Client;
  ItemLabel.Margins.Left   := 12;
  ItemLabel.Margins.Top    := 2;
  ItemLabel.Margins.Bottom := 2;
  ItemLabel.Text           := AText;
  ItemLabel.TextSettings.Font.Size := 13;
  ItemLabel.TextSettings.VertAlign := TTextAlign.Center;
  ItemLabel.HitTest        := False;
  { CRITICO: libera o FontColor do estilo nos itens tambem }
  ItemLabel.StyledSettings := ItemLabel.StyledSettings - [TStyledSetting.FontColor,
                                                           TStyledSetting.Size];
  ItemLabel.TextSettings.FontColor := FFontColor;
end;

procedure TRSignCustomComboBox.Clear;
begin
  FItems.Clear;
  FSelectedIdx := -1;
  FScroll.Content.DeleteChildren;
  FLabel.Text := FHintText;
  ApplyLabelColor(FLabel, FHintColor);
end;

{ --------------------------------------------------------------------------- }

procedure TRSignCustomComboBox.RebuildItems;
var
  I         : Integer;
  ItemRect  : TRectangle;
  ItemLabel : TLabel;
begin
  FScroll.Content.DeleteChildren;

  for I := 0 to FItems.Count - 1 do
  begin
    ItemRect := TRectangle.Create(FScroll);
    ItemRect.Parent       := FScroll.Content;
    ItemRect.Align        := TAlignLayout.Top;
    ItemRect.Height       := 36;
    ItemRect.Fill.Color   := FBGColor;
    ItemRect.Stroke.Kind  := TBrushKind.None;
    ItemRect.XRadius      := 4;
    ItemRect.YRadius      := 4;
    ItemRect.Tag          := I;
    ItemRect.HitTest      := True;
    ItemRect.OnClick      := ItemClick;
    ItemRect.OnMouseEnter := ItemMouseEnter;
    ItemRect.OnMouseLeave := ItemMouseLeave;

    ItemLabel := TLabel.Create(ItemRect);
    ItemLabel.Parent         := ItemRect;
    ItemLabel.Align          := TAlignLayout.Client;
    ItemLabel.Margins.Left   := 12;
    ItemLabel.Margins.Top    := 2;
    ItemLabel.Margins.Bottom := 2;
    ItemLabel.Text           := FItems[I];
    ItemLabel.TextSettings.Font.Size := 13;
    ItemLabel.TextSettings.VertAlign := TTextAlign.Center;
    ItemLabel.HitTest        := False;
    { CRITICO: libera o FontColor do estilo }
    ItemLabel.StyledSettings := ItemLabel.StyledSettings - [TStyledSetting.FontColor,
                                                             TStyledSetting.Size];
    ItemLabel.TextSettings.FontColor := FFontColor;
  end;
end;

{ --------------------------------------------------------------------------- }

function TRSignCustomComboBox.SelectedText: string;
begin
  if (FSelectedIdx >= 0) and (FSelectedIdx < FItems.Count) then
    Result := FItems[FSelectedIdx]
  else
    Result := '';
end;

function TRSignCustomComboBox.GetSelectedIndex: Integer;
begin
  Result := FSelectedIdx;
end;

procedure TRSignCustomComboBox.SetSelectedIndex(const Value: Integer);
begin
  if (Value >= 0) and (Value < FItems.Count) then
  begin
    FSelectedIdx  := Value;
    FLabel.Text   := FItems[Value];
    ApplyLabelColor(FLabel, FFontColor);
  end
  else
  begin
    FSelectedIdx  := -1;
    FLabel.Text   := FHintText;
    ApplyLabelColor(FLabel, FHintColor);
  end;
end;

{ --------------------------------------------------------------------------- }

procedure TRSignCustomComboBox.SetBGColor(const Value: TAlphaColor);
begin
  FBGColor               := Value;
  FHoverColor            := DarkenColor(Value, 20);
  FHintColor             := DarkenColor(Value, 100);
  FBackground.Fill.Color := Value;
  FPopupBG.Fill.Color    := Value;
  { Atualiza hint se nada selecionado }
  if FSelectedIdx < 0 then
    ApplyLabelColor(FLabel, FHintColor);
  RebuildItems;
end;

procedure TRSignCustomComboBox.SetBorderColor(const Value: TAlphaColor);
begin
  FBorderColor             := Value;
  FBackground.Stroke.Color := Value;
  FPopupBG.Stroke.Color    := Value;
end;

procedure TRSignCustomComboBox.SetFontColor(const Value: TAlphaColor);
begin
  FFontColor            := Value;
  FArrowPath.Fill.Color := Value;
  { Atualiza label principal se item selecionado }
  if FSelectedIdx >= 0 then
    ApplyLabelColor(FLabel, Value);
  { Atualiza todos os itens ja criados }
  RebuildItems;
end;

procedure TRSignCustomComboBox.SetHintText(const Value: string);
begin
  FHintText := Value;
  if FSelectedIdx < 0 then
    FLabel.Text := Value;
end;

end.
