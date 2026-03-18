unit RSign.Config.Manager;

interface

uses
  System.SysUtils,
  System.IniFiles,
  System.IOUtils,
  RSign.Core.Constants,
  RSign.Core.Interfaces,
  RSign.Types.Common,
  RSign.Types.Certificate,
  RSign.Types.Signing,
  RSign.Types.Config;

type
  TConfigManager = class(TInterfacedObject, IConfigManager)
  private
    FConfigFilePath: string;
    function CriarIniFile: TIniFile;
  protected
    function GetConfigFilePath: string;
    procedure EnsureExists;
    function Load: TConfiguracaoAplicacao;
    procedure Save(const AConfiguracao: TConfiguracaoAplicacao);

    constructor Create;
  public
    class function New : IConfigManager;
  end;

implementation

constructor TConfigManager.Create;
begin
  inherited Create;

  FConfigFilePath := TPath.Combine(
    ExcludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))),
    _INI_FILE_NAME
  );
end;

function TConfigManager.CriarIniFile: TIniFile;
begin
  ForceDirectories(ExtractFileDir(FConfigFilePath));
  Result := TIniFile.Create(FConfigFilePath);
end;

function TConfigManager.GetConfigFilePath: string;
begin
  Result := FConfigFilePath;
end;

procedure TConfigManager.EnsureExists;
var
  LConfiguracao: TConfiguracaoAplicacao;
begin
  if TFile.Exists(FConfigFilePath) then
    Exit;

  LConfiguracao := TConfiguracaoAplicacao.Default;
  Save(LConfiguracao);
end;

function TConfigManager.Load: TConfiguracaoAplicacao;
var
  LIniFile: TIniFile;
