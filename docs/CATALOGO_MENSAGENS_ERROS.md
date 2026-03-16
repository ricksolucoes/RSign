# RSign — Catálogo de Mensagens e Erros

## 1. Objetivo deste documento

Este documento define o catálogo oficial de ocorrências, mensagens amigáveis, mensagens técnicas e ações esperadas do projeto **RSign**.

O objetivo deste material é padronizar:

- o texto apresentado ao usuário;
- o texto técnico registrado em log;
- o comportamento esperado diante de cada falha;
- os cenários que exigem decisão assistida;
- os códigos de referência internos das ocorrências.

Esse catálogo deve ser usado por:

- `RSign.Services.Logger`;
- `RSign.Core.Orchestrator`;
- `RSign.Services.Certificate`;
- `RSign.Services.SignTool`;
- `RSign.Services.FileSigning`;
- `RSign.Services.Signing`;
- `RSign.Services.SigningVerification`;
- `RSign.Services.UserDecision`.

---

## 2. Estrutura recomendada para cada ocorrência

Cada ocorrência do sistema deve possuir, no mínimo:

- **Código interno**;
- **Categoria**;
- **Mensagem amigável**;
- **Mensagem técnica**;
- **Nível de log**;
- **É bloqueante ou não**;
- **Exige decisão assistida ou não**;
- **Ação sugerida**.

---

## 3. Legenda das colunas

### Categoria
Agrupa o domínio da ocorrência.

### Nível
Define a severidade esperada no logger.

### Bloqueante
Indica se a operação deve parar imediatamente.

### Decisão assistida
Indica se o usuário deve ser consultado antes da continuidade.

---

## 4. Ocorrências do ambiente e configuração

| Código | Categoria | Nível | Bloqueante | Decisão assistida | Mensagem amigável | Mensagem técnica | Ação sugerida |
|---|---|---:|---:|---:|---|---|---|
| RSIGN-0001 | Configuração | Error | Sim | Não | Não foi possível carregar a configuração da aplicação. | Falha ao abrir ou interpretar o arquivo de configuração `.ini`. | Validar permissões, integridade do arquivo e estrutura das seções. |
| RSIGN-0002 | Configuração | Warning | Não | Não | Algumas configurações não foram encontradas e os valores padrão foram aplicados. | Uma ou mais chaves do `.ini` estavam ausentes. Defaults em memória foram usados. | Registrar defaults usados e permitir continuidade. |
| RSIGN-0003 | Configuração | Error | Sim | Não | Os caminhos configurados estão incompletos ou inválidos. | O conjunto de entrada, saída ou localização do PFX não atende aos critérios mínimos. | Revisar os campos da aba Locais e Arquivos. |

---

## 5. Ocorrências do SignTool

| Código | Categoria | Nível | Bloqueante | Decisão assistida | Mensagem amigável | Mensagem técnica | Ação sugerida |
|---|---|---:|---:|---:|---|---|---|
| RSIGN-1001 | SignTool | Error | Sim | Não | Não foi possível localizar o aplicativo de assinatura do Windows. | Nenhuma instância válida de `signtool.exe` foi encontrada no caminho manual, PATH ou Windows Kits. | Instalar o Windows SDK ou informar o caminho manual corretamente. |
| RSIGN-1002 | SignTool | Error | Sim | Não | O caminho manual informado para o aplicativo de assinatura não existe. | O arquivo definido em `ManualSignToolPath` não foi encontrado. | Corrigir o caminho manual ou habilitar a localização automática. |
| RSIGN-1003 | SignTool | Error | Sim | Não | O aplicativo de assinatura foi encontrado, mas não pôde ser utilizado. | A execução de validação do `signtool.exe` falhou ou retornou comportamento incompatível. | Verificar versão, permissões e integridade do executável. |
| RSIGN-1004 | SignTool | Info | Não | Sim | Foram encontradas múltiplas versões do aplicativo de assinatura. | Mais de uma instância de `signtool.exe` foi localizada. | Usar a mais nova por padrão ou permitir escolha manual. |
| RSIGN-1005 | SignTool | Success | Não | Não | O aplicativo de assinatura foi localizado com sucesso. | `signtool.exe` validado com sucesso. | Prosseguir com a operação. |

---

## 6. Ocorrências do certificado PFX

