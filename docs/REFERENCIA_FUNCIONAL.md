# RSign — Referência Funcional

## 1. Objetivo deste documento

Este documento descreve o **funcionamento funcional** do projeto **RSign** sob a perspectiva de uso da aplicação.

O foco deste material é explicar:

- o que a aplicação faz;
- para quem ela serve;
- como cada parte da interface participa do fluxo;
- o que o usuário pode configurar;
- o que acontece em cada validação;
- como o sistema se comporta em situações normais e em falhas críticas.

Este documento deve servir como a **referência funcional oficial** do projeto, separando claramente:

- comportamento de negócio e uso;
- decisões técnicas de implementação.

---

## 2. O que é o RSign

O **RSign** é uma aplicação local para Windows destinada à **assinatura digital de arquivos compatíveis com o ecossistema Authenticode**, utilizando inicialmente um **certificado autoassinado em `.pfx`**.

Na prática, a aplicação permite que o usuário:

- configure um perfil de certificado;
- defina como a assinatura deve ser feita;
- escolha o local do certificado e os arquivos a serem processados;
- crie o certificado quando ele não existir;
- valide o ambiente antes da assinatura;
- execute assinatura individual ou em lote;
- preserve o original com sufixo `_OLD`;
- verifique a assinatura depois da operação;
- acompanhe logs e mensagens do processo.

---

## 3. Objetivo funcional da aplicação

Do ponto de vista do usuário, o RSign existe para resolver um fluxo que antes era manual e mais propenso a erro.

A aplicação deve fornecer uma experiência em que o usuário consiga:

1. preparar o ambiente de assinatura;
2. validar se tudo está correto antes de executar;
3. criar ou reutilizar o certificado necessário;
4. escolher um arquivo ou uma pasta;
5. assinar com segurança;
6. preservar o original;
7. receber retorno claro do resultado;
8. consultar o que aconteceu por meio dos logs.

---

## 4. Perfil de uso esperado

O uso esperado do RSign é **local**, em máquina Windows, por alguém que precise assinar arquivos dentro do fluxo aprovado do projeto.

A aplicação foi pensada para cenários como:

- assinatura de um executável específico;
- assinatura de múltiplos arquivos de uma pasta;
- criação controlada de um certificado autoassinado;
- reaproveitamento de configuração salva;
- repetição do processo com o mínimo de retrabalho manual.

---

## 5. Estrutura funcional da interface

A interface principal do RSign foi dividida em **3 abas**, cada uma representando um bloco funcional do processo.

### 5.1. Aba: Perfil do Certificado

Essa aba concentra os dados que definem o perfil do certificado que será criado ou utilizado.

#### O usuário pode informar

- nome do certificado;
- nome da empresa;
- organização;
- departamento;
- cidade;
- estado;
- país;
- e-mail;
- validade;
- senha;
- confirmação da senha;
- tipo do certificado.

#### Finalidade funcional

Essa aba existe para permitir que o usuário controle a identidade lógica do certificado e os dados que serão usados no fluxo de criação ou reaproveitamento do `.pfx`.

#### O que o sistema faz com esses dados

- usa essas informações para compor a criação do certificado autoassinado;
- usa a senha para validação e assinatura;
- persiste esse perfil para reutilização futura;
- utiliza esses dados como base para validações posteriores.

---

### 5.2. Aba: Configuração da Assinatura

Essa aba concentra as regras de operação da assinatura.

#### O usuário pode configurar

- caminho manual do `signtool.exe`;
- uso de localização automática;
- preferência por usar a versão mais nova encontrada;
- URL do servidor de timestamp;
- verificação pós-assinatura;
- confirmação em caso de falha do timestamp;
- modo de log.

#### Finalidade funcional

Essa aba existe para permitir que o usuário controle **como** a assinatura será executada.

#### O que o sistema faz com esses dados

- define de onde virá o `signtool.exe`;
- define se haverá tentativa de usar timestamp;
- define se a assinatura será verificada após a execução;
- define como os eventos serão registrados;
- influencia diretamente o comportamento do fluxo operacional.

---

### 5.3. Aba: Locais e Arquivos

Essa aba concentra os caminhos físicos usados pela aplicação.

#### O usuário pode configurar

- local onde o `.pfx` será salvo ou lido;
- nome do arquivo `.pfx`;
- caminho final do certificado;
- arquivo único para assinatura;
- pasta de entrada para assinatura em lote;
- pasta de saída;
- uso da mesma pasta do original;
- estratégia de preservação do original.

#### Finalidade funcional

Essa aba existe para controlar **onde** o sistema buscará e gravará os artefatos da operação.

#### O que o sistema faz com esses dados

- localiza ou cria o `.pfx`;
- identifica o arquivo único ou a lista de arquivos válidos;
- define onde o resultado assinado será produzido;
- calcula o backup `_OLD`;
- organiza a execução em item único ou lote.

