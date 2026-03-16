# RSign — Documento de Arquitetura das Units

## 1. Objetivo deste documento

Este documento define a arquitetura técnica do projeto **RSign**, descrevendo com profundidade:

- a organização das **units** do projeto;
- a responsabilidade de cada módulo;
- a comunicação entre UI, orquestrador e serviços;
- as regras de negócio que cada camada deve respeitar;
- o fluxo técnico completo da aplicação;
- a base para implementação, manutenção e evolução futura do sistema.

Este material deve ser usado como **referência oficial da arquitetura interna** do projeto. A intenção é impedir crescimento desordenado, evitar mistura de responsabilidades e manter o desenvolvimento sempre dentro do escopo já aprovado.

---

## 2. Visão geral do projeto

O **RSign** é uma aplicação **Windows local**, desenvolvida em **Delphi 10.2 + FMX**, destinada à assinatura de arquivos compatíveis com **Authenticode**, utilizando inicialmente **certificado autoassinado em `.pfx`** e com arquitetura preparada para futura adoção de:

- **PFX externo**;
- **certificado real de Code Signing**.

O sistema precisa ser capaz de:

- localizar e validar o ambiente de assinatura;
- localizar e validar o `signtool.exe`;
- localizar, validar e criar o certificado quando necessário;
- trabalhar com **arquivo único** ou **assinatura em lote**;
- renomear o original com sufixo `_OLD`;
- manter o arquivo assinado com o nome original;
- verificar a assinatura ao final;
- registrar logs em tela e arquivo;
- explicar problemas técnicos e aguardar decisão do usuário em pontos críticos.

---

## 3. Princípios arquiteturais obrigatórios

A implementação do RSign deve seguir estes princípios desde a primeira unit criada.

### 3.1. Separação clara de responsabilidades

A tela não deve decidir regras técnicas de assinatura.

A UI deve apenas:

- coletar dados;
- exibir estados;
- solicitar operações;
- exibir mensagens e logs;
- repassar decisões do usuário ao núcleo.

Toda a lógica operacional deve ficar em **services** e ser coordenada por um **orquestrador**.

### 3.2. Núcleo desacoplado da interface

As regras de negócio devem continuar funcionando mesmo que, futuramente, a UI FMX seja substituída por:

- aplicação console;
- serviço Windows;
- automação por linha de comando;
- integração com outro front-end.

### 3.3. Orquestração centralizada

O fluxo do sistema não deve ficar espalhado entre múltiplas units de tela.

Deve existir um módulo central responsável por decidir a ordem das ações:

- validar ambiente;
- validar certificado;
- validar arquivos;
- preparar backup;
- assinar;
- verificar;
- registrar resultado.

### 3.4. Decisão assistida em falhas críticas

O projeto não deve tomar decisões silenciosas em cenários ambíguos ou destrutivos.

Exemplos de situações que exigem decisão do usuário:

- certificado vencido;
- PFX corrompido;
- senha inválida;
- timestamp indisponível;
- arquivo bloqueado;
- signtool inválido ou incompatível.

### 3.5. Preparação para crescimento futuro

Mesmo começando com certificado autoassinado, a arquitetura deve nascer preparada para suportar futuramente:

- certificado `.pfx` fornecido externamente;
- certificado corporativo de Code Signing;
- seleção de múltiplos perfis de assinatura;
- mais de uma política de timestamp;
- outros modos de automação.

---

## 4. Estrutura macro da solução

A solução deve ser organizada em camadas para impedir acoplamento indevido.

### 4.1. Camadas previstas

#### UI
Responsável pela interface FMX.

#### Core
Responsável pela orquestração do fluxo, contratos e tipos principais.

#### Services
Responsável pela execução das regras especializadas.

#### Config
Responsável pela persistência e carregamento de configurações.

#### Utils
Responsável por utilitários genéricos e helpers sem regra de negócio principal.

#### Docs
Responsável por documentação do projeto.

---

## 5. Estrutura sugerida de pastas

