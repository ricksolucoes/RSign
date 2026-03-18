# RSign — Documento de Interfaces e Contratos

## 1. Objetivo deste documento

Este documento define, em nível de contrato, o que cada **service**, o **orquestrador** e os contratos auxiliares do projeto **RSign** devem expor no Delphi 10.

O foco deste material é detalhar:

- as interfaces formais esperadas para o núcleo da aplicação;
- os métodos que cada interface deve disponibilizar;
- a responsabilidade exata de cada método;
- os parâmetros de entrada esperados;
- os retornos esperados;
- as regras de uso e de não uso;
- os vínculos entre contratos, tipos e fluxo operacional.

Este documento complementa o material arquitetural já aprovado e deve ser usado como **base oficial** para implementar a unit `RSign.Core.Interfaces.pas` e guiar a criação das classes concretas nas units de `Services`, `Config` e `Core`.

---

## 2. Finalidade prática dos contratos

No RSign, os contratos existem para impedir que a aplicação cresça de forma acoplada à interface FMX.

Na prática, eles precisam garantir que:

- a UI não chame classes concretas diretamente sem necessidade;
- a orquestração do fluxo seja previsível;
- a implementação possa ser trocada sem quebrar o restante do sistema;
- o projeto permaneça apto para futura evolução para console, automação ou integração externa;
- cada responsabilidade técnica fique claramente isolada.

---

## 3. Princípios obrigatórios para o desenho das interfaces

## 3.1. Interfaces devem representar intenção de negócio

Os contratos não devem expor detalhes desnecessários de implementação.

Exemplo correto:

- `ValidarCertificado`
- `CriarCertificadoAutoassinado`
- `LocalizarSignTool`
- `PrepararArquivos`

Exemplo incorreto:

- `ExecutarPowerShellInternoA`
- `MontarLinhaX`
- `FazerCopiaTemporaria2`

A implementação concreta pode usar PowerShell, `signtool`, APIs do Windows ou outros mecanismos, mas a interface deve continuar representando o **objetivo funcional**, não o mecanismo interno.

---

## 3.2. Interfaces devem devolver estruturas ricas

Sempre que a operação puder gerar múltiplos dados relevantes, o retorno deve ser uma estrutura rica, e não apenas `Boolean`.

Exemplo:

- status encontrado;
- código de retorno;
- mensagem técnica;
- mensagem amigável;
- caminho resolvido;
- necessidade de decisão do usuário.

Isso evita múltiplos parâmetros `out` desnecessários e melhora legibilidade.

---

## 3.3. Métodos não devem misturar responsabilidades

Um método de validação não deve também salvar configuração.

Um método de assinatura não deve também decidir por conta própria se o usuário deseja continuar sem timestamp.

Um método de UI não deve ser necessário para que o orquestrador funcione.

---

## 3.4. Contratos precisam permitir operação assistida

Como o projeto possui vários pontos de decisão do usuário, o núcleo precisa conseguir perguntar sem depender diretamente de controles visuais.

Por isso o contrato `IUserDecisionService` é obrigatório.

---

## 3.5. Contratos devem ser compatíveis com Delphi 10

As assinaturas sugeridas neste documento foram pensadas para Delphi 10, evitando dependência de recursos mais recentes da linguagem.

---

## 4. Convenções sugeridas para a implementação dos contratos

## 4.1. Nome das interfaces

As interfaces devem usar prefixo `I`.

Exemplos:

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

---

## 4.2. Nome dos métodos

Os métodos devem ser escritos em português e refletir ações claras.

Exemplos:

- `CarregarConfiguracao`
- `SalvarConfiguracao`
- `LocalizarSignTool`
- `ValidarCertificado`
- `PrepararArquivos`
- `AssinarArquivo`
- `VerificarAssinatura`

---

## 4.3. Parâmetros

Sugestão de padrão:

- parâmetros de entrada com prefixo `A`;
- variáveis locais com prefixo `L` na implementação concreta;
- campos com prefixo `F` nas classes concretas.

---

## 4.4. Exceptions vs resultado estruturado

A recomendação para o RSign é:

- usar **resultado estruturado** para cenários esperados de negócio;
- usar **exception** apenas para falhas realmente inesperadas ou de infraestrutura interna.

Exemplo de resultado estruturado:

- certificado vencido;
- timestamp indisponível;
- arquivo com extensão não suportada.

Exemplo de exception aceitável:

- erro interno de acesso a memória;
- falha irrecuperável de parsing interno;
- corrupção de estado que não deveria acontecer.

---

## 5. Tipos auxiliares que os contratos pressupõem

Antes de listar as interfaces, este documento define os principais tipos que elas devem usar. Eles não precisam ser implementados exatamente com este nome, mas a ideia funcional precisa ser preservada.

---

## 5.1. Tipos gerais

### `TStatusOperacao`

Representa o estado geral de uma operação.

Valores sugeridos:

- `stNaoIniciado`
- `stSucesso`
- `stAviso`
- `stFalha`
- `stCancelado`
- `stRequerDecisao`

