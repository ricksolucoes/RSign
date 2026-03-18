# RSign — Roadmap

## 1. Objetivo deste documento

Este documento define a evolução planejada do projeto **RSign**, separando com clareza:

- o que faz parte da primeira entrega utilizável;
- o que foi aprovado para fases futuras;
- o que depende de maturação técnica adicional;
- o que não faz parte do escopo atual.

O roadmap existe para impedir expansão desordenada do projeto e para orientar priorização técnica sem perda do contexto oficial.

---

## 2. Princípios do roadmap

O roadmap do RSign deve respeitar estas regras:

- primeiro consolidar o núcleo mínimo funcional com segurança e rastreabilidade;
- depois ampliar flexibilidade operacional;
- por fim evoluir para cenários avançados, sem quebrar o fluxo inicial aprovado;
- toda nova fase deve preservar a arquitetura desacoplada entre UI, orquestração e serviços.

---

## 3. Fase 1 — MVP operacional aprovado

Esta fase representa a primeira versão funcional e utilizável do projeto.

### Escopo da Fase 1

- UI FMX em 3 abas:
  - Perfil do Certificado
  - Configuração da Assinatura
  - Locais e Arquivos
- Persistência local via `.ini`
- Detecção automática e manual do `signtool.exe`
- Escolha da versão mais nova por padrão
- Suporte a certificado autoassinado em `.pfx`
- Criação do certificado quando não existir
- Validação do PFX existente
- Assinatura de arquivo único
- Assinatura em lote
- Filtro por extensões suportadas:
  - `.exe`
  - `.dll`
  - `.msi`
  - `.cab`
  - `.cat`
- Estratégia `_OLD` para preservação do original
- Assinatura com SHA256
- Timestamp configurável
- Pergunta ao usuário em caso de falha de timestamp
- Verificação pós-assinatura habilitada por padrão
- Logs em tela e arquivo
- Decisão assistida do usuário em falhas críticas

### Critério de conclusão da Fase 1

A Fase 1 será considerada concluída quando o sistema conseguir, de forma estável:

1. carregar configuração;
2. validar ambiente;
3. validar ou criar PFX;
4. processar arquivo único e lote;
5. assinar;
6. verificar;
7. registrar logs;
8. exibir resultado amigável e técnico.

---

## 4. Fase 2 — Flexibilização do uso do certificado

### Objetivo

Ampliar o suporte ao certificado, indo além do autoassinado.

### Itens previstos

- suporte a **PFX externo** já existente;
- seleção de múltiplos perfis de certificado;
- importação guiada de perfis;
- validação mais rica de cadeia e propósito do certificado;
- reuso de perfis sem recriação manual;
- histórico do último PFX utilizado.

### Benefício esperado

Reduzir dependência do fluxo de criação e aproximar o projeto de um uso mais próximo de ambientes reais.

---

## 5. Fase 3 — Evolução para Code Signing real

### Objetivo

Preparar o sistema para uso de certificado real de assinatura de código.

### Itens previstos

- seleção explícita do tipo de certificado na UI;
- tratamento específico para certificado real;
- políticas distintas de timestamp;
- validações compatíveis com cadeia corporativa ou pública;
- regras de persistência adequadas ao novo tipo de certificado.

### Observação

Essa fase depende de definição posterior do contexto real de distribuição, política corporativa e infraestrutura disponível.

---

## 6. Fase 4 — Melhorias de rastreabilidade e suporte operacional

### Itens previstos

- exportação de relatório final em arquivo separado;
- tela de histórico de logs;
- filtros visuais por severidade e operação;
- visualização consolidada de resultados por lote;
- estatísticas resumidas de sucesso, falha e aviso.

---

## 7. Fase 5 — Automação sem UI

### Objetivo

Reaproveitar o núcleo do projeto em outros modos de operação.

### Itens previstos

- execução por linha de comando;
- automação local sem interação visual;
- modo silencioso controlado por parâmetros;
- reaproveitamento do orquestrador fora da UI FMX.

### Pré-requisito

O núcleo de serviços e orquestração precisa permanecer totalmente desacoplado da interface.

---

## 8. Fora do escopo atual

Os itens abaixo não fazem parte da evolução imediata já aprovada:

- assinatura em nuvem;
- dependência de banco de dados;
- integração com serviço Windows;
- gestão distribuída centralizada de certificados;
- uso remoto multiusuário;
- integração com infraestrutura corporativa não especificada.

---

## 9. Priorização resumida

### Prioridade imediata
- Fase 1

### Prioridade de curto prazo
- Fase 2
- Fase 4

### Prioridade condicionada a contexto futuro
- Fase 3
- Fase 5

---

## 10. Conclusão

O roadmap do RSign foi estruturado para garantir que a primeira entrega seja útil, estável e segura, enquanto preserva espaço para crescimento técnico posterior sem necessidade de refazer o núcleo da aplicação.
