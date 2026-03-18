# RSign

Assinador local de arquivos para Windows, desenvolvido em **Delphi 10+ + FMX**, com suporte inicial a **certificado autoassinado em `.pfx`** e arquitetura preparada para futura adoção de **certificados reais de Code Signing**.

> Este documento descreve o **contexto atual do projeto**, a **base funcional existente em BAT**, o **comportamento planejado para a aplicação FMX**, a **arquitetura técnica prevista**, o **fluxo completo de uso**, as **regras de negócio já definidas** e a **ordem recomendada de implementação**. O objetivo é manter o projeto sempre alinhado ao mesmo contexto técnico, evitando desvios de escopo, suposições indevidas e perda de decisões já tomadas.

---

## 1. Visão geral do projeto

O **RSign** é um utilitário local para **assinar arquivos suportados pelo ecossistema Authenticode** no Windows, utilizando inicialmente um **certificado autoassinado** exportado em formato `.pfx`.

O projeto nasce a partir de uma **BAT funcional** que já realiza uma assinatura básica de executáveis, porém com limitações importantes de validação, rastreabilidade, flexibilidade e separação de responsabilidades. A proposta do RSign é transformar esse fluxo em uma **aplicação desktop FMX**, com interface visual, configuração persistente, validações robustas, logs detalhados, operação assistida e arquitetura pronta para evolução.

### Objetivos centrais

- Validar o ambiente necessário para assinatura.
- Verificar se o certificado `.pfx` existe, está íntegro e está apto para uso.
- Criar o certificado autoassinado quando ele não existir.
- Permitir uso futuro de **PFX externo** e de **Code Signing real**.
- Assinar um arquivo específico ou vários arquivos em lote.
- Controlar melhor o `signtool.exe`, usando detecção automática e caminho manual.
- Renomear o arquivo original com sufixo `_OLD` e manter o assinado com o nome original.
- Validar a assinatura depois da operação, com essa verificação ativada por padrão.
- Explicar problemas críticos ao usuário e **aguardar decisão explícita** antes de continuar.
- Registrar logs amigáveis e técnicos, tanto em tela quanto em arquivo.

---

## 2. Base atual do projeto

Atualmente existe uma implementação em BAT chamada **`Gerador.bat`**, que funciona como prova de conceito operacional para geração de certificado autoassinado e assinatura de executáveis.

### 2.1. O que a BAT atual faz

A BAT atual executa o seguinte fluxo:

1. Verifica se está sendo executada como administrador.
2. Define e cria as pastas de trabalho:
   - `Certificado`
   - `APP\Input`
   - `APP\Out`
3. Limpa a pasta de saída `APP\Out`.
4. Carrega valores padrão para os dados do certificado.
5. Solicita ao usuário os dados do certificado via prompt.
6. Sanitiza o nome do arquivo PFX.
7. Reutiliza o `.pfx` se ele já existir.
8. Caso o `.pfx` não exista, cria um certificado autoassinado com PowerShell.
9. Lista os arquivos `.exe` em `APP\Input`.
10. Permite que o usuário selecione um executável.
11. Copia o executável para a pasta de saída com sufixo `_ASSINADO`.
12. Localiza o `signtool.exe` usando `PATH` e busca em `Windows Kits`.
13. Assina o arquivo copiado com SHA256 e timestamp da DigiCert.
14. Encerra informando sucesso ou falha.

### 2.2. Dados padrão atuais da BAT

Os valores padrão atualmente presentes na BAT são:
- Empresa: `SUA EMPRESA`
- Organização: `SUA ORGANIZACAO`
- Departamento: `Desenvolvimento`
- Cidade: `Rio de Janeiro`
- Estado: `RJ`
- País: `BR`
- E-mail: `seu@email.com`
- Nome do PFX: `SeuCertificado`
- Senha padrão: `123456`
- Validade padrão: `5` anos

### 2.3. Limitações da BAT atual

Apesar de funcional, a BAT ainda apresenta limitações importantes:

- Exige administrador logo no início, mesmo quando isso pode não ser necessário.
- Trabalha apenas com arquivos `.exe`.
- Verifica apenas se o `.pfx` **existe**, mas não valida:
  - senha
  - integridade
  - vigência
  - chave privada
  - aptidão para assinatura
- Não oferece UI para configuração persistente.
- Não separa regras de negócio da camada de interação.
- Não trata múltiplos cenários com decisão do usuário.
- Não verifica formalmente a assinatura após assinar.
- Não adota a regra final desejada para backup do original.
- Não está preparada para múltiplos perfis de certificado.

