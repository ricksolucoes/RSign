# RSign — Matriz de Implementação

## 1. Objetivo deste documento

Este documento transforma a arquitetura e os contratos já aprovados do **RSign** em uma **matriz prática de implementação**, ligando diretamente:

- cada **interface** à sua **unit concreta**;
- cada **service** às dependências que ele precisa conhecer;
- a **ordem real de codificação** no Delphi 10;
- os **pré-requisitos** de cada módulo;
- os **critérios mínimos de conclusão** antes de avançar para a próxima etapa.

Este material deve ser usado como **guia operacional de desenvolvimento** do projeto, evitando começar units fora de ordem, reduzindo retrabalho e mantendo a implementação fiel ao escopo já aprovado.

---

## 2. Objetivo prático da matriz

A finalidade desta matriz é responder, de forma objetiva, às perguntas abaixo:

- qual interface será implementada em qual unit concreta;
- quais types precisam existir antes de implementar cada classe;
- quais services dependem de outros services;
- em que momento da implementação cada módulo entra;
- o que precisa estar pronto para considerar uma unit concluída;
- quais testes mínimos devem ser realizados antes de seguir.

---

## 3. Princípios de implementação que esta matriz assume

### 3.1. A ordem de criação importa

No RSign, a implementação deve começar pela base do projeto e só depois avançar para módulos operacionais e UI.

A sequência correta é:

1. constantes e types;
2. contratos;
3. configuração e logger;
4. executor de processos;
5. serviços de descoberta e validação;
6. serviços operacionais;
7. orquestrador;
8. UI e views.

### 3.2. A UI só entra depois do núcleo

As telas não devem ser o ponto de partida do projeto. Primeiro o núcleo precisa existir, ser previsível e estar organizado.

### 3.3. Toda implementação concreta deve respeitar o contrato aprovado

A classe concreta pode ter métodos privados auxiliares, mas a comunicação oficial com o restante do projeto deve seguir as interfaces descritas em `RSign.Core.Interfaces.pas`.

---

## 4. Legenda da matriz

### Colunas utilizadas

- **Ordem**: posição recomendada de implementação.
- **Interface**: contrato principal associado.
- **Unit concreta**: unit onde a implementação deve existir.
- **Classe sugerida**: nome recomendado para a classe concreta.
- **Depende de**: units ou contratos que precisam existir antes.
- **Usa Types**: estruturas de dados esperadas.
- **Critério de pronto**: condição mínima para considerar o módulo implementado.
- **Observações**: pontos técnicos relevantes.

---

## 5. Matriz principal de implementação

