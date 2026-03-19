unit RSign.Services.ProcessExecutor;

interface

uses
  System.SysUtils,
  Winapi.Windows,
  RSign.Core.Interfaces,
  RSign.Types.Common;

type
  TProcessExecutorService = class(TInterfacedObject, IProcessExecutor)
  private
    FLogger: ILoggerService;
    function MontarComandoExecutado(const AExecutablePath: string; const AParameters: string): string;
    function CriarNomeTemporarioSeguro: string;
    function CriarArquivoTemporario(const ADiretorioBase: string; var AHandle: THandle): string;
    function LerConteudoArquivo(const ACaminhoArquivo: string): string;
    procedure RemoverArquivoTemporario(const ACaminhoArquivo: string);
  protected
    constructor Create(const ALogger: ILoggerService);
    function Execute(const AExecutablePath: string; const AParameters: string; const AWorkingDirectory: string; ATimeoutMiliseconds: Cardinal): TResultadoProcessoExterno;
  public
    class function New(const ALogger: ILoggerService): IProcessExecutor;
  end;

implementation

uses
  System.Classes,
  System.IOUtils;

constructor TProcessExecutorService.Create(const ALogger: ILoggerService);
begin
  inherited Create;
  FLogger := ALogger;
end;

class function TProcessExecutorService.New(const ALogger: ILoggerService): IProcessExecutor;
begin
  Result := Self.Create(ALogger);
end;

function TProcessExecutorService.MontarComandoExecutado(const AExecutablePath: string; const AParameters: string): string;
begin
  Result := '"' + Trim(AExecutablePath) + '"';

  if Trim(AParameters) <> '' then
    Result := Result + ' ' + Trim(AParameters);
end;

function TProcessExecutorService.CriarNomeTemporarioSeguro: string;
var
  LGuid: TGUID;
begin
  CreateGUID(LGuid);
  Result := GUIDToString(LGuid);
  Result := StringReplace(Result, '{', '', [rfReplaceAll]);
  Result := StringReplace(Result, '}', '', [rfReplaceAll]);
  Result := StringReplace(Result, '-', '', [rfReplaceAll]);
end;

function TProcessExecutorService.CriarArquivoTemporario(const ADiretorioBase: string; var AHandle: THandle): string;
var
  LAtributosSeguranca: TSecurityAttributes;
  LCaminhoArquivo: string;
begin
  FillChar(LAtributosSeguranca, SizeOf(LAtributosSeguranca), 0);
  LAtributosSeguranca.nLength := SizeOf(LAtributosSeguranca);
  LAtributosSeguranca.bInheritHandle := True;
  LAtributosSeguranca.lpSecurityDescriptor := nil;

  LCaminhoArquivo := TPath.Combine(ADiretorioBase, CriarNomeTemporarioSeguro + '.tmp');

  AHandle := CreateFile(
    PChar(LCaminhoArquivo),
    GENERIC_READ or GENERIC_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE,
    @LAtributosSeguranca,
    CREATE_ALWAYS,
    FILE_ATTRIBUTE_TEMPORARY,
    0
  );

  if AHandle = INVALID_HANDLE_VALUE then
    raise Exception.CreateFmt('Não foi possível criar o arquivo temporário: %s', [LCaminhoArquivo]);

  Result := LCaminhoArquivo;
end;

function TProcessExecutorService.LerConteudoArquivo(const ACaminhoArquivo: string): string;
var
  LBytes: TBytes;
  LBytesSemBom: TBytes;
  LTamanhoSemBom: Integer;
begin
  Result := '';

  if not TFile.Exists(ACaminhoArquivo) then
    Exit;

  LBytes := TFile.ReadAllBytes(ACaminhoArquivo);

  if Length(LBytes) = 0 then
    Exit;

  if (Length(LBytes) >= 3) and
     (LBytes[0] = $EF) and
     (LBytes[1] = $BB) and
     (LBytes[2] = $BF) then
  begin
    LTamanhoSemBom := Length(LBytes) - 3;
    SetLength(LBytesSemBom, LTamanhoSemBom);

    if LTamanhoSemBom > 0 then
      Move(LBytes[3], LBytesSemBom[0], LTamanhoSemBom);

    Result := TEncoding.UTF8.GetString(LBytesSemBom);
    Exit;
  end;

  Result := TEncoding.Default.GetString(LBytes);
end;

procedure TProcessExecutorService.RemoverArquivoTemporario(const ACaminhoArquivo: string);
begin
  if Trim(ACaminhoArquivo) = '' then
    Exit;

  if not TFile.Exists(ACaminhoArquivo) then
    Exit;

  TFile.Delete(ACaminhoArquivo);
end;

function TProcessExecutorService.Execute(const AExecutablePath: string; const AParameters: string; const AWorkingDirectory: string; ATimeoutMiliseconds: Cardinal): TResultadoProcessoExterno;
var
  LStartupInfo: TStartupInfo;
  LProcessInformation: TProcessInformation;
  LCommandLine: string;
  LDiretorioTrabalho: string;
  LCaminhoExecutavel: string;
  LDiretorioTemporario: string;
  LArquivoSaidaPadrao: string;
  LArquivoErroPadrao: string;
  LHandleSaidaPadrao: THandle;
  LHandleErroPadrao: THandle;
  LCodigoEspera: DWORD;
  LCodigoSaidaProcesso: Cardinal;
  LCriadoComSucesso: Boolean;
  LPonteiroDiretorioTrabalho: PChar;
