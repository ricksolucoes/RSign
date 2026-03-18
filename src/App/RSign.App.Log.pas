unit RSign.App.Log;

interface

uses
  System.SysUtils,
  System.Classes;

type
  TAPPLog = class
  public
    class procedure AdicionarLinha(const ALista: TStrings; const ALinha: string); static;
  end;

implementation

class procedure TAPPLog.AdicionarLinha(const ALista: TStrings; const ALinha: string);
begin
  if ALista = nil then
    Exit;

  ALista.Add(ALinha);
end;

end.
