# RSign — ADR / Decisões Técnicas

## 1. Objetivo deste documento

Este documento registra, de forma objetiva, as principais decisões arquiteturais do projeto **RSign**.

Cada decisão aqui listada deve ser tratada como base oficial até que outra decisão a substitua explicitamente.

---

## ADR-001 — Plataforma da aplicação

### Decisão
O projeto será desenvolvido em **Delphi 10+ FMX**.

### Motivo
A aplicação precisa de interface desktop local, com possibilidade de evolução futura, mantendo compatibilidade com o contexto aprovado do projeto.

### Impacto
- a UI será visual e local;
- a arquitetura deve permanecer desacoplada para permitir reaproveitamento futuro do núcleo.

---

## ADR-002 — Origem do projeto

### Decisão
O projeto nasce a partir da BAT `Gerador.bat`, mas será tratado como **evolução arquitetural**, não como simples conversão visual.

### Motivo
A BAT atual comprova viabilidade operacional, mas não atende bem a requisitos de persistência, rastreabilidade, testes e separação de responsabilidades.

### Impacto
A nova aplicação deve preservar o fluxo essencial, porém com arquitetura em camadas e serviços especializados.

---

## ADR-003 — Certificado inicial

### Decisão
A primeira versão utilizará **certificado autoassinado em `.pfx`**, com previsão futura de suporte a **PFX externo** e **Code Signing real**.

### Motivo
Permite iniciar o projeto com um fluxo controlado, sem bloquear a evolução futura.

### Impacto
Os tipos, contratos e serviços devem nascer preparados para múltiplas origens de certificado.

---

## ADR-004 — Store do Windows

### Decisão
O certificado não será mantido permanentemente em store. O artefato final deve ficar apenas em `.pfx`.

### Motivo
Esse é o comportamento funcional aprovado para a primeira fase do projeto.

### Impacto
A criação técnica pode usar store temporário, mas o certificado deve ser removido após exportação.

---

## ADR-005 — Persistência de configuração

### Decisão
A persistência local será feita por arquivo `.ini`.

### Motivo
O `.ini` atende bem ao escopo do projeto, é simples no Delphi 10.2 e favorece manutenção humana direta.

### Impacto
A configuração deve ser centralizada no `RSign.Config.Manager`.

---

## ADR-006 — Estratégia de arquivo assinado

### Decisão
O arquivo original será preservado com sufixo `_OLD`, e o arquivo assinado manterá o nome original.

### Motivo
Essa estratégia reduz risco operacional e mantém previsibilidade para o usuário.

### Impacto
A lógica de preparação de arquivos deve ser centralizada no serviço de arquivo.

---

## ADR-007 — Seleção do signtool

### Decisão
O sistema deve suportar detecção automática e caminho manual do `signtool.exe`, usando a versão mais nova por padrão.

### Motivo
A flexibilidade melhora compatibilidade com ambientes diferentes sem perder controle operacional.

### Impacto
O serviço de `signtool` deve listar candidatos, validar versões e devolver a escolha adotada.

---

## ADR-008 — Decisão assistida do usuário

### Decisão
Falhas críticas ou ambíguas não devem ser resolvidas silenciosamente. O sistema deve explicar e aguardar decisão do usuário.

### Motivo
O fluxo aprovado exige transparência em situações como certificado vencido, timestamp indisponível e senha inválida.

### Impacto
A comunicação entre núcleo e UI deve passar por contrato de decisão, sem acoplamento direto a mensagens visuais concretas.

---

## ADR-009 — Verificação pós-assinatura

### Decisão
A verificação da assinatura deve vir habilitada por padrão, podendo ser desativada pela UI.

### Motivo
A verificação aumenta segurança operacional e confiabilidade do fluxo.

### Impacto
O orquestrador deve tratar a verificação como etapa padrão da operação.

---

## ADR-010 — Estrutura em camadas

### Decisão
O projeto será organizado em camadas de UI, Core, Types, Config, Services e Utils.

### Motivo
Evita crescimento desordenado e mistura de responsabilidades.

### Impacto
Toda nova unit deve respeitar a direção correta de dependência entre camadas.
