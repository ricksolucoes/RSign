unit RSign.UI.Loading;

interface

uses
  System.UITypes,
  System.Classes,
  System.SysUtils,

  FMX.Types,
  FMX.Forms,
  FMX.Layouts,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.Controls,
  FMX.Graphics,

  RSign.Core.Constants;

type
  TRSignLoadingOverlay = class(TRectangle)
  private
    FDots  : array[0..2] of TRectangle;
    FTimer : TTimer;
    FTick  : Integer;
    procedure OnTick(Sender: TObject);
    procedure BuildCard(const AMessage: string);
    class function CreateLabel(AParent: TFmxObject; const AText: string;
      AColor: TAlphaColor; AFontSize: Single; ABold: Boolean): TLabel;
  public
    constructor Create(AOwner: TComponent; const AMessage: string); reintroduce;
    destructor Destroy; override;
  end;

type
  TRSignLoading = class
  public
    class function Show(AForm: TForm; const AMessage: string): TRSignLoadingOverlay;
    class procedure Hide(var AOverlay: TRSignLoadingOverlay);
  end;

implementation

{ TRSignLoadingOverlay }

constructor TRSignLoadingOverlay.Create(AOwner: TComponent; const AMessage: string);
begin
  inherited Create(AOwner);
  FTick := 0;
  BuildCard(AMessage);
end;

destructor TRSignLoadingOverlay.Destroy;
begin
  if Assigned(FTimer) then
  begin
    FTimer.Enabled := False;
    FTimer.OnTimer := nil;
  end;
  inherited;
end;

class function TRSignLoadingOverlay.CreateLabel(AParent: TFmxObject;
  const AText: string; AColor: TAlphaColor; AFontSize: Single;
  ABold: Boolean): TLabel;
begin
  Result                          := TLabel.Create(AParent);
  Result.Parent                   := AParent;
  Result.Text                     := AText;
  Result.StyledSettings           := [];
  Result.TextSettings.FontColor   := AColor;
  Result.TextSettings.Font.Size   := AFontSize;
  Result.TextSettings.HorzAlign   := TTextAlign.Center;
  Result.TextSettings.VertAlign   := TTextAlign.Center;

  if ABold then
    Result.TextSettings.Font.Style := [TFontStyle.fsBold]
  else
    Result.TextSettings.Font.Style := [];
end;

procedure TRSignLoadingOverlay.BuildCard(const AMessage: string);
var
  LCard  : TRectangle;
  LName  : TLabel;
  LStatus: TLabel;
  LMsg   : TLabel;
  I      : Integer;
  LDotX  : Single;
  LDotY  : Single;
begin
  // Overlay
  StyleName        := EmptyStr;
  Fill.Kind        := TBrushKind.Solid;
  Fill.Color       := _LOADING_OVERLAY_BACKGROUND;
  Stroke.Kind      := TBrushKind.None;
  Align            := TAlignLayout.Contents;
  HitTest          := True;

  // Card
  LCard                  := TRectangle.Create(Self);
  LCard.Parent           := Self;
  LCard.StyleName        := EmptyStr;
  LCard.Width            := _LOADING_CARD_WIDTH;
  LCard.Height           := _LOADING_CARD_HEIGHT;
  LCard.Align            := TAlignLayout.Center;
  LCard.Fill.Kind        := TBrushKind.Solid;
  LCard.Fill.Color       := _LOADING_CARD_BACKGROUND;
  LCard.Stroke.Kind      := TBrushKind.Solid;
  LCard.Stroke.Color     := _LOADING_CARD_BORDER;
  LCard.Stroke.Thickness := 1.0;
  LCard.XRadius          := 14;
  LCard.YRadius          := 14;

  // Labels
  LName        := CreateLabel(LCard, _APP_NAME, _LOADING_BRAND_NAME_COLOR, 20, True);
  LName.Align  := TAlignLayout.Top;
  LName.Height := 42;

  LStatus        := CreateLabel(LCard, _LOADING_STATUS, _LOADING_STATUS_LABEL_COLOR, 9, False);
  LStatus.Align  := TAlignLayout.Top;
  LStatus.Height := 14;

  LMsg             := CreateLabel(LCard, AMessage, _LOADING_MESSAGE_TEXT_COLOR, 14, False);
  LMsg.Align       := TAlignLayout.Top;
  LMsg.Height      := 30;
  LMsg.Margins.Top := 4;

  // Pontos
  LDotX := (_LOADING_CARD_WIDTH - (3 * _LOADING_DOT_SIZE + 2 * _LOADING_DOT_SPACING)) / 2;
  LDotY := 90 + ((_LOADING_CARD_HEIGHT - 90) / 2) - (_LOADING_DOT_SIZE / 2);

  for I := 0 to 2 do
  begin
    FDots[I]                  := TRectangle.Create(LCard);
    FDots[I].Parent           := LCard;
    FDots[I].StyleName        := EmptyStr;
    FDots[I].Align            := TAlignLayout.None;
    FDots[I].Width            := _LOADING_DOT_SIZE;
    FDots[I].Height           := _LOADING_DOT_SIZE;
    FDots[I].XRadius          := _LOADING_DOT_SIZE / 2;
    FDots[I].YRadius          := _LOADING_DOT_SIZE / 2;
    FDots[I].Fill.Kind        := TBrushKind.Solid;
    FDots[I].Fill.Color       := _LOADING_DOT_COLOR;
    FDots[I].Stroke.Kind      := TBrushKind.None;
    FDots[I].Position.X       := LDotX + I * (_LOADING_DOT_SIZE + _LOADING_DOT_SPACING);
    FDots[I].Position.Y       := LDotY;
    FDots[I].Opacity          := 0.25;
  end;

  // Timer de animação
  FTimer          := TTimer.Create(Self);
  FTimer.Interval := 300;
  FTimer.OnTimer  := OnTick;
  FTimer.Enabled  := True;
end;

procedure TRSignLoadingOverlay.OnTick(Sender: TObject);
var
  I: Integer;
begin
  Inc(FTick);

  // Cicla qual ponto está aceso — padrão sequencial 0 → 1 → 2 → 0
  for I := 0 to 2 do
  begin
    if (FTick mod 3) = I then
      FDots[I].Opacity := 1.0
    else
      FDots[I].Opacity := 0.25;
  end;
end;

{ TRSignLoading }

class function TRSignLoading.Show(AForm: TForm;
  const AMessage: string): TRSignLoadingOverlay;
begin
  Result        := TRSignLoadingOverlay.Create(AForm, AMessage);
  Result.Parent := AForm;
  Result.BringToFront;
  Application.ProcessMessages;
end;

class procedure TRSignLoading.Hide(var AOverlay: TRSignLoadingOverlay);
begin
  if Assigned(AOverlay) then
  begin
    AOverlay.Parent := nil;
    FreeAndNil(AOverlay);
  end;
end;

end.