```text
RSign/
├── README.md
├── RSign.dpr
│
├── src/
│   ├── views/                         # Entrada principal da aplicação, inicialização e composição do sistema
│   │   ├── RSign.View.Main.pas
│   │   ├── RSign.View.Configuracao.pas
│   │   └── RSign.View.Log.pas
│   │
│   ├── Core/                          # Contracts, orquestração, constantes globais e regras centrais de coordenação
│   │   ├── RSign.Core.Constants.pas
│   │   ├── RSign.Core.Interfaces.pas
│   │   └── RSign.Core.Orchestrator.pas
│   │
│   ├── Types/                         # Records, enums, classes DTO e estruturas de transporte de dados
│   │   ├── RSign.Types.Common.pas
│   │   ├── RSign.Types.Certificate.pas
│   │   └── RSign.Types.Signing.pas
│   │
│   ├── Config/                        # Persistência local das configurações do projeto
│   │   └── RSign.Config.Manager.pas
│   │
│   ├── Services/                      # Implementações especializadas por domínio funcional
│   │   ├── RSign.Services.Certificate.pas
│   │   ├── RSign.Services.SignTool.pas
│   │   ├── RSign.Services.FileSigning.pas
│   │   ├── RSign.Services.Signing.pas
│   │   ├── RSign.Services.SigningVerification.pas
│   │   ├── RSign.Services.ProcessExecutor.pas
│   │   └── RSign.Services.Logger.pas
│   │
│   ├── UI/                             # Forms, frames, view models simples e elementos visuais da aplicação
│   │   ├── RSign.UI.Main.pas
│   │   └── Frame/
│   │       ├── RSign.UI.Frame.CertificateProfile.pas
│   │       ├── RSign.UI.Frame.SigningSettings.pas
│   │       └── RSign.UI.Frame.Paths.pas
│   │
│   ├── Utils/                          # Helpers de string, arquivo, processo e pequenas rotinas auxiliares
│   │   ├── RSign.Utils.Path.pas
│   │   └── RSign.Utils.Strings.pas
│   │
│   └── assets/                         # Recursos estáticos utilizados pela aplicação
│       ├── icons/
│       └── images/
│
├── docs/                               # Documentação do projeto
│   ├── REFERENCIA_FUCIONAL.md          # Descrição das funcionalidades
│   ├── CONTEXTO_TECNICO.md             # Arquitetura e decisões técnicas
│   └── PLANO_IMPLEMENTACAO_RSIGN.md    # Planejamento de implementação
```

### 5.1. Significado de cada pasta

#### `src/views`
Entrada principal da aplicação, inicialização e composição do sistema.

#### `src/Core`
Contracts, orquestração, constantes globais e regras centrais de coordenação.

#### `src/Types`
Records, enums, classes DTO e estruturas de transporte de dados.

#### `src/Config`
Persistência local das configurações do projeto.

#### `src/Services`
Implementações especializadas por domínio funcional.

#### `src/UI`
Forms, frames, view models simples e elementos visuais da aplicação.

#### `src/Utils`
Helpers de string, arquivo, processo e pequenas rotinas auxiliares.

---

## 6. Convenção sugerida de nomenclatura das units

Para manter clareza e previsibilidade, recomenda-se um namespace consistente.

### 6.1. Prefixo

Todas as units do núcleo devem seguir o prefixo:

- `RSign.`

### 6.2. Exemplo de nomenclatura

- `RSign.View.Main`
- `RSign.View.Configuracao.pas`
- `RSign.View.Log.pas`
- `RSign.Core.Constants`
- `RSign.Core.Interfaces`
- `RSign.Core.Orchestrator`
- `RSign.Types.Common`
- `RSign.Types.Certificate`
- `RSign.Types.Signing`
- `RSign.Config.Manager`
- `RSign.Services.Certificate`
- `RSign.Services.SignTool`
- `RSign.Services.FileSigning`
- `RSign.Services.Signing`
- `RSign.Services.SigningVerification`
- `RSign.Services.ProcessExecutor`
- `RSign.Services.Logger`
- `RSign.UI.Main`
- `RSign.UI.Frame.CertificateProfile`
- `RSign.UI.Frame.SigningSettings`
- `RSign.UI.Frame.Paths`
- `RSign.Utils.Path`
- `RSign.Utils.Strings`

---

## 7. Catálogo técnico das units previstas

Abaixo está a arquitetura sugerida das units, com foco em responsabilidade, entrada, saída e dependências esperadas.

---

## 7.1. Camada View

### `RSign.View.Main`

#### Responsabilidade
Ponto de entrada principal da aplicação FMX.

#### Deve fazer

- inicializar a aplicação;
- carregar temas básicos da interface, se existirem;
- criar a form principal;
- preparar objetos centrais de composição;
- injetar o orquestrador e os serviços necessários na UI principal.

#### Não deve fazer

- validar certificado;
- assinar arquivos;
- localizar `signtool`;
- salvar configuração diretamente.

---

### `RSign.View.Configuracao`

#### Responsabilidade
Atuar como ponto de entrada e composição da tela de configuração da aplicação, organizando a abertura, carregamento e integração do formulário responsável pelas preferências persistentes do sistema.

#### Deve fazer