---

## 6. Fluxo funcional principal

O fluxo funcional esperado da aplicação, na visão do usuário, é este:

1. abrir o RSign;
2. revisar ou ajustar o perfil do certificado;
3. revisar ou ajustar as configurações de assinatura;
4. informar o local do PFX e os arquivos/pastas de entrada e saída;
5. validar o ambiente de assinatura;
6. validar o certificado;
7. criar o certificado, se necessário;
8. validar o arquivo ou a pasta;
9. executar a assinatura;
10. verificar a assinatura, se essa opção estiver ativa;
11. receber o resultado final;
12. consultar os logs gerados.

---

## 7. O que acontece quando o usuário valida o ambiente

Quando o usuário aciona a validação do ambiente, a aplicação deve verificar se a estrutura necessária para a assinatura está disponível.

### Essa validação deve cobrir pelo menos

- disponibilidade do `signtool.exe`;
- coerência dos caminhos informados;
- acesso ao local de entrada e saída;
- compatibilidade básica do cenário configurado.

### Resultado funcional esperado

O usuário deve receber uma resposta clara informando, por exemplo:

- qual `signtool` será usado;
- se o caminho manual é válido;
- se a versão automática encontrada é aceitável;
- se há alguma pendência que precisa ser corrigida antes da assinatura.

---

## 8. O que acontece quando o usuário valida o certificado

Ao validar o certificado, a aplicação deve analisar o `.pfx` configurado ou confirmar que será necessário criá-lo.

### Situações possíveis

#### 8.1. O PFX não existe

Nesse caso, a aplicação deve informar claramente que o certificado ainda não está disponível e oferecer a criação do novo certificado, quando isso fizer parte do fluxo permitido.

#### 8.2. O PFX existe e está válido

Nesse caso, a aplicação deve confirmar que o certificado pode ser usado na operação de assinatura.

#### 8.3. O PFX existe, mas há problema

Nessa situação, o sistema deve explicar o que ocorreu e aguardar uma decisão do usuário.

Exemplos:

- senha inválida;
- certificado vencido;
- certificado próximo do vencimento;
- PFX corrompido;
- ausência de chave privada;
- incompatibilidade com assinatura.

---

## 9. O que acontece quando o usuário cria o certificado

Quando a criação do certificado for autorizada, a aplicação deve executar um fluxo controlado para gerar o `.pfx`.

### Resultado funcional esperado

Ao final da operação, o usuário deve receber:

- confirmação de que o certificado foi criado;
- local onde o `.pfx` foi salvo;
- indicação de sucesso ou falha;
- log técnico da operação.

### Observação importante

Embora a criação técnica possa passar temporariamente por store do Windows, a visão funcional do sistema continua sendo:

- o resultado final é o arquivo `.pfx` configurado pelo usuário.

---

## 10. O que acontece ao assinar um arquivo único

Quando o usuário escolhe um arquivo único, a aplicação deve seguir um fluxo funcional simples e previsível.

### Passos esperados

1. validar se o arquivo existe;
2. validar se a extensão é suportada;
3. validar se o arquivo pode ser lido e manipulado;
4. preparar o backup do original;
5. executar a assinatura;
6. verificar a assinatura, se habilitado;
7. exibir o resultado final.

### Resultado esperado para o usuário

- o arquivo original passa a existir com sufixo `_OLD`;
- o arquivo assinado final mantém o nome original;
- o usuário recebe uma mensagem de sucesso, alerta ou falha;
- o log registra o histórico técnico da operação.

---

## 11. O que acontece ao assinar em lote

Quando o usuário seleciona uma pasta, a aplicação deve trabalhar item por item dentro das extensões aprovadas.

### Comportamento esperado

- localizar arquivos válidos na pasta;
- ignorar arquivos incompatíveis;
- processar cada item individualmente;
- registrar resultado por arquivo;
- consolidar um resumo ao final.

### Resultado funcional esperado

Ao fim da operação em lote, o usuário deve conseguir visualizar:

- quantos arquivos foram encontrados;
- quantos foram assinados com sucesso;
- quantos falharam;
- quais itens exigem revisão;
- quais avisos ocorreram durante o processo.

---

## 12. Preservação do arquivo original

A política funcional aprovada do projeto é sempre preservar o original.

### Regra funcional

Antes de produzir o arquivo assinado final, o sistema deve renomear o arquivo original com o sufixo `_OLD`.

### Exemplo

```text
Original antes: MeuModulo.dll
Após o processo:
- MeuModulo_OLD.dll
- MeuModulo.dll   (assinado)
```

### Valor funcional dessa regra

Essa estratégia protege o usuário contra perda silenciosa do arquivo original e mantém rastreabilidade local da substituição.

---

## 13. Verificação pós-assinatura

A aplicação deve oferecer uma etapa de verificação após a assinatura.

