unit RSign.Services.FileSigning;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  System.StrUtils,
  System.IOUtils,
  RSign.Core.Constants,
  RSign.Core.Interfaces,
  RSign.Types.Config,
  RSign.Types.Signing;

type
  TFileSigningService = class(TInterfacedObject, IFileSigningService)
  private
    FLogger: ILoggerService;
    function ExtensaoSuportada(const AExtensao: string): Boolean;
    function PodeAbrirArquivoParaLeituraEscrita(const ACaminhoArquivo: string): Boolean;
    function MontarCaminhoBackupOld(const ACaminhoArquivo: string): string;
    function MontarCaminhoArquivoAssinadoFinal(const ACaminhoArquivo: string; const AConfiguracao: TConfiguracaoAplicacao): string;
    function PrepararItemArquivo(const ACaminhoArquivo: string; const AConfiguracao: TConfiguracaoAplicacao): TItemArquivoAssinatura;
    procedure AdicionarItem(var AItens: TItensArquivoAssinatura; const AItem: TItemArquivoAssinatura);
    procedure AdicionarItemInvalido(var AItens: TItensArquivoAssinatura; const ACaminhoArquivo: string; const AMotivoBloqueio: string);
    procedure PrepararArquivoUnico(var AItens: TItensArquivoAssinatura; const AConfiguracao: TConfiguracaoAplicacao);
    procedure PrepararLote(var AItens: TItensArquivoAssinatura; const AConfiguracao: TConfiguracaoAplicacao);
  protected
    constructor Create(const ALogger: ILoggerService);
    function PrepararArquivos(const AConfiguracao: TConfiguracaoAplicacao): TItensArquivoAssinatura;
  public
    class function New(const ALogger: ILoggerService): IFileSigningService;
  end;

implementation

uses
  RSign.Types.Common;

constructor TFileSigningService.Create(const ALogger: ILoggerService);
begin
  inherited Create;
  FLogger := ALogger;
end;

class function TFileSigningService.New(const ALogger: ILoggerService): IFileSigningService;
begin
  Result := Self.Create(ALogger);
end;

function TFileSigningService.ExtensaoSuportada(const AExtensao: string): Boolean;
var
  LListaExtensoes: TStringDynArray;
  LIndice: Integer;
  LExtensaoNormalizada: string;
begin
  Result := False;
  LExtensaoNormalizada := LowerCase(Trim(AExtensao));

  if LExtensaoNormalizada = '' then
    Exit;

  LListaExtensoes := SplitString(LowerCase(_SUPPORTED_EXTENSIONS), ';');

  for LIndice := Low(LListaExtensoes) to High(LListaExtensoes) do
  begin
    if SameText(Trim(LListaExtensoes[LIndice]), LExtensaoNormalizada) then
      Exit(True);
  end;
end;

function TFileSigningService.PodeAbrirArquivoParaLeituraEscrita(const ACaminhoArquivo: string): Boolean;
var
  LArquivo: TFileStream;
begin
  Result := False;

  if not TFile.Exists(ACaminhoArquivo) then
    Exit;

  try
    LArquivo := TFileStream.Create(ACaminhoArquivo, fmOpenReadWrite or fmShareExclusive);
    try
      Result := True;
    finally
      LArquivo.Free;
    end;
  except
    Result := False;
  end;
end;

function TFileSigningService.MontarCaminhoBackupOld(const ACaminhoArquivo: string): string;
var
  LDiretorioArquivo: string;
  LNomeSemExtensao: string;
  LExtensaoArquivo: string;
begin
  LDiretorioArquivo := ExtractFilePath(ACaminhoArquivo);
  LNomeSemExtensao := ChangeFileExt(ExtractFileName(ACaminhoArquivo), '');
  LExtensaoArquivo := ExtractFileExt(ACaminhoArquivo);

  Result := TPath.Combine(LDiretorioArquivo, LNomeSemExtensao + '_OLD' + LExtensaoArquivo);
end;

function TFileSigningService.MontarCaminhoArquivoAssinadoFinal(const ACaminhoArquivo: string; const AConfiguracao: TConfiguracaoAplicacao): string;
begin
  if AConfiguracao.Caminhos.UsarMesmoDiretorioDoOriginal or (Trim(AConfiguracao.Caminhos.DiretorioSaida) = '') then
    Exit(ACaminhoArquivo);

  Result := TPath.Combine(AConfiguracao.Caminhos.DiretorioSaida, ExtractFileName(ACaminhoArquivo));
end;