- inicializar a tela de configuração quando ela for aberta de forma isolada ou integrada à aplicação principal;
- preparar a ligação entre a interface visual de configuração e o gerenciador de configurações;
- carregar os dados persistidos no `.ini` e disponibilizá-los para exibição na UI;
- permitir que alterações feitas pelo usuário sejam refletidas corretamente no fluxo da aplicação;
- centralizar a criação do formulário de configuração, caso essa tela exista separadamente da tela principal;
- preparar a comunicação com o orquestrador quando alguma validação precisar ser executada a partir da configuração;
- garantir que os valores padrão sejam exibidos quando ainda não houver configuração salva.

#### Não deve fazer

- validar profundamente certificado `.pfx`;
- localizar `signtool.exe` diretamente;
- executar assinatura;
- decidir regras de negócio sobre timestamp, recriação de certificado ou continuidade em falhas críticas;
- salvar dados em arquivo manualmente sem passar pelo gerenciador de configuração.

#### Papel arquitetural

Essa unit existe para separar o conceito de **entrada visual da configuração** da lógica de execução da aplicação.

Mesmo que a tela principal já possua abas de configuração, essa unit continua válida como ponto de composição de um fluxo dedicado de preferências, permitindo:

- futura abertura da configuração em janela separada;
- reutilização do carregamento das preferências;
- organização do projeto sem concentrar toda a inicialização visual em uma única unit.

#### Relação com outras units

Deve conversar principalmente com:

- `RSign.UI.Main`
- `RSign.Config.Manager`
- `RSign.Types.Config`
- `RSign.Core.Interfaces`

#### Observação importante

Caso o projeto permaneça com a configuração totalmente embutida na tela principal, essa unit ainda pode existir como camada de organização, responsável por:

- carregar preferências;
- aplicar defaults;
- sincronizar dados entre o `.ini` e os frames de configuração.

---

### `RSign.View.Log`

#### Responsabilidade
Atuar como ponto de entrada e composição da visualização de logs da aplicação, permitindo exibição técnica e amigável dos eventos gerados durante validações, criação de certificado, assinatura e verificação.

#### Deve fazer

- inicializar a tela ou área de visualização de logs;
- preparar a interface de leitura dos eventos registrados pelo sistema;
- permitir exibição organizada por nível de severidade;
- possibilitar atualização visual durante a execução das operações;
- permitir futura navegação entre logs resumidos e logs detalhados;
- servir como base para telas auxiliares de auditoria local ou inspeção técnica;
- integrar o logger da aplicação à camada visual sem acoplar o núcleo a controles FMX específicos.

#### Não deve fazer

- gravar diretamente no arquivo de log;
- decidir o conteúdo técnico que será registrado;
- montar mensagens de assinatura;
- executar validações ou chamadas operacionais;
- interpretar regras de negócio de certificado, signtool ou arquivos.

#### Papel arquitetural

Essa unit existe para separar a **apresentação dos logs** da **geração dos logs**.

O núcleo da aplicação deve continuar registrando eventos por meio de `ILoggerService`, enquanto essa unit fica responsável apenas por:

- carregar a visualização;
- exibir mensagens;
- organizar filtros visuais;
- facilitar leitura pelo usuário.

#### Conteúdo esperado na visualização

A interface ligada a essa unit deve permitir exibir, no mínimo:

- data e hora do evento;
- nível do log;
- origem da operação;
- mensagem amigável;
- detalhe técnico expandido;
- status final da etapa.

#### Relação com outras units

Deve conversar principalmente com:

- `RSign.Services.Logger`
- `RSign.UI.Main`
- `RSign.Core.Interfaces`
- `RSign.Types.Common`

#### Possibilidades futuras previstas

Essa unit já deve nascer preparada para evolução futura, permitindo:

- exportação de log para arquivo externo;
- filtro por nível de severidade;
- filtro por operação;
- separação entre log da sessão atual e histórico anterior;
- painel de auditoria local.

#### Observação importante

Mesmo que inicialmente o log fique visível na própria tela principal, essa unit continua útil como ponto de composição de uma visualização dedicada, evitando que a responsabilidade de monitoramento visual fique misturada com a execução operacional.

---

## 7.2. Camada Core

### `RSign.Core.Constants`

#### Responsabilidade
Centralizar constantes globais do sistema.

#### Conteúdo esperado

- nome do projeto;
- versão atual;
- extensões suportadas;
- senha padrão inicial;
- nome padrão do certificado;
- URL padrão do timestamp;
- nomes de seções do arquivo `.ini`;
- nomes de pastas padrão.

#### Observação
As constantes devem conter apenas defaults estáticos. Valores mutáveis devem estar na configuração.

---

### `RSign.Core.Interfaces`

#### Responsabilidade
Declarar contratos formais das interfaces utilizadas pelo sistema.

#### Interfaces previstas