---

### `TNivelLog`

Representa o nível do evento de log.

Valores sugeridos:

- `nlInfo`
- `nlWarning`
- `nlError`
- `nlDebug`
- `nlSuccess`

---

### `TModoAssinatura`

Representa o modo de processamento de arquivos.

Valores sugeridos:

- `maArquivoUnico`
- `maLote`

---

### `TTipoCertificado`

Representa a origem lógica do certificado.

Valores sugeridos:

- `tcAutoassinado`
- `tcPFXExterno`
- `tcCodeSigningReal`

---

### `TOrigemSignTool`

Representa como o `signtool` foi escolhido.

Valores sugeridos:

- `osManual`
- `osPath`
- `osWindowsKits`
- `osNaoEncontrado`

---

### `TAcaoUsuarioFalha`

Representa a decisão tomada pelo usuário em cenários críticos.

Valores sugeridos:

- `aufCancelar`
- `aufContinuar`
- `aufRecriar`
- `aufSelecionarOutro`
- `aufIgnorar`
- `aufTentarNovamente`

---

## 5.2. Estruturas gerais de resultado

### `TResultadoPadrao`

Estrutura base para respostas simples.

Campos mínimos sugeridos:

- `Status: TStatusOperacao`
- `Sucesso: Boolean`
- `MensagemAmigavel: string`
- `MensagemTecnica: string`

---

### `TResultadoProcesso`

Estrutura de retorno de execução externa.

Campos mínimos sugeridos:

- `Sucesso: Boolean`
- `CodigoSaida: Integer`
- `SaidaPadrao: string`
- `SaidaErro: string`
- `ComandoCompleto: string`
- `TempoExecucaoMs: Int64`
- `MensagemAmigavel: string`
- `MensagemTecnica: string`

---

### `TLogEvento`

Estrutura de evento de log.

Campos mínimos sugeridos:

- `DataHora: TDateTime`
- `Nivel: TNivelLog`
- `Origem: string`
- `MensagemAmigavel: string`
- `MensagemTecnica: string`

---

## 5.3. Estruturas de configuração

### `TConfiguracaoCertificado`

Campos mínimos já aprovados pela arquitetura:

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
- pasta base do PFX;
- nome do arquivo PFX.

---

### `TConfiguracaoAssinatura`

Campos mínimos sugeridos:

- usar detecção automática do `signtool`;
- caminho manual do `signtool`;
- usar versão mais nova;
- URL do timestamp;
- verificar após assinar;
- permitir continuidade sem timestamp mediante confirmação;
- modo de operação;
- usar mesma pasta de saída;
- pasta de entrada;
- pasta de saída;
- arquivo único selecionado.

---

### `TConfiguracaoLog`

Campos mínimos sugeridos:

- habilitar log em arquivo;
- habilitar log visual;
- pasta do log;
- nome base do log;
- gravar debug ou não.

---

### `TConfiguracaoGeral`

Estrutura consolidada da aplicação.

Campos mínimos sugeridos:

- `Certificado: TConfiguracaoCertificado`
- `Assinatura: TConfiguracaoAssinatura`
- `Log: TConfiguracaoLog`

---

## 5.4. Estruturas específicas de domínio

### `TStatusSignTool`

Campos mínimos sugeridos:

- `Encontrado: Boolean`
- `Valido: Boolean`
- `Origem: TOrigemSignTool`
- `Caminho: string`
- `Versao: string`
- `MensagemAmigavel: string`
- `MensagemTecnica: string`

---

### `TStatusCertificado`

Campos mínimos sugeridos:

- `ArquivoExiste: Boolean`
- `SenhaValida: Boolean`
- `Integro: Boolean`
- `PossuiChavePrivada: Boolean`
- `CompativelAssinatura: Boolean`
- `DataInicial: TDateTime`
- `DataFinal: TDateTime`
- `Vencido: Boolean`
- `ProximoVencimento: Boolean`
- `RequerDecisao: Boolean`
- `MensagemAmigavel: string`
- `MensagemTecnica: string`

---

### `TResultadoCriacaoCertificado`

Campos mínimos sugeridos:

- `Sucesso: Boolean`
- `CaminhoPFX: string`
- `Thumbprint: string`
- `ResultadoProcesso: TResultadoProcesso`
- `MensagemAmigavel: string`
- `MensagemTecnica: string`

---

### `TItemArquivoAssinatura`

Campos mínimos sugeridos:

- `CaminhoOriginal: string`
- `NomeArquivo: string`
- `Extensao: string`
- `CaminhoBackupOld: string`
- `CaminhoAssinadoFinal: string`
- `Valido: Boolean`
- `MotivoBloqueio: string`

---

### `TResultadoPreparacaoArquivo`

Campos mínimos sugeridos:

- `Sucesso: Boolean`
- `Item: TItemArquivoAssinatura`
- `MensagemAmigavel: string`
- `MensagemTecnica: string`

---

