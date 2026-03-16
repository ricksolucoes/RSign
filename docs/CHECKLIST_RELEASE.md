# RSign — Checklist de Release

## 1. Objetivo deste documento

Este checklist existe para validar se uma versão do **RSign** está pronta para ser empacotada, testada e disponibilizada para uso interno.

Ele deve ser executado antes de qualquer release considerada utilizável.

---

## 2. Checklist de documentação

- [ ] README atualizado
- [ ] Changelog atualizado
- [ ] Roadmap revisado, se necessário
- [ ] Arquitetura das units compatível com o código atual
- [ ] Contratos e interfaces revisados
- [ ] Especificação do `.ini` alinhada ao comportamento real
- [ ] Catálogo de mensagens alinhado ao sistema
- [ ] Plano de testes revisado

---

## 3. Checklist de compilação

- [ ] Projeto compila no Delphi 10.2 sem erros
- [ ] Não há units órfãs ou referências quebradas
- [ ] Dependências externas previstas estão disponíveis
- [ ] Forms e frames abrem sem falha de criação

---

## 4. Checklist de configuração

- [ ] O `RSign.ini` é criado corretamente quando não existe
- [ ] Defaults são carregados corretamente
- [ ] Alterações feitas na UI persistem corretamente
- [ ] Caminhos inválidos são tratados com mensagem adequada

---

## 5. Checklist de signtool

- [ ] Detecção automática funciona
- [ ] Caminho manual funciona
- [ ] A versão escolhida é mostrada corretamente
- [ ] Falha de localização gera mensagem amigável e técnica

---

## 6. Checklist de certificado

- [ ] O sistema detecta ausência de PFX
- [ ] O sistema cria PFX quando necessário
- [ ] O sistema valida senha do PFX
- [ ] O sistema valida vigência
- [ ] O sistema detecta PFX corrompido
- [ ] O sistema detecta ausência de chave privada
- [ ] O sistema remove o certificado do store temporário após exportação

---

## 7. Checklist de assinatura

- [ ] Arquivo único funciona corretamente
- [ ] Lote funciona corretamente
- [ ] Apenas extensões suportadas são processadas
- [ ] O original é renomeado para `_OLD`
- [ ] O assinado mantém o nome original
- [ ] Falhas por item no lote são registradas corretamente

---

## 8. Checklist de timestamp e verificação

- [ ] Timestamp é aplicado quando disponível
- [ ] Falha de timestamp pergunta ao usuário se deseja continuar
- [ ] Verificação pós-assinatura funciona quando ativada
- [ ] Desativação da verificação funciona corretamente

---

## 9. Checklist de log e rastreabilidade

- [ ] Logs aparecem na tela
- [ ] Logs são gravados em arquivo
- [ ] Senha do certificado não aparece em texto puro
- [ ] Erros técnicos são registrados
- [ ] Mensagens amigáveis são apresentadas ao usuário

---

## 10. Checklist final de aceite

- [ ] Fluxo principal executa do início ao fim
- [ ] Não há falhas críticas sem tratamento
- [ ] O comportamento está alinhado à documentação oficial do projeto
- [ ] A release pode ser testada ou utilizada com segurança no contexto aprovado