- `ILoggerService`
- `IConfigManager`
- `IProcessExecutor`
- `ISignToolService`
- `ICertificateService`
- `IFileSigningService`
- `ISigningService`
- `ISigningVerificationService`
- `IUserDecisionService`
- `IOrchestrator`

#### Importância
Essa unit impede que a UI dependa de classes concretas e ajuda a manter o projeto preparado para testes e troca de implementação.

---

### `RSign.Core.Orchestrator`

#### Responsabilidade
Coordenar o fluxo técnico completo do RSign.

#### Esse é o coração operacional do sistema.

Ele deve decidir:

1. quando validar a configuração;
2. quando localizar o `signtool`;
3. quando validar o certificado;
4. quando criar o certificado;
5. quando pedir decisão ao usuário;
6. quando preparar backup do arquivo;
7. quando chamar a assinatura;
8. quando executar verificação;
9. quando registrar resultado final.

#### Entradas

- configuração carregada;
- contexto da operação solicitado pela UI;
- lista de arquivos selecionados;
- decisões do usuário em cenários críticos.

#### Saídas

- resultado consolidado por item;
- status geral da operação;
- logs;
- mensagens amigáveis;
- mensagens técnicas.

#### Não deve fazer diretamente

- manipulação bruta de arquivo;
- execução de processo externo;
- construção direta da interface;
- leitura direta do `.ini`.

---

## 7.3. Camada Types

### `RSign.Types.Common`

#### Responsabilidade
Definir enums e tipos comuns a todo o sistema.

#### Enums sugeridos

- `TTipoCertificado`
- `TModoAssinatura`
- `TStatusOperacao`
- `TNivelLog`
- `TAcaoUsuarioFalha`
- `TOrigemSignTool`
- `TResultadoVerificacao`

#### Objetivo
Padronizar estados e respostas, evitando strings soltas espalhadas pelo projeto.

---

### `RSign.Types.Certificate`

#### Responsabilidade
Representar os dados técnicos e operacionais do certificado.

#### Estruturas sugeridas

##### `TConfiguracaoCertificado`
Contém:

- tipo do certificado;
- nome do certificado;
- nome da empresa;
- organização;
- departamento;
- cidade;
- estado;
- país;
- e-mail;
- validade;
- senha;
- caminho base do PFX;
- nome do arquivo PFX.

##### `TStatusCertificado`
Contém:

- arquivo existe;
- senha válida;
- possui chave privada;
- certificado íntegro;
- compatível com assinatura;
- data inicial de vigência;
- data final de vigência;
- vencido;
- próximo do vencimento;
- mensagem técnica;
- mensagem amigável.

##### `TResultadoCriacaoCertificado`
Contém:

- sucesso;
- caminho do PFX gerado;
- thumbprint, se obtido;
- comandos executados;
- mensagens de erro;
- logs associados.

---

### `RSign.Types.Signing`

#### Responsabilidade
Representar a operação de assinatura.

#### Estruturas sugeridas

##### `TItemArquivoAssinatura`
Contém:

- caminho original;
- nome do arquivo;
- extensão;
- caminho do backup `_OLD`;
- caminho do arquivo assinado final;
- válido para assinatura;
- motivo de bloqueio.

##### `TConfiguracaoAssinatura`
Contém:

- usar detecção automática do `signtool`;
- caminho manual do `signtool`;
- usar versão mais nova;
- URL do timestamp;
- verificar ao final;
- permitir continuar sem timestamp após confirmação;
- modo da operação;
- origem dos arquivos;
- destino dos arquivos;
- usar pasta única ou seleção unitária.

##### `TResultadoAssinatura`
Contém:

- arquivo alvo;
- sucesso;
- comando executado;
- código de retorno;
- saída padrão;
- erro padrão;
- assinatura aplicada;
- timestamp aplicado;
- verificação executada;
- verificação aprovada;
- mensagem técnica;
- mensagem amigável.

---

### `RSign.Types.Config`

#### Responsabilidade
Separar os blocos persistidos da configuração do sistema.

#### Estruturas sugeridas

- `TConfiguracaoGeral`
- `TConfiguracaoCaminhos`
- `TConfiguracaoLog`
- `TConfiguracaoUI`

---

## 7.4. Camada Config

### `RSign.Config.Manager`

#### Responsabilidade
Persistir e restaurar as configurações da aplicação.

#### Formato recomendado

- `.ini`

#### Motivos

- facilidade de uso no Delphi 10.2;
- simplicidade de manutenção;
- leitura humana;
- baixo custo de implementação;
- suficiente para o escopo atual.

#### Deve fazer

- criar arquivo de configuração padrão se não existir;
- ler seções separadas por aba funcional;
- gravar alterações feitas pelo usuário;
- validar campos mínimos antes de persistir;
- devolver estruturas prontas para uso pelo orquestrador.