| Código | Categoria | Nível | Bloqueante | Decisão assistida | Mensagem amigável | Mensagem técnica | Ação sugerida |
|---|---|---:|---:|---:|---|---|---|
| RSIGN-2001 | Certificado | Warning | Não | Sim | O certificado configurado não foi encontrado. Deseja criá-lo agora? | O arquivo `.pfx` não existe no caminho configurado. | Oferecer criação do certificado autoassinado. |
| RSIGN-2002 | Certificado | Error | Sim | Sim | O certificado foi encontrado, mas a senha informada não é válida. | Falha na abertura do `.pfx` com a senha atual. | Permitir corrigir senha, selecionar outro PFX ou cancelar. |
| RSIGN-2003 | Certificado | Error | Sim | Sim | O certificado encontrado parece estar corrompido ou inválido. | O `.pfx` existe, porém não pôde ser lido como certificado válido. | Permitir recriar ou selecionar outro PFX. |
| RSIGN-2004 | Certificado | Warning | Não | Sim | O certificado está vencido. Deseja recriá-lo ou cancelar? | A data final de vigência do certificado já foi ultrapassada. | Oferecer recriação ou troca do PFX. |
| RSIGN-2005 | Certificado | Warning | Não | Sim | O certificado está próximo do vencimento. Deseja continuar assim mesmo? | A validade restante está abaixo do limite operacional definido. | Permitir continuar, trocar ou recriar. |
| RSIGN-2006 | Certificado | Error | Sim | Sim | O certificado não possui chave privada utilizável para assinatura. | O `.pfx` foi aberto, porém sem private key válida para o fluxo de assinatura. | Selecionar outro PFX ou recriar. |
| RSIGN-2007 | Certificado | Error | Sim | Sim | O certificado encontrado não é compatível com assinatura de código. | A análise do certificado não confirmou uso compatível com assinatura esperada. | Selecionar outro PFX ou recriar. |
| RSIGN-2008 | Certificado | Success | Não | Não | O certificado foi validado com sucesso. | O `.pfx` está íntegro, com senha correta e pronto para uso. | Prosseguir com a operação. |
| RSIGN-2009 | Certificado | Success | Não | Não | O certificado foi criado com sucesso. | Certificado temporário gerado no store, exportado para `.pfx` e removido do store. | Registrar detalhes da operação em log. |
| RSIGN-2010 | Certificado | Error | Sim | Não | Não foi possível criar o certificado configurado. | Falha durante criação, exportação ou remoção do certificado temporário. | Validar PowerShell, permissões e parâmetros de geração. |

---

## 7. Ocorrências dos arquivos de entrada e saída

| Código | Categoria | Nível | Bloqueante | Decisão assistida | Mensagem amigável | Mensagem técnica | Ação sugerida |
|---|---|---:|---:|---:|---|---|---|
| RSIGN-3001 | Arquivo | Error | Sim | Não | O arquivo selecionado não foi encontrado. | O caminho de entrada informado não existe. | Corrigir a seleção do arquivo ou pasta. |
| RSIGN-3002 | Arquivo | Error | Sim | Não | O tipo de arquivo selecionado não é suportado para assinatura neste projeto. | Extensão fora da lista aprovada: `.exe`, `.dll`, `.msi`, `.cab`, `.cat`. | Selecionar um arquivo compatível. |
| RSIGN-3003 | Arquivo | Error | Sim | Não | O arquivo está sem permissão de leitura ou escrita. | O processo não conseguiu acesso adequado ao arquivo alvo. | Verificar permissões do sistema de arquivos. |
| RSIGN-3004 | Arquivo | Error | Sim | Sim | O arquivo parece estar em uso ou bloqueado por outro processo. | Falha ao abrir, mover ou renomear o arquivo, sugerindo lock externo. | Fechar o processo que usa o arquivo e tentar novamente. |
| RSIGN-3005 | Arquivo | Error | Sim | Não | Não foi possível preparar a cópia de segurança do arquivo original. | Falha ao renomear o original para `_OLD`. | Verificar bloqueio, permissões e existência prévia do backup. |
| RSIGN-3006 | Arquivo | Success | Não | Não | O arquivo foi preparado com sucesso para assinatura. | Validação do item concluída e estratégia `_OLD` pronta para execução. | Prosseguir com a assinatura. |
| RSIGN-3007 | Arquivo | Warning | Não | Não | Nenhum arquivo compatível foi encontrado na pasta selecionada. | A varredura da pasta não encontrou extensões suportadas. | Revisar pasta de entrada. |

---

## 8. Ocorrências da assinatura

