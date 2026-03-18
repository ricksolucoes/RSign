# RSign — Decisão Arquitetural: Renomear a camada `View` para `App`

## 1. Objetivo deste documento

Este documento formaliza a decisão de arquitetura de **renomear a camada `View` para `App`** no projeto **RSign**.

A motivação principal é eliminar ambiguidade técnica na estrutura do projeto, evitar interpretação incorreta sobre o papel de determinadas units e alinhar a nomenclatura com a responsabilidade real de cada camada.

Esta decisão passa a valer como referência oficial do projeto e deve ser lida antes da arquitetura, dos contratos e da matriz de implementação.

---

## 2. Problema identificado

Durante a preparação da base inicial do projeto, foram previstas units com os seguintes nomes:

- `RSign.View.Main`
- `RSign.View.Configuracao`
- `RSign.View.Log`

Ao evoluir a análise arquitetural e confrontar essa estrutura com o comportamento real esperado no **Delphi 10.2 FMX**, ficou claro que essas units **não representam views visuais reais**.

No contexto de aplicações FMX, uma **view visual** costuma ser uma unit que implementa diretamente:

- um `TForm`;
- um `TFrame`;
- ou outro módulo visual com arquivo `.fmx`.

No entanto, as units acima foram concebidas para exercer responsabilidades como:

- composição da aplicação;
- inicialização de fluxo;
- apoio à configuração;
- integração de logging com a camada visual;
- coordenação entre UI e núcleo.

Ou seja, essas units não são “telas” propriamente ditas.

---

## 3. Risco de manter o nome `View`

Manter o nome `View` para essas units cria problemas práticos e conceituais.

### 3.1. Indução ao erro na leitura do projeto

Quem olhar a estrutura poderá concluir que:

- essas units deveriam ter `.fmx`;
- essas units seriam formulários ou frames;
- essas units fariam parte direta da camada visual principal.

Isso gera expectativa errada e dificulta manutenção.

### 3.2. Confusão entre UI visual e coordenação

O projeto já possui uma camada visual real, composta por units como:

- `RSign.UI.Main`
- `RSign.UI.Frame.CertificateProfile`
- `RSign.UI.Frame.SigningSettings`
- `RSign.UI.Frame.Paths`

Essas sim representam a interface FMX de forma concreta.

Quando uma unit não visual recebe o prefixo `View`, ela passa a competir semanticamente com a camada `UI`, o que enfraquece a clareza arquitetural.

### 3.3. Problemas práticos em implementação

Essa nomenclatura pode levar a decisões erradas, como:

- tentativa de criar `.fmx` para units que não deveriam ter design visual;
- inclusão incorreta dessas units como forms do projeto;
- sobreposição entre responsabilidades de tela e de coordenação;
- aumento do retrabalho.

---

## 4. Decisão adotada

Fica definido que a camada antes chamada de `View` será renomeada para `App`.

Essa nova nomenclatura reflete melhor o papel real dessas units, que é servir como **camada de aplicação e coordenação**, e não como camada visual direta.

---

## 5. Novo mapeamento oficial

### 5.1. Units

#### Antes
- `RSign.View.Main`
- `RSign.View.Configuracao`
- `RSign.View.Log`

#### Depois
- `RSign.App.Main`
- `RSign.App.Configuracao`
- `RSign.App.Log`

### 5.2. Arquivos

#### Antes
- `RSign.View.Main.pas`
- `RSign.View.Configuracao.pas`
- `RSign.View.Log.pas`

#### Depois
- `RSign.App.Main.pas`
- `RSign.App.Configuracao.pas`
- `RSign.App.Log.pas`

### 5.3. Classes

#### Antes
- `TViewMain`
- `TViewConfiguracao`
- `TViewLog`

#### Depois
- `TAPPMain`
- `TAPPConfiguracao`
- `TAPPLog`

> Observação: caso `TViewMain` ainda não tenha sido implementada ou ainda esteja em revisão, a adoção de `TAPPMain` passa a ser a forma recomendada daqui para frente.

---

## 6. Justificativa para o nome `App`

O nome `App` foi escolhido porque representa melhor units que:

- inicializam a aplicação;
- compõem dependências;
- centralizam integração entre UI e núcleo;
- coordenam carregamento de estado;
- apoiam o ciclo de vida da aplicação sem serem, elas próprias, a interface visual.