---

## 3. Objetivo da migração para Delphi 10+ FMX

A versão Delphi do RSign não será apenas uma “BAT com tela”. Ela será uma aplicação com:

- **núcleo desacoplado** em serviços;
- **interface FMX** organizada por contexto de uso;
- **regras explícitas** para cada etapa;
- **persistência de configuração**;
- **tratamento assistido de falhas**;
- **logs técnicos e operacionais**;
- **evolução futura planejada**.

### 3.1. O que a aplicação Delphi deverá resolver

A aplicação deverá transformar um fluxo linear e rígido em um fluxo controlado, validável e extensível.

Isso inclui:

- decidir automaticamente o que puder ser decidido com segurança;
- pedir intervenção do usuário quando houver risco ou ambiguidade;
- apresentar informações claras sobre o que está acontecendo;
- manter contexto técnico consistente entre criação do certificado, seleção de arquivos, assinatura e verificação.

---

## 4. Escopo funcional do RSign

O escopo aprovado até o momento é o seguinte.

### 4.1. Certificado

- O projeto usará inicialmente **certificado autoassinado**.
- O sistema deve ficar preparado para, no futuro, aceitar:
  - **PFX externo**
  - **Code Signing real**
- O artefato final do certificado deve permanecer como **arquivo `.pfx`**.
- O certificado **não deve permanecer instalado** como destino final em store do Windows.
- A senha padrão pode permanecer como `123456`, mas deve ser **editável pela UI**.
- Caso o `.pfx` exista, mas apresente problema, o sistema deve:
  1. explicar o problema;
  2. mostrar impacto;
  3. aguardar a decisão do usuário.

### 4.2. Arquivos suportados

A aplicação trabalhará com extensões conhecidas e previamente definidas:

- `.exe`
- `.dll`
- `.msi`
- `.cab`
- `.cat`

### 4.3. Estratégia de saída

Quando um arquivo for assinado, a regra aprovada é:

1. renomear o original com sufixo `_OLD`;
2. manter o arquivo assinado com o **nome original**.

#### Exemplo

Arquivo original:

```text
MeuSistema.exe
```

Após o processo:

```text
MeuSistema_OLD.exe
MeuSistema.exe   <- versão assinada
```

### 4.4. Modo de operação

O sistema deve aceitar os dois cenários:

- assinatura de **um arquivo específico**;
- assinatura em **lote por pasta**.

A definição virá da UI.

### 4.5. Verificação pós-assinatura

- Deve existir a opção de verificar ou não a assinatura após assinar.
- O padrão inicial será **sempre verificar**.

### 4.6. Signtool

A aplicação deve:

- permitir caminho manual do `signtool.exe`;
- localizar automaticamente quando o caminho manual não for informado;
- preferir a **versão mais nova**;
- permitir que o usuário substitua essa escolha pela UI.

### 4.7. Execução local

- A aplicação será usada **localmente**.
- O modo de uso será:
  - manual
  - e automatizado internamente pela própria aplicação, quando possível

### 4.8. Permissões administrativas

A aplicação **não deve exigir administrador sempre**.

Ela deve tentar operar normalmente e só elevar exigência quando isso realmente for necessário para alguma ação específica.

### 4.9. Logs

A aplicação deve registrar logs:

- na tela
- em arquivo
- com visão amigável
- com visão técnica

---

## 5. Estrutura da interface FMX

A UI do RSign será organizada em **3 abas principais**, separando claramente dados do certificado, comportamento da assinatura e caminhos de trabalho.

## 5.1. Aba 1 — Perfil do Certificado

Responsável pelos dados de identidade do certificado e seu perfil de geração/uso.

### Campos previstos

- Nome do certificado
- Nome da empresa
- Organização
- Departamento
- Cidade
- Estado
- País
- E-mail
- Validade em anos
- Senha do PFX
- Confirmação da senha
- Tipo do certificado
  - Autoassinado
  - PFX externo
  - Futuro suporte a Code Signing real

### Regras da aba

- Todos os valores padrão devem ser editáveis.
- A UI deve informar se o certificado será:
  - criado
  - reutilizado
  - validado
  - ou substituído
- A aplicação deve deixar visível qual perfil de certificado está em uso.

## 5.2. Aba 2 — Configuração da Assinatura

Responsável pelas definições operacionais do processo de assinatura.

