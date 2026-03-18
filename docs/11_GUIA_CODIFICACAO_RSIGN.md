# RSign — Guia de Codificação

## 1. Objetivo deste documento

Este documento define os padrões mínimos de codificação do projeto **RSign**, com foco em:

- organização do código Delphi 10.2;
- clareza e previsibilidade de nomenclatura;
- separação de responsabilidades;
- padronização de tratamento de falhas, logs e contratos;
- consistência entre UI, Core, Types, Config e Services.

Este guia deve ser respeitado em toda nova unit criada para o projeto.

---

## 2. Princípios obrigatórios

### 2.1. Cada unit deve ter responsabilidade clara
Uma unit não deve misturar:

- UI com regra de negócio;
- persistência com composição visual;
- execução de processo externo com decisão de fluxo;
- geração de mensagens com manipulação de arquivo.

### 2.2. A UI não executa regra de negócio profunda
A UI apenas:

- coleta dados;
- exibe status;
- solicita operação;
- apresenta mensagens e logs.

### 2.3. O orquestrador coordena, os services executam
O fluxo central deve viver no orquestrador. Os services devem executar responsabilidades especializadas.

### 2.4. Types não conhecem UI
Records, enums e DTOs não devem depender de forms, frames ou componentes FMX.

### 2.5. Toda falha relevante deve ser rastreável
Falhas técnicas e operacionais devem ser registradas por logger e retornar resultado estruturado.

---

## 3. Convenções de nomenclatura

### 3.1. Units
Usar prefixo `RSign.` e namespace coerente.

Exemplos:

- `RSign.Core.Interfaces`
- `RSign.Services.Certificate`
- `RSign.UI.Frame.Paths`

### 3.2. Interfaces
Toda interface deve iniciar com `I`.

Exemplos:

- `ILoggerService`
- `ICertificateService`
- `IOrchestrator`

### 3.3. Classes
Classes concretas devem usar `T` e nome explícito.

Exemplos:

- `TLoggerService`
- `TCertificateService`
- `TMainForm`

### 3.4. Campos
Campos privados devem iniciar com `F`.

Exemplo:

```delphi
FLogger: ILoggerService;
```

### 3.5. Parâmetros
Parâmetros devem iniciar com `A`.

Exemplo:

```delphi
function ValidarCertificado(const AConfiguracao: TConfiguracaoCertificado): TStatusCertificado;
```

### 3.6. Variáveis locais
Variáveis locais devem iniciar com `L`.

Exemplo:

```delphi
var
  LResultado: TResultadoAssinatura;
```

---

## 4. Padrões de implementação

### 4.1. Interfaces antes das implementações
Sempre que a arquitetura já tiver contrato definido, a implementação deve respeitar primeiro a interface aprovada.

### 4.2. Métodos devem ter objetivo único
Métodos muito grandes ou com múltiplas decisões não devem ser mantidos monolíticos.

### 4.3. Evitar dependências ocultas
Toda dependência importante deve ser injetada ou explicitamente composta.

### 4.4. Não usar strings soltas para estados importantes
Estados devem preferir enums, records e contratos estruturados.

### 4.5. Não capturar exceções silenciosamente
Toda exceção capturada deve ser:

- tratada;
- convertida em resultado útil;
- ou registrada em log.

---

## 5. Regras específicas por camada

### 5.1. UI
A UI não deve:

- montar comandos do `signtool`;
- abrir PFX diretamente;
- validar integridade de certificado por conta própria;
- gravar arquivo `.ini` sem passar pelo gerenciador.

### 5.2. Core
O Core deve conter:

- contratos;
- constantes;
- orquestração;
- decisões centrais do fluxo.

### 5.3. Services
Cada service deve atuar em um domínio funcional específico.

### 5.4. Config
A persistência deve ser centralizada no gerenciador de configuração.

### 5.5. Utils
Helpers devem ser genéricos e não devem assumir regra de negócio principal.

---

## 6. Tratamento de resultados

Sempre que possível, preferir retorno estruturado em vez de múltiplas flags soltas.

Exemplo esperado:

- status de sucesso;
- código de retorno;
- mensagem técnica;
- mensagem amigável;
- dados complementares;
- log associado.

---

## 7. Logs

### Regras obrigatórias

- não registrar senha do certificado em texto puro;
- registrar início e fim de operações relevantes;
- registrar caminho adotado do `signtool`;
- registrar decisões do usuário em cenários críticos;
- registrar saída de processos externos quando relevante.

---

## 8. Comentários e documentação interna

Toda unit deve ter, no mínimo:

- cabeçalho com responsabilidade;
- contexto resumido;
- relação com outras camadas, quando necessário.

Métodos públicos relevantes devem ter documentação clara sobre:

- objetivo;
- entrada;
- saída;
- exceções ou falhas previstas.

---

## 9. Compatibilidade com Delphi 10.2

### Regras recomendadas

- evitar recursos que prejudiquem compatibilidade com Delphi 10.2;
- manter implementação simples, estável e legível;
- não depender de abstrações que compliquem desnecessariamente o projeto.

---

## 10. Critério de aceitação de código

Um trecho de código só deve ser considerado pronto quando:

- respeita a arquitetura aprovada;
- está no namespace correto;
- não mistura responsabilidades;
- trata falhas relevantes;
- registra eventos importantes;
- usa tipos e contratos definidos;
- mantém o contexto oficial do RSign.