| Ordem | Interface | Unit concreta | Classe sugerida | Depende de | Usa Types | Critério de pronto | Observações |
|---|---|---|---|---|---|---|---|
| 1 | — | `RSign.Core.Constants.pas` | `TRSignConstants` ou constantes globais | nenhuma | — | constantes globais definidas e compilando | manter apenas defaults estáticos |
| 2 | — | `RSign.Types.Common.pas` | enums e records básicos | `RSign.Core.Constants` | `TStatusOperacao`, `TNivelLog`, `TModoAssinatura`, `TTipoCertificado`, etc. | tipos comuns consolidados | evitar strings soltas |
| 3 | — | `RSign.Types.Certificate.pas` | records do domínio de certificado | `RSign.Types.Common` | `TConfiguracaoCertificado`, `TStatusCertificado`, `TResultadoCriacaoCertificado` | records de certificado compilando | manter foco só em certificado |
| 4 | — | `RSign.Types.Signing.pas` | records do domínio de assinatura | `RSign.Types.Common` | `TConfiguracaoAssinatura`, `TItemArquivoAssinatura`, `TResultadoAssinatura`, `TStatusSignTool` | records de assinatura compilando | separar arquivo, signtool e resultado |
| 5 | — | `RSign.Types.Config.pas` | records de configuração persistida | `RSign.Types.Common`, `RSign.Types.Certificate`, `RSign.Types.Signing` | `TConfiguracaoGeral`, `TConfiguracaoCaminhos`, `TConfiguracaoLog`, `TConfiguracaoAplicacao` | bloco de configuração completo compilando | refletir as 3 abas da UI |
| 6 | todas | `RSign.Core.Interfaces.pas` | interfaces do núcleo | todos os Types | todos os types públicos | interfaces formalizadas e compilando | não colocar implementação |
| 7 | `IConfigManager` | `RSign.Config.Manager.pas` | `TConfigManager` | `RSign.Core.Interfaces`, `RSign.Types.Config`, `RSign.Core.Constants` | `TConfiguracaoAplicacao` e blocos internos | carregar/criar/salvar `.ini` funcionando | usar `TIniFile` ou equivalente compatível com Delphi 10 |
| 8 | `ILoggerService` | `RSign.Services.Logger.pas` | `TLoggerService` | `RSign.Core.Interfaces`, `RSign.Types.Common`, `RSign.Core.Constants` | `TNivelLog` e estrutura de evento de log | gravação em arquivo e emissão para UI funcionando | não registrar senha em texto puro |
| 9 | `IProcessExecutor` | `RSign.Services.ProcessExecutor.pas` | `TProcessExecutorService` | `RSign.Core.Interfaces`, `RSign.Types.Common`, `RSign.Services.Logger` | `TResultadoProcesso` | executar processo externo com stdout/stderr/exit code | base para PowerShell e signtool |
| 10 | `ISignToolService` | `RSign.Services.SignTool.pas` | `TSignToolService` | `IProcessExecutor`, `ILoggerService`, `IConfigManager`, `RSign.Core.Constants`, `RSign.Types.Signing` | `TStatusSignTool` | localizar e validar o `signtool.exe` | precisa suportar caminho manual e detecção automática |
| 11 | `IFileSigningService` | `RSign.Services.FileSigning.pas` | `TFileSigningService` | `ILoggerService`, `RSign.Core.Constants`, `RSign.Types.Signing`, `RSign.Utils.Path` | `TItemArquivoAssinatura`, `TResultadoPreparacaoArquivos` | validar arquivo(s), filtrar extensões e preparar `_OLD` | tratar arquivo único e lote |
| 12 | `ICertificateService` | `RSign.Services.Certificate.pas` | `TCertificateService` | `IProcessExecutor`, `ILoggerService`, `IConfigManager`, `RSign.Types.Certificate`, `RSign.Types.Common` | `TStatusCertificado`, `TResultadoCriacaoCertificado` | validar PFX e criar autoassinado com exportação | remover do store após exportar o PFX |
| 13 | `ISigningService` | `RSign.Services.Signing.pas` | `TSigningService` | `IProcessExecutor`, `ILoggerService`, `ISignToolService`, `ICertificateService`, `RSign.Types.Signing`, `RSign.Types.Certificate` | `TResultadoAssinatura` | assinatura real via `signtool sign` funcionando | precisa suportar fallback sem timestamp mediante decisão |
| 14 | `ISigningVerificationService` | `RSign.Services.SigningVerification.pas` | `TSigningVerificationService` | `IProcessExecutor`, `ILoggerService`, `ISignToolService`, `RSign.Types.Signing` | `TResultadoVerificacaoAssinatura` | verificação pós-assinatura funcionando | vem habilitada por padrão |
| 15 | `IUserDecisionService` | `RSign.Services.UserDecision.pas` | `TUserDecisionService` | `RSign.Core.Interfaces`, `RSign.Types.Common` | `TDecisaoUsuario`, `TOpcaoDecisao` | abstração de perguntas críticas funcionando | não acoplar ao `ShowMessage` diretamente no núcleo |
| 16 | `IOrchestrator` | `RSign.Core.Orchestrator.pas` | `TOrchestrator` | todos os serviços anteriores, `RSign.Types.*`, `RSign.Core.Interfaces` | todos os records de contexto e resultado | fluxo completo de validação, assinatura e verificação funcionando | coração do sistema |
| 17 | — | `RSign.UI.Frame.CertificateProfile.pas` | `TFrameCertificateProfile` | `RSign.Types.Certificate`, `IConfigManager` | `TConfiguracaoCertificado` | frame carregando/salvando dados do perfil | sem regra operacional |
| 18 | — | `RSign.UI.Frame.SigningSettings.pas` | `TFrameSigningSettings` | `RSign.Types.Signing`, `RSign.Types.Config`, `IConfigManager` | `TConfiguracaoAssinatura`, `TConfiguracaoLog` | frame refletindo opções técnicas e defaults | sem montar comando de assinatura |
| 19 | — | `RSign.UI.Frame.Paths.pas` | `TFramePaths` | `RSign.Types.Config`, `RSign.Types.Signing`, `IConfigManager`, `IFileSigningService` | `TConfiguracaoCaminhos` | frame de caminhos e seleção de arquivo/pasta funcional | filtro por extensões conhecidas |
| 20 | — | `RSign.UI.Main.pas` | `TFrmMain` | frames, `IOrchestrator`, `ILoggerService`, `IConfigManager` | configuração consolidada e status | integração visual principal pronta | sem lógica de negócio pesada |
| 21 | — | `RSign.View.Configuracao.pas` | composição da abertura/configuração | `RSign.UI.Main`, `IConfigManager` | tipos de configuração | fluxo de preferências organizado | útil mesmo com config embutida |
| 22 | — | `RSign.View.Log.pas` | composição da visualização de log | `ILoggerService`, `RSign.UI.Main` | eventos de log | visualização dedicada ou embutida organizada | separa apresentação de geração de log |
| 23 | — | `RSign.View.Main.pas` | bootstrap da aplicação | `RSign.UI.Main`, `RSign.Core.Orchestrator` e composição geral | contexto global | aplicação abre, injeta dependências e carrega estado inicial | último passo da montagem |