### `TResultadoAssinatura`

Campos mínimos sugeridos:

- `ArquivoAlvo: string`
- `Sucesso: Boolean`
- `ComandoExecutado: string`
- `CodigoRetorno: Integer`
- `SaidaPadrao: string`
- `SaidaErro: string`
- `AssinaturaAplicada: Boolean`
- `TimestampAplicado: Boolean`
- `MensagemAmigavel: string`
- `MensagemTecnica: string`

---

### `TResultadoVerificacaoAssinatura`

Campos mínimos sugeridos:

- `Sucesso: Boolean`
- `AssinaturaValida: Boolean`
- `TimestampPresente: Boolean`
- `CodigoRetorno: Integer`
- `SaidaPadrao: string`
- `SaidaErro: string`
- `MensagemAmigavel: string`
- `MensagemTecnica: string`

---

### `TSolicitacaoDecisaoUsuario`

Campos mínimos sugeridos:

- `Codigo: string`
- `Titulo: string`
- `MensagemAmigavel: string`
- `MensagemTecnica: string`
- `OpcoesDisponiveis: TArray<TAcaoUsuarioFalha>`
- `OpcaoPadrao: TAcaoUsuarioFalha`

---

### `TRespostaDecisaoUsuario`

Campos mínimos sugeridos:

- `Confirmado: Boolean`
- `AcaoSelecionada: TAcaoUsuarioFalha`
- `Observacao: string`

---

### `TResultadoLoteAssinatura`

Campos mínimos sugeridos:

- `QuantidadeTotal: Integer`
- `QuantidadeSucesso: Integer`
- `QuantidadeFalha: Integer`
- `QuantidadeAviso: Integer`
- `Itens: TArray<TResultadoAssinatura>`
- `MensagemAmigavel: string`
- `MensagemTecnica: string`

---

## 6. Contrato `ILoggerService`

## 6.1. Finalidade

Centralizar o registro de eventos técnicos e operacionais da aplicação.

Esse contrato não deve depender de controles específicos da UI. Ele precisa permitir que a aplicação registre eventos tanto em arquivo quanto em memória e que a interface apenas consuma o que for necessário.

---

## 6.2. Assinatura sugerida

```pascal
 type
   ILoggerService = interface
     ['{A0F5A6B1-7A56-4A2C-8A1A-1D7CBE7F0001}']
     procedure Registrar(const ANivel: TNivelLog; const AOrigem: string;
       const AMensagemAmigavel: string; const AMensagemTecnica: string = '');
     procedure Info(const AOrigem: string; const AMensagemAmigavel: string;
       const AMensagemTecnica: string = '');
     procedure Aviso(const AOrigem: string; const AMensagemAmigavel: string;
       const AMensagemTecnica: string = '');
     procedure Erro(const AOrigem: string; const AMensagemAmigavel: string;
       const AMensagemTecnica: string = '');
     procedure Debug(const AOrigem: string; const AMensagemAmigavel: string;
       const AMensagemTecnica: string = '');
     procedure Sucesso(const AOrigem: string; const AMensagemAmigavel: string;
       const AMensagemTecnica: string = '');
     function ListarEventosSessao: TArray<TLogEvento>;
     procedure LimparSessao;
     procedure PersistirSessao;
   end;
```

---

## 6.3. Métodos detalhados

### `Registrar`

#### Objetivo
Registrar um evento genérico com nível explícito.

#### Quando usar
Quando a camada chamadora já souber exatamente o nível do evento.

#### Parâmetros
- `ANivel`: nível do log.
- `AOrigem`: nome lógico da unit, interface ou etapa.
- `AMensagemAmigavel`: texto apropriado para leitura humana.
- `AMensagemTecnica`: detalhe adicional técnico.

#### Retorno
Não retorna valor.

#### Observações
Esse é o método base. Os demais atalhos devem delegar para ele.

---

### `Info`

#### Objetivo
Registrar evento informativo.

#### Uso típico
- início de fluxo;
- carregamento de configuração;
- caminho de entrada carregado;
- detecção de `signtool`.

---

### `Aviso`

#### Objetivo
Registrar evento não bloqueante, mas relevante.

#### Uso típico
- certificado próximo do vencimento;
- timestamp indisponível antes da decisão do usuário;
- item ignorado em lote.

---

### `Erro`

#### Objetivo
Registrar falha relevante.

#### Uso típico
- PFX inválido;
- assinatura falhou;
- `signtool` não encontrado;
- acesso negado.

---

### `Debug`

#### Objetivo
Registrar detalhe técnico adicional, útil para diagnóstico.

#### Uso típico
- comando externo montado;
- código de saída;
- resposta integral do processo;
- caminhos intermediários.

#### Observação
O uso visual na UI pode ser filtrado.

---

### `Sucesso`

#### Objetivo
Registrar etapa concluída com êxito.

#### Uso típico
- certificado criado;
- arquivo preparado;
- assinatura concluída;
- verificação aprovada.

---

