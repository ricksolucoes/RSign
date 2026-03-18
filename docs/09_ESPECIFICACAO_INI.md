# RSign — Especificação do Arquivo INI

## 1. Objetivo deste documento

Este documento define a especificação oficial do arquivo de configuração persistida do projeto **RSign**.

O objetivo deste material é detalhar:

- o nome e o papel do arquivo `.ini`;
- as seções aprovadas para o projeto;
- as chaves persistidas por aba funcional;
- os tipos esperados de cada valor;
- os valores padrão iniciais;
- as regras de leitura, gravação e validação;
- o mapeamento entre UI, Types, Config e Orquestrador.

Este arquivo deve ser tratado como a **referência oficial da persistência local** do projeto. Toda leitura ou gravação de configuração deve respeitar esta especificação.

---

## 2. Papel do arquivo INI no projeto

O RSign foi definido como uma aplicação local, sem dependência de banco de dados. Por esse motivo, a persistência da configuração operacional será feita por meio de um arquivo `.ini`.

Esse arquivo deve permitir que a aplicação:

- reabra com os últimos valores usados;
- preserve caminhos, preferências e defaults alterados pelo usuário;
- recupere rapidamente o contexto da última operação;
- reduza retrabalho manual entre execuções;
- mantenha compatibilidade com Delphi 10.2 com baixo custo de implementação.

---

## 3. Nome e local do arquivo

## 3.1. Nome sugerido

O nome padrão recomendado para o arquivo é:

```text
RSign.ini
```

## 3.2. Local padrão sugerido

O arquivo deve ser salvo, por padrão, no mesmo diretório da aplicação.

Exemplo:

```text
C:\RSign\RSign.ini
```

## 3.3. Regra operacional

Se o arquivo não existir:

1. a aplicação deve criar um arquivo novo;
2. os valores padrão devem ser aplicados em memória;
3. a gravação inicial deve respeitar as seções previstas neste documento.

---

## 4. Regras gerais de persistência

## 4.1. Regras obrigatórias

- Toda leitura deve ser tolerante a ausência de chave.
- Toda ausência de chave deve cair em valor padrão seguro.
- Toda gravação deve passar por `RSign.Config.Manager`.
- A UI não deve escrever diretamente no `.ini`.
- Senhas não devem ser gravadas em logs técnicos em texto puro.
- Alterações feitas pelo usuário devem ser persistidas apenas após validação mínima.

## 4.2. Regras de compatibilidade

- O `.ini` deve ser legível manualmente.
- O nome das seções não deve depender da linguagem da UI.
- O nome das chaves deve permanecer estável para evitar quebra entre versões.
- Mudanças futuras devem preferir adição de novas chaves a renomeações destrutivas.

## 4.3. Estratégia de leitura

O `RSign.Config.Manager` deve:

1. verificar se o arquivo existe;
2. criar se necessário;
3. carregar as seções esperadas;
4. aplicar defaults quando faltarem chaves;
5. devolver estruturas prontas para uso pela UI e pelo orquestrador.

---

## 5. Seções aprovadas

As seções oficiais do arquivo `.ini` são as seguintes:

- `[CertificateProfile]`
- `[SigningSettings]`
- `[Paths]`
- `[Log]`

Essas seções refletem diretamente a divisão funcional aprovada do projeto.

---

## 6. Seção `[CertificateProfile]`

## 6.1. Objetivo

Persistir os dados do perfil do certificado exibidos e editados na aba **Perfil do Certificado**.

## 6.2. Chaves aprovadas

### `CertificateType`
- **Tipo:** string
- **Valores esperados:** `SelfSigned`, `ExternalPFX`, `CodeSigningFuture`
- **Padrão:** `SelfSigned`
- **Mapeamento:** `TTipoCertificado`

### `CertificateName`
- **Tipo:** string
- **Padrão:** `RSign Certificado`
- **Descrição:** nome lógico do certificado usado pela aplicação.

### `CompanyName`
- **Tipo:** string
- **Padrão:** vazio
- **Descrição:** razão ou nome da empresa usado na composição do certificado.

### `Organization`
- **Tipo:** string
- **Padrão:** vazio
- **Descrição:** organização a ser usada no perfil do certificado.

### `Department`
- **Tipo:** string
- **Padrão:** vazio
- **Descrição:** departamento vinculado ao perfil.

### `City`
- **Tipo:** string
- **Padrão:** vazio
- **Descrição:** cidade usada na composição do certificado.

### `State`
- **Tipo:** string
- **Padrão:** vazio
- **Descrição:** estado usado na composição do certificado.