#### Seções sugeridas do `.ini`

##### `[CertificateProfile]`
Dados do perfil do certificado.

##### `[SigningSettings]`
Configurações técnicas da assinatura.

##### `[Paths]`
Local do PFX, origem dos arquivos e destino.

##### `[Log]`
Configurações de log.

---

## 7.5. Camada Services

### `RSign.Services.Logger`

#### Responsabilidade
Centralizar o registro de logs do sistema.

#### Deve fazer

- registrar em arquivo;
- registrar em memória ou componente visual da UI;
- separar níveis de severidade;
- padronizar mensagens técnicas e amigáveis;
- permitir reaproveitamento por qualquer módulo.

#### Níveis sugeridos

- `Info`
- `Warning`
- `Error`
- `Debug`
- `Success`

#### Exemplos de uso

- início de operação;
- arquivo selecionado;
- signtool detectado;
- certificado inválido;
- assinatura bem-sucedida;
- falha na verificação.

---

### `RSign.Services.ProcessExecutor`

#### Responsabilidade
Executar processos externos do Windows e capturar seu retorno.

#### Será usado por

- serviço de certificado;
- serviço de assinatura;
- serviço de verificação;
- descoberta avançada do `signtool`.

#### Deve fazer

- executar comando com parâmetros;
- capturar código de saída;
- capturar stdout;
- capturar stderr;
- suportar timeout configurável;
- informar falha de execução de forma padronizada.

#### Justificativa
Essa unit evita repetição de lógica de processo externo em vários módulos.

---

### `RSign.Services.SignTool`

#### Responsabilidade
Localizar, validar e escolher o `signtool.exe` a ser usado.

#### Deve fazer

- aceitar caminho manual informado pela UI;
- validar se o caminho manual existe;
- localizar instâncias via PATH;
- localizar instâncias em pastas conhecidas do Windows Kits;
- listar candidatas encontradas;
- identificar a versão de cada executável encontrado;
- escolher a mais nova por padrão;
- permitir override manual do usuário.

#### Saída esperada

`TStatusSignTool`, contendo:

- encontrado ou não;
- origem da escolha;
- versão detectada;
- caminho final adotado;
- mensagem técnica;
- mensagem amigável.

---

### `RSign.Services.Certificate`

#### Responsabilidade
Gerenciar toda a vida útil do certificado dentro do escopo do projeto.

#### Deve fazer

- verificar existência do `.pfx`;
- validar senha do PFX;
- validar integridade;
- verificar presença de chave privada;
- validar vigência;
- identificar vencimento;
- identificar proximidade de vencimento;
- validar compatibilidade com assinatura;
- criar certificado autoassinado quando necessário;
- exportar para `.pfx`;
- remover o certificado do store temporário após exportação.

#### Estratégia técnica aprovada

Como a criação do autoassinado normalmente passa por store do Windows, a implementação deve:

1. criar temporariamente no `CurrentUser\My`;
2. exportar o `.pfx`;
3. remover o certificado do store;
4. manter apenas o `.pfx` como artefato final.

#### Cenários que devem pedir decisão ao usuário

- PFX existe, mas senha inválida;
- PFX corrompido;
- certificado vencido;
- certificado próximo do vencimento;
- certificado sem chave privada;
- certificado incompatível para assinatura.

---

### `RSign.Services.FileSigning`

#### Responsabilidade
Preparar e validar arquivos a serem assinados.

#### Deve fazer

- validar se o arquivo existe;
- validar extensão suportada;
- validar acesso de leitura e escrita;
- verificar se o arquivo está em uso ou bloqueado;
- calcular caminho do `_OLD`;
- preparar estratégia de backup;
- calcular caminho do assinado final;
- validar operação em lote.

#### Regras aprovadas

- extensões aceitas inicialmente:
  - `.exe`
  - `.dll`
  - `.msi`
  - `.cab`
  - `.cat`
- o original deve ser renomeado para `_OLD`;
- o arquivo assinado final deve manter o nome original.

#### Exemplo

Original:

```text
MeuModulo.dll
```

Resultado:

```text
MeuModulo_OLD.dll
MeuModulo.dll
```

---

### `RSign.Services.Signing`

#### Responsabilidade
Montar e executar o processo de assinatura do arquivo.

#### Deve fazer

- receber arquivo preparado para assinatura;
- montar linha de comando do `signtool`;
- aplicar SHA256;
- aplicar certificado `.pfx` e senha;
- aplicar timestamp quando configurado;
- capturar retorno da execução;
- devolver resultado estruturado.

#### Situações críticas previstas