function TFileSigningService.PrepararItemArquivo(const ACaminhoArquivo: string; const AConfiguracao: TConfiguracaoAplicacao): TItemArquivoAssinatura;
begin
  Result := TItemArquivoAssinatura.Empty;
  Result.CaminhoOriginal := Trim(ACaminhoArquivo);
  Result.NomeArquivo := ExtractFileName(Result.CaminhoOriginal);
  Result.Extensao := LowerCase(ExtractFileExt(Result.CaminhoOriginal));
  Result.CaminhoArquivoAssinadoFinal := MontarCaminhoArquivoAssinadoFinal(Result.CaminhoOriginal, AConfiguracao);

  if AConfiguracao.Caminhos.UsarMesmoDiretorioDoOriginal then
    Result.CaminhoBackupOld := MontarCaminhoBackupOld(Result.CaminhoOriginal)
  else
    Result.CaminhoBackupOld := '';

  if Result.CaminhoOriginal = '' then
  begin
    Result.MotivoBloqueio := 'Nenhum arquivo foi informado para assinatura.';
    Exit;
  end;

  if not TFile.Exists(Result.CaminhoOriginal) then
  begin
    Result.MotivoBloqueio := 'O arquivo informado não foi encontrado.';
    Exit;
  end;

  if not ExtensaoSuportada(Result.Extensao) then
  begin
    Result.MotivoBloqueio := 'A extensão do arquivo não é suportada para assinatura.';
    Exit;
  end;

  if not PodeAbrirArquivoParaLeituraEscrita(Result.CaminhoOriginal) then
  begin
    Result.MotivoBloqueio := 'O arquivo não está acessível para leitura e escrita.';
    Exit;
  end;

  if (not AConfiguracao.Caminhos.UsarMesmoDiretorioDoOriginal) and (Trim(AConfiguracao.Caminhos.DiretorioSaida) <> '') then
  begin
    try
      ForceDirectories(AConfiguracao.Caminhos.DiretorioSaida);
    except
      on E: Exception do
      begin
        Result.MotivoBloqueio := 'Não foi possível preparar o diretório de saída. ' + E.Message;
        Exit;
      end;
    end;
  end;

  Result.ValidoParaAssinatura := True;
end;

procedure TFileSigningService.AdicionarItem(var AItens: TItensArquivoAssinatura; const AItem: TItemArquivoAssinatura);
begin
  SetLength(AItens, Length(AItens) + 1);
  AItens[High(AItens)] := AItem;
end;

procedure TFileSigningService.AdicionarItemInvalido(var AItens: TItensArquivoAssinatura; const ACaminhoArquivo: string; const AMotivoBloqueio: string);
var
  LItem: TItemArquivoAssinatura;
begin
  LItem := TItemArquivoAssinatura.Empty;
  LItem.CaminhoOriginal := Trim(ACaminhoArquivo);
  LItem.NomeArquivo := ExtractFileName(LItem.CaminhoOriginal);
  LItem.Extensao := LowerCase(ExtractFileExt(LItem.CaminhoOriginal));
  LItem.MotivoBloqueio := AMotivoBloqueio;
  AdicionarItem(AItens, LItem);
end;

procedure TFileSigningService.PrepararArquivoUnico(var AItens: TItensArquivoAssinatura; const AConfiguracao: TConfiguracaoAplicacao);
var
  LItem: TItemArquivoAssinatura;
begin
  if Trim(AConfiguracao.Caminhos.CaminhoArquivoEntrada) = '' then
  begin
    AdicionarItemInvalido(AItens, '', 'Nenhum arquivo de entrada foi informado para o modo de arquivo único.');
    Exit;
  end;

  LItem := PrepararItemArquivo(AConfiguracao.Caminhos.CaminhoArquivoEntrada, AConfiguracao);
  AdicionarItem(AItens, LItem);
end;

procedure TFileSigningService.PrepararLote(var AItens: TItensArquivoAssinatura; const AConfiguracao: TConfiguracaoAplicacao);
var
  LArquivosEncontrados: TStringDynArray;
  LArquivoAtual: string;
  LItem: TItemArquivoAssinatura;
begin
  if Trim(AConfiguracao.Caminhos.DiretorioEntradaLote) = '' then
  begin
    AdicionarItemInvalido(AItens, '', 'Nenhum diretório de entrada foi informado para o modo lote.');
    Exit;
  end;

  if not TDirectory.Exists(AConfiguracao.Caminhos.DiretorioEntradaLote) then
  begin
    AdicionarItemInvalido(AItens, AConfiguracao.Caminhos.DiretorioEntradaLote, 'O diretório informado para o modo lote não foi encontrado.');
    Exit;
  end;

  LArquivosEncontrados := TDirectory.GetFiles(AConfiguracao.Caminhos.DiretorioEntradaLote, '*.*', TSearchOption.soTopDirectoryOnly);

  if Length(LArquivosEncontrados) = 0 then
  begin
    AdicionarItemInvalido(AItens, AConfiguracao.Caminhos.DiretorioEntradaLote, 'Nenhum arquivo foi encontrado no diretório de entrada do lote.');
    Exit;
  end;

  for LArquivoAtual in LArquivosEncontrados do
  begin
    LItem := PrepararItemArquivo(LArquivoAtual, AConfiguracao);

    if LItem.ValidoParaAssinatura then
      AdicionarItem(AItens, LItem)
    else if Trim(LItem.Extensao) <> '' then
      AdicionarItem(AItens, LItem);
  end;

  if Length(AItens) = 0 then
    AdicionarItemInvalido(AItens, AConfiguracao.Caminhos.DiretorioEntradaLote, 'Nenhum arquivo compatível foi encontrado para assinatura no lote.');
end;

function TFileSigningService.PrepararArquivos(const AConfiguracao: TConfiguracaoAplicacao): TItensArquivoAssinatura;
begin
  SetLength(Result, 0);

  if Assigned(FLogger) then
    FLogger.Info('FileSigning', 'Iniciando a preparação dos arquivos para assinatura.');

  case AConfiguracao.Assinatura.ModoOperacaoArquivos of
    TModoOperacaoArquivos.Unico:
      PrepararArquivoUnico(Result, AConfiguracao);

    TModoOperacaoArquivos.Lote:
      PrepararLote(Result, AConfiguracao);
  else
    PrepararArquivoUnico(Result, AConfiguracao);
  end;

  if Assigned(FLogger) then
    FLogger.Success('FileSigning', 'Preparação dos arquivos concluída.');
end;

end.