### Campos previstos

- Caminho manual do `signtool.exe`
- Opção para localizar automaticamente o `signtool`
- Exibição da versão localizada
- Preferir versão mais nova automaticamente
- URL do servidor de timestamp
- Verificar assinatura após assinar
- Continuar sem timestamp apenas mediante confirmação
- Tipo de execução:
  - arquivo único
  - lote
- Tipo de log:
  - tela
  - arquivo
  - ambos

### Regras da aba

- A verificação pós-assinatura vem ativada por padrão.
- O timestamp deve ser configurável.
- Em caso de falha no timestamp, o sistema deve perguntar ao usuário se deseja continuar sem ele.
- A escolha do `signtool` pela versão mais nova deve ser o comportamento padrão.

## 5.3. Aba 3 — Locais e Arquivos

Responsável pelos caminhos físicos do certificado e dos arquivos que serão assinados.

### Bloco 1 — Certificado PFX

- Local onde o certificado será salvo
- Nome do arquivo PFX
- Caminho final completo do PFX
- Botão para localizar PFX existente
- Botão para criar novo PFX

### Bloco 2 — Origem dos arquivos

- Selecionar um arquivo específico
- Selecionar uma pasta
- Exibir lista dos arquivos compatíveis encontrados
- Filtrar apenas extensões suportadas

### Bloco 3 — Destino dos arquivos

- Pasta de saída
- Opção para reutilizar a mesma pasta do arquivo original
- Estratégia visualmente documentada de backup com `_OLD`

### Regras da aba

- O local e o nome do PFX devem ser definidos pelo usuário.
- O usuário deve poder escolher se o processo será por arquivo ou por pasta.
- O sistema deve mostrar o que será usado como entrada e saída antes de iniciar a assinatura.

---

## 6. Fluxo funcional esperado

O fluxo funcional planejado para a aplicação é o seguinte.

### 6.1. Fluxo principal

1. Carregar as configurações padrão e personalizadas.
2. Validar os caminhos definidos na UI.
3. Resolver o `signtool.exe` por caminho manual ou descoberta automática.
4. Validar o(s) arquivo(s) selecionado(s).
5. Filtrar apenas extensões permitidas.
6. Verificar se o `.pfx` existe.
7. Se não existir, oferecer criação.
8. Se existir, validar o PFX.
9. Explicar falhas críticas e aguardar decisão do usuário.
10. Preparar backup do arquivo original com sufixo `_OLD`.
11. Assinar o arquivo final com o nome original.
12. Verificar a assinatura, se habilitado.
13. Registrar logs.
14. Exibir resultado amigável e técnico.

### 6.2. Fluxo de validação do certificado

Ao encontrar um arquivo `.pfx`, o sistema deverá validar:

- existência física;
- leitura do arquivo;
- senha informada;
- integridade do conteúdo;
- presença de chave privada;
- vigência do certificado;
- possibilidade de uso para assinatura.

### 6.3. Fluxo de criação do certificado

A melhor prática adotada para evitar falhas de geração será:

1. criar temporariamente o certificado em `CurrentUser\My`;
2. exportar para o caminho `.pfx` definido pelo usuário;
3. remover o certificado temporário do store;
4. manter apenas o `.pfx` como artefato final.

> Observação importante: o store será usado apenas como etapa técnica transitória de criação. O artefato final e persistente do projeto continuará sendo exclusivamente o arquivo `.pfx`.

### 6.4. Fluxo de assinatura de arquivo único

1. Usuário escolhe um arquivo suportado.
2. Sistema valida extensão, existência e acesso.
3. Sistema valida o certificado.
4. Sistema valida o `signtool`.
5. Sistema renomeia o original para `_OLD`.
6. Sistema produz o arquivo assinado com o nome original.
7. Sistema verifica a assinatura, se habilitado.
8. Sistema grava logs e exibe o resultado.

### 6.5. Fluxo de assinatura em lote

1. Usuário escolhe uma pasta.
2. Sistema varre os arquivos pelas extensões suportadas.
3. Sistema monta uma lista de trabalho.
4. Para cada item:
   - valida o arquivo;
   - prepara backup `_OLD`;
   - assina;
   - verifica, se habilitado;
   - registra o resultado individual.
5. Ao final, o sistema exibe um consolidado com sucessos, falhas e avisos.

---

## 7. Política de decisão do usuário