begin
  Result := TResultadoProcessoExterno.Empty;
  LHandleSaidaPadrao := INVALID_HANDLE_VALUE;
  LHandleErroPadrao := INVALID_HANDLE_VALUE;
  LArquivoSaidaPadrao := '';
  LArquivoErroPadrao := '';
  LPonteiroDiretorioTrabalho := nil;

  LCaminhoExecutavel := Trim(AExecutablePath);
  LDiretorioTrabalho := Trim(AWorkingDirectory);

  if LCaminhoExecutavel = '' then
  begin
    Result.ErroPadrao := 'Nenhum executável foi informado para execução.';
    Exit;
  end;

  if ATimeoutMiliseconds = 0 then
    ATimeoutMiliseconds := INFINITE;

  LCommandLine := MontarComandoExecutado(LCaminhoExecutavel, AParameters);
  Result.ComandoExecutado := LCommandLine;

  if Trim(LDiretorioTrabalho) <> '' then
    LPonteiroDiretorioTrabalho := PChar(LDiretorioTrabalho);

  LDiretorioTemporario := TPath.Combine(TPath.GetTempPath, 'RSign');
  ForceDirectories(LDiretorioTemporario);

  if Assigned(FLogger) then
    FLogger.Debug('ProcessExecutor', 'Executando comando: ' + LCommandLine);

  try
    LArquivoSaidaPadrao := CriarArquivoTemporario(LDiretorioTemporario, LHandleSaidaPadrao);
    LArquivoErroPadrao := CriarArquivoTemporario(LDiretorioTemporario, LHandleErroPadrao);

    FillChar(LStartupInfo, SizeOf(LStartupInfo), 0);
    LStartupInfo.cb := SizeOf(LStartupInfo);
    LStartupInfo.dwFlags := STARTF_USESTDHANDLES;
    LStartupInfo.hStdInput := GetStdHandle(STD_INPUT_HANDLE);
    LStartupInfo.hStdOutput := LHandleSaidaPadrao;
    LStartupInfo.hStdError := LHandleErroPadrao;

    FillChar(LProcessInformation, SizeOf(LProcessInformation), 0);

    UniqueString(LCommandLine);

    LCriadoComSucesso := CreateProcess(
      nil,
      PChar(LCommandLine),
      nil,
      nil,
      True,
      CREATE_NO_WINDOW,
      nil,
      LPonteiroDiretorioTrabalho,
      LStartupInfo,
      LProcessInformation
    );

    if not LCriadoComSucesso then
    begin
      Result.CodigoSaida := GetLastError;
      Result.ErroPadrao := SysErrorMessage(Result.CodigoSaida);

      if Assigned(FLogger) then
        FLogger.Error('ProcessExecutor', 'Falha ao iniciar o processo.', Result.ErroPadrao);

      Exit;
    end;

    CloseHandle(LProcessInformation.hThread);

    LCodigoEspera := WaitForSingleObject(LProcessInformation.hProcess, ATimeoutMiliseconds);

    if LCodigoEspera = WAIT_TIMEOUT then
    begin
      TerminateProcess(LProcessInformation.hProcess, Cardinal(ERROR_TIMEOUT));
      WaitForSingleObject(LProcessInformation.hProcess, 5000);
      Result.CodigoSaida := ERROR_TIMEOUT;
      Result.ErroPadrao := 'A execução do processo excedeu o tempo limite configurado.';

      if Assigned(FLogger) then
        FLogger.Warning('ProcessExecutor', 'Processo encerrado por timeout.', Result.ComandoExecutado);
    end
    else
    begin
      GetExitCodeProcess(LProcessInformation.hProcess, LCodigoSaidaProcesso);
      Result.CodigoSaida := Integer(LCodigoSaidaProcesso);
    end;

    CloseHandle(LProcessInformation.hProcess);
    LProcessInformation.hProcess := 0;

    if LHandleSaidaPadrao <> INVALID_HANDLE_VALUE then
    begin
      CloseHandle(LHandleSaidaPadrao);
      LHandleSaidaPadrao := INVALID_HANDLE_VALUE;
    end;

    if LHandleErroPadrao <> INVALID_HANDLE_VALUE then
    begin
      CloseHandle(LHandleErroPadrao);
      LHandleErroPadrao := INVALID_HANDLE_VALUE;
    end;

    Result.SaidaPadrao := Trim(LerConteudoArquivo(LArquivoSaidaPadrao));
    Result.ErroPadrao := Trim(LerConteudoArquivo(LArquivoErroPadrao));
    Result.Sucesso := (LCodigoEspera <> WAIT_TIMEOUT) and (Result.CodigoSaida = 0);

    if Assigned(FLogger) then
    begin
      if Result.Sucesso then
        FLogger.Success('ProcessExecutor', 'Processo executado com sucesso.')
      else
        FLogger.Warning('ProcessExecutor', 'Processo executado com falha.', 'Código de saída: ' + IntToStr(Result.CodigoSaida));

      if Trim(Result.SaidaPadrao) <> '' then
        FLogger.Debug('ProcessExecutor', 'STDOUT: ' + Result.SaidaPadrao);

      if Trim(Result.ErroPadrao) <> '' then
        FLogger.Debug('ProcessExecutor', 'STDERR: ' + Result.ErroPadrao);
    end;
  finally
    if LHandleSaidaPadrao <> INVALID_HANDLE_VALUE then
      CloseHandle(LHandleSaidaPadrao);

    if LHandleErroPadrao <> INVALID_HANDLE_VALUE then
      CloseHandle(LHandleErroPadrao);

    RemoverArquivoTemporario(LArquivoSaidaPadrao);
    RemoverArquivoTemporario(LArquivoErroPadrao);
  end;
end;

end.