- falha ao abrir PFX;
- senha incorreta;
- signtool indisponível;
- timestamp indisponível;
- arquivo não compatível;
- acesso negado.

#### Regra aprovada para timestamp

Quando o timestamp falhar, o sistema deve:

1. explicar o problema ao usuário;
2. informar o impacto da continuidade sem timestamp;
3. perguntar se deseja continuar sem timestamp.

---

### `RSign.Services.SigningVerification`

#### Responsabilidade
Verificar a assinatura após a operação.

#### Deve fazer

- executar verificação formal usando o `signtool`;
- identificar se a assinatura foi aplicada;
- identificar se o timestamp está presente quando aplicável;
- registrar resultado técnico;
- registrar resultado amigável.

#### Regra aprovada

- essa verificação deve vir **habilitada por padrão**;
- o usuário poderá desativá-la pela UI.

---

### `RSign.Services.UserDecision`

#### Responsabilidade
Abstrair a comunicação entre núcleo e UI para cenários em que o sistema precisa aguardar decisão do usuário.

#### Motivo

O orquestrador precisa perguntar coisas ao usuário sem depender diretamente de `ShowMessage`, `MessageDlg` ou componentes visuais específicos.

#### Exemplos de perguntas que essa unit deve suportar

- recriar certificado vencido;
- continuar sem timestamp;
- cancelar ou seguir com certificado próximo do vencimento;
- selecionar outro PFX;
- usar ou não o `signtool` encontrado automaticamente.

---

## 7.6. Camada UI

### `RSign.UI.Main`

#### Responsabilidade
Tela principal do sistema.

#### Deve conter

- controle de abas principal;
- área de ações principais;
- área de log visual;
- botões de carregar, salvar, validar e executar operação;
- integração com orquestrador.

#### Não deve conter

- regras de validação profunda do certificado;
- construção de comandos do signtool;
- manipulação de backup `_OLD`;
- lógica de persistência em baixo nível.

---

### `RSign.UI.Frame.CertificateProfile`

#### Responsabilidade
Representar a aba **Perfil do Certificado**.

#### Campos previstos

- nome do certificado;
- nome da empresa;
- organização;
- departamento;
- cidade;
- estado;
- país;
- e-mail;
- validade;
- senha;
- confirmação da senha;
- tipo do certificado.

#### Objetivo

Isolar a edição do perfil do certificado e facilitar reutilização e manutenção.

---

### `RSign.UI.Frame.SigningSettings`

#### Responsabilidade
Representar a aba **Configuração da Assinatura**.

#### Campos previstos

- caminho manual do `signtool`;
- localizar automaticamente;
- usar versão mais nova;
- URL do timestamp;
- verificar assinatura ao final;
- modo de log;
- habilitar confirmação em falha de timestamp.

---

### `RSign.UI.Frame.Paths`

#### Responsabilidade
Representar a aba **Locais e Arquivos**.

#### Blocos previstos

##### Certificado PFX
- local do PFX;
- nome do PFX;
- caminho completo final;
- localizar PFX;
- criar novo PFX.

##### Origem dos arquivos
- arquivo específico;
- pasta de entrada;
- modo arquivo único ou lote;
- lista dos arquivos encontrados.

##### Destino dos arquivos
- pasta de saída;
- opção de usar a mesma pasta do original;
- comportamento de backup `_OLD`.

---

## 8. Fluxos arquiteturais da aplicação

A seguir estão os fluxos internos que orientam a conversa entre as units.

---

## 8.1. Fluxo de inicialização

1. `RSign.View.Main` inicia a aplicação.
2. `RSign.UI.Main` é criada.
3. `RSign.Config.Manager` carrega o `.ini`.
4. `RSign.UI.Main` distribui os dados para os frames.
5. `RSign.Core.Orchestrator` é instanciado com os serviços.
6. `RSign.Services.Logger` é preparado.
7. A UI exibe os valores atuais e fica pronta para uso.

---

## 8.2. Fluxo de validação do ambiente

1. A UI solicita validação.
2. O orquestrador consulta `RSign.Services.SignTool`.
3. O serviço tenta caminho manual ou localização automática.
4. O resultado é enviado ao logger.
5. O status é devolvido para a UI.
6. A UI mostra ao usuário qual executável será usado.

---

## 8.3. Fluxo de validação do certificado

1. O orquestrador recebe a configuração do PFX.
2. `RSign.Services.Certificate` valida existência do arquivo.
3. Se não existir, o serviço informa que precisa criar.
4. Se existir, valida senha, vigência, integridade e chave privada.
5. Em caso de problema crítico, o orquestrador pede decisão ao usuário.
6. O resultado final retorna à UI e ao logger.

---

## 8.4. Fluxo de criação do certificado