Uma regra central já aprovada no projeto é que o sistema **não deve decidir sozinho cenários críticos** quando existir risco operacional, perda de rastreabilidade ou necessidade de escolha entre alternativas válidas.

Nesses casos, o sistema deve:

1. detectar o problema;
2. explicar o que aconteceu;
3. informar impacto;
4. apresentar opções coerentes;
5. aguardar decisão explícita do usuário.

### 7.1. Cenários típicos que exigem decisão

- PFX encontrado, mas com senha inválida;
- PFX corrompido;
- certificado vencido;
- certificado sem chave privada;
- certificado incompatível com assinatura;
- falha no timestamp;
- `signtool` encontrado, mas não executável;
- arquivo em uso ou bloqueado;
- conflito em arquivo `_OLD` existente.

### 7.2. Regra específica para timestamp

Quando o servidor de timestamp falhar, o sistema deve:

1. informar a falha;
2. explicar o impacto de prosseguir sem timestamp;
3. perguntar ao usuário se deseja continuar mesmo assim.

---

## 8. Regras técnicas do processo de assinatura

## 8.1. Algoritmos previstos

A base atual utiliza:

- digest de arquivo: `SHA256`
- digest do timestamp: `SHA256`
- servidor de timestamp padrão: `http://timestamp.digicert.com`

A aplicação Delphi deve manter esses valores como padrão inicial, com possibilidade de ajuste pela UI.

## 8.2. Ferramenta de assinatura

A assinatura será realizada usando `signtool.exe`, que deve ser tratado como dependência operacional externa do Windows SDK / Windows Kits.

### Estratégia de resolução do signtool

1. verificar caminho manual informado na configuração;
2. procurar via `PATH`;
3. procurar em `Program Files (x86)\Windows Kits`;
4. procurar em `Program Files\Windows Kits`;
5. ordenar candidatos e preferir a versão mais nova;
6. permitir override manual pela UI.

## 8.3. Verificação pós-assinatura

Quando habilitada, a aplicação deverá validar se o arquivo assinado está com a assinatura corretamente aplicada.

A verificação deve, sempre que possível, confirmar:

- se a assinatura foi inserida;
- se o certificado foi reconhecido no arquivo;
- se o timestamp foi aplicado;
- se a ferramenta retornou sucesso técnico.

---

## 9. Arquitetura técnica prevista

O RSign será implementado com uma arquitetura em camadas leves, buscando clareza, rastreabilidade e facilidade de manutenção.

### 9.1. Princípios adotados

- separação de responsabilidades;
- baixo acoplamento;
- serviços especializados;
- UI sem regras de negócio pesadas;
- núcleo preparado para evolução futura.

### 9.2. Camadas previstas

#### Camada de UI
Responsável apenas por:

- exibir dados;
- coletar escolhas do usuário;
- apresentar logs e mensagens;
- acionar o orquestrador.

#### Camada de Orquestração
Responsável por:

- controlar o fluxo completo;
- coordenar serviços;
- consolidar resultados;
- decidir quando pedir ação do usuário.

#### Camada de Serviços
Responsável por executar tarefas especializadas, como:

- validar certificado;
- criar certificado;
- localizar signtool;
- validar arquivos;
- assinar arquivos;
- verificar assinatura;
- registrar logs.

#### Camada de Configuração
Responsável por:

- armazenar valores padrão;
- ler personalizações;
- persistir preferências do usuário.

#### Camada de Modelos
Responsável por:

- transportar dados entre UI, orquestrador e serviços.

---

## 10. Estrutura sugerida de units

Abaixo está a estrutura inicial sugerida para o projeto Delphi 10+ FMX.

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


### 10.1. Responsabilidade de cada unit

#### `RSign.Types.pas`
Concentrará os tipos de dados do sistema:

- configurações;
- status;
- resultados;
- enums;
- records auxiliares.

#### `RSign.Config.pas`
Responsável por:

- defaults do projeto;
- leitura e gravação de configuração;
- resolução de caminhos e preferências.

#### `RSign.Utils.pas`
Responsável por utilidades pequenas e reutilizáveis:

- manipulação de caminhos;
- tratamento de extensão;
- normalização de nomes;
- apoio a textos e mensagens.

#### `RSign.Logger.pas`
Responsável por:

- escrever logs em arquivo;
- publicar logs para a UI;
- organizar mensagens técnicas e amigáveis.

#### `RSign.Processo.pas`
Responsável por encapsular execução de processos externos:

- PowerShell;
- `signtool.exe`;
- captura de `stdout`, `stderr` e exit code.