Essa camada funciona mais como “camada de aplicação” do que como “camada de visualização”.

---

## 7. Regra oficial da arquitetura daqui para frente

A partir desta decisão, a arquitetura do projeto deve seguir a seguinte distinção:

### 7.1. Camada `UI`
Reservada exclusivamente para elementos visuais reais da aplicação.

Exemplos:

- forms;
- frames;
- componentes de tela;
- units com `.fmx`.

### 7.2. Camada `App`
Reservada para units de coordenação, composição e apoio ao fluxo geral da aplicação.

Exemplos:

- inicialização da aplicação;
- organização de abertura de telas;
- composição com serviços;
- integração entre UI, configuração e logger.

### 7.3. Camada `Core`
Reservada para contratos, tipos centrais, constantes e orquestração.

### 7.4. Camada `Services`
Reservada para execução especializada das regras operacionais.

### 7.5. Camada `Config`
Reservada para persistência e restauração das configurações.

---

## 8. Regra oficial de nomenclatura daqui para frente

### 8.1. Se a unit for visual real
Deve permanecer na camada `UI`, com nomes como:

- `RSign.UI.Main`
- `RSign.UI.Frame.CertificateProfile`
- `RSign.UI.Frame.SigningSettings`
- `RSign.UI.Frame.Paths`

Essas units podem ter:

- `TForm`
- `TFrame`
- arquivo `.fmx`

### 8.2. Se a unit não for visual real
Deve pertencer à camada `App`, com nomes como:

- `RSign.App.Main`
- `RSign.App.Configuracao`
- `RSign.App.Log`

Essas units **não devem induzir expectativa de `.fmx`** e não devem ser tratadas como forms.

---

## 9. Impacto documental da mudança

A mudança deve ser refletida em todos os documentos que ainda mencionarem:

- `RSign.View.Main`
- `RSign.View.Configuracao`
- `RSign.View.Log`
- `TViewMain`
- `TViewConfiguracao`
- `TViewLog`

Essas referências devem ser atualizadas para:

- `RSign.App.Main`
- `RSign.App.Configuracao`
- `RSign.App.Log`
- `TAPPMain`
- `TAPPConfiguracao`
- `TAPPLog`

---

## 10. Impacto técnico da mudança

Além da documentação, a alteração deve ser aplicada também em:

- cláusulas `uses`;
- referências cruzadas entre units;
- registro de forms/classes quando existir;
- comentários internos;
- contratos de composição da aplicação;
- matriz de implementação;
- arquitetura das units;
- qualquer base de código nova gerada a partir da documentação.

---

## 11. Primeiro passo obrigatório antes da continuidade do desenvolvimento

Antes de continuar a codificação do projeto, esta mudança deve ser aplicada como primeira ação de alinhamento arquitetural.

### Ordem recomendada

1. atualizar os documentos principais;
2. substituir referências de `View` por `App` onde a unit não for visual;
3. atualizar nomes de arquivos, units e classes;
4. manter `UI` apenas para forms e frames reais;
5. revisar a estrutura do projeto com base nessa separação;
6. só então continuar a implementação.

---

## 12. Regra documental durante a fase de documentação

Enquanto o projeto ainda estiver em fase de documentação, deve prevalecer a seguinte regra:

- uma decisão principal deve permanecer concentrada em um único documento principal;
- mudanças incrementais dessa mesma decisão devem ser incorporadas ao arquivo principal;
- documentos complementares paralelos só devem existir quando tratarem de assunto realmente independente.

Essa regra evita concorrência documental, leitura fora de contexto e dúvida sobre qual arquivo representa a decisão oficial.

---

## 13. Conclusão

A nomenclatura anterior da camada `View` induzia a erro, pois não representava corretamente a natureza das units em questão.

A substituição por `App` melhora:

- a leitura técnica da solução;
- a coerência entre nome e responsabilidade;
- a manutenção futura;
- a compatibilidade conceitual com a arquitetura aprovada.

Fica, portanto, oficializado no projeto **RSign** que:

- `View` não deve ser usada para units que não são visuais;
- a camada de coordenação da aplicação deve se chamar `App`;
- essa mudança deve se refletir em units, arquivos e classes;
- essa mudança é o primeiro ajuste obrigatório antes de prosseguir com a implementação.
