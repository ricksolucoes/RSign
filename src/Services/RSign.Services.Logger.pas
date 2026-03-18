unit RSign.Services.Logger;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  RSign.Core.Interfaces,
  RSign.Types.Common,
  RSign.Types.Config;

type
  TLoggerService = class(TInterfacedObject, ILoggerService)
  private
    FOnLog: TOnLogEvent;
    FLogFilePath: string;
    function MontarLinhaLog(ANivelLog: TNivelLog; const AOrigem: string; const AMensagem: string; const ADetalheTecnico: string): string;
    procedure EscreverEmArquivo(const ALinhaLog: string);
  protected
    procedure SetOnLog(const AOnLog: TOnLogEvent);
    procedure SetLogFilePath(const ALogFilePath: string);
    procedure Log(ANivelLog: TNivelLog; const AOrigem: string; const AMensagem: string; const ADetalheTecnico: string = '');
    procedure Info(const AOrigem: string; const AMensagem: string);
    procedure Warning(const AOrigem: string; const AMensagem: string; const ADetalheTecnico: string = '');
    procedure Error(const AOrigem: string; const AMensagem: string; const ADetalheTecnico: string = '');
    procedure Debug(const AOrigem: string; const AMensagem: string);
    procedure Success(const AOrigem: string; const AMensagem: string);

    constructor Create;
  public

    class function New : ILoggerService;
  end;

implementation

constructor TLoggerService.Create;
begin
  inherited Create;
  FLogFilePath := TConfiguracaoLog.Default.CaminhoArquivoLog;
end;

procedure TLoggerService.SetOnLog(const AOnLog: TOnLogEvent);
begin
  FOnLog := AOnLog;
end;

procedure TLoggerService.SetLogFilePath(const ALogFilePath: string);
begin
  FLogFilePath := Trim(ALogFilePath);
end;

function TLoggerService.MontarLinhaLog(ANivelLog: TNivelLog; const AOrigem: string; const AMensagem: string; const ADetalheTecnico: string): string;
begin
  Result :=
    FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) +
    ' [' + ANivelLog.ToString + '] ' +
    AOrigem + ' - ' + AMensagem;

  if Trim(ADetalheTecnico) <> '' then
    Result := Result + ' | Detalhe: ' + ADetalheTecnico;
end;

class function TLoggerService.New: ILoggerService;
begin
  Result := Self.Create;
end;

procedure TLoggerService.EscreverEmArquivo(const ALinhaLog: string);
var
  LDiretorioLog: string;
  LEncodingUTF8: TUTF8Encoding;
begin
  if Trim(FLogFilePath) = '' then
    Exit;

  LDiretorioLog := ExtractFileDir(FLogFilePath);
  if Trim(LDiretorioLog) <> '' then
    ForceDirectories(LDiretorioLog);

  LEncodingUTF8 := TUTF8Encoding.Create;
  try
    if not TFile.Exists(FLogFilePath) then
      TFile.WriteAllText(FLogFilePath, ALinhaLog + sLineBreak, LEncodingUTF8)
    else
      TFile.AppendAllText(FLogFilePath, ALinhaLog + sLineBreak, TEncoding.UTF8);
  finally
    LEncodingUTF8.Free;
  end;
end;

procedure TLoggerService.Log(ANivelLog: TNivelLog; const AOrigem: string; const AMensagem: string; const ADetalheTecnico: string = '');
var
  LLinhaLog: string;
begin
  LLinhaLog := MontarLinhaLog(ANivelLog, AOrigem, AMensagem, ADetalheTecnico);
  EscreverEmArquivo(LLinhaLog);

  if Assigned(FOnLog) then
    FOnLog(LLinhaLog);
end;

procedure TLoggerService.Info(const AOrigem: string; const AMensagem: string);
begin
  Log(TNivelLog.Info, AOrigem, AMensagem);
end;

procedure TLoggerService.Warning(const AOrigem: string; const AMensagem: string; const ADetalheTecnico: string = '');
begin
  Log(TNivelLog.Warning, AOrigem, AMensagem, ADetalheTecnico);
end;

procedure TLoggerService.Error(const AOrigem: string; const AMensagem: string; const ADetalheTecnico: string = '');
begin
  Log(TNivelLog.Error, AOrigem, AMensagem, ADetalheTecnico);
end;

procedure TLoggerService.Debug(const AOrigem: string; const AMensagem: string);
begin
  Log(TNivelLog.Debug, AOrigem, AMensagem);
end;

procedure TLoggerService.Success(const AOrigem: string; const AMensagem: string);
begin
  Log(TNivelLog.Success, AOrigem, AMensagem);
end;

end.