#### `RSign.Certificado.pas`
Responsável por:

- validar `.pfx`;
- criar certificado autoassinado;
- exportar para `.pfx`;
- remover certificado temporário do store;
- preparar futura abstração para PFX externo e Code Signing real.

#### `RSign.Signtool.pas`
Responsável por:

- localizar `signtool.exe`;
- listar candidatos;
- selecionar a melhor versão;
- validar executabilidade do binário.

#### `RSign.Arquivo.pas`
Responsável por:

- validar caminhos de origem;
- filtrar arquivos suportados;
- preparar backup `_OLD`;
- normalizar entrada e saída.

#### `RSign.Assinatura.pas`
Responsável por:

- montar comandos de assinatura;
- executar a assinatura;
- devolver resultado detalhado por arquivo.

#### `RSign.Verificacao.pas`
Responsável por:

- verificar se a assinatura foi aplicada;
- interpretar resultado técnico da verificação;
- consolidar status pós-assinatura.

#### `RSign.Orquestrador.pas`
Responsável por:

- ser o cérebro do fluxo;
- chamar os serviços na ordem correta;
- interromper ou continuar conforme regras;
- conversar com a UI apenas no nível de intenção.

---

## 11. Modelos de dados previstos

Os tipos abaixo representam a base lógica esperada do projeto.

### 11.1. Tipos de configuração

- `TConfiguracaoAssinatura`
- `TConfiguracaoSigntool`
- `TConfiguracaoLog`
- `TDadosCertificado`

### 11.2. Tipos de status e resultado

- `TStatusCertificado`
- `TStatusSigntool`
- `TStatusArquivo`
- `TResultadoAssinatura`
- `TResultadoVerificacao`
- `TResultadoLote`

### 11.3. Enums prováveis

- `TTipoCertificado`
- `TModoAssinatura`
- `TPoliticaTimestamp`
- `TNivelLog`
- `TStatusOperacao`

---

## 12. Configurações padrão do projeto

Os valores padrão iniciais aprovados até o momento são:

- senha padrão do PFX: `123456`
- verificação pós-assinatura: ligada
- resolução automática do `signtool`: ligada
- preferência pela versão mais nova do `signtool`: ligada
- modo de operação selecionável por UI
- extensões suportadas fixas: `.exe`, `.dll`, `.msi`, `.cab`, `.cat`
- timestamp configurável

> Todos os padrões devem poder ser ajustados pela interface, salvo regras técnicas que não façam sentido alterar em tempo de uso.

---

## 13. Requisitos operacionais

### 13.1. Plataforma alvo

- Windows
- execução local
- Delphi 10+
- interface FMX

### 13.2. Dependências externas esperadas

- PowerShell disponível no sistema
- `signtool.exe` disponível manualmente ou instalável via Windows SDK / Windows Kits

### 13.3. Permissões

A aplicação deve operar com o mínimo de privilégio possível.

Somente etapas que realmente necessitem elevação devem exigir permissão adicional. O comportamento padrão não deve obrigar o usuário a abrir o sistema sempre como administrador.

---

## 14. Política de logs

A política de logs do RSign precisa atender dois públicos diferentes:

1. o usuário operacional, que precisa de mensagens claras;
2. o usuário técnico, que precisa de detalhe para diagnóstico.

### 14.1. Log amigável

Exemplos do que deve conter:

- início da operação;
- certificado localizado;
- arquivo preparado para assinatura;
- assinatura concluída;
- verificação aprovada;
- alerta sobre falha no timestamp.

### 14.2. Log técnico

Exemplos do que deve conter:

- caminho do arquivo;
- caminho do PFX;
- origem do `signtool`;
- comando executado;
- exit code;
- saída padrão e erro padrão;
- resultado da verificação;
- rastreamento de decisão do usuário.

---

## 15. Experiência de uso esperada

### 15.1. Uso típico com certificado já existente

1. Usuário abre o RSign.
2. Confere o perfil do certificado.
3. Define o local e nome do `.pfx`.
4. Escolhe um arquivo ou uma pasta.
5. Confirma o `signtool` encontrado.
6. Inicia a operação.
7. O sistema valida o certificado.
8. O sistema assina.
9. O sistema verifica a assinatura.
10. O sistema mostra resultado e grava log.

### 15.2. Uso típico sem certificado existente