### `ListarEventosSessao`

#### Objetivo
Devolver todos os eventos registrados durante a sessão atual.

#### Retorno
Array de `TLogEvento`.

#### Uso típico
- alimentar grid ou memo de log visual;
- exportar sessão;
- montar resumo final.

---

### `LimparSessao`

#### Objetivo
Limpar a memória de eventos da sessão atual.

#### Uso típico
Antes de começar uma nova operação manual completa.

---

### `PersistirSessao`

#### Objetivo
Forçar gravação do conteúdo acumulado em arquivo, caso a implementação trabalhe com buffer.

#### Uso típico
- final de lote;
- fechamento controlado da aplicação;
- auditoria manual.

---

## 7. Contrato `IConfigManager`

## 7.1. Finalidade

Persistir, carregar, validar e restaurar a configuração da aplicação, respeitando as três abas lógicas aprovadas:

- perfil do certificado;
- configuração da assinatura;
- locais e arquivos.

---

## 7.2. Assinatura sugerida

```pascal
 type
   IConfigManager = interface
     ['{A0F5A6B1-7A56-4A2C-8A1A-1D7CBE7F0002}']
     function CarregarConfiguracao: TConfiguracaoGeral;
     function SalvarConfiguracao(const AConfiguracao: TConfiguracaoGeral): TResultadoPadrao;
     function CriarConfiguracaoPadrao: TConfiguracaoGeral;
     function ValidarConfiguracao(const AConfiguracao: TConfiguracaoGeral): TResultadoPadrao;
     function ObterCaminhoArquivoConfiguracao: string;
     function ConfiguracaoExiste: Boolean;
   end;
```

---

## 7.3. Métodos detalhados

### `CarregarConfiguracao`

#### Objetivo
Ler a configuração persistida e devolver a estrutura consolidada pronta para uso.

#### Regras
- se o arquivo não existir, a implementação pode criar defaults internamente ou devolver estrutura padrão;
- não deve acionar UI;
- não deve validar profundamente arquivo a arquivo.

---

### `SalvarConfiguracao`

#### Objetivo
Persistir o estado atual da configuração.

#### Entrada
`AConfiguracao` consolidada.

#### Retorno
`TResultadoPadrao` indicando sucesso ou falha de persistência.

#### Regras
- deve validar os campos mínimos antes de gravar;
- não deve decidir regras de assinatura.

---

### `CriarConfiguracaoPadrao`

#### Objetivo
Devolver a estrutura default do sistema, baseada nas constantes aprovadas.

#### Uso típico
- primeira execução;
- restaurar defaults;
- fallback quando o `.ini` estiver ausente.

---

### `ValidarConfiguracao`

#### Objetivo
Fazer validação estrutural mínima da configuração, sem executar o fluxo técnico profundo.

#### Deve validar
- campos básicos vazios;
- consistência de caminhos básicos;
- modo de operação selecionado;
- nome do PFX informado.

#### Não deve validar
- integridade real do PFX;
- existência real do `signtool`;
- assinatura real de arquivos.

---

### `ObterCaminhoArquivoConfiguracao`

#### Objetivo
Informar o caminho físico do arquivo de configuração utilizado.

#### Uso típico
- exibir na UI;
- depuração;
- suporte técnico.

---

### `ConfiguracaoExiste`

#### Objetivo
Indicar se já há persistência prévia.

#### Uso típico
- decidir se a UI carrega defaults ou não;
- controles de primeira execução.

---

## 8. Contrato `IProcessExecutor`

## 8.1. Finalidade

Centralizar a execução de processos externos do Windows, como PowerShell e `signtool.exe`, com captura padronizada de retorno.

---

## 8.2. Assinatura sugerida

```pascal
 type
   IProcessExecutor = interface
     ['{A0F5A6B1-7A56-4A2C-8A1A-1D7CBE7F0003}']
     function Executar(const AArquivoExecutavel: string; const AParametros: string;
       const ADiretorioTrabalho: string = ''; const ATimeoutMs: Cardinal = 0): TResultadoProcesso;
     function ExecutarComandoCompleto(const AComandoCompleto: string;
       const ADiretorioTrabalho: string = ''; const ATimeoutMs: Cardinal = 0): TResultadoProcesso;
     function ExecutavelExiste(const AArquivoExecutavel: string): Boolean;
   end;
```

---

## 8.3. Métodos detalhados

### `Executar`

#### Objetivo
Executar um binário externo com parâmetros separados.

#### Uso típico
- chamar `signtool.exe`;
- chamar `powershell.exe`;
- chamar `certutil`, se necessário futuramente.

#### Retorno
`TResultadoProcesso` com stdout, stderr, exit code e comando consolidado.

#### Regras
- deve capturar saída padrão e erro padrão;
- deve respeitar timeout quando informado;
- não deve interpretar regra de negócio.

---

### `ExecutarComandoCompleto`

#### Objetivo
Executar um comando pronto quando a composição do texto integral já tiver sido feita por outro serviço.