begin
  EnsureExists;
  Result   := TConfiguracaoAplicacao.Default;
  LIniFile := CriarIniFile;
  try
    // [CertificateProfile]
    Result.Certificado.TipoCertificado := TTipoCertificado.FromString(
      LIniFile.ReadString(
        _INI_SECTION_CERTIFICATE_PROFILE,
        'TipoCertificado',
        Result.Certificado.TipoCertificado.ToString
      )
    );
    Result.Certificado.NomeCertificado :=
      LIniFile.ReadString(
        _INI_SECTION_CERTIFICATE_PROFILE,
        'NomeCertificado',
        Result.Certificado.NomeCertificado
      );
    Result.Certificado.NomeEmpresa :=
      LIniFile.ReadString(
        _INI_SECTION_CERTIFICATE_PROFILE,
        'NomeEmpresa',
        Result.Certificado.NomeEmpresa
      );
    Result.Certificado.Organizacao :=
      LIniFile.ReadString(
        _INI_SECTION_CERTIFICATE_PROFILE,
        'Organizacao',
        Result.Certificado.Organizacao
      );
    Result.Certificado.Departamento :=
      LIniFile.ReadString(
        _INI_SECTION_CERTIFICATE_PROFILE,
        'Departamento',
        Result.Certificado.Departamento
      );
    Result.Certificado.Cidade :=
      LIniFile.ReadString(
        _INI_SECTION_CERTIFICATE_PROFILE,
        'Cidade',
        Result.Certificado.Cidade
      );
    Result.Certificado.Estado :=
      LIniFile.ReadString(
        _INI_SECTION_CERTIFICATE_PROFILE,
        'Estado',
        Result.Certificado.Estado
      );
    Result.Certificado.Pais :=
      LIniFile.ReadString(
        _INI_SECTION_CERTIFICATE_PROFILE,
        'Pais',
        Result.Certificado.Pais
      );
    Result.Certificado.Email :=
      LIniFile.ReadString(
        _INI_SECTION_CERTIFICATE_PROFILE,
        'Email',
        Result.Certificado.Email
      );
    Result.Certificado.ValidadeDias :=
      LIniFile.ReadInteger(
        _INI_SECTION_CERTIFICATE_PROFILE,
        'ValidadeDias',
        Result.Certificado.ValidadeDias
      );
    Result.Certificado.Senha :=
      LIniFile.ReadString(
        _INI_SECTION_CERTIFICATE_PROFILE,
        'Senha',
        Result.Certificado.Senha
      );
    Result.Certificado.ConfirmacaoSenha :=
      LIniFile.ReadString(
        _INI_SECTION_CERTIFICATE_PROFILE,
        'ConfirmacaoSenha',
        Result.Certificado.ConfirmacaoSenha
      );

    // [SigningSettings]
    Result.Assinatura.LocalizarAutomaticamenteSignTool :=
      LIniFile.ReadBool(
        _INI_SECTION_SIGNING_SETTINGS,
        'LocalizarAutomaticamenteSignTool',
        Result.Assinatura.LocalizarAutomaticamenteSignTool
      );
    Result.Assinatura.CaminhoManualSignTool :=
      LIniFile.ReadString(
        _INI_SECTION_SIGNING_SETTINGS,
        'CaminhoManualSignTool',
        Result.Assinatura.CaminhoManualSignTool
      );
    Result.Assinatura.UsarVersaoMaisNova :=
      LIniFile.ReadBool(
        _INI_SECTION_SIGNING_SETTINGS,
        'UsarVersaoMaisNova',
        Result.Assinatura.UsarVersaoMaisNova
      );
    Result.Assinatura.UrlTimestamp :=
      LIniFile.ReadString(
        _INI_SECTION_SIGNING_SETTINGS,
        'UrlTimestamp',
        Result.Assinatura.UrlTimestamp
      );
    Result.Assinatura.VerificarAssinaturaAoFinal :=
      LIniFile.ReadBool(
        _INI_SECTION_SIGNING_SETTINGS,
        'VerificarAssinaturaAoFinal',
        Result.Assinatura.VerificarAssinaturaAoFinal
      );
    Result.Assinatura.PermitirContinuarSemTimestamp :=
      LIniFile.ReadBool(
        _INI_SECTION_SIGNING_SETTINGS,
        'PermitirContinuarSemTimestamp',
        Result.Assinatura.PermitirContinuarSemTimestamp
      );
    Result.Assinatura.ModoOperacaoArquivos :=
      TModoOperacaoArquivos.FromString(
        LIniFile.ReadString(
          _INI_SECTION_SIGNING_SETTINGS,
          'ModoOperacaoArquivos',
          Result.Assinatura.ModoOperacaoArquivos.ToString
        )
      );
    Result.Assinatura.ModoSaidaLog :=
      TModoSaidaLog.FromString(
        LIniFile.ReadString(
          _INI_SECTION_SIGNING_SETTINGS,
          'ModoSaidaLog',
          Result.Assinatura.ModoSaidaLog.ToString
        )
      );

    // [Paths]
    Result.Caminhos.DiretorioPfx :=
      LIniFile.ReadString(
        _INI_SECTION_PATHS,
        'DiretorioPfx',
        Result.Caminhos.DiretorioPfx
      );
    Result.Caminhos.NomeArquivoPfx :=
      LIniFile.ReadString(
        _INI_SECTION_PATHS,
        'NomeArquivoPfx',
        Result.Caminhos.NomeArquivoPfx
      );
    Result.Caminhos.CaminhoArquivoEntrada :=
      LIniFile.ReadString(
        _INI_SECTION_PATHS,
        'CaminhoArquivoEntrada',
        Result.Caminhos.CaminhoArquivoEntrada
      );
    Result.Caminhos.DiretorioEntradaLote :=
      LIniFile.ReadString(
        _INI_SECTION_PATHS,
        'DiretorioEntradaLote',
        Result.Caminhos.DiretorioEntradaLote
      );
    Result.Caminhos.DiretorioSaida :=
      LIniFile.ReadString(
        _INI_SECTION_PATHS,
        'DiretorioSaida',
        Result.Caminhos.DiretorioSaida
      );
    Result.Caminhos.UsarMesmoDiretorioDoOriginal :=
      LIniFile.ReadBool(
        _INI_SECTION_PATHS,
        'UsarMesmoDiretorioDoOriginal',
        Result.Caminhos.UsarMesmoDiretorioDoOriginal
      );

    // [Log]
    Result.Log.ModoSaidaLog :=
      TModoSaidaLog.FromString(
        LIniFile.ReadString(
          _INI_SECTION_LOG,
          'ModoSaidaLog',
          Result.Log.ModoSaidaLog.ToString
        )
      );
    Result.Log.CaminhoArquivoLog :=
      LIniFile.ReadString(
        _INI_SECTION_LOG,
        'CaminhoArquivoLog',
        Result.Log.CaminhoArquivoLog
      );

    // [UI]
    Result.UI.UltimaAbaAtiva :=
      LIniFile.ReadInteger(
        _INI_SECTION_UI,
        'UltimaAbaAtiva',
        Result.UI.UltimaAbaAtiva
      );
  finally
    LIniFile.Free;
  end;