| Código | Categoria | Nível | Bloqueante | Decisão assistida | Mensagem amigável | Mensagem técnica | Ação sugerida |
|---|---|---:|---:|---:|---|---|---|
| RSIGN-4001 | Assinatura | Error | Sim | Não | Não foi possível iniciar o processo de assinatura. | Falha ao executar o `signtool sign`. | Verificar executor de processo, parâmetros e permissões. |
| RSIGN-4002 | Assinatura | Error | Sim | Não | A assinatura falhou ao acessar o certificado configurado. | O `signtool` não conseguiu abrir o `.pfx` ou validar a senha. | Confirmar senha e integridade do arquivo PFX. |
| RSIGN-4003 | Assinatura | Warning | Não | Sim | Não foi possível aplicar o timestamp. Deseja continuar sem ele? | O servidor de timestamp não respondeu ou retornou falha durante a assinatura. | Explicar impacto e aguardar decisão do usuário. |
| RSIGN-4004 | Assinatura | Warning | Não | Não | A assinatura foi concluída sem timestamp. | O processo seguiu após confirmação explícita do usuário para continuar sem timestamp. | Registrar decisão e impacto no log. |
| RSIGN-4005 | Assinatura | Success | Não | Não | A assinatura foi aplicada com sucesso. | O `signtool sign` concluiu a operação com retorno compatível. | Prosseguir para verificação, se habilitada. |

---

## 9. Ocorrências da verificação pós-assinatura

| Código | Categoria | Nível | Bloqueante | Decisão assistida | Mensagem amigável | Mensagem técnica | Ação sugerida |
|---|---|---:|---:|---:|---|---|---|
| RSIGN-5001 | Verificação | Error | Sim | Não | A verificação da assinatura falhou. | O `signtool verify` não confirmou uma assinatura válida no arquivo resultante. | Revisar assinatura, certificado e timestamp. |
| RSIGN-5002 | Verificação | Warning | Não | Não | A assinatura foi encontrada, mas o timestamp não foi confirmado. | A verificação identificou assinatura presente sem timestamp válido ou detectável. | Registrar a condição e avaliar impacto operacional. |
| RSIGN-5003 | Verificação | Success | Não | Não | A assinatura foi verificada com sucesso. | O `signtool verify` validou a assinatura do arquivo. | Finalizar a operação com sucesso. |
| RSIGN-5004 | Verificação | Info | Não | Não | A verificação final foi ignorada conforme configuração. | A opção `VerifyAfterSigning` estava desabilitada. | Registrar a escolha do usuário. |

---

## 10. Ocorrências do fluxo em lote

| Código | Categoria | Nível | Bloqueante | Decisão assistida | Mensagem amigável | Mensagem técnica | Ação sugerida |
|---|---|---:|---:|---:|---|---|---|
| RSIGN-6001 | Lote | Info | Não | Não | A operação em lote foi iniciada. | Processo de assinatura em lote iniciado com a lista de arquivos válidos. | Registrar quantidade total de itens. |
| RSIGN-6002 | Lote | Warning | Não | Não | Um dos arquivos do lote falhou, mas os demais continuarão sendo processados. | Falha isolada por item em fluxo configurado para continuar. | Registrar item, motivo e continuidade. |
| RSIGN-6003 | Lote | Success | Não | Não | A operação em lote foi concluída. | Lote finalizado com resumo consolidado de sucessos, falhas e avisos. | Exibir relatório resumido ao usuário. |

---

## 11. Mensagens de decisão assistida recomendadas

## 11.1. Certificado inexistente

**Mensagem amigável sugerida**

> O certificado configurado não foi encontrado no local informado. Deseja criar um novo certificado agora?

## 11.2. Certificado vencido

**Mensagem amigável sugerida**

> O certificado encontrado está vencido. Você pode recriá-lo, selecionar outro arquivo PFX ou cancelar a operação.

## 11.3. Certificado próximo do vencimento

**Mensagem amigável sugerida**

> O certificado está próximo do vencimento. Deseja continuar com ele mesmo assim?

## 11.4. Falha no timestamp

**Mensagem amigável sugerida**

> Não foi possível aplicar o timestamp. Sem ele, a assinatura pode ter validade prática reduzida em cenários futuros. Deseja continuar sem timestamp?

## 11.5. Arquivo bloqueado

**Mensagem amigável sugerida**

> O arquivo parece estar em uso por outro processo. Feche o aplicativo que está utilizando esse arquivo ou tente novamente mais tarde.

---

## 12. Regras de implementação

- Os códigos internos devem permanecer estáveis.
- A mensagem amigável deve ser curta, clara e orientada ao usuário.
- A mensagem técnica deve ser detalhada o suficiente para log e suporte.
- O orquestrador deve decidir o comportamento com base na classificação da ocorrência.
- A UI não deve criar mensagens arbitrárias para cenários já catalogados.

---

## 13. Conclusão

O catálogo de mensagens do RSign existe para garantir consistência entre operação, log técnico e experiência do usuário.

A regra central é:

- o **service detecta**;
- o **logger registra**;
- o **orquestrador interpreta**;
- a **UI apresenta**;
- o **usuário decide**, quando a situação exigir.

Esse padrão deve ser seguido em toda implementação futura do projeto.
