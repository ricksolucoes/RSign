# RSign — Contexto Técnico

## 1. Objetivo deste documento

Este documento consolida o **contexto técnico oficial** do projeto **RSign**, reunindo em um único material:

- a origem funcional do projeto;
- as decisões técnicas já aprovadas;
- os limites conhecidos da solução atual;
- o comportamento esperado da aplicação FMX;
- os critérios que devem ser respeitados durante toda a implementação;
- a preparação da arquitetura para crescimento futuro.

Este arquivo deve ser tratado como a **memória técnica permanente** do projeto. Sempre que surgir uma nova dúvida de implementação, decisão de arquitetura, comportamento de interface ou regra operacional, a validação deve partir deste documento antes de qualquer codificação.

---

## 2. Origem do projeto

O projeto **RSign** nasce a partir de uma solução existente em **BAT**, chamada `Gerador.bat`, criada para:

- gerar um certificado autoassinado;
- exportar esse certificado em `.pfx`;
- localizar o `signtool.exe`;
- selecionar um executável;
- assinar o arquivo usando SHA256 e timestamp.

Essa BAT representa a **base operacional original** do processo, porém ela não atende adequadamente a requisitos de:

- rastreabilidade;
- persistência de configuração;
- separação de responsabilidades;
- validação rica do certificado;
- suporte a assinatura em lote;
- decisão assistida em falhas críticas;
- extensibilidade futura.

Por esse motivo, o RSign foi definido como uma **evolução arquitetural** desse fluxo, e não apenas como uma reescrita visual da BAT.

---

## 3. Plataforma aprovada

O projeto foi definido para operar com as seguintes bases técnicas:

- **Linguagem / IDE:** Delphi 10.2
- **Camada visual:** FMX
- **Sistema operacional alvo:** Windows
- **Modo de operação:** local
- **Execução:** manual e automática, conforme o fluxo disparado pela UI
- **Assinatura inicial:** certificado autoassinado em `.pfx`
- **Evolução futura prevista:** PFX externo e certificado real de Code Signing

O projeto **não** foi pensado inicialmente para:

- assinatura em nuvem;
- uso corporativo distribuído com store centralizado;
- orquestração remota;
- dependência de banco de dados;
- exigência de serviço Windows.

A arquitetura, no entanto, deve continuar apta a crescer para novos cenários no futuro.

---

## 4. Objetivo técnico do RSign

O RSign deve ser uma aplicação local capaz de:

1. localizar e validar o ambiente necessário para assinatura;
2. localizar e validar o `signtool.exe`;
3. localizar o certificado `.pfx` ou criá-lo quando não existir;
4. validar o certificado antes do uso;
5. trabalhar com **arquivo único** ou **lote de arquivos**;
6. preservar o original por meio do sufixo `_OLD`;
7. manter o arquivo assinado com o nome original;
8. assinar com SHA256;
9. aplicar timestamp quando configurado;
10. verificar a assinatura ao final, por padrão;
11. explicar problemas críticos e aguardar a decisão do usuário;
12. registrar logs técnicos e amigáveis em tela e em arquivo.

---

## 5. Decisões técnicas já aprovadas

Esta seção resume as decisões que já foram fechadas e que devem valer durante a implementação.

### 5.1. Tipo de certificado na fase inicial

Na fase inicial, o projeto utilizará:

- **certificado autoassinado**
- exportado em **`.pfx`**

Ao mesmo tempo, a arquitetura deve prever suporte futuro para:

- **PFX externo** já existente;
- **certificado real de Code Signing**.

### 5.2. Destino final do certificado

O certificado **não deve permanecer armazenado como solução final em store do Windows**.

O artefato final esperado pelo sistema é o arquivo:

- `.pfx`

### 5.3. Estratégia técnica de criação do certificado

Como a geração de certificado autoassinado via mecanismos nativos normalmente passa por store do Windows, a melhor prática aprovada foi:

1. criar temporariamente o certificado no store `CurrentUser\My`;
2. exportar o certificado para `.pfx`;
3. remover imediatamente o certificado do store;
4. manter apenas o `.pfx` como artefato final.

Essa decisão foi aprovada por ser a forma mais segura e estável de evitar erro técnico na criação do certificado sem contrariar a regra de negócio do projeto.

### 5.4. Senha padrão do PFX

A senha padrão inicial continua sendo:

- `123456`

No entanto:

- a UI deve sempre permitir alteração;
- a senha deve ser mascarada visualmente;
- a senha não deve ser gravada em logs em texto puro.

### 5.5. Ferramenta de assinatura

A ferramenta de assinatura adotada será o:

- `signtool.exe`

O projeto deve permitir:

- localização automática;
- caminho manual informado pelo usuário;
- escolha automática da **versão mais nova** quando houver múltiplas instalações;
- possibilidade de override manual na UI.

### 5.6. Modo de operação

O projeto deve operar em dois modos:

- **arquivo único**;
- **lote**.

A seleção desse comportamento deve partir da UI.

### 5.7. Estratégia de preservação do original