#### Uso típico
- comandos PowerShell completos;
- execução de script pontual.

#### Observação
A implementação concreta deve tomar cuidado com quoting e escaping.

---

### `ExecutavelExiste`

#### Objetivo
Fazer validação simples de existência física do executável.

#### Uso típico
Antes de tentar uma execução real.

---

## 9. Contrato `ISignToolService`

## 9.1. Finalidade

Localizar, validar e escolher o `signtool.exe` que será usado pelo sistema.

---

## 9.2. Assinatura sugerida

```pascal
 type
   ISignToolService = interface
     ['{A0F5A6B1-7A56-4A2C-8A1A-1D7CBE7F0004}']
     function LocalizarSignTool(const AConfiguracao: TConfiguracaoAssinatura): TStatusSignTool;
     function ValidarSignTool(const ACaminhoSignTool: string): TStatusSignTool;
     function ListarSignToolsDisponiveis: TArray<TStatusSignTool>;
     function ObterVersaoSignTool(const ACaminhoSignTool: string): string;
     function SelecionarMaisNovo(const ALista: TArray<TStatusSignTool>): TStatusSignTool;
   end;
```

---

## 9.3. Métodos detalhados

### `LocalizarSignTool`

#### Objetivo
Resolver o `signtool` final a partir da configuração.

#### Deve considerar
- caminho manual informado;
- busca no `PATH`;
- busca em Windows Kits;
- preferência pelo mais novo;
- override manual quando configurado.

#### Retorno
`TStatusSignTool` consolidado.

---

### `ValidarSignTool`

#### Objetivo
Validar um caminho específico de `signtool.exe`.

#### Deve verificar
- se o arquivo existe;
- se o executável responde;
- se a versão pode ser lida;
- se o caminho é tecnicamente utilizável.

---

### `ListarSignToolsDisponiveis`

#### Objetivo
Devolver todas as instâncias candidatas encontradas.

#### Uso típico
- preencher UI de seleção manual;
- diagnóstico técnico;
- auditoria de ambiente.

---

### `ObterVersaoSignTool`

#### Objetivo
Ler a versão do binário.

#### Retorno
String com a versão ou vazio quando não disponível.

---

### `SelecionarMaisNovo`

#### Objetivo
Escolher o melhor item de uma lista já localizada.

#### Observação
Esse método deve ser determinístico e documentar claramente o critério de comparação.

---

## 10. Contrato `ICertificateService`

## 10.1. Finalidade

Validar, criar, recriar e inspecionar o certificado `.pfx` usado pela assinatura.

---

## 10. Assinatura sugerida

```pascal
 type
   ICertificateService = interface
     ['{A0F5A6B1-7A56-4A2C-8A1A-1D7CBE7F0005}']
     function ObterCaminhoPFX(const AConfiguracao: TConfiguracaoCertificado): string;
     function CertificadoExiste(const AConfiguracao: TConfiguracaoCertificado): Boolean;
     function ValidarCertificado(const AConfiguracao: TConfiguracaoCertificado): TStatusCertificado;
     function ValidarSenhaPFX(const ACaminhoPFX: string; const ASenha: string): TResultadoPadrao;
     function CriarCertificadoAutoassinado(
       const AConfiguracao: TConfiguracaoCertificado): TResultadoCriacaoCertificado;
     function RecriarCertificadoAutoassinado(
       const AConfiguracao: TConfiguracaoCertificado): TResultadoCriacaoCertificado;
     function RemoverCertificadoTemporarioStore(const AThumbprint: string): TResultadoPadrao;
   end;
```

---

## 10.3. Métodos detalhados

### `ObterCaminhoPFX`

#### Objetivo
Montar o caminho completo final do PFX a partir da configuração.

#### Uso típico
- exibição em UI;
- validação de existência;
- criação de certificado.

---

### `CertificadoExiste`

#### Objetivo
Fazer checagem simples de existência física do PFX.

#### Observação
Esse método não substitui `ValidarCertificado`.

---

### `ValidarCertificado`

#### Objetivo
Executar a validação completa do certificado conforme a regra de negócio aprovada.

#### Deve verificar
- se o arquivo existe;
- se a senha é válida;
- se o arquivo está íntegro;
- se possui chave privada;
- se é compatível com assinatura;
- se está vencido;
- se está próximo do vencimento.

#### Retorno
`TStatusCertificado`.

#### Regra importante
Se a situação exigir intervenção do usuário, o retorno deve marcar `RequerDecisao = True` e explicar a situação, mas não deve abrir UI por conta própria.

---

### `ValidarSenhaPFX`

#### Objetivo
Validar apenas a senha do PFX, sem reexecutar toda a análise sem necessidade.

#### Uso típico
- edição de configuração;
- confirmação prévia rápida.

---

### `CriarCertificadoAutoassinado`

#### Objetivo
Criar o certificado autoassinado conforme o perfil configurado.