### Regra funcional aprovada

- a verificação vem ativada por padrão;
- o usuário pode desativá-la;
- o resultado deve ser exibido de forma clara.

### O usuário deve conseguir entender

- se a assinatura foi aplicada;
- se a verificação foi executada;
- se ela foi aprovada ou não;
- se houve avisos relacionados ao timestamp.

---

## 14. Comportamento em falha de timestamp

Quando o timestamp não puder ser aplicado, o sistema não deve continuar de forma silenciosa.

### Comportamento funcional aprovado

O sistema deve:

1. informar ao usuário que o timestamp falhou;
2. explicar o impacto de continuar sem timestamp;
3. perguntar se o usuário deseja continuar.

Esse comportamento preserva a clareza do fluxo e impede que o usuário avance sem entender a consequência da decisão.

---

## 15. Comportamento em falhas críticas

Algumas falhas não podem ser tratadas como simples mensagens informativas.

### O sistema deve pedir decisão do usuário quando ocorrerem situações como

- certificado vencido;
- certificado próximo do vencimento;
- senha inválida;
- PFX corrompido;
- arquivo bloqueado com possibilidade de nova tentativa;
- falha de timestamp;
- escolha entre recriar certificado ou usar outro arquivo.

### Resultado funcional esperado

O usuário deve sempre receber:

- explicação do problema;
- impacto provável;
- opções claras de continuidade.

---

## 16. Mensagens e logs

O RSign deve trabalhar com dois níveis de comunicação.

### 16.1. Comunicação amigável

Voltada para o usuário entender o que aconteceu de forma objetiva.

Exemplos:

- certificado validado com sucesso;
- assinatura concluída;
- timestamp indisponível;
- PFX não encontrado;
- arquivo incompatível.

### 16.2. Comunicação técnica

Voltada para diagnóstico, manutenção e auditoria local.

Exemplos:

- caminho do `signtool` escolhido;
- comando executado;
- retorno do processo externo;
- detalhes da falha de validação;
- resultado da verificação final.

### Saída esperada

Essas informações devem existir em:

- visualização na tela;
- arquivo de log.

---

## 17. Persistência funcional

A aplicação deve manter as configurações para reaproveitamento nas próximas execuções.

### O usuário não deve precisar reconfigurar a cada abertura

Os seguintes blocos devem ser persistidos:

- perfil do certificado;
- caminhos do PFX;
- caminhos de entrada e saída;
- escolha do `signtool`;
- preferência de verificação;
- configuração do timestamp;
- tipo de log;
- modo de operação.

### Benefício funcional

Isso transforma o RSign em uma ferramenta repetível, previsível e adequada para uso recorrente.

---

## 18. Resultado final esperado pelo usuário

Ao final de uma operação bem-sucedida, o usuário deve perceber que o sistema:

- validou o cenário antes de agir;
- preservou o original;
- executou a assinatura;
- verificou o resultado quando configurado;
- registrou tudo o que aconteceu;
- apresentou retorno claro sobre sucesso, aviso ou erro.

---

## 19. Limites funcionais da fase atual

Para manter o projeto dentro do contexto aprovado, a fase atual não deve ser tratada como solução completa para todos os cenários de assinatura possíveis.

### Não faz parte da fase atual como foco principal

- integração com nuvem;
- assinatura com HSM;
- gerenciamento corporativo distribuído de certificados;
- uso remoto multiusuário;
- telemetria externa;
- painéis avançados de administração.

Esses cenários podem ser considerados futuramente, mas não devem contaminar a definição funcional atual do produto.

---

## 20. Relação deste documento com os demais materiais

Este documento deve ser lido em conjunto com:

- `README.md`
- `CONTEXTO_TECNICO.md`
- `PLANO_IMPLEMENTACAO_RSIGN.md`
- `ARQUITETURA_UNITS_RSIGN_CONSOLIDADO.md`
- `CONTRATOS_INTERFACES_RSIGN.md`
- `MATRIZ_IMPLEMENTACAO_RSIGN.md`

### Papel deste material dentro do conjunto

Se o README apresenta a visão geral e o contexto técnico registra as decisões de engenharia, este documento registra **como o sistema deve se comportar funcionalmente para o usuário**.

---

## 21. Conclusão

A referência funcional do **RSign** estabelece o comportamento esperado da aplicação sem misturar indevidamente detalhes internos de implementação.

Com este documento, o projeto passa a ter uma base clara para responder perguntas como:

- o que o usuário configura;
- o que o sistema valida;
- quando o sistema cria o certificado;
- como funciona a assinatura;
- como funciona o lote;
- quando o sistema pergunta ao usuário antes de continuar;
- o que precisa ser mostrado em tela e em log.

Esse é o material que deve ser usado sempre que a equipe precisar validar se uma tela, fluxo ou comportamento continua fiel ao escopo aprovado do projeto **RSign**.