1. O usuário confirma criação.
2. `RSign.Services.Certificate` monta o processo necessário.
3. O certificado é criado temporariamente no store.
4. O `.pfx` é exportado para o local configurado.
5. O artefato temporário do store é removido.
6. O serviço devolve caminho do PFX e detalhes técnicos.
7. O logger registra a operação.

---

## 8.5. Fluxo de assinatura de arquivo único

1. A UI seleciona um arquivo.
2. O orquestrador chama `RSign.Services.FileSigning`.
3. O arquivo é validado e preparado.
4. O original é renomeado para `_OLD`.
5. O orquestrador chama `RSign.Services.Signing`.
6. A assinatura é aplicada.
7. Se configurado, `RSign.Services.SigningVerification` valida o resultado.
8. O resultado final é devolvido à UI.

---

## 8.6. Fluxo de assinatura em lote

1. A UI seleciona uma pasta.
2. `RSign.Services.FileSigning` lista arquivos permitidos.
3. O orquestrador percorre os itens válidos.
4. Para cada item:
   - valida;
   - gera `_OLD`;
   - assina;
   - verifica;
   - registra log.
5. Ao final, o orquestrador consolida um resumo geral.
6. A UI exibe sucessos, falhas e avisos por item.

---

## 9. Comunicação entre unidades

Abaixo está a direção correta de dependência entre as camadas.

```text
UI -> Core.Orchestrator -> Services -> Utils / ProcessExecutor / Config / Types
```

### Regra de dependência

- A UI pode conhecer interfaces do Core e tipos compartilhados.
- Services podem conhecer Types, Config, Utils e Interfaces.
- Types não devem depender de UI.
- Config não deve depender de UI.
- Utils não deve depender de UI.
- O orquestrador não deve depender de componentes visuais concretos.

---

## 10. Papel das 3 abas dentro da arquitetura

As 3 abas da UI não são apenas uma divisão visual. Elas refletem três blocos lógicos da aplicação.

### Aba 1 — Perfil do Certificado
Mapeia para:

- `RSign.Types.Certificate`
- `RSign.Config.Manager`
- `RSign.Services.Certificate`

### Aba 2 — Configuração da Assinatura
Mapeia para:

- `RSign.Types.Signing`
- `RSign.Config.Manager`
- `RSign.Services.SignTool`
- `RSign.Services.Signing`
- `RSign.Services.SigningVerification`

### Aba 3 — Locais e Arquivos
Mapeia para:

- `RSign.Types.Config`
- `RSign.Config.Manager`
- `RSign.Services.FileSigning`

Essa separação precisa ser mantida para preservar clareza e evitar que a UI vire um bloco monolítico.

---

## 11. Contratos principais esperados

Esta seção descreve o comportamento esperado das interfaces principais, ainda sem amarrar a assinatura final do código.

### `ILoggerService`
Responsável por registrar mensagens técnicas e operacionais.

### `IConfigManager`
Responsável por salvar e restaurar a configuração completa do sistema.

### `IProcessExecutor`
Responsável por executar processos externos e devolver stdout, stderr e exit code.

### `ISignToolService`
Responsável por localizar e validar o `signtool.exe`.

### `ICertificateService`
Responsável por validar e criar certificados `.pfx`.

### `IFileSigningService`
Responsável por validar e preparar arquivos para assinatura.

### `ISigningService`
Responsável por montar e executar a assinatura.

### `ISigningVerificationService`
Responsável por verificar a assinatura aplicada.

### `IUserDecisionService`
Responsável por solicitar decisões da UI quando houver ambiguidade crítica.

### `IOrchestrator`
Responsável por coordenar o fluxo completo da operação.

---

## 12. Política de tratamento de falhas

Nem toda falha deve ter o mesmo comportamento.

### 12.1. Falhas bloqueantes diretas

Exemplos:

- arquivo inexistente;
- extensão inválida;
- signtool não encontrado;
- acesso negado irrecuperável;
- diretório de saída inválido.

Nesses casos, a operação deve ser encerrada com mensagem clara.

### 12.2. Falhas críticas com decisão assistida

Exemplos:

- certificado vencido;
- senha inválida;
- timestamp indisponível;
- certificado próximo do vencimento.

Nesses casos, o sistema deve:

1. registrar tecnicamente o problema;
2. exibir explicação amigável;
3. oferecer opções claras;
4. aguardar a decisão do usuário.

### 12.3. Falhas parciais em lote

Em operação por pasta, uma falha em um item não precisa obrigatoriamente impedir o restante, desde que isso esteja configurado no fluxo final do orquestrador.

A recomendação é:

- falha por item deve ser registrada individualmente;
- ao final deve existir um resumo consolidado.