---

## 6. Matriz por interface e responsabilidades de implementação

## 6.1. `ILoggerService`

### Interface
`ILoggerService`

### Unit concreta
`RSign.Services.Logger.pas`

### Classe sugerida
`TLoggerService`

### Dependências mínimas
- `RSign.Core.Interfaces`
- `RSign.Types.Common`
- `RSign.Core.Constants`

### Deve implementar
- registro de log técnico em arquivo;
- buffer ou notificação para log visual;
- níveis de log padronizados;
- métodos para informação, aviso, erro, debug e sucesso;
- limpeza ou rotação simples do log, se previsto no contrato.

### Critério de pronto
- gerar arquivo de log em local configurado;
- enviar eventos para consumo da UI;
- omitir senha do PFX nos textos gravados.

### Testes mínimos
- registrar uma linha por nível;
- validar criação automática do arquivo;
- validar log concorrente básico entre múltiplas chamadas sequenciais.

---

## 6.2. `IConfigManager`

### Interface
`IConfigManager`

### Unit concreta
`RSign.Config.Manager.pas`

### Classe sugerida
`TConfigManager`

### Dependências mínimas
- `RSign.Core.Interfaces`
- `RSign.Types.Config`
- `RSign.Core.Constants`

### Deve implementar
- carregamento da configuração completa;
- salvamento da configuração completa;
- criação do `.ini` padrão quando não existir;
- leitura por seções lógicas correspondentes às 3 abas e log;
- retorno de estrutura pronta para consumo do orquestrador e da UI.

### Critério de pronto
- abrir o projeto sem `.ini` e gerar defaults válidos;
- salvar alterações e reabrir preservando os dados.

### Testes mínimos
- criar novo `.ini`;
- salvar valor alterado de senha, caminhos e timestamp;
- recarregar e comparar com o salvo.

---

## 6.3. `IProcessExecutor`

### Interface
`IProcessExecutor`

### Unit concreta
`RSign.Services.ProcessExecutor.pas`

### Classe sugerida
`TProcessExecutorService`

### Dependências mínimas
- `RSign.Core.Interfaces`
- `RSign.Services.Logger`
- types de resultado de processo

### Deve implementar
- execução de processo externo;
- passagem de argumentos;
- captura de `stdout` e `stderr`;
- retorno do código de saída;
- timeout configurável;
- retorno estruturado em vez de só booleano.

### Critério de pronto
- executar com sucesso comandos simples do Windows e capturar saída.

### Testes mínimos
- chamar `cmd /c echo teste`;
- chamar PowerShell simples;
- validar timeout em comando longo.

---

## 6.4. `ISignToolService`

### Interface
`ISignToolService`

### Unit concreta
`RSign.Services.SignTool.pas`

### Classe sugerida
`TSignToolService`

### Dependências mínimas
- `IProcessExecutor`
- `ILoggerService`
- `IConfigManager`
- `RSign.Core.Constants`
- `RSign.Types.Signing`

### Deve implementar
- validação de caminho manual;
- busca no `PATH`;
- busca em `Windows Kits`;
- coleta de candidatas;
- identificação de versão;
- seleção da mais nova por padrão;
- retorno estruturado com origem e caminho adotado.

### Critério de pronto
- localizar corretamente o `signtool.exe` mais adequado em ambiente real.

### Testes mínimos
- caminho manual válido;
- caminho manual inválido;
- detecção automática com múltiplas versões;
- ambiente sem signtool.

---

## 6.5. `ICertificateService`

### Interface
`ICertificateService`

### Unit concreta
`RSign.Services.Certificate.pas`

### Classe sugerida
`TCertificateService`

### Dependências mínimas
- `IProcessExecutor`
- `ILoggerService`
- `IConfigManager`
- `RSign.Types.Certificate`
- `RSign.Types.Common`

### Deve implementar
- verificação de existência do PFX;
- validação da senha do PFX;
- validação de integridade;
- validação de vigência;
- validação de chave privada;
- verificação de compatibilidade com assinatura;
- criação de autoassinado;
- exportação para `.pfx`;
- remoção do certificado temporário do store.

