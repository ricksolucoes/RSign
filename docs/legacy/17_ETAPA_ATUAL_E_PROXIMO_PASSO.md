# RSign — Etapa Atual do Projeto e Próximo Passo de Implementação

## 1. Objetivo deste documento

Este documento registra, de forma objetiva e oficial, **em que etapa o projeto RSign se encontra neste momento** e **qual é o próximo passo correto de implementação**.

Ele existe para evitar perda de contexto, impedir avanço fora da sequência aprovada e garantir que o desenvolvimento continue alinhado com a documentação principal do projeto.

---

## 2. Base oficial considerada

Este registro considera como base oficial do projeto:

- o código atual validado pelo usuário;
- a documentação principal organizada em `docs/`;
- a decisão oficial de renomeação da camada `View` para `App`;
- a confirmação do usuário de que a parte visual está estável, funcional e atendendo ao objetivo esperado.

Qualquer conteúdo anterior divergente deve ser tratado como **legacy**.

---

## 3. Etapa em que o projeto se encontra agora

## Etapa atual: **Fase 1 — Fundação concluída**

Com base na documentação oficial e na validação informada pelo usuário, a **Fase 1 — Fundação** deve ser considerada concluída.

### Isso significa que já existe no projeto:

- estrutura base do projeto Delphi FMX;
- organização física das pastas principais;
- units centrais de base;
- types e contratos principais;
- carregamento e gravação do `RSign.ini`;
- tela principal com 3 abas;
- integração inicial com configuração;
- logger funcional na base atual;
- camada `App` adotada como nomenclatura correta;
- parte visual considerada estável e funcional pelo usuário.

---

## 4. O que fica oficialmente encerrado nesta etapa

A partir deste ponto, deve ser considerado encerrado, salvo correção pontual:

- criação do esqueleto base do projeto;
- definição das structures iniciais;
- definição dos records e enums principais;
- criação das interfaces-base;
- criação da UI principal;
- criação dos frames principais;
- integração com o arquivo de configuração;
- estabilização da camada visual para a finalidade atual.

Isso quer dizer que o projeto já ultrapassou a fase de “fundação inicial” e não deve retornar a ela sem necessidade concreta.

---

## 5. O que ainda não pertence à Fase 1

Ainda **não faz parte do que foi concluído**:

- execução real de processos externos;
- localização real do `signtool`;
- validação real do certificado;
- criação real do `.pfx`;
- preparação real de arquivos para assinatura;
- assinatura real do executável;
- verificação real da assinatura;
- tratamento operacional completo do fluxo de decisão assistida.

Esses itens pertencem à próxima fase do projeto.

---

## 6. Próxima etapa do projeto

## Próxima etapa: **início da fase operacional**

Como a fundação foi considerada concluída, o projeto entra agora na fase em que a base estrutural começa a receber implementação operacional concreta.

Essa fase não trata mais da estrutura inicial do projeto, mas sim da execução real das responsabilidades que hoje existem apenas em contrato ou como fluxo previsto.

---

## 7. Próximo passo correto

O próximo passo correto é:

> **implementar a primeira infraestrutura operacional concreta do projeto, começando por `RSign.Services.ProcessExecutor`.**

---

## 8. Justificativa técnica para esse próximo passo

A escolha de começar por `RSign.Services.ProcessExecutor` é tecnicamente coerente com a arquitetura aprovada porque:

- a UI já está considerada fechada pelo usuário;
- a configuração inicial já existe;
- os contratos principais já foram definidos;
- o orquestrador já existe na base atual;
- os próximos serviços operacionais dependem de execução de processos externos;
- sem uma camada central para isso, a lógica de execução tende a se espalhar e quebrar a arquitetura.

Esse serviço deve funcionar como base para os próximos módulos operacionais.

---

## 9. Ordem recomendada a partir deste ponto

A sequência recomendada de continuidade passa a ser:

1. `RSign.Services.ProcessExecutor`
2. `RSign.Services.SignTool`
3. `RSign.Services.Certificate`
4. `RSign.Services.FileSigning`
5. `RSign.Services.Signing`
6. `RSign.Services.SigningVerification`
7. `RSign.Services.UserDecision`
8. evolução do `RSign.Core.Orchestrator` para fluxo operacional completo

---

## 10. O que vai ser feito agora

O que deve ser feito agora, sem sair do contexto aprovado, é:

### Etapa imediata
Implementar `RSign.Services.ProcessExecutor`.

### Objetivo desta implementação
Criar uma base padronizada para:

- executar processos externos;
- capturar código de retorno;
- capturar saída padrão;
- capturar saída de erro;
- devolver resultado estruturado ao restante do projeto.

### Motivo
Essa unit é a base técnica que viabiliza os próximos serviços reais sem espalhar chamadas de processo pela aplicação.

---

## 11. O que não deve ser feito ainda

Para manter a sequência correta do projeto, ainda **não deve ser iniciado diretamente**, antes do `ProcessExecutor`:

- o serviço concreto de `SignTool`;
- o serviço concreto de certificado;
- a assinatura real de arquivos;
- a verificação real da assinatura;
- o fluxo completo final do orquestrador.

Esses itens vêm depois da base de execução externa estar pronta.

---

## 12. Regra de continuidade

A partir deste documento, a continuidade correta do projeto deve respeitar a seguinte regra:

- a Fase 1 já está concluída;
- o próximo avanço começa pela infraestrutura operacional;
- a primeira entrega operacional deve ser `RSign.Services.ProcessExecutor`;
- qualquer retorno à base inicial só deve ocorrer se surgir um erro concreto que exija correção estrutural.

---

## 13. Conclusão

Fica registrado que o projeto **RSign** se encontra atualmente com a **Fase 1 — Fundação concluída**, de acordo com a documentação oficial e com a validação expressa do usuário sobre a estabilidade da interface.

Com isso, o próximo passo correto e alinhado ao projeto é:

> **implementar `RSign.Services.ProcessExecutor` como primeira unit concreta da fase operacional.**

Esse é o ponto de continuidade oficial antes de avançar para `SignTool`, certificado e assinatura real.