---

## 13. Política de logs e rastreabilidade

Toda unit operacional relevante deve reportar eventos ao logger.

### O que precisa ser registrado

- início e fim da operação;
- parâmetros principais relevantes;
- caminho do signtool escolhido;
- validação do certificado;
- decisão do usuário quando houver;
- arquivo processado;
- criação do `_OLD`;
- comando executado;
- saída do comando;
- verificação final;
- sucesso ou erro.

### Tipos de saída recomendados

- log técnico em arquivo;
- log visual resumido na tela;
- detalhamento expandido opcionalmente.

---

## 14. Política de persistência

A persistência deve respeitar a divisão lógica da UI.

### O sistema deve salvar

- perfil do certificado;
- caminhos do PFX;
- local de entrada;
- local de saída;
- seleção do signtool;
- URL do timestamp;
- preferência de verificação pós-assinatura;
- preferência de log;
- último modo usado.

### O sistema não deve depender de memória de sessão apenas

Todas as configurações relevantes precisam ser reaplicáveis a cada abertura da aplicação.

---

## 15. Regras de segurança operacional

Embora seja uma ferramenta local, algumas regras devem ser respeitadas.

### 15.1. Senha padrão

A senha padrão pode permanecer como parte do fluxo inicial, mas a UI deve sempre permitir alteração.

### 15.2. Exibição da senha

A senha deve ser mascarada visualmente na interface.

### 15.3. Logs sensíveis

Evitar gravar a senha do certificado em texto puro no log.

### 15.4. Arquivos destrutivos

Toda operação que substitui o original deve ser protegida pelo fluxo `_OLD`.

---

## 16. Preparação para expansão futura

A arquitetura proposta não deve ser limitada ao autoassinado.

### Caminhos futuros previstos

- usar PFX externo já existente;
- usar certificado corporativo real;
- suportar múltiplos perfis de assinatura;
- permitir automação sem UI;
- geração de relatório final em arquivo separado;
- integração futura com validações adicionais.

### Como a arquitetura já ajuda nisso

- interfaces isoladas;
- tipos independentes da UI;
- orquestrador central;
- serviços segmentados por responsabilidade.

---

## 17. Ordem recomendada de criação das units

Para reduzir retrabalho, a seguinte ordem é a mais segura.

1. `RSign.Core.Constants`
2. `RSign.Types.Common`
3. `RSign.Types.Certificate`
4. `RSign.Types.Signing`
5. `RSign.Types.Config`
6. `RSign.Core.Interfaces`
7. `RSign.Config.Manager`
8. `RSign.Services.Logger`
9. `RSign.Services.ProcessExecutor`
10. `RSign.Services.SignTool`
11. `RSign.Services.FileSigning`
12. `RSign.Services.Certificate`
13. `RSign.Services.Signing`
14. `RSign.Services.SigningVerification`
15. `RSign.Services.UserDecision`
16. `RSign.Core.Orchestrator`
17. `RSign.UI.Frame.CertificateProfile`
18. `RSign.UI.Frame.SigningSettings`
19. `RSign.UI.Frame.Paths`
20. `RSign.UI.Main`
21. `RSign.View.Main`
22. `RSign.View.Configuracao`
23. `RSign.View.Log`

---

## 18. Fluxo técnico final esperado pelo usuário

Na visão de uso final, a aplicação deve funcionar assim:

1. O usuário abre o RSign.
2. O sistema carrega as configurações salvas.
3. O usuário revisa o perfil do certificado.
4. O usuário revisa as configurações de assinatura.
5. O usuário define o local do PFX e os arquivos de entrada/saída.
6. O sistema valida o signtool.
7. O sistema valida o certificado.
8. Se necessário, cria o certificado.
9. O sistema valida os arquivos selecionados.
10. O original é preservado como `_OLD`.
11. A assinatura é executada.
12. A verificação é executada.
13. O sistema apresenta resultado amigável e técnico.
14. Os logs ficam registrados para auditoria local.

---

## 19. Conclusão arquitetural

A arquitetura proposta para o **RSign** foi desenhada para atender simultaneamente quatro objetivos principais:

- manter clareza técnica e separação de responsabilidades;
- sustentar o fluxo aprovado sem sair do contexto do projeto;
- permitir implementação progressiva em Delphi 10.2 FMX;
- preparar o sistema para crescimento futuro sem refazer o núcleo.

O ponto central desta arquitetura é simples:

- a **UI coleta e apresenta**;
- o **orquestrador decide**;
- os **services executam**;
- os **types transportam dados**;
- a **configuração persiste estado**;
- o **logger registra rastreabilidade**.

Esse é o modelo que deve ser seguido durante toda a implementação do projeto.