#### Fluxo esperado
- criar temporariamente no store `CurrentUser\My`;
- exportar para `.pfx`;
- remover o artefato temporário do store;
- devolver detalhes da operação.

#### Retorno
`TResultadoCriacaoCertificado`.

---

### `RecriarCertificadoAutoassinado`

#### Objetivo
Gerar um novo certificado substituindo a estratégia anterior quando houver decisão explícita do usuário.

#### Diferença para o método anterior
Esse método existe para deixar explícito que a ação partiu de um cenário de falha, vencimento ou invalidação do PFX anterior.

---

### `RemoverCertificadoTemporarioStore`

#### Objetivo
Remover o certificado temporário do store após exportação.

#### Uso típico
- final do fluxo de criação;
- limpeza corretiva.

---

## 11. Contrato `IFileSigningService`

## 11.1. Finalidade

Validar e preparar os arquivos que serão assinados.

---

## 11.2. Assinatura sugerida

```pascal
 type
   IFileSigningService = interface
     ['{A0F5A6B1-7A56-4A2C-8A1A-1D7CBE7F0006}']
     function ValidarArquivo(const ACaminhoArquivo: string): TResultadoPreparacaoArquivo;
     function ListarArquivosValidos(const APasta: string): TArray<TItemArquivoAssinatura>;
     function PrepararArquivo(const ACaminhoArquivo: string;
       const APastaSaida: string; const AUsarMesmaPasta: Boolean): TResultadoPreparacaoArquivo;
     function PrepararArquivos(const APastaEntrada: string; const APastaSaida: string;
       const AUsarMesmaPasta: Boolean): TArray<TResultadoPreparacaoArquivo>;
     function ExtensaoSuportada(const AExtensao: string): Boolean;
   end;
```

---

## 11.3. Métodos detalhados

### `ValidarArquivo`

#### Objetivo
Executar a validação estrutural de um arquivo candidato.

#### Deve verificar
- existência;
- extensão suportada;
- acesso de leitura e escrita;
- bloqueio por uso;
- viabilidade de operação.

---

### `ListarArquivosValidos`

#### Objetivo
Ler uma pasta e devolver apenas arquivos compatíveis.

#### Regras
- deve considerar apenas extensões aprovadas;
- não deve iniciar assinatura;
- deve ser apropriado para exibição em grade ou lista na UI.

---

### `PrepararArquivo`

#### Objetivo
Calcular e preparar toda a estrutura de backup e destino para um único arquivo.

#### Deve definir
- caminho `_OLD`;
- caminho final do assinado;
- validação prévia da pasta de saída.

#### Observação
A criação física do `_OLD` pode ser feita aqui ou em etapa imediatamente anterior à assinatura, mas a decisão deve ser consistente no projeto inteiro.

---

### `PrepararArquivos`

#### Objetivo
Executar a preparação em lote.

#### Uso típico
Operação por pasta.

---

### `ExtensaoSuportada`

#### Objetivo
Responder se a extensão faz parte da política aprovada.

#### Extensões aprovadas
- `.exe`
- `.dll`
- `.msi`
- `.cab`
- `.cat`

---

## 12. Contrato `ISigningService`

## 12.1. Finalidade

Montar e executar o processo efetivo de assinatura do arquivo.

---

## 12.2. Assinatura sugerida

```pascal
 type
   ISigningService = interface
     ['{A0F5A6B1-7A56-4A2C-8A1A-1D7CBE7F0007}']
     function AssinarArquivo(const ASignTool: TStatusSignTool;
       const AConfiguracaoCertificado: TConfiguracaoCertificado;
       const AConfiguracaoAssinatura: TConfiguracaoAssinatura;
       const AItemArquivo: TItemArquivoAssinatura): TResultadoAssinatura;
     function MontarComandoAssinatura(const ASignTool: TStatusSignTool;
       const AConfiguracaoCertificado: TConfiguracaoCertificado;
       const AConfiguracaoAssinatura: TConfiguracaoAssinatura;
       const AItemArquivo: TItemArquivoAssinatura): string;
     function AssinarSemTimestamp(const ASignTool: TStatusSignTool;
       const AConfiguracaoCertificado: TConfiguracaoCertificado;
       const AItemArquivo: TItemArquivoAssinatura): TResultadoAssinatura;
   end;
```

---

## 12.3. Métodos detalhados

### `AssinarArquivo`

#### Objetivo
Executar a assinatura padrão, considerando timestamp quando configurado.

#### Deve fazer
- montar o comando;
- aplicar SHA256;
- aplicar `.pfx` e senha;
- usar o `signtool` resolvido;
- capturar retorno completo.

#### Não deve fazer
- perguntar ao usuário se continua sem timestamp;
- verificar a assinatura ao final;
- decidir fluxo de lote.

Essas decisões pertencem ao orquestrador.

---

### `MontarComandoAssinatura`

#### Objetivo
Gerar a linha de comando final para execução.

#### Uso típico
- debug;
- log técnico;
- inspeção avançada;
- eventual execução posterior.

