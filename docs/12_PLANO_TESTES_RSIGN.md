# RSign — Plano de Testes

## 1. Objetivo deste documento

Este documento define o plano de testes funcional e técnico do projeto **RSign**, cobrindo os cenários mínimos necessários para validar a aplicação antes do uso regular.

O objetivo é garantir que o sistema atenda ao fluxo aprovado do projeto em relação a:

- carregamento de configuração;
- validação do ambiente;
- validação e criação do certificado;
- seleção e preparação de arquivos;
- assinatura;
- verificação pós-assinatura;
- logs;
- tratamento de falhas bloqueantes e assistidas.

---

## 2. Escopo do plano de testes

Este plano cobre a fase atual do projeto, em que o RSign opera localmente em Windows com:

- Delphi 10.2;
- interface FMX;
- certificado autoassinado em `.pfx`;
- uso de `signtool.exe`;
- assinatura de extensões conhecidas;
- operação em arquivo único e em lote.

Este documento não cobre, nesta fase:

- integração com certificado corporativo real;
- automação via linha de comando sem UI;
- integração com CI;
- assinatura em ambiente distribuído.

---

## 3. Estratégia geral de testes

Os testes devem ser organizados em quatro blocos principais:

### 3.1. Testes de configuração
Validação do arquivo `.ini`, defaults e persistência.

### 3.2. Testes de ambiente
Validação do `signtool`, permissões e caminhos.

### 3.3. Testes de certificado
Validação, criação, erro de senha, vencimento e integridade do `.pfx`.

### 3.4. Testes de assinatura
Arquivo único, lote, verificação final, timestamp e preservação do original.

---

## 4. Ambiente mínimo recomendado para testes

- Windows compatível com o uso do `signtool.exe`
- Delphi 10.2 para build da aplicação
- PowerShell disponível
- Windows SDK instalado ou caminho válido do `signtool.exe`
- Permissão de leitura e escrita nas pastas de teste
- Pasta de entrada com arquivos compatíveis e incompatíveis

---

## 5. Dados de teste recomendados

## 5.1. Certificados

Preparar ao menos os seguintes cenários:

- PFX inexistente
- PFX válido
- PFX válido com senha errada informada na UI
- PFX corrompido
- PFX vencido
- PFX próximo do vencimento
- PFX sem chave privada utilizável, quando possível simular

## 5.2. Arquivos

Preparar ao menos:

- `.exe` válido
- `.dll` válida
- `.msi` válido
- `.cab` válido
- `.cat` válido
- arquivo de extensão não suportada, como `.txt`
- arquivo inexistente
- arquivo bloqueado por outro processo

## 5.3. Pastas

Preparar ao menos:

- pasta com apenas arquivos válidos
- pasta com arquivos válidos e inválidos misturados
- pasta vazia
- pasta sem permissão de escrita

---

## 6. Critérios gerais de aceite

Uma execução será considerada aprovada quando:

- a aplicação não sair do contexto aprovado do projeto;
- o `.ini` for respeitado;
- o `signtool` for localizado conforme regra definida;
- o `.pfx` for validado corretamente;
- o original for preservado como `_OLD`;
- o assinado final mantiver o nome original;
- a verificação pós-assinatura se comportar conforme configuração;
- logs técnicos e amigáveis forem gerados;
- falhas assistidas realmente pedirem decisão do usuário.

---

## 7. Casos de teste

## 7.1. Configuração

### CT-001 — Criar configuração padrão quando o `.ini` não existe
**Objetivo:** validar criação do arquivo de configuração inicial.  
**Pré-condição:** `RSign.ini` inexistente.  
**Passos:** abrir a aplicação.  
**Resultado esperado:** aplicação cria ou prepara configuração padrão e apresenta valores default na UI.  
**Status esperado:** aprovado sem bloqueio.

### CT-002 — Carregar configuração existente
**Objetivo:** validar leitura do `.ini`.  
**Pré-condição:** `RSign.ini` preenchido com valores válidos.  
**Passos:** abrir a aplicação.  
**Resultado esperado:** campos da UI refletem os dados persistidos.  
**Status esperado:** aprovado.

### CT-003 — Aplicar defaults para chaves ausentes
**Objetivo:** validar tolerância a chaves faltantes.  
**Pré-condição:** `.ini` existente com algumas chaves removidas.  
**Passos:** abrir a aplicação.  
**Resultado esperado:** valores ausentes são preenchidos com defaults e a aplicação continua funcionando.  
**Status esperado:** warning registrado, sem bloqueio.

---

## 7.2. SignTool

### CT-010 — Localizar `signtool` automaticamente
**Objetivo:** validar detecção automática.  
**Pré-condição:** Windows SDK instalado.  
**Passos:** habilitar localização automática e validar ambiente.  
**Resultado esperado:** `signtool.exe` localizado e versão exibida.  
**Status esperado:** sucesso.