### Critério de pronto
- conseguir validar um PFX existente e criar um novo PFX autoassinado no fluxo aprovado.

### Testes mínimos
- PFX inexistente;
- PFX válido;
- senha inválida;
- PFX corrompido;
- criação nova com exportação e limpeza do store temporário.

---

## 6.6. `IFileSigningService`

### Interface
`IFileSigningService`

### Unit concreta
`RSign.Services.FileSigning.pas`

### Classe sugerida
`TFileSigningService`

### Dependências mínimas
- `ILoggerService`
- `RSign.Core.Constants`
- `RSign.Types.Signing`
- `RSign.Utils.Path`

### Deve implementar
- validação de existência do arquivo;
- filtro por extensões suportadas;
- validação de acesso e bloqueio;
- preparação do `_OLD`;
- preparação do nome final assinado;
- listagem de itens em lote.

### Critério de pronto
- receber arquivo ou pasta e devolver coleção estruturada pronta para assinatura.

### Testes mínimos
- arquivo único válido;
- arquivo com extensão inválida;
- pasta com mistura de itens válidos e inválidos;
- geração correta de nomes `_OLD`.

---

## 6.7. `ISigningService`

### Interface
`ISigningService`

### Unit concreta
`RSign.Services.Signing.pas`

### Classe sugerida
`TSigningService`

### Dependências mínimas
- `IProcessExecutor`
- `ILoggerService`
- `ISignToolService`
- `ICertificateService`
- `RSign.Types.Signing`
- `RSign.Types.Certificate`

### Deve implementar
- montagem do comando do `signtool sign`;
- uso do PFX e senha;
- SHA256;
- timestamp configurável;
- retorno estruturado da execução;
- suporte ao fluxo com e sem timestamp, conforme decisão do usuário.

### Critério de pronto
- conseguir assinar um arquivo válido usando PFX configurado e devolver resultado estruturado.

### Testes mínimos
- assinatura com timestamp funcionando;
- falha de timestamp com continuação autorizada;
- falha de PFX;
- falha de signtool.

---

## 6.8. `ISigningVerificationService`

### Interface
`ISigningVerificationService`

### Unit concreta
`RSign.Services.SigningVerification.pas`

### Classe sugerida
`TSigningVerificationService`

### Dependências mínimas
- `IProcessExecutor`
- `ILoggerService`
- `ISignToolService`
- `RSign.Types.Signing`

### Deve implementar
- chamada ao `signtool verify`;
- leitura do resultado;
- identificação se a assinatura foi aplicada;
- identificação se o timestamp foi reconhecido, quando aplicável;
- retorno estruturado de verificação.

### Critério de pronto
- conseguir validar tecnicamente uma assinatura recém-aplicada.

### Testes mínimos
- arquivo assinado corretamente;
- arquivo sem assinatura;
- verificação desabilitada por configuração;
- falha do signtool na verificação.

---

## 6.9. `IUserDecisionService`

### Interface
`IUserDecisionService`

### Unit concreta
`RSign.Services.UserDecision.pas`

### Classe sugerida
`TUserDecisionService`

### Dependências mínimas
- `RSign.Core.Interfaces`
- `RSign.Types.Common`

### Deve implementar
- exibição abstrata de perguntas críticas;
- retorno de decisão selecionada;
- encapsulamento das opções sem expor a UI concreta ao núcleo.

### Critério de pronto
- o orquestrador consegue solicitar decisão sem conhecer `MessageDlg`, `ShowMessage` ou componente visual específico.

### Testes mínimos
- pergunta sobre certificado vencido;
- pergunta sobre continuar sem timestamp;
- cancelamento explícito do usuário.

---

## 6.10. `IOrchestrator`

### Interface
`IOrchestrator`

### Unit concreta
`RSign.Core.Orchestrator.pas`

### Classe sugerida
`TOrchestrator`

### Dependências mínimas
- `ILoggerService`
- `IConfigManager`
- `IProcessExecutor`
- `ISignToolService`
- `ICertificateService`
- `IFileSigningService`
- `ISigningService`
- `ISigningVerificationService`
- `IUserDecisionService`
- todos os `RSign.Types.*`

### Deve implementar
- validação de configuração;
- validação do ambiente;
- localização e escolha do signtool;
- validação ou criação do certificado;
- preparação dos arquivos;
- execução da assinatura;
- execução da verificação;
- coleta de decisões do usuário em cenários críticos;
- consolidação do resultado final da operação.

### Critério de pronto
- executar o fluxo completo do RSign de ponta a ponta, tanto em arquivo único quanto em lote.