A política oficial aprovada é:

- o arquivo original deve ser renomeado com sufixo `_OLD`;
- o arquivo assinado final deve manter o **nome original**.

Exemplo:

```text
Arquivo original: MeuApp.exe
Backup:           MeuApp_OLD.exe
Assinado final:   MeuApp.exe
```

### 5.8. Extensões aceitas inicialmente

O sistema deve trabalhar inicialmente com extensões conhecidas e compatíveis com o fluxo aprovado:

- `.exe`
- `.dll`
- `.msi`
- `.cab`
- `.cat`

A UI e o serviço de arquivos devem respeitar esse filtro como comportamento padrão.

### 5.9. Verificação pós-assinatura

A verificação da assinatura após a operação deve existir e vir:

- **ativada por padrão**

O usuário poderá desativá-la pela UI, mas o comportamento inicial padrão da aplicação deve continuar sendo verificar a assinatura ao final.

### 5.10. Timestamp

O projeto deve permitir configuração do servidor de timestamp.

Se o timestamp falhar:

1. o sistema deve explicar o problema;
2. o sistema deve explicar o impacto técnico de continuar sem timestamp;
3. o sistema deve perguntar se o usuário deseja continuar sem timestamp.

O sistema **não deve continuar silenciosamente** nesse cenário.

### 5.11. Privilégios administrativos

A aplicação **não deve exigir privilégio administrativo logo no início**.

A elevação só deve ocorrer quando realmente necessária, conforme o fluxo técnico adotado pela implementação.

### 5.12. Logs

O projeto deve registrar logs em:

- tela;
- arquivo.

As mensagens precisam existir em dois níveis:

- **amigável**, voltada ao usuário;
- **técnica**, voltada ao diagnóstico e manutenção.

---

## 6. Limitações conhecidas da BAT original

A BAT original é relevante como referência de comportamento inicial, mas possui limitações que **não podem ser repetidas** no projeto Delphi sem tratamento adequado.

### Limitações identificadas

- exige administrador logo no início;
- trabalha apenas com `.exe`;
- verifica apenas a existência física do `.pfx`;
- não valida de forma rica:
  - senha do certificado;
  - integridade do PFX;
  - presença de chave privada;
  - compatibilidade com assinatura;
  - vigência;
- não confirma formalmente a assinatura ao final;
- concentra o fluxo todo em uma lógica procedural única;
- não persiste configuração de forma estruturada;
- não separa interface, regra de negócio e execução técnica;
- não trabalha com camadas nem com contratos.

Essas limitações justificam diretamente a arquitetura aprovada para o RSign.

---

## 7. Diretrizes arquiteturais obrigatórias

Durante a codificação, as seguintes diretrizes devem ser preservadas.

### 7.1. A UI não decide regra técnica

A interface FMX deve:

- coletar dados;
- mostrar resultados;
- apresentar mensagens;
- encaminhar decisões do usuário.

A UI **não deve**:

- construir comandos de assinatura;
- validar certificado em profundidade;
- localizar `signtool` diretamente;
- decidir automaticamente sobre continuidade em falhas críticas.

### 7.2. O orquestrador centraliza o fluxo

Toda a sequência operacional deve passar por um módulo orquestrador responsável por decidir a ordem correta de:

- validação de ambiente;
- validação do `signtool`;
- validação do certificado;
- criação do certificado;
- preparação de arquivos;
- assinatura;
- verificação;
- registro de resultado.

### 7.3. Services executam responsabilidades especializadas

Cada domínio funcional deve possuir sua própria implementação especializada.

Exemplos:

- certificado;
- signtool;
- arquivos;
- assinatura;
- verificação;
- processos externos;
- logger.

### 7.4. Types transportam dados

Os dados operacionais devem circular em structures claras, e não em cadeias de parâmetros soltos.

### 7.5. Configuração deve ser persistida

O sistema deve ser reaberto mantendo:

- perfil do certificado;
- caminhos;
- preferências de assinatura;
- preferências de log;
- signtool;
- timestamp;
- modo de operação.

---

## 8. Estrutura visual aprovada

A UI principal do RSign foi aprovada com **3 abas funcionais**.

### 8.1. Aba: Perfil do Certificado

Destinada a configurar:

- nome do certificado;
- empresa;
- organização;
- departamento;
- cidade;
- estado;
- país;
- e-mail;
- validade;
- senha;
- confirmação de senha;
- tipo do certificado.

### 8.2. Aba: Configuração da Assinatura

Destinada a configurar:

- caminho manual do `signtool`;
- localização automática;
- uso da versão mais nova;
- URL do timestamp;
- verificação pós-assinatura;
- confirmação para continuar sem timestamp;
- modo de log.

### 8.3. Aba: Locais e Arquivos

Destinada a configurar:

- local do `.pfx`;
- nome do `.pfx`;
- caminho completo do certificado;
- origem dos arquivos;
- seleção de arquivo único ou pasta;
- destino de saída;
- modo de preservação do original;
- lista de arquivos válidos encontrados.

