unit RSign.Services.SignTool;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  System.StrUtils,
  System.IOUtils,
  Winapi.Windows,
  RSign.Core.Interfaces,
  RSign.Types.Common,
  RSign.Types.Signing;

type
  TSignToolCandidate = record
    CaminhoArquivo: string;
    VersaoArquivo: string;
    Origem: TOrigemSignTool;
  end;

  TSignToolCandidateArray = array of TSignToolCandidate;

  TSignToolService = class(TInterfacedObject, ISignToolService)
  private
    FLogger: ILoggerService;
    FProcessExecutor: IProcessExecutor;
    function ObterVersaoArquivo(const ACaminhoArquivo: string): string;
    function CompararVersoes(const AVersaoEsquerda: string; const AVersaoDireita: string): Integer;
    function ObterParteVersao(const AVersao: string; AIndice: Integer): Integer;
    function MontarStatusFalha(const AMensagemAmigavel: string; const AMensagemTecnica: string): TStatusSignTool;
    function ValidarExecutavel(const ACaminhoArquivo: string): Boolean;
    function ObterArquiteturaHost: Word;
    function ObterArquiteturaCandidato(const ACaminhoArquivo: string): string;
    function CandidatoCompativelComHost(const ACaminhoArquivo: string): Boolean;
    function ObterPesoArquitetura(const ACaminhoArquivo: string): Integer;
    procedure AdicionarCandidato(var ACandidatos: TSignToolCandidateArray; AProcessados: TStrings; const ACaminhoArquivo: string; AOrigem: TOrigemSignTool);
    procedure LocalizarNoPath(var ACandidatos: TSignToolCandidateArray; AProcessados: TStrings);
    procedure LocalizarNosWindowsKits(var ACandidatos: TSignToolCandidateArray; AProcessados: TStrings);
    function SelecionarMelhorCandidato(const ACandidatos: TSignToolCandidateArray; AUsarVersaoMaisNova: Boolean): TSignToolCandidate;
    procedure RemoverCandidato(var ACandidatos: TSignToolCandidateArray; AIndice: Integer);
    function LocalizarIndiceCandidato(const ACandidatos: TSignToolCandidateArray; const ACaminhoArquivo: string): Integer;
  protected
    constructor Create(const ALogger: ILoggerService; const AProcessExecutor: IProcessExecutor);
    function Localizar(const AConfiguracaoAssinatura: TConfiguracaoAssinatura): TStatusSignTool;
  public
    class function New(const ALogger: ILoggerService; const AProcessExecutor: IProcessExecutor): ISignToolService;
  end;

implementation

uses
  RSign.Core.Constants;

constructor TSignToolService.Create(const ALogger: ILoggerService; const AProcessExecutor: IProcessExecutor);
begin
  inherited Create;
  FLogger := ALogger;
  FProcessExecutor := AProcessExecutor;
end;

class function TSignToolService.New(const ALogger: ILoggerService; const AProcessExecutor: IProcessExecutor): ISignToolService;
begin
  Result := Self.Create(ALogger, AProcessExecutor);
end;

function TSignToolService.ObterVersaoArquivo(const ACaminhoArquivo: string): string;
var
  LTamanhoInfo: DWORD;
  LHandleInfo: DWORD;
  LBuffer: Pointer;
  LTamanhoBuffer: UINT;
  LVersaoInfo: PVSFixedFileInfo;
