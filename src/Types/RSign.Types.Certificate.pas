unit RSign.Types.Certificate;

interface

uses
  RSign.Core.Constants,
  RSign.Types.Common;

type
  TConfiguracaoCertificado = record
    TipoCertificado: TTipoCertificado;
    NomeCertificado: string;
    NomeEmpresa: string;
    Organizacao: string;
    Departamento: string;
    Cidade: string;
    Estado: string;
    Pais: string;
    Email: string;
    ValidadeDias: Integer;
    Senha: string;
    ConfirmacaoSenha: string;
    class function Default: TConfiguracaoCertificado; static;
  end;

  TStatusCertificado = record
    ArquivoExiste: Boolean;
    SenhaValida: Boolean;
    PossuiChavePrivada: Boolean;
    CertificadoIntegro: Boolean;
    CompativelComAssinatura: Boolean;
    Vencido: Boolean;
    ProximoDoVencimento: Boolean;
    MensagemTecnica: string;
    MensagemAmigavel: string;
    class function Empty: TStatusCertificado; static;
  end;

  TResultadoCriacaoCertificado = record
    Sucesso: Boolean;
    CaminhoPfxGerado: string;
    Thumbprint: string;
    ComandosExecutados: string;
    MensagemErro: string;
    class function Empty: TResultadoCriacaoCertificado; static;
  end;

implementation

class function TConfiguracaoCertificado.Default: TConfiguracaoCertificado;
begin
  Result.TipoCertificado := TTipoCertificado.Autoassinado;
  Result.NomeCertificado := _DEFAULT_CERTIFICATE_NAME;
  Result.NomeEmpresa := 'Empresa Exemplo';
  Result.Organizacao := 'Empresa Exemplo';
  Result.Departamento := 'TI';
  Result.Cidade := 'Rio de Janeiro';
  Result.Estado := 'RJ';
  Result.Pais := 'BR';
  Result.Email := 'contato@empresa.com';
  Result.ValidadeDias := 365;
  Result.Senha := _DEFAULT_CERTIFICATE_PASSWORD;
  Result.ConfirmacaoSenha := _DEFAULT_CERTIFICATE_PASSWORD;
end;

class function TStatusCertificado.Empty: TStatusCertificado;
begin
  Result.ArquivoExiste := False;
  Result.SenhaValida := False;
  Result.PossuiChavePrivada := False;
  Result.CertificadoIntegro := False;
  Result.CompativelComAssinatura := False;
  Result.Vencido := False;
  Result.ProximoDoVencimento := False;
  Result.MensagemTecnica := '';
  Result.MensagemAmigavel := '';
end;

class function TResultadoCriacaoCertificado.Empty: TResultadoCriacaoCertificado;
begin
  Result.Sucesso := False;
  Result.CaminhoPfxGerado := '';
  Result.Thumbprint := '';
  Result.ComandosExecutados := '';
  Result.MensagemErro := '';
end;

end.