#### Observação
A implementação concreta deve cuidar de quoting seguro para caminhos com espaços.

---

### `AssinarSemTimestamp`

#### Objetivo
Executar a assinatura sem timestamp, mas apenas após decisão explícita do usuário em caso de falha.

#### Motivo da existência
Deixa claro no núcleo que a operação sem timestamp é um caminho alternativo controlado, e não a assinatura padrão.

---

## 13. Contrato `ISigningVerificationService`

## 13.1. Finalidade

Executar a verificação formal da assinatura aplicada ao arquivo.

---

## 13.2. Assinatura sugerida

```pascal
 type
   ISigningVerificationService = interface
     ['{A0F5A6B1-7A56-4A2C-8A1A-1D7CBE7F0008}']
     function VerificarAssinatura(const ASignTool: TStatusSignTool;
       const ACaminhoArquivo: string): TResultadoVerificacaoAssinatura;
     function MontarComandoVerificacao(const ASignTool: TStatusSignTool;
       const ACaminhoArquivo: string): string;
   end;
```

---

## 13.3. Métodos detalhados

### `VerificarAssinatura`

#### Objetivo
Executar a checagem formal do arquivo já assinado.

#### Deve identificar
- se existe assinatura válida;
- se a verificação foi aprovada;
- se há evidência de timestamp quando aplicável;
- qual foi o resultado técnico do processo.

#### Retorno
`TResultadoVerificacaoAssinatura`.

---

### `MontarComandoVerificacao`

#### Objetivo
Gerar a linha de comando utilizada para a verificação.

#### Uso típico
- log técnico;
- análise de suporte;
- depuração.

---

## 14. Contrato `IUserDecisionService`

## 14.1. Finalidade

Permitir que o núcleo solicite uma decisão ao usuário sem depender diretamente de controles visuais ou chamadas fixas de FMX.

---

## 14.2. Assinatura sugerida

```pascal
 type
   IUserDecisionService = interface
     ['{A0F5A6B1-7A56-4A2C-8A1A-1D7CBE7F0009}']
     function SolicitarDecisao(
       const ASolicitacao: TSolicitacaoDecisaoUsuario): TRespostaDecisaoUsuario;
   end;
```

---

## 14.3. Método detalhado

### `SolicitarDecisao`

#### Objetivo
Apresentar ao usuário um cenário crítico e devolver a ação escolhida.

#### Uso típico
- certificado vencido;
- senha inválida;
- timestamp indisponível;
- escolha de continuar ou cancelar.

#### Retorno
`TRespostaDecisaoUsuario`.

#### Regra importante
A implementação concreta da UI decide como mostrar a pergunta, mas o contrato padroniza a troca de dados.

---

## 15. Contrato `IOrchestrator`

## 15.1. Finalidade

Coordenar o fluxo completo do sistema, sem executar diretamente as especialidades de cada domínio.

Esse contrato é o mais importante do núcleo, porque ele representa o comportamento oficial do RSign.

---

## 15.2. Assinatura sugerida

```pascal
 type
   IOrchestrator = interface
     ['{A0F5A6B1-7A56-4A2C-8A1A-1D7CBE7F0010}']
     function ValidarAmbiente(const AConfiguracao: TConfiguracaoGeral): TResultadoPadrao;
     function ValidarCertificado(const AConfiguracao: TConfiguracaoGeral): TStatusCertificado;
     function CriarOuRecriarCertificado(
       const AConfiguracao: TConfiguracaoGeral): TResultadoCriacaoCertificado;
     function ExecutarAssinaturaArquivo(const AConfiguracao: TConfiguracaoGeral): TResultadoAssinatura;
     function ExecutarAssinaturaLote(const AConfiguracao: TConfiguracaoGeral): TResultadoLoteAssinatura;
     function ExecutarFluxoCompleto(const AConfiguracao: TConfiguracaoGeral): TResultadoPadrao;
   end;
```

---

## 15.3. Métodos detalhados

### `ValidarAmbiente`

#### Objetivo
Executar a validação estrutural do ambiente antes da assinatura.

#### Deve envolver
- validação da configuração mínima;
- resolução do `signtool`;
- validação básica de caminhos.

#### Não deve envolver
- assinatura de arquivos;
- verificação final;
- alteração destrutiva de arquivos.

#### Uso típico
Botão “Validar ambiente” na UI.

---

### `ValidarCertificado`

#### Objetivo
Acionar o fluxo oficial de validação do certificado a partir da configuração completa.

#### Retorno
`TStatusCertificado`.

#### Diferença em relação ao service direto
O service conhece apenas a especialidade do certificado. O orquestrador conhece o contexto do uso e decide o que fazer com o resultado.

---

### `CriarOuRecriarCertificado`

#### Objetivo
Executar a criação ou recriação com base no contexto atual e, se necessário, decisão prévia do usuário.

#### Cenários previstos
- PFX inexistente;
- certificado vencido com confirmação de recriação;
- PFX corrompido com substituição autorizada.

---