### CT-011 — Usar caminho manual válido
**Objetivo:** validar caminho manual.  
**Pré-condição:** caminho válido para `signtool.exe`.  
**Passos:** informar caminho manual e validar ambiente.  
**Resultado esperado:** sistema usa o executável manual informado.  
**Status esperado:** sucesso.

### CT-012 — Caminho manual inválido
**Objetivo:** validar falha de caminho manual.  
**Pré-condição:** caminho inexistente.  
**Passos:** informar caminho manual inválido e validar ambiente.  
**Resultado esperado:** erro bloqueante com mensagem clara.  
**Status esperado:** falha controlada.

### CT-013 — `signtool` ausente
**Objetivo:** validar comportamento sem ferramenta instalada.  
**Pré-condição:** sem SDK e sem caminho manual válido.  
**Passos:** validar ambiente.  
**Resultado esperado:** erro bloqueante informando ausência do `signtool`.  
**Status esperado:** falha controlada.

---

## 7.3. Certificado

### CT-020 — Criar certificado quando o PFX não existe
**Objetivo:** validar geração do certificado autoassinado.  
**Pré-condição:** caminho do PFX configurado sem arquivo existente.  
**Passos:** validar certificado e confirmar criação.  
**Resultado esperado:** certificado criado, exportado para `.pfx` e removido do store temporário.  
**Status esperado:** sucesso.

### CT-021 — Validar PFX existente e íntegro
**Objetivo:** validar reaproveitamento do PFX.  
**Pré-condição:** PFX válido e senha correta.  
**Passos:** validar certificado.  
**Resultado esperado:** certificado aprovado para uso.  
**Status esperado:** sucesso.

### CT-022 — Senha incorreta do PFX
**Objetivo:** validar falha assistida por senha.  
**Pré-condição:** PFX válido, senha errada na UI.  
**Passos:** validar certificado.  
**Resultado esperado:** sistema informa erro e pede decisão ao usuário.  
**Status esperado:** falha assistida.

### CT-023 — PFX corrompido
**Objetivo:** validar falha por integridade.  
**Pré-condição:** arquivo `.pfx` inválido.  
**Passos:** validar certificado.  
**Resultado esperado:** sistema informa corrupção ou invalidez e pede decisão.  
**Status esperado:** falha assistida.

### CT-024 — PFX vencido
**Objetivo:** validar comportamento para certificado vencido.  
**Pré-condição:** PFX expirado.  
**Passos:** validar certificado.  
**Resultado esperado:** sistema informa vencimento e pede decisão.  
**Status esperado:** falha assistida.

### CT-025 — PFX próximo do vencimento
**Objetivo:** validar aviso de vencimento próximo.  
**Pré-condição:** PFX com validade curta remanescente.  
**Passos:** validar certificado.  
**Resultado esperado:** sistema avisa e pede decisão antes de continuar.  
**Status esperado:** warning assistido.

---

## 7.4. Arquivo único

### CT-030 — Assinar um `.exe` válido
**Objetivo:** validar o fluxo principal de assinatura unitária.  
**Pré-condição:** `signtool` válido, PFX válido e arquivo `.exe` suportado.  
**Passos:** selecionar arquivo, validar e assinar.  
**Resultado esperado:**
- original renomeado para `_OLD`;
- novo arquivo assinado mantém nome original;
- verificação final aprovada.  
**Status esperado:** sucesso.

### CT-031 — Arquivo com extensão não suportada
**Objetivo:** validar bloqueio por extensão.  
**Pré-condição:** arquivo `.txt` selecionado.  
**Passos:** tentar validar arquivo.  
**Resultado esperado:** sistema bloqueia antes da assinatura.  
**Status esperado:** falha controlada.

### CT-032 — Arquivo inexistente
**Objetivo:** validar caminho inválido.  
**Pré-condição:** seleção aponta para arquivo inexistente.  
**Passos:** validar arquivo.  
**Resultado esperado:** erro claro e bloqueante.  
**Status esperado:** falha controlada.

### CT-033 — Arquivo bloqueado
**Objetivo:** validar falha assistida de lock.  
**Pré-condição:** arquivo aberto por outro processo.  
**Passos:** validar e preparar assinatura.  
**Resultado esperado:** sistema informa bloqueio e pede decisão ou encerramento.  
**Status esperado:** falha assistida.

---

## 7.5. Lote

### CT-040 — Assinar lote apenas com arquivos válidos
**Objetivo:** validar fluxo em pasta.  
**Pré-condição:** pasta com arquivos compatíveis.  
**Passos:** selecionar pasta e executar assinatura em lote.  
**Resultado esperado:** todos os arquivos válidos processados, com resumo final consolidado.  
**Status esperado:** sucesso.

### CT-041 — Pasta com válidos e inválidos misturados
**Objetivo:** validar filtragem de extensões e continuidade.  
**Pré-condição:** pasta com arquivos suportados e não suportados.  
**Passos:** executar lote.  
**Resultado esperado:** apenas arquivos válidos entram no fluxo de assinatura; inválidos ficam fora com registro em log.  
**Status esperado:** sucesso parcial controlado.