### Testes mínimos
- fluxo completo com arquivo único;
- fluxo completo em lote;
- certificado inexistente com criação;
- timestamp falhando e decisão do usuário;
- item inválido em lote sem derrubar todo o restante, conforme política definida.

---

## 7. Matriz de dependências entre módulos

```text
RSign.Core.Constants
        ↓
RSign.Types.Common
        ↓
RSign.Types.Certificate / RSign.Types.Signing / RSign.Types.Config
        ↓
RSign.Core.Interfaces
        ↓
RSign.Config.Manager + RSign.Services.Logger
        ↓
RSign.Services.ProcessExecutor
        ↓
RSign.Services.SignTool + RSign.Services.FileSigning + RSign.Services.Certificate
        ↓
RSign.Services.Signing + RSign.Services.SigningVerification + RSign.Services.UserDecision
        ↓
RSign.Core.Orchestrator
        ↓
RSign.UI.Frame.*
        ↓
RSign.UI.Main
        ↓
RSign.View.Configuracao / RSign.View.Log / RSign.View.Main
```

### Regra importante

Nenhuma unit de UI deve ser dependência obrigatória do núcleo. A direção correta continua sendo do visual para o núcleo, nunca o contrário.

---

## 8. Matriz de implementação por fase

## Fase 1 — Base do projeto

### Units
- `RSign.Core.Constants`
- `RSign.Types.Common`
- `RSign.Types.Certificate`
- `RSign.Types.Signing`
- `RSign.Types.Config`
- `RSign.Core.Interfaces`

### Resultado esperado
O projeto passa a ter linguagem comum, contratos e tipos base estáveis.

---

## Fase 2 — Persistência e rastreabilidade

### Units
- `RSign.Config.Manager`
- `RSign.Services.Logger`

### Resultado esperado
A aplicação consegue carregar defaults, persistir preferências e registrar operação.

---

## Fase 3 — Infraestrutura operacional

### Units
- `RSign.Services.ProcessExecutor`
- `RSign.Services.SignTool`
- `RSign.Services.FileSigning`

### Resultado esperado
O projeto consegue executar processos externos, localizar signtool e preparar arquivos.

---

## Fase 4 — Certificado

### Units
- `RSign.Services.Certificate`

### Resultado esperado
O projeto consegue validar PFX existente ou criar um novo autoassinado no fluxo aprovado.

---

## Fase 5 — Assinatura e verificação

### Units
- `RSign.Services.Signing`
- `RSign.Services.SigningVerification`
- `RSign.Services.UserDecision`

### Resultado esperado
O projeto assina, pergunta quando necessário e verifica o resultado.

---

## Fase 6 — Orquestração

### Units
- `RSign.Core.Orchestrator`

### Resultado esperado
O fluxo completo fica centralizado e reaproveitável.

---

## Fase 7 — Interface FMX

### Units
- `RSign.UI.Frame.CertificateProfile`
- `RSign.UI.Frame.SigningSettings`
- `RSign.UI.Frame.Paths`
- `RSign.UI.Main`
- `RSign.View.Configuracao`
- `RSign.View.Log`
- `RSign.View.Main`

### Resultado esperado
A aplicação fica utilizável visualmente sem transferir lógica de negócio para os forms.

---

## 9. Critérios globais de aceite da implementação

A implementação do RSign pode ser considerada coerente com esta matriz quando:

1. todos os contracts estiverem implementados por classes concretas nas units previstas;
2. a UI consumir interfaces, e não regras de negócio diretamente;
3. o orquestrador centralizar o fluxo completo;
4. o certificado puder ser validado e criado conforme o fluxo aprovado;
5. a assinatura funcionar em arquivo único e lote;
6. a verificação pós-assinatura estiver operacional;
7. os logs existirem em tela e arquivo;
8. as decisões críticas passarem por `IUserDecisionService`;
9. a persistência das configurações refletir as 3 abas da UI;
10. a solução compilar de forma organizada no Delphi 10.

---

## 10. Conclusão

Esta matriz existe para transformar a documentação do **RSign** em uma sequência executável de desenvolvimento.

A ideia central que deve ser preservada durante toda a implementação é:

- **types definem a linguagem comum**;
- **interfaces definem o contrato**;
- **services executam responsabilidades isoladas**;
- **o orquestrador coordena o fluxo**;
- **a UI apenas coleta, apresenta e dispara operações**.

Esse documento deve ser usado como referência permanente para decidir:

- o que implementar primeiro;
- onde cada classe deve nascer;
- o que cada módulo pode ou não pode conhecer;
- quando uma etapa realmente está pronta para avançar.