end;

class function TConfigManager.New: IConfigManager;
begin
  Result := Self.Create;
end;

procedure TConfigManager.Save(const AConfiguracao: TConfiguracaoAplicacao);
var
  LIniFile: TIniFile;
begin
  if Trim(AConfiguracao.Caminhos.DiretorioPfx) <> '' then
    ForceDirectories(AConfiguracao.Caminhos.DiretorioPfx);

  if Trim(AConfiguracao.Caminhos.DiretorioSaida) <> '' then
    ForceDirectories(AConfiguracao.Caminhos.DiretorioSaida);

  if Trim(ExtractFileDir(AConfiguracao.Log.CaminhoArquivoLog)) <> '' then
    ForceDirectories(ExtractFileDir(AConfiguracao.Log.CaminhoArquivoLog));

  LIniFile := CriarIniFile;
  try
    // [CertificateProfile]
    LIniFile.WriteString(
      _INI_SECTION_CERTIFICATE_PROFILE,
      'TipoCertificado',
      AConfiguracao.Certificado.TipoCertificado.ToString
    );
    LIniFile.WriteString(
      _INI_SECTION_CERTIFICATE_PROFILE,
      'NomeCertificado',
      AConfiguracao.Certificado.NomeCertificado
    );
    LIniFile.WriteString(
      _INI_SECTION_CERTIFICATE_PROFILE,
      'NomeEmpresa',
      AConfiguracao.Certificado.NomeEmpresa
    );
    LIniFile.WriteString(
      _INI_SECTION_CERTIFICATE_PROFILE,
      'Organizacao',
      AConfiguracao.Certificado.Organizacao
    );
    LIniFile.WriteString(
      _INI_SECTION_CERTIFICATE_PROFILE,
      'Departamento',
      AConfiguracao.Certificado.Departamento
    );
    LIniFile.WriteString(
      _INI_SECTION_CERTIFICATE_PROFILE,
      'Cidade',
      AConfiguracao.Certificado.Cidade
    );
    LIniFile.WriteString(
      _INI_SECTION_CERTIFICATE_PROFILE,
      'Estado',
      AConfiguracao.Certificado.Estado
    );
    LIniFile.WriteString(
      _INI_SECTION_CERTIFICATE_PROFILE,
      'Pais',
      AConfiguracao.Certificado.Pais
    );
    LIniFile.WriteString(
      _INI_SECTION_CERTIFICATE_PROFILE,
      'Email',
      AConfiguracao.Certificado.Email
    );
    LIniFile.WriteInteger(
      _INI_SECTION_CERTIFICATE_PROFILE,
      'ValidadeDias',
      AConfiguracao.Certificado.ValidadeDias
    );
    LIniFile.WriteString(
      _INI_SECTION_CERTIFICATE_PROFILE,
      'Senha',
      AConfiguracao.Certificado.Senha
    );
    LIniFile.WriteString(
      _INI_SECTION_CERTIFICATE_PROFILE,
      'ConfirmacaoSenha',
      AConfiguracao.Certificado.ConfirmacaoSenha
    );

    // [SigningSettings]
    LIniFile.WriteBool(
      _INI_SECTION_SIGNING_SETTINGS,
      'LocalizarAutomaticamenteSignTool',
      AConfiguracao.Assinatura.LocalizarAutomaticamenteSignTool
    );
    LIniFile.WriteString(
      _INI_SECTION_SIGNING_SETTINGS,
      'CaminhoManualSignTool',
      AConfiguracao.Assinatura.CaminhoManualSignTool
    );
    LIniFile.WriteBool(
      _INI_SECTION_SIGNING_SETTINGS,
      'UsarVersaoMaisNova',
      AConfiguracao.Assinatura.UsarVersaoMaisNova
    );
    LIniFile.WriteString(
      _INI_SECTION_SIGNING_SETTINGS,
      'UrlTimestamp',
      AConfiguracao.Assinatura.UrlTimestamp
    );
    LIniFile.WriteBool(
      _INI_SECTION_SIGNING_SETTINGS,
      'VerificarAssinaturaAoFinal',
      AConfiguracao.Assinatura.VerificarAssinaturaAoFinal
    );
    LIniFile.WriteBool(
      _INI_SECTION_SIGNING_SETTINGS,
      'PermitirContinuarSemTimestamp',
      AConfiguracao.Assinatura.PermitirContinuarSemTimestamp
    );
    LIniFile.WriteString(
      _INI_SECTION_SIGNING_SETTINGS,
      'ModoOperacaoArquivos',
      AConfiguracao.Assinatura.ModoOperacaoArquivos.ToString
    );
    LIniFile.WriteString(
      _INI_SECTION_SIGNING_SETTINGS,
      'ModoSaidaLog',
      AConfiguracao.Assinatura.ModoSaidaLog.ToString
    );

    // [Paths]
    LIniFile.WriteString(
      _INI_SECTION_PATHS,
      'DiretorioPfx',
      AConfiguracao.Caminhos.DiretorioPfx
    );
    LIniFile.WriteString(
      _INI_SECTION_PATHS,
      'NomeArquivoPfx',
      AConfiguracao.Caminhos.NomeArquivoPfx
    );
    LIniFile.WriteString(
      _INI_SECTION_PATHS,
      'CaminhoArquivoEntrada',
      AConfiguracao.Caminhos.CaminhoArquivoEntrada
    );
    LIniFile.WriteString(
      _INI_SECTION_PATHS,
      'DiretorioEntradaLote',
      AConfiguracao.Caminhos.DiretorioEntradaLote
    );
    LIniFile.WriteString(
      _INI_SECTION_PATHS,
      'DiretorioSaida',
      AConfiguracao.Caminhos.DiretorioSaida
    );
    LIniFile.WriteBool(
      _INI_SECTION_PATHS,
      'UsarMesmoDiretorioDoOriginal',
      AConfiguracao.Caminhos.UsarMesmoDiretorioDoOriginal
    );

    // [Log]
    LIniFile.WriteString(
      _INI_SECTION_LOG,
      'ModoSaidaLog',
      AConfiguracao.Log.ModoSaidaLog.ToString
    );
    LIniFile.WriteString(
      _INI_SECTION_LOG,
      'CaminhoArquivoLog',
      AConfiguracao.Log.CaminhoArquivoLog
    );

    // [UI]
    LIniFile.WriteInteger(
      _INI_SECTION_UI,
      'UltimaAbaAtiva',
      AConfiguracao.UI.UltimaAbaAtiva
    );

    LIniFile.UpdateFile;
  finally
    LIniFile.Free;
  end;
end;

end.