### CT-042 — Pasta vazia ou sem arquivos suportados
**Objetivo:** validar lote sem itens úteis.  
**Pré-condição:** pasta vazia ou sem extensões aceitas.  
**Passos:** executar lote.  
**Resultado esperado:** sistema informa que não encontrou itens compatíveis.  
**Status esperado:** warning sem crash.

### CT-043 — Falha em um item do lote
**Objetivo:** validar continuidade do lote quando houver problema em um item.  
**Pré-condição:** pelo menos um arquivo válido e um bloqueado.  
**Passos:** executar lote.  
**Resultado esperado:** item bloqueado falha com log individual; os demais continuam se o fluxo estiver configurado para continuar.  
**Status esperado:** parcial controlado.

---

## 7.6. Timestamp e verificação

### CT-050 — Timestamp aplicado com sucesso
**Objetivo:** validar assinatura com timestamp.  
**Pré-condição:** servidor de timestamp acessível.  
**Passos:** assinar arquivo com timestamp habilitado.  
**Resultado esperado:** assinatura concluída com timestamp confirmado.  
**Status esperado:** sucesso.

### CT-051 — Falha no timestamp e usuário cancela
**Objetivo:** validar decisão assistida negativa.  
**Pré-condição:** URL de timestamp inválida ou indisponível.  
**Passos:** assinar arquivo e escolher não continuar sem timestamp.  
**Resultado esperado:** operação interrompida de forma controlada.  
**Status esperado:** cancelamento assistido.

### CT-052 — Falha no timestamp e usuário continua
**Objetivo:** validar decisão assistida positiva.  
**Pré-condição:** URL de timestamp inválida ou indisponível.  
**Passos:** assinar arquivo e escolher continuar sem timestamp.  
**Resultado esperado:** assinatura concluída sem timestamp, com registro da decisão.  
**Status esperado:** sucesso com warning.

### CT-053 — Verificação pós-assinatura habilitada
**Objetivo:** validar comportamento padrão.  
**Pré-condição:** `VerifyAfterSigning=1`.  
**Passos:** assinar arquivo válido.  
**Resultado esperado:** sistema executa verificação e registra o resultado.  
**Status esperado:** sucesso.

### CT-054 — Verificação pós-assinatura desabilitada
**Objetivo:** validar comportamento opcional.  
**Pré-condição:** `VerifyAfterSigning=0`.  
**Passos:** assinar arquivo válido.  
**Resultado esperado:** sistema não verifica ao final e registra essa escolha em log.  
**Status esperado:** sucesso.

---

## 7.7. Logs

### CT-060 — Gerar log visual
**Objetivo:** validar saída na interface.  
**Pré-condição:** `EnableUILog=1`.  
**Passos:** executar validação e assinatura.  
**Resultado esperado:** eventos aparecem na área de log da aplicação.  
**Status esperado:** sucesso.

### CT-061 — Gerar log em arquivo
**Objetivo:** validar rastreabilidade persistida.  
**Pré-condição:** `EnableFileLog=1`.  
**Passos:** executar operação.  
**Resultado esperado:** arquivo de log criado na pasta configurada.  
**Status esperado:** sucesso.

### CT-062 — Não registrar senha em log
**Objetivo:** validar segurança mínima.  
**Pré-condição:** senha definida na UI.  
**Passos:** executar fluxo completo com log ativo.  
**Resultado esperado:** a senha não aparece em texto puro no log técnico.  
**Status esperado:** sucesso.

---

## 8. Critérios de regressão mínima

Sempre que houver alteração em services, orquestrador ou Config Manager, os seguintes testes devem ser repetidos obrigatoriamente:

- CT-001
- CT-010
- CT-020
- CT-021
- CT-030
- CT-040
- CT-050
- CT-053
- CT-061
- CT-062

---

## 9. Critérios de encerramento da fase atual

A fase atual do projeto pode ser considerada testada quando:

- todos os cenários críticos bloqueantes estiverem cobertos;
- os cenários assistidos pedirem decisão corretamente;
- o backup `_OLD` funcionar de forma consistente;
- o lote não quebrar por falha pontual não bloqueante;
- os logs estiverem íntegros;
- a assinatura unitária e em lote estiverem funcionais;
- a verificação final refletir corretamente a configuração.

---

## 10. Conclusão

O plano de testes do RSign foi desenhado para proteger o fluxo aprovado do projeto e reduzir o risco de desvio funcional durante a implementação.

A ideia central é simples:

- validar primeiro a **configuração**;
- depois o **ambiente**;
- depois o **certificado**;
- depois o **arquivo**;
- então a **assinatura**;
- e por fim a **verificação e os logs**.

Esse encadeamento deve ser preservado em toda etapa de validação do projeto.
