# RSign

Assinador local de arquivos para Windows, desenvolvido em **Delphi 10+ FMX**, com suporte inicial a **certificado autoassinado em `.pfx`** e arquitetura preparada para futura adoção de **certificados reais de Code Signing**.

> Este README é a referência funcional e técnica oficial do projeto. Ele documenta a base atual em BAT, o comportamento esperado da aplicação FMX, a arquitetura prevista, as regras de negócio aprovadas, a experiência de uso final, os requisitos para compilação e execução, e o roadmap técnico de implementação. A finalidade é preservar o contexto do projeto e evitar decisões fora do escopo já definido.

---

## Sumário

- [1. Status atual do projeto](#1-status-atual-do-projeto)
- [2. Objetivo do RSign](#2-objetivo-do-rsign)
- [3. Base atual: Gerador.bat](#3-base-atual-geradorbat)
- [4. Escopo funcional aprovado](#4-escopo-funcional-aprovado)
- [5. Interface final esperada](#5-interface-final-esperada)
- [6. Fluxo técnico completo](#6-fluxo-técnico-completo)
- [7. Regras de decisão assistida](#7-regras-de-decisão-assistida)
- [8. Arquitetura técnica planejada](#8-arquitetura-técnica-planejada)
- [9. Estrutura sugerida do repositório](#9-estrutura-sugerida-do-repositório)
- [10. Units previstas e responsabilidades](#10-units-previstas-e-responsabilidades)
- [11. Modelos e tipos de dados esperados](#11-modelos-e-tipos-de-dados-esperados)
- [12. Configurações padrão do projeto](#12-configurações-padrão-do-projeto)
- [13. Pré-requisitos de ambiente](#13-pré-requisitos-de-ambiente)
- [14. Como compilar o projeto](#14-como-compilar-o-projeto)
- [15. Como usar a aplicação](#15-como-usar-a-aplicação)
- [16. Logs, rastreabilidade e diagnóstico](#16-logs-rastreabilidade-e-diagnóstico)
- [17. Regras de segurança e observações operacionais](#17-regras-de-segurança-e-observações-operacionais)
- [18. Limitações conhecidas do modelo inicial](#18-limitações-conhecidas-do-modelo-inicial)
- [19. Roadmap técnico de implementação](#19-roadmap-técnico-de-implementação)
- [20. Diretriz oficial de continuidade do contexto](#20-diretriz-oficial-de-continuidade-do-contexto)

---

## 1. Status atual do projeto

No estado atual documentado, o projeto se encontra assim:

- **Base funcional existente:** `Gerador.bat`
- **Tecnologia alvo da nova aplicação:** Delphi 10+ FMX
- **Plataforma de execução:** Windows local
- **Modelo inicial de certificado:** autoassinado em `.pfx`
- **Expansão futura prevista:** PFX externo e Code Signing real
- **Fluxo principal:** definido
- **Política de timestamp:** definida
- **Política de backup de arquivo original:** definida
- **Política de logs:** definida
- **Divisão da UI em abas:** definida
- **Estratégia de descoberta do `signtool`:** definida
- **Modo de operação:** arquivo único e lote por pasta

O próximo passo de implementação é transformar essas definições em um projeto FMX real, com units separadas, fluxo orquestrado, persistência de configuração e operação guiada pela interface.

---

## 2. Objetivo do RSign

O **RSign** é um utilitário local para assinatura de arquivos compatíveis com o ecossistema **Authenticode** no Windows, visando inicialmente um cenário de assinatura técnica local com certificado autoassinado, mas com estrutura preparada para crescimento futuro.

### Objetivos centrais

- Verificar se o ambiente necessário para assinatura está disponível.
- Verificar se o certificado `.pfx` existe, é válido e está utilizável.
- Criar o certificado autoassinado quando necessário.
- Permitir ao usuário configurar o local e o nome do PFX.
- Permitir assinatura de um arquivo específico ou de vários arquivos em lote.
- Trabalhar com extensões suportadas previamente definidas.
- Localizar automaticamente o `signtool.exe`, com possibilidade de override manual.
- Renomear o arquivo original com sufixo `_OLD` e manter o arquivo assinado com o nome original.
- Verificar a assinatura após o processo, com essa opção ativada por padrão.
- Registrar logs em tela e em arquivo, com visão amigável e técnica.
- Explicar problemas críticos e aguardar decisão do usuário antes de seguir.

### O que o projeto não pretende ser neste primeiro momento

- um substituto completo para infraestrutura corporativa de Code Signing;
- uma ferramenta de distribuição pública com confiança automática em máquinas de terceiros;
- um sistema dependente de instalação permanente de certificado em store como regra principal de operação.

---

## 3. Base atual: Gerador.bat

Atualmente o projeto possui uma BAT funcional que já serve como prova de conceito operacional.

### 3.1. O que a BAT atual já faz

A BAT executa o seguinte fluxo:

1. Verifica se está rodando como administrador.
2. Define e cria as pastas de trabalho.
3. Limpa a pasta de saída.
4. Solicita ao usuário os dados do certificado.
5. Usa um nome padrão de PFX quando nada é informado.
6. Reutiliza o `.pfx` se ele já existir.
7. Cria um certificado autoassinado com PowerShell se o PFX não existir.
8. Lista arquivos `.exe` na pasta de entrada.
9. Permite escolher um executável.
10. Localiza o `signtool.exe`.
11. Copia o executável para saída.
12. Assina o arquivo com SHA256 e timestamp.

### 3.2. Limitações da BAT atual

Apesar de útil como base inicial, a BAT possui limitações importantes:

- exige administrador logo no início;
- trabalha somente com `.exe`;
- verifica existência do PFX, mas não valida sua saúde real;
- não valida formalmente a assinatura após assinar;
- não oferece persistência de configuração;
- não separa regra de negócio da interação com o usuário;
- não implementa a estratégia final de backup aprovada para o projeto FMX;
- não oferece logs técnicos consolidados;
- não está preparada para múltiplos perfis de certificado.

### 3.3. Valores padrão atualmente existentes na BAT

Os valores padrão atualmente conhecidos na base BAT são:

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

Esses valores podem seguir como ponto de partida, mas o projeto FMX deve permitir alteração pela interface.

---

## 4. Escopo funcional aprovado

O escopo funcional validado até o momento é o seguinte.

### 4.1. Certificado

- O projeto usará inicialmente **certificado autoassinado**.
- A arquitetura deve prever futura aceitação de:
  - PFX externo;
  - certificado real de Code Signing.
- O artefato final do certificado deve ser um arquivo **`.pfx`**.
- O certificado não deve permanecer instalado como resultado final em store do Windows.
- A senha padrão pode permanecer como `123456`, mas deve ser editável pela UI.
- Sempre que existir problema crítico com o PFX, o sistema deve explicar o cenário e aguardar decisão do usuário.

### 4.2. Extensões suportadas

O sistema deve trabalhar apenas com extensões conhecidas e previstas:

- `.exe`
- `.dll`
- `.msi`
- `.cab`
- `.cat`

### 4.3. Estratégia de saída dos arquivos

A estratégia aprovada é:

1. renomear o arquivo original com o sufixo `_OLD`;
2. produzir o arquivo assinado com o nome original.

#### Exemplo

Arquivo antes:

```text
MeuSistema.exe
```

Resultado após assinatura:

```text
MeuSistema_OLD.exe
MeuSistema.exe
```

### 4.4. Modos de operação

A aplicação deve permitir:

- assinatura de arquivo único;
- assinatura em lote por pasta.

A escolha será feita pela UI.

### 4.5. Verificação pós-assinatura

- A aplicação deve oferecer a opção de verificar ou não a assinatura após assinar.
- O comportamento padrão inicial deve ser **sempre verificar**.

### 4.6. Resolução do `signtool.exe`

A aplicação deve:

- permitir caminho manual;
- localizar automaticamente quando não houver caminho manual;
- preferir a versão mais nova encontrada;
- permitir que o usuário substitua a escolha automática.

### 4.7. Execução local

A aplicação será usada localmente e deve contemplar:

- uso manual pela interface;
- automatização interna do fluxo quando houver dados suficientes para isso.

### 4.8. Permissões administrativas

A aplicação não deve exigir administrador sempre.

Ela deve tentar trabalhar com privilégio normal e só exigir elevação quando alguma ação realmente depender disso.

---

## 5. Interface final esperada

A interface FMX do RSign deve ser organizada em **3 abas principais**, separando o que é perfil do certificado, o que é comportamento operacional e o que é caminho físico de trabalho.

## 5.1. Aba 1 — Perfil do Certificado

Essa aba concentra a identidade e o perfil lógico do certificado.

### Campos previstos

- Nome do certificado
- Nome da empresa
- Organização
- Departamento
- Cidade
- Estado
- País
- E-mail
- Validade do certificado
- Senha do PFX
- Confirmar senha
- Tipo do certificado:
  - Autoassinado
  - PFX externo
  - Futuro suporte a Code Signing real

### Regras dessa aba

- todos os valores padrão devem ser editáveis;
- a UI deve informar se o certificado será criado, reutilizado, validado ou substituído;
- o perfil ativo do certificado precisa ficar visível para o usuário;
- a tela deve deixar claro que, no modo inicial do projeto, o resultado final será sempre um `.pfx`.

## 5.2. Aba 2 — Configuração da Assinatura

Essa aba controla o comportamento operacional do processo.

### Campos previstos

- caminho manual do `signtool.exe`;
- opção de localizar `signtool` automaticamente;
- versão do `signtool` encontrada;
- preferência automática pela versão mais nova;
- URL do servidor de timestamp;
- verificar assinatura após assinar;
- política de falha de timestamp com confirmação do usuário;
- modo de operação:
  - arquivo único
  - lote
- tipo de log:
  - tela
  - arquivo
  - ambos

### Regras dessa aba

- a verificação pós-assinatura vem ligada por padrão;
- em caso de falha no timestamp, o sistema deve perguntar antes de continuar sem ele;
- a seleção automática do `signtool` mais novo deve ser o padrão inicial;
- o comportamento real aplicado deve ficar visível antes da execução.

## 5.3. Aba 3 — Locais e Arquivos

Essa aba concentra todos os caminhos físicos usados na operação.

### Bloco 1 — Certificado PFX

- local onde o PFX será salvo;
- nome do arquivo PFX;
- caminho final completo do PFX;
- botão para localizar PFX existente;
- botão para criar novo PFX.

### Bloco 2 — Origem dos arquivos

- seleção de arquivo específico;
- seleção de pasta para lote;
- listagem dos arquivos compatíveis encontrados;
- filtro por extensões suportadas.

### Bloco 3 — Destino dos arquivos

- pasta de saída;
- opção de usar a mesma pasta do arquivo original;
- indicação da política de backup `_OLD`;
- visão prévia da origem e do destino antes de assinar.

### Regras dessa aba

- o usuário deve definir o local e o nome do PFX;
- o usuário deve definir a pasta ou o arquivo a ser assinado;
- o sistema deve mostrar claramente entrada, saída e nome final esperado dos arquivos;
- a operação não deve começar com caminhos ambíguos.

---

## 6. Fluxo técnico completo

O fluxo técnico esperado da aplicação deve ser este.

### 6.1. Fluxo principal

1. Carregar configurações padrão e personalizadas.
2. Validar caminhos definidos na UI.
3. Resolver o `signtool.exe` por configuração manual ou descoberta automática.
4. Validar arquivo único ou montar lote por pasta.
5. Filtrar apenas extensões suportadas.
6. Verificar se o `.pfx` existe.
7. Se não existir, oferecer criação.
8. Se existir, validar o PFX.
9. Em caso de falha crítica, explicar o problema e aguardar decisão do usuário.
10. Preparar o backup `_OLD`.
11. Produzir o arquivo assinado com o nome original.
12. Verificar a assinatura, se habilitado.
13. Registrar logs.
14. Exibir resultado amigável e técnico.

### 6.2. Fluxo de validação do certificado

Quando encontrar um PFX, o sistema deve validar:

- existência física do arquivo;
- leitura do conteúdo;
- senha informada;
- integridade do PFX;
- presença de chave privada;
- vigência do certificado;
- aptidão para uso em assinatura.

### 6.3. Fluxo de criação do certificado

Para minimizar falhas de geração, a prática adotada no projeto será:

1. criar temporariamente o certificado em `CurrentUser\My`;
2. exportar para o caminho `.pfx` configurado;
3. remover o certificado temporário do store;
4. manter apenas o `.pfx` como artefato persistente.

> O store será usado apenas como etapa técnica transitória de criação. O resultado final válido para o projeto continuará sendo somente o arquivo `.pfx`.

### 6.4. Fluxo de arquivo único

1. usuário escolhe um arquivo suportado;
2. sistema valida extensão, existência e permissão de acesso;
3. sistema valida o PFX;
4. sistema valida o `signtool`;
5. sistema renomeia o original para `_OLD`;
6. sistema produz o arquivo assinado com o nome original;
7. sistema verifica a assinatura, se habilitado;
8. sistema grava logs e apresenta o resultado.

### 6.5. Fluxo de lote por pasta

1. usuário escolhe uma pasta;
2. sistema varre arquivos pelas extensões suportadas;
3. sistema monta uma fila de processamento;
4. para cada item:
   - valida o arquivo;
   - prepara `_OLD`;
   - assina;
   - verifica, se habilitado;
   - grava log individual;
5. ao final, o sistema apresenta um consolidado com sucessos, avisos e falhas.

---

## 7. Regras de decisão assistida

Uma diretriz central já aprovada é: o sistema **não deve decidir sozinho cenários críticos** quando houver risco operacional, dúvida técnica relevante ou necessidade de escolha entre alternativas válidas.

Nesses casos, o comportamento obrigatório é:

1. detectar o problema;
2. explicar o que aconteceu;
3. informar o impacto;
4. apresentar opções coerentes;
5. aguardar decisão explícita do usuário.

### 7.1. Situações típicas que exigem decisão

- PFX encontrado, mas com senha inválida;
- PFX corrompido;
- certificado vencido;
- certificado sem chave privada;
- certificado incompatível com assinatura;
- falha no timestamp;
- `signtool` encontrado, mas não funcional;
- arquivo em uso ou bloqueado;
- conflito de nome em arquivo `_OLD` já existente.

### 7.2. Regra específica para timestamp

Se o timestamp falhar, o sistema deve:

1. informar o erro;
2. explicar o impacto de prosseguir sem timestamp;
3. perguntar se o usuário deseja continuar sem ele.

---

## 8. Arquitetura técnica planejada

A aplicação deve ser construída com uma arquitetura em camadas leves, clara e de fácil manutenção.

### 8.1. Princípios adotados

- separação de responsabilidades;
- baixo acoplamento;
- serviços especializados;
- UI sem regra de negócio pesada;
- orquestração centralizada do fluxo;
- preparação para evolução futura.

### 8.2. Camadas previstas

#### Camada de UI
Responsável por:

- exibir dados;
- coletar escolhas do usuário;
- mostrar mensagens e logs;
- acionar o orquestrador.

#### Camada de Orquestração
Responsável por:

- controlar o fluxo completo;
- chamar os serviços na ordem correta;
- consolidar resultados;
- decidir quando interromper ou pedir decisão ao usuário.

#### Camada de Serviços
Responsável por tarefas especializadas:

- validar certificado;
- criar certificado;
- localizar `signtool`;
- validar arquivos;
- assinar;
- verificar assinatura;
- registrar logs.

#### Camada de Configuração
Responsável por:

- armazenar padrões;
- ler preferências salvas;
- persistir ajustes do usuário.

#### Camada de Modelos
Responsável por transportar dados entre UI, serviços e orquestrador.

---

## 9. Estrutura sugerida do repositório

Como o projeto ainda será implementado, a estrutura abaixo é a recomendação inicial para o repositório GitHub.

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

### Observação sobre a estrutura

- `Source/` concentrará o código Delphi;
- `Config/` deverá conter a configuração persistida da aplicação;
- `Logs/` poderá armazenar logs operacionais;
- `Temp/` servirá para trabalho temporário, se necessário;
- `Docs/` pode guardar documentação auxiliar além do README.

---

## 10. Units previstas e responsabilidades

### `RSign.Types.pas`
Centralizará tipos de dados, enums, records e contratos simples de transporte.

### `RSign.Config.pas`
Responsável por defaults, leitura e gravação de configuração, caminhos e preferências.

### `RSign.Utils.pas`
Responsável por utilidades gerais, como nomes, caminhos, filtros de extensão e normalização de textos.

### `RSign.Logger.pas`
Responsável por logs em arquivo, publicação de mensagens na UI e separação entre mensagem amigável e técnica.

### `RSign.Processo.pas`
Responsável por encapsular a execução de processos externos, incluindo PowerShell e `signtool.exe`, com captura de `stdout`, `stderr` e exit code.

### `RSign.Certificado.pas`
Responsável por validar `.pfx`, criar certificado autoassinado, exportar para PFX, remover o certificado temporário do store e preparar futura expansão para PFX externo e Code Signing real.

### `RSign.Signtool.pas`
Responsável por localizar o `signtool.exe`, listar candidatos, identificar versões e validar se o executável realmente funciona.

### `RSign.Arquivo.pas`
Responsável por validar caminhos de origem, filtrar extensões, preparar backup `_OLD` e organizar entrada e saída.

### `RSign.Assinatura.pas`
Responsável por montar o comando de assinatura, executar o processo e devolver o resultado detalhado por arquivo.

### `RSign.Verificacao.pas`
Responsável por verificar se a assinatura foi aplicada corretamente e consolidar o resultado pós-assinatura.

### `RSign.Orquestrador.pas`
Responsável por ser o núcleo do fluxo, chamando os serviços na ordem correta e interagindo com a UI apenas por intenção, não por detalhe operacional.

### `View.Main.pas`
Tela principal do sistema, com as três abas centrais e os comandos gerais da operação.

### `View.Configuracao.pas`
Tela complementar para edição e persistência de parâmetros do sistema, se for necessário separar visualmente a configuração principal.

### `View.Log.pas`
Tela ou painel dedicado para exibição detalhada dos logs da execução.

---

## 11. Modelos e tipos de dados esperados

Os nomes abaixo representam a base lógica sugerida para o projeto.

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

Esses nomes ainda podem ser refinados na implementação, mas a responsabilidade funcional de cada tipo deve ser preservada.

---

## 12. Configurações padrão do projeto

Os valores padrão aprovados até aqui são:

- senha padrão do PFX: `123456`;
- verificação pós-assinatura: ligada;
- resolução automática do `signtool`: ligada;
- preferência pela versão mais nova do `signtool`: ligada;
- extensões suportadas: `.exe`, `.dll`, `.msi`, `.cab`, `.cat`;
- timestamp configurável;
- modo de operação selecionável pela UI.

> Todo valor padrão relevante para uso deve poder ser ajustado pela interface, salvo elementos técnicos que não façam sentido alterar em tempo de operação.

---

## 13. Pré-requisitos de ambiente

Antes de compilar ou usar o RSign, o ambiente precisa atender aos pontos abaixo.

### 13.1. Sistema operacional

- Windows
- execução local

### 13.2. Ferramentas de desenvolvimento

- Delphi 10+ com suporte FMX

### 13.3. Dependências operacionais externas

- PowerShell disponível no sistema operacional;
- `signtool.exe` instalado ou acessível manualmente.

### 13.4. Origem esperada do `signtool.exe`

O `signtool.exe` normalmente será encontrado em instalações do:

- Windows SDK
- Windows Kits

A aplicação também deve permitir informar o caminho manualmente.

### 13.5. Permissões

A aplicação deve funcionar com o menor nível de privilégio possível. Apenas etapas que realmente exigirem elevação deverão forçar esse comportamento.

---

## 14. Como compilar o projeto

Como o projeto será implementado em Delphi 10+ FMX, a compilação deverá seguir este fluxo.

### 14.1. Abrir o projeto

1. Abra o Delphi 10+.
2. Carregue o projeto principal `RSign.dpr`.
3. Verifique se os caminhos das units e recursos estão corretamente configurados.

### 14.2. Validar dependências internas

Antes de compilar, confirme que:

- a pasta `Source/` está no Search Path do projeto;
- as units da aplicação foram incluídas corretamente;
- eventuais arquivos de configuração inicial estão presentes;
- a aplicação está preparada para localizar PowerShell e `signtool` em runtime.

### 14.3. Compilar

1. Selecione o alvo Windows.
2. Execute `Build` ou `Compile`.
3. Gere o executável final da aplicação FMX.

### 14.4. Observação importante sobre a compilação

A compilação do RSign gera o executável da ferramenta, mas não elimina a necessidade de o ambiente de execução possuir os componentes externos necessários para o fluxo real de assinatura, especialmente o `signtool.exe`.

---

## 15. Como usar a aplicação

Esta seção descreve o comportamento esperado do uso final do RSign.

## 15.1. Cenário A — Assinar com certificado já existente

1. Abra o RSign.
2. Vá até a aba **Perfil do Certificado** e confira os dados atuais.
3. Vá até a aba **Locais e Arquivos**.
4. Informe o local do PFX e o nome do arquivo, ou localize um PFX existente.
5. Defina um arquivo específico ou uma pasta para lote.
6. Vá até a aba **Configuração da Assinatura** e confira o `signtool`, timestamp e verificação pós-assinatura.
7. Inicie a operação.
8. O sistema validará ambiente, certificado, arquivo e ferramenta.
9. O sistema executará a assinatura.
10. O sistema verificará a assinatura, se a opção estiver ativa.
11. O sistema mostrará o resultado e registrará logs.

## 15.2. Cenário B — Assinar sem PFX existente

1. Abra o RSign.
2. Preencha os dados do certificado na aba **Perfil do Certificado**.
3. Defina o local e o nome do PFX na aba **Locais e Arquivos**.
4. Configure o arquivo ou pasta a ser assinado.
5. Inicie a operação.
6. O sistema verificará que o PFX não existe.
7. O sistema oferecerá a criação do certificado.
8. O certificado será criado temporariamente no store técnico.
9. O sistema exportará para `.pfx`.
10. O certificado temporário será removido.
11. O processo de assinatura seguirá normalmente.

## 15.3. Cenário C — Falha no timestamp

1. O sistema inicia a assinatura.
2. O servidor de timestamp falha ou fica indisponível.
3. O sistema informa o problema.
4. O sistema explica o impacto de seguir sem timestamp.
5. O usuário escolhe continuar ou cancelar.
6. O fluxo segue conforme a decisão tomada.

## 15.4. Cenário D — Assinatura em lote

1. O usuário escolhe uma pasta.
2. O sistema lista os arquivos compatíveis.
3. O usuário revisa a entrada e o destino.
4. O sistema processa item a item.
5. Ao final, é apresentado um resumo consolidado com totais e detalhes.

---

## 16. Logs, rastreabilidade e diagnóstico

A política de logs do projeto precisa atender dois públicos:

1. o usuário operacional, que precisa entender o que aconteceu;
2. o usuário técnico, que precisa diagnosticar rapidamente falhas.

### 16.1. Log amigável

Exemplos do que deve conter:

- início da operação;
- certificado encontrado;
- certificado criado com sucesso;
- arquivo preparado para assinatura;
- assinatura concluída;
- verificação aprovada;
- aviso de falha em timestamp;
- resumo final da operação.

### 16.2. Log técnico

Exemplos do que deve conter:

- caminho do arquivo processado;
- caminho do PFX utilizado;
- caminho e versão do `signtool`;
- comando executado;
- exit code do processo;
- saída padrão e saída de erro;
- retorno da verificação da assinatura;
- decisão tomada pelo usuário em casos críticos.

### 16.3. Persistência dos logs

A aplicação deve conseguir:

- exibir logs em tela;
- gravar logs em arquivo;
- operar em ambos simultaneamente.

---

## 17. Regras de segurança e observações operacionais

### 17.1. Senha padrão do PFX

A senha padrão inicial continuará sendo `123456`, porque isso já faz parte da base operacional atual. Mesmo assim:

- a interface deve permitir alteração;
- a documentação deve deixar claro que isso é um padrão inicial, não uma recomendação forte de segurança;
- o projeto deve permitir evolução futura para políticas de senha mais rígidas.

### 17.2. Uso de store temporário

Embora o projeto não use store como destino final, a geração do certificado poderá usar store temporário por necessidade técnica da criação via PowerShell. Isso não muda a regra funcional do sistema, pois o artefato persistente continua sendo apenas o `.pfx`.

### 17.3. Arquivos em uso

O sistema deve detectar arquivos bloqueados ou em uso e impedir operações silenciosas que gerem estado inconsistente ou perda de rastreabilidade.

### 17.4. Elevação de privilégio

A aplicação deve evitar exigir administrador em toda execução. A necessidade de elevação deve ser contextual, não fixa.

---

## 18. Limitações conhecidas do modelo inicial

O uso de certificado autoassinado atende ao cenário de assinatura técnica local, mas não oferece automaticamente o mesmo nível de confiança pública que um certificado real emitido por autoridade certificadora reconhecida.

### Impacto prático

Um arquivo assinado com certificado autoassinado:

- pode ser assinado com sucesso;
- pode ser validado tecnicamente;
- mas não terá, por padrão, o mesmo nível de confiança pública em máquinas de terceiros.

Por isso, a arquitetura já nasce preparada para futura evolução para certificados reais de Code Signing.

---

## 19. Roadmap técnico de implementação

A sequência recomendada de implementação é esta.

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
- preparar a estratégia `_OLD` + nome original assinado.

### Fase 5 — Assinatura

- montar comando;
- executar assinatura;
- capturar retorno técnico.

### Fase 6 — Verificação

- executar verificação pós-assinatura;
- consolidar sucesso, aviso ou falha.

### Fase 7 — UI FMX

- construir as três abas principais;
- integrar campos, botões e listagens;
- exibir logs;
- apresentar decisões de usuário quando necessário.

### Fase 8 — Refinos finais

- persistência definitiva das preferências;
- revisão de mensagens;
- testes do fluxo completo;
- preparação da expansão futura.

---

## 20. Diretriz oficial de continuidade do contexto

Este README passa a ser a referência principal do projeto **RSign** e deve ser tratado como documento de contexto obrigatório para as próximas etapas.

Toda evolução do projeto deve respeitar, no mínimo:

- o uso inicial de certificado autoassinado em `.pfx`;
- a preparação futura para PFX externo e Code Signing real;
- a divisão da UI em 3 abas;
- a política de decisão assistida;
- a estratégia de backup `_OLD` + arquivo assinado com nome original;
- a política de timestamp com confirmação do usuário em caso de falha;
- as extensões suportadas já aprovadas;
- a execução local em Windows com Delphi 10+ FMX.

Sempre que o projeto avançar de fase, este documento deve ser atualizado para refletir:

- o que já foi implementado;
- o que mudou no fluxo;
- o que continua como regra;
- o que ainda está planejado.

Essa atualização contínua é obrigatória para garantir que o desenvolvimento do RSign permaneça fiel ao contexto definido e não desvie para soluções fora do escopo aprovado.
