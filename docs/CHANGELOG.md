# Changelog

Todos os registros relevantes do projeto **RSign** devem ser documentados neste arquivo.

O objetivo deste changelog é manter rastreabilidade da evolução do projeto, deixando claro:

- o que foi adicionado;
- o que foi alterado;
- o que foi corrigido;
- o que foi removido;
- quais decisões impactaram o comportamento técnico e funcional do sistema.

Este arquivo deve ser atualizado sempre que houver mudança que afete:

- arquitetura das units;
- contratos e interfaces;
- comportamento da UI;
- persistência do `.ini`;
- criação e validação do certificado;
- processo de assinatura;
- verificação pós-assinatura;
- logs, mensagens e testes.

---

## Convenção recomendada

Estrutura sugerida para cada versão:

```text
## [versão] - AAAA-MM-DD
### Adicionado
### Alterado
### Corrigido
### Removido
### Observações técnicas
```

---

## [0.1.0] - 2026-03-16

### Adicionado

- Definição oficial do projeto **RSign** como aplicação local em **Delphi 10.2 + FMX**.
- README principal do repositório, descrevendo objetivo, contexto, arquitetura, fluxo e roadmap.
- Plano de implementação por fases.
- Documento de arquitetura das units.
- Documento de contratos e interfaces.
- Matriz de implementação ligando interfaces, units concretas, dependências e critérios de pronto.
- Documento de contexto técnico.
- Documento de referência funcional.
- Especificação do arquivo `RSign.ini`.
- Catálogo padronizado de mensagens e erros.
- Plano de testes funcionais e técnicos.
- Documento complementar de roadmap.
- Guia de codificação do projeto.
- Checklist de release.
- Registro formal de decisões arquiteturais.

### Alterado

- O fluxo original baseado em BAT foi oficialmente redefinido para uma aplicação desktop com arquitetura em camadas.
- A estratégia de saída dos arquivos foi alterada de `*_ASSINADO` para preservação do original com sufixo `_OLD` e manutenção do nome original no arquivo assinado.
- O processo passou a prever decisão assistida do usuário em falhas críticas, em vez de prosseguir silenciosamente.

### Corrigido

- Correção da nomenclatura funcional do documento `REFERENCIA_FUNCIONAL.md`.
- Consolidação da arquitetura com inclusão de `RSign.View.Configuracao` e `RSign.View.Log`.

### Removido

- Dependência conceitual de execução exclusivamente por linha de comando.
- Premissa de que todo o processo deve exigir privilégio administrativo desde o início.

### Observações técnicas

- O certificado autoassinado continua sendo a base inicial do projeto.
- O artefato final de certificado permanece em `.pfx`.
- A criação técnica do certificado pode usar store temporário do Windows com remoção imediata após exportação.
- O projeto continua preparado para suporte futuro a **PFX externo** e **Code Signing real**.

---

## Modelo para próximas versões

## [0.2.0] - AAAA-MM-DD

### Adicionado
- 

### Alterado
- 

### Corrigido
- 

### Removido
- 

### Observações técnicas
- 