Essa divisão visual **não é apenas estética**. Ela reflete a divisão lógica do sistema e deve ser preservada como parte da arquitetura.

---

## 9. Fluxo técnico consolidado da aplicação

O fluxo técnico esperado da aplicação é o seguinte.

1. carregar configurações persistidas;
2. exibir dados atuais na interface;
3. validar o `signtool` conforme configuração;
4. validar o certificado informado;
5. criar certificado se necessário e autorizado;
6. validar arquivo único ou lista em lote;
7. preparar backup `_OLD`;
8. executar assinatura;
9. verificar assinatura, se habilitado;
10. registrar log detalhado;
11. apresentar resultado consolidado ao usuário.

---

## 10. Política de falhas

Nem toda falha deve receber o mesmo tratamento.

### 10.1. Falhas bloqueantes diretas

Devem interromper a operação imediatamente quando não houver caminho viável.

Exemplos:

- arquivo inexistente;
- extensão inválida;
- pasta de saída inválida;
- `signtool` não encontrado;
- acesso negado irrecuperável.

### 10.2. Falhas com decisão assistida

Devem registrar o problema e pedir decisão explícita do usuário.

Exemplos:

- certificado vencido;
- senha inválida do PFX;
- PFX corrompido;
- certificado próximo do vencimento;
- timestamp indisponível;
- arquivo bloqueado com possibilidade de nova tentativa;
- `signtool` automático encontrado, mas com necessidade de confirmação pelo usuário.

### 10.3. Falhas parciais em lote

Em modo lote, a falha de um item não deve necessariamente impedir o restante do processamento.

A recomendação técnica aprovada é:

- falhar por item quando necessário;
- registrar individualmente cada ocorrência;
- consolidar um resumo geral ao final.

---

## 11. Persistência aprovada

A configuração local do sistema deve ser mantida em:

- arquivo `.ini`

Motivos aprovados:

- simplicidade de implementação no Delphi 10.2;
- leitura humana;
- manutenção de baixo custo;
- aderência suficiente ao escopo do projeto.

### Seções aprovadas

- `[CertificateProfile]`
- `[SigningSettings]`
- `[Paths]`
- `[Log]`

---

## 12. Segurança operacional mínima

Mesmo sendo uma ferramenta local, o projeto deve respeitar regras básicas de segurança operacional.

### Regras mínimas

- mascarar a senha na UI;
- não gravar senha em log em texto puro;
- preservar o original por meio do fluxo `_OLD`;
- não remover silenciosamente o original sem backup;
- registrar erros de forma rastreável;
- evitar decisões automáticas em falhas críticas.

---

## 13. Limites atuais do projeto

Para evitar desvio de escopo, estes limites devem ser respeitados no estágio atual.

### O projeto atual não contempla como escopo principal

- gerenciamento de certificados empresariais distribuídos;
- assinatura baseada em HSM;
- integração com nuvem;
- store corporativo centralizado;
- mecanismos avançados de compliance;
- catálogo completo de relatórios em banco de dados;
- telemetria externa.

Esses itens não estão proibidos tecnicamente, mas **não fazem parte da fase atual**.

---

## 14. Expansão futura prevista

A arquitetura já deve nascer preparada para cenários futuros, incluindo:

- uso de PFX externo sem recriação;
- uso de certificado real de Code Signing;
- múltiplos perfis de assinatura;
- automação sem UI;
- exportação de relatórios finais;
- suporte a mais políticas de timestamp;
- novas estratégias de validação.

A preparação para esses cenários deve ocorrer por meio de:

- interfaces bem definidas;
- services segmentados;
- orquestrador central;
- types independentes da interface;
- baixo acoplamento com FMX.

---

## 15. Relação deste documento com os demais artefatos

Este documento deve ser lido em conjunto com:

- `README.md`
- `PLANO_IMPLEMENTACAO_RSIGN.md`
- `ARQUITETURA_UNITS_RSIGN_CONSOLIDADO.md`
- `CONTRATOS_INTERFACES_RSIGN.md`
- `MATRIZ_IMPLEMENTACAO_RSIGN.md`

### Papel de cada um

- **README**: visão geral do repositório e do projeto.
- **Plano de implementação**: ordem e fases de execução.
- **Arquitetura das units**: organização estrutural da solução.
- **Contratos e interfaces**: o que cada módulo deve expor.
- **Matriz de implementação**: qual interface será implementada em qual unit e em que ordem.
- **Contexto técnico**: memória consolidada das decisões técnicas aprovadas.

---

## 16. Conclusão

O **RSign** não deve ser tratado como uma simples tela para reproduzir uma BAT existente.

Ele é uma evolução arquitetural de um fluxo operacional real, com objetivo de transformar um processo manual e procedural em uma aplicação Delphi 10.2 FMX com:

- separação clara de responsabilidades;
- configuração persistente;
- validações ricas;
- rastreabilidade;
- decisão assistida;
- preparo para crescimento futuro.

A partir deste documento, toda nova implementação deve respeitar estas premissas como referência oficial do projeto.