1. Usuário abre o RSign.
2. Informa os dados do certificado.
3. Define o local do `.pfx`.
4. Inicia a criação.
5. O sistema gera temporariamente o certificado.
6. O sistema exporta para `.pfx`.
7. O sistema remove o certificado temporário do store.
8. O sistema usa o `.pfx` recém-gerado para assinar o arquivo.

### 15.3. Uso típico com falha de timestamp

1. Usuário inicia a assinatura.
2. O sistema alcança a etapa de timestamp.
3. O serviço falha.
4. O sistema informa o problema.
5. O sistema pergunta se o usuário deseja continuar sem timestamp.
6. A operação segue ou é cancelada conforme a decisão recebida.

---

## 16. Limitações conhecidas do modelo inicial

O uso de certificado autoassinado resolve o cenário de assinatura técnica local, mas possui limitações naturais quando comparado a certificados reais de Code Signing.

### 16.1. Impacto prático

Um arquivo assinado com certificado autoassinado:

- pode ser assinado com sucesso;
- pode ser verificado tecnicamente;
- porém não terá, por padrão, a mesma confiança pública de distribuição obtida com um certificado emitido por autoridade certificadora reconhecida.

Por isso, o projeto já nasce preparado para futura evolução para certificados reais.

---

## 17. Roadmap técnico recomendado

A sequência recomendada de implementação é a seguinte.

### Fase 1 — Base estrutural

- criação do projeto FMX;
- definição dos tipos centrais;
- criação do módulo de configuração;
- criação do logger;
- criação do executor de processos.

### Fase 2 — Signtool

- localizar candidatos;
- identificar versões;
- permitir escolha automática e manual;
- validar funcionamento do executável.

### Fase 3 — Certificado

- validar PFX;
- criar certificado autoassinado;
- exportar para PFX;
- remover certificado temporário do store;
- consolidar mensagens de status.

### Fase 4 — Arquivos

- validar entrada;
- varrer pasta;
- filtrar extensões;
- preparar estratégia `_OLD` + arquivo assinado com nome original.

### Fase 5 — Assinatura

- montar comando;
- executar assinatura;
- capturar resultado técnico.

### Fase 6 — Verificação

- executar verificação pós-assinatura;
- consolidar sucesso, aviso ou falha.

### Fase 7 — UI FMX

- construir as 3 abas principais;
- integrar botões, campos e listagens;
- apresentar logs e decisões.

### Fase 8 — Refinos finais

- persistência das preferências;
- testes de fluxo completo;
- ajustes de mensagens;
- preparação para expansão futura.

---

## 18. Resumo executivo do que será criado

O RSign será uma aplicação FMX local para Windows, construída sobre uma base já validada em BAT, porém com evolução forte em arquitetura, clareza operacional e segurança de fluxo.

### Em essência, o projeto entregará

- geração e reaproveitamento de certificado `.pfx` autoassinado;
- suporte futuro a certificados reais;
- assinatura local de arquivos suportados;
- seleção por arquivo ou lote;
- UI organizada por contexto;
- logs completos;
- verificação pós-assinatura;
- tomada de decisão assistida em casos críticos;
- estrutura técnica sustentável para manutenção.

---

## 19. Status atual do projeto

No contexto documentado até aqui, o projeto está nesta situação:

- **base atual existente:** BAT funcional
- **tipo de aplicação alvo:** Delphi 10+ FMX
- **fluxo principal:** definido
- **UI principal:** definida em 3 abas
- **extensões suportadas:** definidas
- **estratégia de backup:** definida
- **política de timestamp:** definida
- **política de logs:** definida
- **arquitetura macro:** definida
- **roadmap técnico:** definido

O próximo passo natural, a partir deste README, é transformar esta especificação em:

1. estrutura de units;
2. contratos entre UI e serviços;
3. implementação faseada do projeto.

---

## 20. Diretriz de continuidade do contexto

Este README passa a ser a referência funcional e técnica do projeto **RSign** para manter continuidade entre as próximas etapas.

A partir dele, qualquer evolução do projeto deve respeitar:

- o tipo de certificado atualmente adotado;
- a estratégia de arquivo `_OLD` + nome original assinado;
- a divisão da UI em 3 abas;
- a política de decisão assistida;
- as extensões suportadas já aprovadas;
- a preparação futura para Code Signing real;
- o uso local em Windows com Delphi 10+ FMX.

Sempre que houver expansão do projeto, este documento deve ser atualizado para preservar o contexto correto do que foi decidido, do que já foi implementado e do que ainda será desenvolvido.