### `ExecutarAssinaturaArquivo`

#### Objetivo
Executar o fluxo completo para um único arquivo.

#### Fluxo esperado
1. validar ambiente;
2. validar certificado;
3. preparar arquivo;
4. assinar;
5. perguntar sobre continuidade sem timestamp se necessário;
6. verificar assinatura se habilitado;
7. registrar resultado.

---

### `ExecutarAssinaturaLote`

#### Objetivo
Executar o fluxo completo de assinatura em lote.

#### Fluxo esperado
1. validar ambiente uma vez;
2. validar certificado uma vez;
3. listar e preparar arquivos válidos;
4. processar item a item;
5. registrar falhas individuais;
6. consolidar resumo final.

#### Regra importante
Uma falha em um item não deve necessariamente abortar o lote inteiro, a menos que a falha seja de ambiente global.

---

### `ExecutarFluxoCompleto`

#### Objetivo
Fornecer um ponto de entrada único para a operação padrão do sistema, deixando o orquestrador decidir se o contexto é arquivo único ou lote.

#### Quando usar
- botão principal “Executar” da UI;
- automação futura;
- integração com outro front-end.

#### Observação
A implementação concreta deve inspecionar `TModoAssinatura` e direcionar para o método adequado.

---

## 16. Ordem de dependência entre os contratos

A relação esperada entre os contratos é a seguinte:

```text
IOrchestrator
 ├── IConfigManager
 ├── ILoggerService
 ├── ISignToolService
 ├── ICertificateService
 ├── IFileSigningService
 ├── ISigningService
 ├── ISigningVerificationService
 └── IUserDecisionService

ISignToolService
 └── IProcessExecutor

ICertificateService
 ├── IProcessExecutor
 └── ILoggerService

IFileSigningService
 └── ILoggerService

ISigningService
 ├── IProcessExecutor
 └── ILoggerService

ISigningVerificationService
 ├── IProcessExecutor
 └── ILoggerService
```

---

## 17. Regras importantes de implementação por contrato

## 17.1. Logger

- nunca registrar senha do PFX em texto puro;
- deve registrar detalhes suficientes para auditoria local;
- a UI não deve montar logs por conta própria.

---

## 17.2. Configuração

- a implementação deve respeitar as três abas aprovadas;
- defaults devem poder ser restaurados;
- persistência deve ser reaplicável entre sessões.

---

## 17.3. Processo externo

- o contrato deve esconder os detalhes de criação de processo;
- stdout e stderr precisam ser mantidos separados;
- timeout precisa ser suportado.

---

## 17.4. SignTool

- deve preferir a versão mais nova por padrão;
- deve permitir override manual;
- não deve fazer assinatura nem verificação.

---

## 17.5. Certificado

- deve validar mais do que simples existência;
- deve respeitar a criação temporária em store com remoção posterior;
- não deve abrir UI para decidir nada.

---

## 17.6. Arquivos

- deve respeitar apenas extensões aprovadas;
- deve calcular `_OLD` e destino final de forma determinística;
- não deve chamar `signtool`.

---

## 17.7. Assinatura

- deve executar a assinatura, não decidir o fluxo;
- deve prever caminho alternativo sem timestamp, mas apenas quando solicitado pelo orquestrador.

---

## 17.8. Verificação

- deve apenas verificar;
- não deve refazer assinatura nem recriar certificado.

---

## 17.9. Decisão do usuário

- deve ser agnóstica em relação à tecnologia visual;
- deve devolver resposta objetiva ao núcleo.

---

## 17.10. Orquestrador

- não deve executar especialidades diretamente;
- deve coordenar todo o fluxo aprovado;
- deve concentrar a política de continuidade e cancelamento.

---

## 18. Sugestão de organização da unit `RSign.Core.Interfaces.pas`

Uma organização segura para a unit de interfaces é:

1. `uses` mínimos de `System.SysUtils`, `System.Generics.Collections` ou equivalentes necessários;
2. declaração dos tipos compartilhados já importados de `Types`;
3. declaração de interfaces auxiliares;
4. declaração de interfaces operacionais;
5. declaração do orquestrador por último.

---

## 19. Conclusão

O projeto **RSign** precisa de contratos fortes porque seu fluxo mistura:

- validação de ambiente;
- validação e criação de certificado;
- preparação de arquivos;
- assinatura efetiva;
- verificação final;
- interação assistida com o usuário.

Sem contratos claros, a UI tenderia a acumular lógica, os services tenderiam a se misturar e o fluxo real da aplicação ficaria distribuído em vários pontos difíceis de manter.

Com os contratos deste documento, o desenho esperado passa a ser:

- a **UI coleta dados e dispara operações**;
- o **orquestrador coordena o fluxo**;
- os **services executam especialidades**;
- o **logger registra a rastreabilidade**;
- a **configuração persiste o estado**;
- a **decisão do usuário entra por um contrato próprio**.

Esse é o modelo que deve orientar a implementação da unit de interfaces e das classes concretas do projeto.
