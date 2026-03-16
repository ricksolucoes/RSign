# RSign

Assinador local de arquivos para Windows, desenvolvido em **Delphi 10+**, com suporte ao **certificado autoassinado em `.pfx`** e estrutura preparada para futura adoção de **PFX externo** e **certificados reais de Code Signing**.

> Este README descreve o que a aplicação faz, como a interface foi organizada, quais regras operacionais já estão definidas, como o fluxo de assinatura funciona e como a base foi separada em camadas para facilitar manutenção e evolução.

## Sumário

* [1. Visão geral](#1-visão-geral)
* [2. Status atual do projeto](#2-status-atual-do-projeto)
* [3. Objetivo do RSign](#3-objetivo-do-rsign)
* [4. Escopo funcional](#4-escopo-funcional)
* [5. Interface da aplicação](#5-interface-da-aplicação)
* [6. Fluxo de execução](#6-fluxo-de-execução)
* [7. Regras de decisão assistida](#7-regras-de-decisão-assistida)
* [8. Arquitetura técnica](#8-arquitetura-técnica)
* [9. Estrutura sugerida do projeto](#9-estrutura-sugerida-do-projeto)
* [10. Units e responsabilidades](#10-units-e-responsabilidades)
* [11. Modelos e tipos previstos](#11-modelos-e-tipos-previstos)
* [12. Configurações padrão](#12-configurações-padrão)
* [13. Requisitos de ambiente](#13-requisitos-de-ambiente)
* [14. Como compilar](#14-como-compilar)
* [15. Como usar](#15-como-usar)
* [16. Logs e rastreabilidade](#16-logs-e-rastreabilidade)
* [17. Regras operacionais e cuidados](#17-regras-operacionais-e-cuidados)
* [18. Limitações do modelo inicial](#18-limitações-do-modelo-inicial)
* [19. Roadmap técnico](#19-roadmap-técnico)
* [20. Diretriz de continuidade](#20-diretriz-de-continuidade)

## 1. Visão geral

O **RSign** é uma aplicação desktop para Windows voltada à assinatura local de arquivos compatíveis com o ecossistema **Authenticode**, usando um **arquivo `.pfx` autoassinado**.

A proposta do projeto é transformar o processo de assinatura em um fluxo claro, controlado e reutilizável dentro de uma aplicação, com:

* configuração persistente;
* validação do certificado antes do uso;
* descoberta e controle do `signtool.exe`;
* assinatura de arquivo único ou lote por pasta;
* verificação pós-assinatura;
* logs amigáveis e técnicos;
* decisões assistidas quando existir risco ou ambiguidade.

O foco do RSign não é apenas assinar um arquivo. O foco é fazer isso com rastreabilidade, previsibilidade.

## 2. Status atual do projeto

No contexto definido até aqui, o projeto está assim:

* **tecnologia alvo:** Delphi 10+ FMX;
* **plataforma:** Windows local;
* **modelo inicial de certificado:** `.pfx` autoassinado;
* **expansão futura prevista:** PFX externo e Code Signing real;
* **estratégia de backup do original:** definida;
* **política de timestamp:** definida;
* **política de logs:** definida;
* **estratégia de descoberta do `signtool.exe`:** definida;
* **modo de operação:** arquivo único e lote por pasta;

## 3. Objetivo do RSign

O objetivo do RSign é permitir assinatura local de arquivos com uma aplicação Delphi que centralize configuração, validação, execução e diagnóstico do processo.

### O que o projeto entrega

* uso inicial de certificado autoassinado em `.pfx`;
* possibilidade futura de usar PFX externo;
* preparação para certificados reais de Code Signing;
* escolha entre assinatura de um único arquivo ou lote por pasta;
* filtro por extensões suportadas;
* descoberta automática do `signtool.exe` com opção de caminho manual;
* preservação do original com sufixo `_OLD`;
* verificação da assinatura após o processo;
* exibição de mensagens operacionais e técnicas;
* intervenção do usuário em cenários críticos.

### O que o projeto não pretende ser neste primeiro momento

* uma infraestrutura corporativa completa de Code Signing;
* uma solução de confiança pública automática em máquinas de terceiros;
* uma aplicação dependente de instalação permanente do certificado em store como regra principal de operação.

## 4. Escopo funcional

## 4.1. Certificado

O projeto trabalha inicialmente com **certificado autoassinado** exportado em **`.pfx`**.

O sistema também já nasce preparado para cenários futuros:

* uso de **PFX externo**;
* uso de **certificado real de Code Signing**.

### Regras definidas

* o artefato final persistente deve ser um arquivo `.pfx`;
* o certificado não deve permanecer instalado como resultado final da operação;
* a senha padrão pode ser mantida inicialmente como `123456`, mas deve ser editável pela interface;
* se o PFX existir e apresentar problema, o sistema deve explicar a situação e aguardar a decisão do usuário.

## 4.2. Extensões suportadas

O RSign trabalha com extensões conhecidas e previamente aprovadas:

* `.exe`
* `.dll`
* `.msi`
* `.cab`
* `.cat`

## 4.3. Estratégia de saída

Quando um arquivo for assinado, a regra aprovada é esta:

1. renomear o arquivo original com sufixo `_OLD`;
2. manter o arquivo assinado com o nome original.

### Exemplo

Arquivo antes da assinatura:

```text
MeuSistema.exe
```

Resultado esperado:

```text
MeuSistema_OLD.exe
MeuSistema.exe
```

## 4.4. Modos de operação

A aplicação deve permitir dois cenários:

* **arquivo único**
* **lote por pasta**

Essa escolha será feita pela interface.

## 4.5. Verificação pós-assinatura

A aplicação deve permitir verificar ou não a assinatura ao final do processo.

O padrão inicial será:

* **verificação ativada**

## 4.6. Resolução do `signtool.exe`

A aplicação deve:

* aceitar caminho manual do `signtool.exe`;
* localizar automaticamente quando o caminho manual não for informado;
* preferir a versão mais nova encontrada;
* permitir que o usuário substitua essa escolha.

## 4.7. Execução local

O uso do RSign será local, em ambiente Windows, com dois comportamentos possíveis:

* uso manual pela interface;
* automação interna do próprio fluxo, quando os dados já estiverem suficientes para isso.

## 4.8. Permissões administrativas

A aplicação não deve exigir execução como administrador em todos os cenários.

Ela deve tentar operar com privilégio normal e só exigir elevação quando alguma etapa realmente depender disso.

## 5. Interface da aplicação

A UI foi definida em **3 abas principais**, separando os dados do certificado, o comportamento da assinatura e os caminhos físicos usados na operação.

## 5.1. Aba 1 — Perfil do Certificado

Essa aba concentra os dados de identidade e o perfil de uso do certificado.

### Campos previstos

* nome do certificado;
* nome da empresa;
* organização;
* departamento;
* cidade;
* estado;
* país;
* e-mail;
* validade em anos;
* senha do PFX;
* confirmação da senha;
* tipo do certificado:

  * autoassinado;
  * PFX externo;
  * futuro suporte a Code Signing real.

### Regras dessa aba

* todos os valores padrão devem ser editáveis;
* a UI deve indicar se o certificado será criado, reutilizado, validado ou substituído;
* o perfil ativo do certificado deve ficar visível;
* o modo atual do projeto deve deixar claro que o resultado final é um `.pfx`.

## 5.2. Aba 2 — Configuração da Assinatura

Essa aba controla o comportamento operacional do processo.

### Campos previstos

* caminho manual do `signtool.exe`;
* opção para localizar automaticamente o `signtool`;
* versão encontrada;
* preferência automática pela versão mais nova;
* URL do servidor de timestamp;
* verificar assinatura após assinar;
* continuar sem timestamp apenas com confirmação;
* modo de operação:
  * arquivo único
  * lote
* tipo de log:
  * tela
  * arquivo
  * ambos

### Regras dessa aba

* a verificação pós-assinatura deve vir ativada por padrão;
* o timestamp precisa ser configurável;
* se houver falha no timestamp, o sistema deve perguntar antes de seguir sem ele;
* a escolha automática da versão mais nova do `signtool` deve ser o comportamento padrão.

## 5.3. Aba 3 — Locais e Arquivos

Essa aba reúne os caminhos físicos usados pelo processo.

### Bloco 1 — Certificado PFX

* local onde o PFX será salvo;
* nome do arquivo PFX;
* caminho completo final do PFX;
* botão para localizar PFX existente;
* botão para criar novo PFX.

### Bloco 2 — Origem dos arquivos

* seleção de um arquivo específico;
* seleção de uma pasta;
* lista dos arquivos compatíveis encontrados;
* filtro por extensões suportadas.

### Bloco 3 — Destino dos arquivos

* pasta de saída;
* opção para reutilizar a mesma pasta do arquivo original;
* indicação visual da política `_OLD`;
* prévia clara de origem, destino e nome final esperado.

### Regras dessa aba

* o local e o nome do PFX devem ser definidos pelo usuário;
* o usuário deve poder escolher entre pasta ou arquivo;
* o sistema deve mostrar entrada e saída antes de iniciar;
* a operação não deve começar com caminhos ambíguos.

## 6. Fluxo de execução

## 6.1. Fluxo principal

O fluxo principal da aplicação deve seguir esta sequência:

1. carregar as configurações padrão e personalizadas;
2. validar os caminhos definidos na UI;
3. resolver o `signtool.exe` por caminho manual ou descoberta automática;
4. validar o arquivo único ou montar a lista de lote;
5. filtrar apenas as extensões suportadas;
6. verificar se o `.pfx` existe;
7. se não existir, oferecer criação;
8. se existir, validar o PFX;
9. em caso de falha crítica, explicar o problema e aguardar decisão do usuário;
10. preparar o backup `_OLD`;
11. executar a assinatura mantendo o nome original do arquivo final;
12. verificar a assinatura, se habilitado;
13. registrar logs;
14. exibir resultado amigável e técnico.

## 6.2. Validação do certificado

Ao encontrar um arquivo `.pfx`, o sistema deve validar:

* existência física;
* leitura do conteúdo;
* senha informada;
* integridade do arquivo;
* presença de chave privada;
* vigência do certificado;
* aptidão para uso em assinatura.

## 6.3. Criação do certificado

A estratégia técnica definida para criação é:

1. criar temporariamente o certificado em `CurrentUser\My`;
2. exportar para o caminho `.pfx` configurado;
3. remover o certificado temporário do store;
4. manter apenas o `.pfx` como artefato persistente.

> O uso do store é apenas transitório durante a criação. O resultado funcional do projeto continua sendo o arquivo `.pfx`.

## 6.4. Fluxo de arquivo único

1. o usuário escolhe um arquivo suportado;
2. o sistema valida extensão, existência e acesso;
3. o sistema valida o PFX;
4. o sistema valida o `signtool`;
5. o sistema renomeia o original para `_OLD`;
6. o sistema gera o arquivo assinado com o nome original;
7. o sistema verifica a assinatura, se habilitado;
8. o sistema grava logs e apresenta o resultado.

## 6.5. Fluxo de lote por pasta

1. o usuário escolhe uma pasta;
2. o sistema varre os arquivos pelas extensões suportadas;
3. o sistema monta a lista de processamento;
4. para cada item, o sistema:

   * valida o arquivo;
   * prepara `_OLD`;
   * assina;
   * verifica, se habilitado;
   * grava o resultado individual;
5. ao final, apresenta um consolidado com sucessos, avisos e falhas.

---

## 7. Regras de decisão assistida

Uma regra central do projeto é esta: o sistema **não deve decidir sozinho cenários críticos** quando houver risco operacional, dúvida relevante ou necessidade de escolha entre alternativas válidas.

Nesses casos, o comportamento obrigatório é:

1. detectar o problema;
2. explicar o que aconteceu;
3. informar o impacto;
4. apresentar opções coerentes;
5. aguardar decisão explícita do usuário.

## 7.1. Situações típicas que exigem decisão

* PFX encontrado, mas com senha inválida;
* PFX corrompido;
* certificado vencido;
* certificado sem chave privada;
* certificado incompatível com assinatura;
* falha no timestamp;
* `signtool` encontrado, mas não funcional;
* arquivo em uso ou bloqueado;
* conflito com `_OLD` já existente.

## 7.2. Regra específica para timestamp

Se o timestamp falhar, o sistema deve:

1. informar a falha;
2. explicar o impacto de seguir sem timestamp;
3. perguntar se o usuário deseja continuar mesmo assim.

## 8. Arquitetura técnica

A aplicação foi pensada em camadas leves, com responsabilidades separadas e fluxo centralizado.

## 8.1. Princípios adotados

* separação de responsabilidades;
* baixo acoplamento;
* serviços especializados;
* UI sem regra de negócio pesada;
* orquestração central do fluxo;
* estrutura preparada para evolução futura.

## 8.2. Camadas previstas

### Camada de UI

Responsável por:

* exibir dados;
* coletar escolhas do usuário;
* mostrar mensagens e logs;
* acionar o orquestrador.

### Camada de Orquestração

Responsável por:

* controlar o fluxo completo;
* chamar os serviços na ordem correta;
* consolidar resultados;
* decidir quando interromper ou pedir decisão ao usuário.

### Camada de Serviços

Responsável por tarefas especializadas:

* validar certificado;
* criar certificado;
* localizar `signtool`;
* validar arquivos;
* assinar;
* verificar assinatura;
* registrar logs.

### Camada de Configuração

Responsável por:

* armazenar padrões;
* ler preferências salvas;
* persistir ajustes do usuário.

### Camada de Modelos

Responsável por transportar dados entre UI, serviços e orquestrador.

## 9. Estrutura sugerida do projeto

### Estrutura do Projeto (Repositório)

```text
RSign/
├── README.md
├── RSign.dpr
│
├── src/
│   ├── views/
│   │   ├── RSign.View.Main.pas
│   │   ├── RSign.View.Configuracao.pas
│   │   └── RSign.View.Log.pas
│   │
│   ├── core/
│   │   ├── RSign.Types.pas
│   │   ├── RSign.Config.pas
│   │   ├── RSign.Utils.pas
│   │   ├── RSign.Logger.pas
│   │   ├── RSign.Processo.pas
│   │   ├── RSign.Certificado.pas
│   │   ├── RSign.Signtool.pas
│   │   ├── RSign.Arquivo.pas
│   │   ├── RSign.Assinatura.pas
│   │   ├── RSign.Verificacao.pas
│   │   └── RSign.Orquestrador.pas
│   │
│   └── assets/
│       ├── icons/
│       └── images/
│
└── docs/
```

#### Observações

* `src/` concentra todo o **código Delphi do projeto**.
* `views/` contém as **interfaces FMX**.
* `core/` contém os **serviços, lógica de negócio e infraestrutura**.
* `assets/` armazena **ícones e recursos visuais**.
* `docs/` pode centralizar **documentação complementar do projeto**.

### Estrutura de Execução da Aplicação

Após compilado, o executável do **RSign** pode operar com a seguinte estrutura de diretórios:

```text
RSign/
├── RSign.exe
│
├── Config/
│   └── RSign.ini
│
├── Logs/
│
└── Temp/
```

#### Observações

* `Config/` guarda a **configuração persistida da aplicação**.
* `Logs/` armazena **logs operacionais e técnicos gerados durante a execução**.
* `Temp/` pode ser usada para **arquivos temporários durante processos de assinatura e validação**.

## 10. Units e responsabilidades

### `RSign.Types.pas`

Centraliza tipos de dados, enums, records e contratos simples de transporte.

### `RSign.Config.pas`

Responsável por defaults, leitura e gravação de configuração, resolução de caminhos e preferências.

### `RSign.Utils.pas`

Responsável por utilidades gerais, como nomes, caminhos, filtros de extensão e normalização de textos.

### `RSign.Logger.pas`

Responsável por logs em arquivo, publicação de mensagens na UI e separação entre mensagem amigável e técnica.

### `RSign.Processo.pas`

Responsável por encapsular execução de processos externos, como PowerShell e `signtool.exe`, com captura de `stdout`, `stderr` e `exit code`.

### `RSign.Certificado.pas`

Responsável por validar `.pfx`, criar certificado autoassinado, exportar para PFX, remover certificado temporário do store e preparar a expansão para PFX externo e Code Signing real.

### `RSign.Signtool.pas`

Responsável por localizar o `signtool.exe`, listar candidatos, identificar versões e validar se o executável realmente funciona.

### `RSign.Arquivo.pas`

Responsável por validar caminhos de origem, filtrar extensões, preparar backup `_OLD` e organizar entrada e saída.

### `RSign.Assinatura.pas`

Responsável por montar o comando de assinatura, executar o processo e devolver o resultado detalhado por arquivo.

### `RSign.Verificacao.pas`

Responsável por verificar se a assinatura foi aplicada corretamente e consolidar o resultado pós-assinatura.

### `RSign.Orquestrador.pas`

Responsável por ser o núcleo do fluxo, chamando os serviços na ordem correta e se comunicando com a UI no nível de intenção.

### `RSign.View.Main.pas`

Tela principal da aplicação, com as três abas centrais e os comandos gerais da operação.

### `RSign.View.Configuracao.pas`

Tela complementar para persistência e edição de parâmetros, caso isso seja separado da tela principal.

### `RSign.View.Log.pas`

Tela ou painel dedicado para exibição detalhada dos logs.

---

## 11. Modelos e tipos previstos

Os nomes abaixo representam a base lógica esperada do projeto.

## 11.1. Tipos de configuração

* `TConfiguracaoAssinatura`
* `TConfiguracaoSigntool`
* `TConfiguracaoLog`
* `TDadosCertificado`

## 11.2. Tipos de status e resultado

* `TStatusCertificado`
* `TStatusSigntool`
* `TStatusArquivo`
* `TResultadoAssinatura`
* `TResultadoVerificacao`
* `TResultadoLote`

## 11.3. Enums prováveis

* `TTipoCertificado`
* `TModoAssinatura`
* `TPoliticaTimestamp`
* `TNivelLog`
* `TStatusOperacao`

## 12. Configurações padrão

Os padrões iniciais aprovados até aqui são:

* senha padrão do PFX: `123456`;
* verificação pós-assinatura: ligada;
* resolução automática do `signtool`: ligada;
* preferência pela versão mais nova do `signtool`: ligada;
* extensões suportadas: `.exe`, `.dll`, `.msi`, `.cab`, `.cat`;
* timestamp configurável;
* modo de operação selecionável pela UI.

## 13. Requisitos de ambiente

## 13.1. Sistema operacional

* Windows
* execução local

## 13.2. Ferramentas de desenvolvimento

* Delphi 10+ com suporte FMX

## 13.3. Dependências externas

* PowerShell disponível no sistema operacional;
* `signtool.exe` instalado ou acessível manualmente.

## 13.4. Origem esperada do `signtool.exe`

O `signtool.exe` normalmente será encontrado em instalações do:

* Windows SDK
* Windows Kits

A aplicação também deve permitir informar o caminho manualmente.

## 13.5. Permissões

A aplicação deve operar com o menor nível de privilégio possível. Apenas etapas que realmente exigirem elevação deverão depender disso.

## 14. Como compilar

Como o projeto será compilado em **Delphi 10+ FMX**, o fluxo esperado é este:

1. abrir o Delphi 10+;
2. carregar o projeto principal `RSign.dpr`;
3. selecionar o alvo Windows;
4. executar `Build` ou `Compile`;
5. gerar o executável final da aplicação.

### Observação

Compilar o RSign gera o executável da ferramenta, mas o ambiente de execução continua precisando dos componentes externos usados pelo processo real de assinatura, principalmente o `signtool.exe`.

## 15. Como usar

## 15.1. Cenário A — Assinar com PFX existente

1. abra o RSign;
2. revise a aba **Perfil do Certificado**;
3. vá para **Locais e Arquivos**;
4. informe o local e o nome do PFX, ou localize um já existente;
5. escolha um arquivo ou uma pasta;
6. confira `signtool`, timestamp e verificação na aba **Configuração da Assinatura**;
7. inicie a operação;
8. o sistema valida ambiente, certificado, arquivos e ferramenta;
9. o sistema assina;
10. o sistema verifica a assinatura, se essa opção estiver ativa;
11. o resultado é exibido e registrado em log.

## 15.2. Cenário B — Assinar sem PFX existente

1. abra o RSign;
2. preencha os dados do certificado na aba **Perfil do Certificado**;
3. defina o local e o nome do PFX;
4. selecione o arquivo ou a pasta que será assinada;
5. inicie a operação;
6. o sistema identifica que o PFX não existe;
7. o sistema oferece a criação;
8. o certificado é criado temporariamente no store técnico;
9. o sistema exporta para `.pfx`;
10. o certificado temporário é removido;
11. o fluxo segue normalmente para a assinatura.

## 15.3. Cenário C — Falha no timestamp

1. o processo chega à etapa de timestamp;
2. o servidor falha ou fica indisponível;
3. o sistema informa o problema;
4. o impacto de seguir sem timestamp é explicado;
5. o usuário escolhe continuar ou cancelar;
6. a execução segue conforme essa decisão.

## 15.4. Cenário D — Assinatura em lote

1. o usuário escolhe uma pasta;
2. o sistema lista os arquivos compatíveis;
3. entrada e destino são revisados;
4. o processamento ocorre item a item;
5. ao final, um resumo consolidado é exibido com totais e detalhes.

## 16. Logs e rastreabilidade

A política de logs do projeto precisa atender dois perfis de uso:

1. o usuário operacional, que precisa entender o que aconteceu;
2. o usuário técnico, que precisa diagnosticar falhas com rapidez.

## 16.1. Log amigável

Exemplos do que deve conter:

* início da operação;
* certificado encontrado;
* certificado criado com sucesso;
* arquivo preparado para assinatura;
* assinatura concluída;
* verificação aprovada;
* aviso de falha em timestamp;
* resumo final da operação.

## 16.2. Log técnico

Exemplos do que deve conter:

* caminho do arquivo processado;
* caminho do PFX utilizado;
* caminho e versão do `signtool`;
* comando executado;
* `exit code` do processo;
* saída padrão e saída de erro;
* retorno da verificação da assinatura;
* decisão tomada pelo usuário em casos críticos.

## 16.3. Persistência dos logs

A aplicação deve conseguir:

* exibir logs em tela;
* gravar logs em arquivo;
* operar nos dois formatos ao mesmo tempo.

## 17. Regras operacionais e cuidados

## 17.1. Senha padrão do PFX

A senha padrão inicial permanece como `123456` por compatibilidade com o fluxo atual do projeto. Mesmo assim:

* a interface deve permitir alteração;
* a documentação deve deixar claro que isso é apenas um padrão inicial;
* o projeto deve permitir evolução futura para políticas de senha mais rígidas.

## 17.2. Uso de store temporário

O projeto não usa store como destino final, mas a criação do certificado pode passar por store temporário por necessidade técnica da geração via PowerShell. Isso não altera a regra funcional do sistema, porque o artefato persistente continua sendo o `.pfx`.

## 17.3. Arquivos em uso

O sistema deve detectar arquivos bloqueados ou em uso e impedir operações silenciosas que possam gerar estado inconsistente ou perda de rastreabilidade.

## 17.4. Elevação de privilégio

A aplicação deve evitar exigir administrador como regra fixa. A necessidade de elevação deve ser contextual.

## 18. Limitações do modelo inicial

O uso de certificado autoassinado atende ao cenário de assinatura técnica local, mas não oferece automaticamente o mesmo nível de confiança pública de um certificado real emitido por autoridade certificadora reconhecida.

### Impacto prático

Um arquivo assinado com certificado autoassinado:

* pode ser assinado com sucesso;
* pode ser validado tecnicamente;
* mas não terá, por padrão, o mesmo nível de confiança pública em máquinas de terceiros.

Por isso, a arquitetura já foi pensada para futura evolução para certificados reais de Code Signing.

## 19. Roadmap técnico

A sequência recomendada de implementação é esta.

## Fase 1 — Base estrutural

* criação do projeto FMX;
* definição dos tipos centrais;
* criação do módulo de configuração;
* criação do logger;
* criação do executor de processos.

## Fase 2 — Signtool

* localizar candidatos;
* identificar versões;
* permitir escolha automática e manual;
* validar funcionamento do executável.

## Fase 3 — Certificado

* validar PFX;
* criar certificado autoassinado;
* exportar para PFX;
* remover certificado temporário do store;
* consolidar mensagens de status.

## Fase 4 — Arquivos

* validar entrada;
* varrer pasta;
* filtrar extensões;
* preparar a estratégia `_OLD` + arquivo assinado com nome original.

## Fase 5 — Assinatura

* montar comando;
* executar assinatura;
* capturar retorno técnico.

## Fase 6 — Verificação

* executar verificação pós-assinatura;
* consolidar sucesso, aviso ou falha.

## Fase 7 — UI FMX

* construir as três abas principais;
* integrar campos, botões e listagens;
* exibir logs;
* apresentar decisões ao usuário quando necessário.

## Fase 8 — Refinos finais

* persistência definitiva das preferências;
* revisão de mensagens;
* testes do fluxo completo;
* preparação para expansão futura.

## 20. Diretriz de continuidade

Toda evolução do projeto deve respeitar, no mínimo:

* o uso inicial de certificado autoassinado em `.pfx`;
* a preparação futura para PFX externo e Code Signing real;
* a divisão da UI em 3 abas;
* a política de decisão assistida;
* a estratégia `_OLD` + arquivo assinado com nome original;
* a política de timestamp com confirmação do usuário em caso de falha;
* as extensões suportadas já aprovadas;
* a execução local em Windows.

Sempre que o projeto avançar, este documento deve ser atualizado para refletir:

* o que já foi implementado;
* o que mudou no fluxo;
* o que continua como regra;
* o que ainda está planejado.
