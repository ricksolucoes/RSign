unit RSign.Services.UserDecision;

interface

uses
  System.SysUtils,
  System.UITypes,
  FMX.DialogService.Sync,
  RSign.Core.Interfaces;

type
  TUserDecisionService = class(TInterfacedObject, IUserDecisionService)
  protected
    constructor Create;
    function Confirmar(const ATitulo: string; const AMensagem: string; const ADetalheTecnico: string = ''): Boolean;
  public
    class function New: IUserDecisionService;
  end;

implementation

constructor TUserDecisionService.Create;
begin
  inherited Create;
end;

class function TUserDecisionService.New: IUserDecisionService;
begin
  Result := Self.Create;
end;

function TUserDecisionService.Confirmar(const ATitulo: string; const AMensagem: string; const ADetalheTecnico: string = ''): Boolean;
var
  LMensagemCompleta: string;
begin
  LMensagemCompleta := Trim(ATitulo);

  if LMensagemCompleta <> '' then
    LMensagemCompleta := LMensagemCompleta + sLineBreak + sLineBreak;

  LMensagemCompleta := LMensagemCompleta + Trim(AMensagem);

  if Trim(ADetalheTecnico) <> '' then
    LMensagemCompleta := LMensagemCompleta + sLineBreak + sLineBreak + 'Detalhe técnico:' + sLineBreak + ADetalheTecnico;

  Result :=
    TDialogServiceSync.MessageDialog(
      LMensagemCompleta,
      TMsgDlgType.mtConfirmation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
      TMsgDlgBtn.mbNo,
      0
    ) = mrYes;
end;

end.