### `Country`
- **Tipo:** string
- **Padrão:** `BR`
- **Descrição:** país usado na composição do certificado.

### `Email`
- **Tipo:** string
- **Padrão:** vazio
- **Descrição:** e-mail associado ao perfil do certificado.

### `ValidityDays`
- **Tipo:** inteiro
- **Padrão:** `365`
- **Descrição:** validade do certificado em dias.

### `PFXPassword`
- **Tipo:** string
- **Padrão:** `123456`
- **Descrição:** senha do arquivo `.pfx`.
- **Observação:** a senha deve ser mascarada na UI e nunca deve ser gravada em log técnico.

## 6.3. Exemplo de seção

```ini
[CertificateProfile]
CertificateType=SelfSigned
CertificateName=RSign Certificado
CompanyName=
Organization=
Department=
City=
State=
Country=BR
Email=
ValidityDays=365
PFXPassword=123456
```

---

## 7. Seção `[SigningSettings]`

## 7.1. Objetivo

Persistir os dados da aba **Configuração da Assinatura**.

## 7.2. Chaves aprovadas

### `UseAutoSignToolDetection`
- **Tipo:** boolean
- **Valores esperados:** `0` ou `1`
- **Padrão:** `1`
- **Descrição:** habilita busca automática do `signtool.exe`.

### `ManualSignToolPath`
- **Tipo:** string
- **Padrão:** vazio
- **Descrição:** caminho manual informado pelo usuário.

### `UseNewestSignTool`
- **Tipo:** boolean
- **Padrão:** `1`
- **Descrição:** define se a versão mais nova será priorizada automaticamente.

### `TimestampUrl`
- **Tipo:** string
- **Padrão:** `http://timestamp.digicert.com`
- **Descrição:** servidor de timestamp usado na assinatura.

### `VerifyAfterSigning`
- **Tipo:** boolean
- **Padrão:** `1`
- **Descrição:** define se a verificação pós-assinatura será executada.

### `AllowContinueWithoutTimestamp`
- **Tipo:** boolean
- **Padrão:** `0`
- **Descrição:** indica apenas permissão funcional. A continuação sem timestamp deve continuar dependendo de confirmação do usuário.

### `SigningMode`
- **Tipo:** string
- **Valores esperados:** `SingleFile`, `Batch`
- **Padrão:** `SingleFile`
- **Mapeamento:** `TModoAssinatura`

## 7.3. Exemplo de seção

```ini
[SigningSettings]
UseAutoSignToolDetection=1
ManualSignToolPath=
UseNewestSignTool=1
TimestampUrl=http://timestamp.digicert.com
VerifyAfterSigning=1
AllowContinueWithoutTimestamp=0
SigningMode=SingleFile
```

---

## 8. Seção `[Paths]`

## 8.1. Objetivo

Persistir os dados da aba **Locais e Arquivos**.

## 8.2. Chaves aprovadas

### `PFXDirectory`
- **Tipo:** string
- **Padrão:** diretório da aplicação
- **Descrição:** pasta base onde o `.pfx` será salvo ou localizado.

### `PFXFileName`
- **Tipo:** string
- **Padrão:** `RSignCertificado.pfx`
- **Descrição:** nome físico do arquivo `.pfx`.

### `InputMode`
- **Tipo:** string
- **Valores esperados:** `SingleFile`, `Folder`
- **Padrão:** `SingleFile`
- **Descrição:** origem operacional da assinatura.

### `InputFile`
- **Tipo:** string
- **Padrão:** vazio
- **Descrição:** caminho completo do arquivo selecionado.

### `InputDirectory`
- **Tipo:** string
- **Padrão:** vazio
- **Descrição:** pasta de entrada usada no modo lote.

### `OutputDirectory`
- **Tipo:** string
- **Padrão:** vazio
- **Descrição:** pasta de saída da operação.

### `UseSameDirectoryAsInput`
- **Tipo:** boolean
- **Padrão:** `1`
- **Descrição:** define se a saída ocorrerá no mesmo diretório do original.

### `RenameOriginalToOld`
- **Tipo:** boolean
- **Padrão:** `1`
- **Descrição:** define a estratégia aprovada de renomear o original com sufixo `_OLD`.

## 8.3. Exemplo de seção

```ini
[Paths]
PFXDirectory=C:\RSign\Certificado
PFXFileName=RSignCertificado.pfx
InputMode=SingleFile
InputFile=C:\RSign\Input\MeuApp.exe
InputDirectory=C:\RSign\Input
OutputDirectory=C:\RSign\Out
UseSameDirectoryAsInput=1
RenameOriginalToOld=1
```