begin
  Result := '';
  LTamanhoInfo := GetFileVersionInfoSize(PChar(ACaminhoArquivo), LHandleInfo);

  if LTamanhoInfo = 0 then
    Exit;

  GetMem(LBuffer, LTamanhoInfo);
  try
    if not GetFileVersionInfo(PChar(ACaminhoArquivo), 0, LTamanhoInfo, LBuffer) then
      Exit;

    if not VerQueryValue(LBuffer, '\', Pointer(LVersaoInfo), LTamanhoBuffer) then
      Exit;

    Result :=
      IntToStr(HiWord(LVersaoInfo.dwFileVersionMS)) + '.' +
      IntToStr(LoWord(LVersaoInfo.dwFileVersionMS)) + '.' +
      IntToStr(HiWord(LVersaoInfo.dwFileVersionLS)) + '.' +
      IntToStr(LoWord(LVersaoInfo.dwFileVersionLS));
  finally
    FreeMem(LBuffer);
  end;
end;

function TSignToolService.ObterParteVersao(const AVersao: string; AIndice: Integer): Integer;
var
  LPartesVersao: TStringDynArray;
begin
  Result := 0;
  LPartesVersao := SplitString(AVersao, '.');

  if (AIndice >= Low(LPartesVersao)) and (AIndice <= High(LPartesVersao)) then
    Result := StrToIntDef(Trim(LPartesVersao[AIndice]), 0);
end;

function TSignToolService.CompararVersoes(const AVersaoEsquerda: string; const AVersaoDireita: string): Integer;
var
  LIndice: Integer;
  LParteEsquerda: Integer;
  LParteDireita: Integer;
begin
  Result := 0;

  for LIndice := 0 to 3 do
  begin
    LParteEsquerda := ObterParteVersao(AVersaoEsquerda, LIndice);
    LParteDireita := ObterParteVersao(AVersaoDireita, LIndice);

    if LParteEsquerda > LParteDireita then
      Exit(1);

    if LParteEsquerda < LParteDireita then
      Exit(-1);
  end;
end;

function TSignToolService.MontarStatusFalha(const AMensagemAmigavel: string; const AMensagemTecnica: string): TStatusSignTool;
begin
  Result := TStatusSignTool.Empty;
  Result.MensagemAmigavel := AMensagemAmigavel;
  Result.MensagemTecnica := AMensagemTecnica;
end;

function TSignToolService.ValidarExecutavel(const ACaminhoArquivo: string): Boolean;
var
  LResultadoProcesso: TResultadoProcessoExterno;
  LTextoRetorno: string;
begin
  Result := False;

  if Trim(ACaminhoArquivo) = '' then
    Exit;

  if not TFile.Exists(ACaminhoArquivo) then
    Exit;

  if not Assigned(FProcessExecutor) then
    Exit(True);

  try
    LResultadoProcesso := FProcessExecutor.Execute(
      ACaminhoArquivo,
      '/?',
      ExtractFilePath(ACaminhoArquivo),
      5000
    );

    LTextoRetorno := UpperCase(LResultadoProcesso.SaidaPadrao + ' ' + LResultadoProcesso.ErroPadrao);
    Result := LResultadoProcesso.Sucesso or (Pos('SIGNTOOL', LTextoRetorno) > 0);
  except
    on E: Exception do
    begin
      Result := False;

      if Assigned(FLogger) then
        FLogger.Debug('SignTool', 'Falha ao validar o executável do SignTool. ' + E.Message);
    end;
  end;
end;

function TSignToolService.ObterArquiteturaHost: Word;
var
  LSystemInfo: TSystemInfo;
begin
  GetNativeSystemInfo(LSystemInfo);
  Result := LSystemInfo.wProcessorArchitecture;
end;

function TSignToolService.ObterArquiteturaCandidato(const ACaminhoArquivo: string): string;
var
  LCaminhoNormalizado: string;
begin
  LCaminhoNormalizado := '\' + LowerCase(StringReplace(ACaminhoArquivo, '/', '\', [rfReplaceAll])) + '\';

  if Pos('\arm64\', LCaminhoNormalizado) > 0 then
    Exit('arm64');

  if Pos('\arm\', LCaminhoNormalizado) > 0 then
    Exit('arm');

  if Pos('\x64\', LCaminhoNormalizado) > 0 then
    Exit('x64');

  if Pos('\x86\', LCaminhoNormalizado) > 0 then
    Exit('x86');

  Result := '';
end;

function TSignToolService.CandidatoCompativelComHost(const ACaminhoArquivo: string): Boolean;
var
  LArquiteturaHost: Word;
  LArquiteturaCandidato: string;
begin
  Result := True;
  LArquiteturaHost := ObterArquiteturaHost();
  LArquiteturaCandidato := ObterArquiteturaCandidato(ACaminhoArquivo);

  if LArquiteturaCandidato = '' then
    Exit;

  case LArquiteturaHost of
    PROCESSOR_ARCHITECTURE_AMD64:
      Result := SameText(LArquiteturaCandidato, 'x64') or SameText(LArquiteturaCandidato, 'x86');

    PROCESSOR_ARCHITECTURE_INTEL:
      Result := SameText(LArquiteturaCandidato, 'x86');

    _PROCESSOR_ARCHITECTURE_ARM64:
      Result := SameText(LArquiteturaCandidato, 'arm64') or SameText(LArquiteturaCandidato, 'arm');

    PROCESSOR_ARCHITECTURE_ARM:
      Result := SameText(LArquiteturaCandidato, 'arm');
  end;
end;

function TSignToolService.ObterPesoArquitetura(const ACaminhoArquivo: string): Integer;
var
  LArquiteturaHost: Word;
  LArquiteturaCandidato: string;
begin
  Result := 0;
  LArquiteturaHost := ObterArquiteturaHost();
  LArquiteturaCandidato := ObterArquiteturaCandidato(ACaminhoArquivo);

  case LArquiteturaHost of
    PROCESSOR_ARCHITECTURE_AMD64:
      begin
        if SameText(LArquiteturaCandidato, 'x64') then
          Exit(20);

        if SameText(LArquiteturaCandidato, 'x86') then
          Exit(10);
      end;

    PROCESSOR_ARCHITECTURE_INTEL:
      begin
        if SameText(LArquiteturaCandidato, 'x86') then
          Exit(20);
      end;

    _PROCESSOR_ARCHITECTURE_ARM64:
      begin
        if SameText(LArquiteturaCandidato, 'arm64') then
          Exit(20);

        if SameText(LArquiteturaCandidato, 'arm') then
          Exit(10);
      end;

    PROCESSOR_ARCHITECTURE_ARM:
      begin
        if SameText(LArquiteturaCandidato, 'arm') then
          Exit(20);
      end;
  end;
end;

procedure TSignToolService.AdicionarCandidato(var ACandidatos: TSignToolCandidateArray; AProcessados: TStrings; const ACaminhoArquivo: string; AOrigem: TOrigemSignTool);
var
  LCandidato: TSignToolCandidate;
  LCaminhoNormalizado: string;
begin
  LCaminhoNormalizado := Trim(ACaminhoArquivo);

  if LCaminhoNormalizado = '' then
    Exit;

  if not TFile.Exists(LCaminhoNormalizado) then
    Exit;

  if Assigned(AProcessados) then
  begin
    if AProcessados.IndexOf(AnsiLowerCase(LCaminhoNormalizado)) >= 0 then
      Exit;

    AProcessados.Add(AnsiLowerCase(LCaminhoNormalizado));
  end;

  if not CandidatoCompativelComHost(LCaminhoNormalizado) then
  begin
    if Assigned(FLogger) then
      FLogger.Debug('SignTool', 'Candidato ignorado por arquitetura incompatível com o host: ' + LCaminhoNormalizado);

    Exit;
  end;

  if LocalizarIndiceCandidato(ACandidatos, LCaminhoNormalizado) >= 0 then
    Exit;

  LCandidato.CaminhoArquivo := LCaminhoNormalizado;
  LCandidato.VersaoArquivo := ObterVersaoArquivo(LCaminhoNormalizado);
  LCandidato.Origem := AOrigem;

  SetLength(ACandidatos, Length(ACandidatos) + 1);
  ACandidatos[High(ACandidatos)] := LCandidato;
end;

procedure TSignToolService.LocalizarNoPath(var ACandidatos: TSignToolCandidateArray; AProcessados: TStrings);
var
  LCaminhoPath: string;
  LDiretorios: TStringList;
  LIndice: Integer;
  LCaminhoCandidato: string;
begin
  LCaminhoPath := GetEnvironmentVariable('PATH');

  if Trim(LCaminhoPath) = '' then
    Exit;

  LDiretorios := TStringList.Create;
  try
    ExtractStrings([';'], [], PChar(LCaminhoPath), LDiretorios);

    for LIndice := 0 to LDiretorios.Count - 1 do
    begin
      LCaminhoCandidato := TPath.Combine(Trim(LDiretorios[LIndice]), 'signtool.exe');
      AdicionarCandidato(ACandidatos, AProcessados, LCaminhoCandidato, TOrigemSignTool.Automatico);
    end;
  finally
    LDiretorios.Free;
  end;
end;

procedure TSignToolService.LocalizarNosWindowsKits(var ACandidatos: TSignToolCandidateArray; AProcessados: TStrings);
var
  LDiretoriosBase: array[0..2] of string;
  LDiretorioBase: string;
  LArquivosEncontrados: TStringDynArray;
  LArquivoEncontrado: string;
begin
  LDiretoriosBase[0] := TPath.Combine(GetEnvironmentVariable('ProgramFiles(x86)'), 'Windows Kits');
  LDiretoriosBase[1] := TPath.Combine(GetEnvironmentVariable('ProgramFiles'), 'Windows Kits');
  LDiretoriosBase[2] := 'C:\Program Files (x86)\Windows Kits';

  for LDiretorioBase in LDiretoriosBase do
  begin
    if Trim(LDiretorioBase) = '' then
      Continue;

    if not TDirectory.Exists(LDiretorioBase) then
      Continue;

    try
      LArquivosEncontrados := TDirectory.GetFiles(LDiretorioBase, 'signtool.exe', TSearchOption.soAllDirectories);

      for LArquivoEncontrado in LArquivosEncontrados do
        AdicionarCandidato(ACandidatos, AProcessados, LArquivoEncontrado, TOrigemSignTool.Automatico);
    except
      on E: Exception do
      begin
        if Assigned(FLogger) then
          FLogger.Warning('SignTool', 'Falha ao consultar o diretório do Windows Kits.', E.Message);
      end;
    end;
  end;
end;

function TSignToolService.SelecionarMelhorCandidato(const ACandidatos: TSignToolCandidateArray; AUsarVersaoMaisNova: Boolean): TSignToolCandidate;
var
  LIndice: Integer;
  LComparacaoVersao: Integer;
  LPesoSelecionado: Integer;
  LPesoAtual: Integer;
begin
  Result.CaminhoArquivo := '';
  Result.VersaoArquivo := '';
  Result.Origem := TOrigemSignTool.NaoDefinido;

  if Length(ACandidatos) = 0 then
    Exit;

  Result := ACandidatos[0];

  for LIndice := 1 to High(ACandidatos) do
  begin
    if AUsarVersaoMaisNova then
    begin
      LComparacaoVersao := CompararVersoes(ACandidatos[LIndice].VersaoArquivo, Result.VersaoArquivo);

      if LComparacaoVersao > 0 then
      begin
        Result := ACandidatos[LIndice];
        Continue;
      end;

      if LComparacaoVersao < 0 then
        Continue;
    end;

    LPesoAtual := ObterPesoArquitetura(ACandidatos[LIndice].CaminhoArquivo);
    LPesoSelecionado := ObterPesoArquitetura(Result.CaminhoArquivo);

    if LPesoAtual > LPesoSelecionado then
      Result := ACandidatos[LIndice];
  end;
end;

procedure TSignToolService.RemoverCandidato(var ACandidatos: TSignToolCandidateArray; AIndice: Integer);
var
  LIndice: Integer;
begin
  if (AIndice < Low(ACandidatos)) or (AIndice > High(ACandidatos)) then
    Exit;

  for LIndice := AIndice to High(ACandidatos) - 1 do
    ACandidatos[LIndice] := ACandidatos[LIndice + 1];

  SetLength(ACandidatos, Length(ACandidatos) - 1);
end;

function TSignToolService.LocalizarIndiceCandidato(const ACandidatos: TSignToolCandidateArray; const ACaminhoArquivo: string): Integer;
var
  LIndice: Integer;
begin
  Result := -1;

  for LIndice := Low(ACandidatos) to High(ACandidatos) do
  begin
    if SameText(Trim(ACandidatos[LIndice].CaminhoArquivo), Trim(ACaminhoArquivo)) then
      Exit(LIndice);
  end;
end;

function TSignToolService.Localizar(const AConfiguracaoAssinatura: TConfiguracaoAssinatura): TStatusSignTool;
var
  LCandidatos: TSignToolCandidateArray;
  LCandidatoSelecionado: TSignToolCandidate;
  LIndiceCandidato: Integer;
  LProcessados: TStringList;
begin
  Result := TStatusSignTool.Empty;
  SetLength(LCandidatos, 0);
  LProcessados := TStringList.Create;
  try
    LProcessados.CaseSensitive := False;
    LProcessados.Sorted := False;
    LProcessados.Duplicates := dupIgnore;

    if LProcessados.IndexOf(AnsiLowerCase(Trim(AConfiguracaoAssinatura.CaminhoManualSignTool))) < 0 then
      LProcessados.Add(AnsiLowerCase(Trim(AConfiguracaoAssinatura.CaminhoManualSignTool)));

    if Trim(AConfiguracaoAssinatura.CaminhoManualSignTool) <> '' then
    begin
      if Assigned(FLogger) then
        FLogger.Debug('SignTool', 'Validando caminho manual do SignTool: ' + AConfiguracaoAssinatura.CaminhoManualSignTool);

      if not TFile.Exists(AConfiguracaoAssinatura.CaminhoManualSignTool) then
      begin
        if not AConfiguracaoAssinatura.LocalizarAutomaticamenteSignTool then
        begin
          Result := MontarStatusFalha(
            'O caminho manual do SignTool não foi encontrado.',
            'Arquivo não encontrado: ' + AConfiguracaoAssinatura.CaminhoManualSignTool
          );
          Exit;
        end;
      end
      else
      begin
        if not CandidatoCompativelComHost(AConfiguracaoAssinatura.CaminhoManualSignTool) then
        begin
          if not AConfiguracaoAssinatura.LocalizarAutomaticamenteSignTool then
          begin
            Result := MontarStatusFalha(
              'O SignTool informado manualmente não é compatível com o Windows atual.',
              'Arquitetura incompatível para o executável: ' + AConfiguracaoAssinatura.CaminhoManualSignTool
            );
            Exit;
          end;

          if Assigned(FLogger) then
            FLogger.Debug('SignTool', 'Caminho manual ignorado por arquitetura incompatível com o host: ' + AConfiguracaoAssinatura.CaminhoManualSignTool);
        end
        else if not ValidarExecutavel(AConfiguracaoAssinatura.CaminhoManualSignTool) then
        begin
          if not AConfiguracaoAssinatura.LocalizarAutomaticamenteSignTool then
          begin
            Result := MontarStatusFalha(
              'O SignTool informado manualmente não pôde ser validado.',
              'Falha ao validar o executável: ' + AConfiguracaoAssinatura.CaminhoManualSignTool
            );
            Exit;
          end;
        end
        else
        begin
          Result.Encontrado := True;
          Result.Origem := TOrigemSignTool.Manual;
          Result.VersaoDetectada := ObterVersaoArquivo(AConfiguracaoAssinatura.CaminhoManualSignTool);
          Result.CaminhoFinal := AConfiguracaoAssinatura.CaminhoManualSignTool;
          Result.MensagemAmigavel := 'SignTool localizado com sucesso no caminho manual.';
          Result.MensagemTecnica := 'SignTool validado com sucesso pelo caminho manual.';

          if Assigned(FLogger) then
            FLogger.Success('SignTool', 'SignTool localizado com sucesso no caminho manual.');

          Exit;
        end;
      end;
    end;

    if not AConfiguracaoAssinatura.LocalizarAutomaticamenteSignTool then
    begin
      Result := MontarStatusFalha(
        'A localização automática do SignTool está desativada.',
        'Nenhum caminho manual válido foi informado e a localização automática está desativada.'
      );
      Exit;
    end;

    if Assigned(FLogger) then
      FLogger.Debug('SignTool', 'Iniciando a localização automática do SignTool.');

    LocalizarNoPath(LCandidatos, LProcessados);
    LocalizarNosWindowsKits(LCandidatos, LProcessados);

    if Length(LCandidatos) = 0 then
    begin
      Result := MontarStatusFalha(
        'Não foi possível localizar o SignTool no ambiente atual.',
        'Nenhum candidato compatível do SignTool foi encontrado no PATH ou no Windows Kits.'
      );
      Exit;
    end;

    while Length(LCandidatos) > 0 do
    begin
      LCandidatoSelecionado := SelecionarMelhorCandidato(LCandidatos, AConfiguracaoAssinatura.UsarVersaoMaisNova);

      if ValidarExecutavel(LCandidatoSelecionado.CaminhoArquivo) then
      begin
        Result.Encontrado := True;
        Result.Origem := LCandidatoSelecionado.Origem;
        Result.VersaoDetectada := LCandidatoSelecionado.VersaoArquivo;
        Result.CaminhoFinal := LCandidatoSelecionado.CaminhoArquivo;
        Result.MensagemAmigavel := 'SignTool localizado com sucesso.';
        Result.MensagemTecnica := 'SignTool localizado e validado com sucesso.';

        if Assigned(FLogger) then
          FLogger.Success('SignTool', 'SignTool localizado com sucesso.');

        Exit;
      end;

      if Assigned(FLogger) then
        FLogger.Debug('SignTool', 'Candidato do SignTool removido após falha de validação: ' + LCandidatoSelecionado.CaminhoArquivo);

      LIndiceCandidato := LocalizarIndiceCandidato(LCandidatos, LCandidatoSelecionado.CaminhoArquivo);
      RemoverCandidato(LCandidatos, LIndiceCandidato);
    end;

    Result := MontarStatusFalha(
      'O SignTool foi encontrado, mas nenhum candidato pôde ser validado.',
      'Todos os candidatos localizados para o SignTool falharam durante a validação.'
    );
  finally
    LProcessados.Free;
  end;
end;

end.