---

## 9. Seção `[Log]`

## 9.1. Objetivo

Persistir preferências de log técnico e visual.

## 9.2. Chaves aprovadas

### `EnableFileLog`
- **Tipo:** boolean
- **Padrão:** `1`
- **Descrição:** habilita gravação em arquivo.

### `EnableUILog`
- **Tipo:** boolean
- **Padrão:** `1`
- **Descrição:** habilita log visual na interface.

### `LogDirectory`
- **Tipo:** string
- **Padrão:** subpasta `logs` da aplicação
- **Descrição:** pasta de gravação dos arquivos de log.

### `LogLevel`
- **Tipo:** string
- **Valores esperados:** `Info`, `Warning`, `Error`, `Debug`, `Success`
- **Padrão:** `Info`
- **Descrição:** nível mínimo de saída visual/técnica, caso a implementação futura use filtro.

## 9.3. Exemplo de seção

```ini
[Log]
EnableFileLog=1
EnableUILog=1
LogDirectory=C:\RSign\logs
LogLevel=Info
```

---

## 10. Mapeamento entre UI e INI

## 10.1. Aba Perfil do Certificado

Mapeia para:

- `[CertificateProfile]`

## 10.2. Aba Configuração da Assinatura

Mapeia para:

- `[SigningSettings]`
- parcialmente `[Log]`

## 10.3. Aba Locais e Arquivos

Mapeia para:

- `[Paths]`

---

## 11. Mapeamento entre Types e INI

## 11.1. `TConfiguracaoCertificado`

Deve ser preenchido a partir de:

- `[CertificateProfile]`

## 11.2. `TConfiguracaoAssinatura`

Deve ser preenchido a partir de:

- `[SigningSettings]`
- `[Paths]`
- parte de `[Log]`, quando aplicável ao fluxo operacional

## 11.3. `TConfiguracaoLog`

Deve ser preenchido a partir de:

- `[Log]`

---

## 12. Regras de validação antes da gravação

O `RSign.Config.Manager` deve validar minimamente:

- se `ValidityDays` é maior que zero;
- se `CertificateType` possui valor suportado;
- se `SigningMode` possui valor suportado;
- se `InputMode` possui valor suportado;
- se `PFXFileName` não está vazio;
- se `TimestampUrl`, quando preenchida, não contém apenas espaços;
- se `ManualSignToolPath`, quando preenchido, não contém apenas espaços.

Essas validações não substituem a validação profunda do orquestrador e dos services, mas evitam persistência incoerente.

---

## 13. Regras de segurança e cuidado

- A senha do PFX pode ser persistida porque isso foi aprovado no contexto do projeto, mas deve permanecer mascarada na UI.
- O sistema não deve escrever a senha em logs.
- O sistema não deve depender de ausência do `.ini` para restaurar defaults; defaults devem sempre existir em código.
- Alterações futuras no arquivo devem priorizar compatibilidade retroativa.

---

## 14. Exemplo completo de arquivo

```ini
[CertificateProfile]
CertificateType=SelfSigned
CertificateName=RSign Certificado
CompanyName=
Organization=
Department=
City=
State=
Country=BR
Email=
ValidityDays=365
PFXPassword=123456

[SigningSettings]
UseAutoSignToolDetection=1
ManualSignToolPath=
UseNewestSignTool=1
TimestampUrl=http://timestamp.digicert.com
VerifyAfterSigning=1
AllowContinueWithoutTimestamp=0
SigningMode=SingleFile

[Paths]
PFXDirectory=C:\RSign\Certificado
PFXFileName=RSignCertificado.pfx
InputMode=SingleFile
InputFile=
InputDirectory=
OutputDirectory=
UseSameDirectoryAsInput=1
RenameOriginalToOld=1

[Log]
EnableFileLog=1
EnableUILog=1
LogDirectory=C:\RSign\logs
LogLevel=Info
```

---

## 15. Conclusão

O arquivo `RSign.ini` é o ponto oficial de persistência do estado operacional da aplicação. Ele foi desenhado para refletir fielmente a separação funcional aprovada do projeto e deve ser tratado como parte central da arquitetura.

A regra principal é simples:

- a **UI coleta e apresenta**;
- o **Config Manager persiste**;
- os **Types representam**;
- o **Orquestrador consome**;
- os **Services validam e executam**.

Esse padrão deve ser mantido em toda evolução futura do RSign.
