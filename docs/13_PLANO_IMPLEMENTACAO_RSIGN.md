# RSign — Plano Técnico de Implementação por Fases

## 1. Objetivo deste documento

Este documento define o plano técnico de implementação do projeto **RSign**, estabelecendo uma sequência de desenvolvimento segura, progressiva e coerente com o escopo já aprovado para a aplicação em **Delphi 10+ FMX**.

O foco deste plano é transformar as decisões funcionais e arquiteturais já fechadas em uma trilha prática de construção do sistema, reduzindo retrabalho, evitando acoplamento indevido e mantendo o projeto preparado para futura evolução de **certificado autoassinado** para **Code Signing real**.

---

## 2. Contexto consolidado do projeto

O projeto **RSign** terá como responsabilidade principal:

- verificar a disponibilidade do ambiente de assinatura;
- localizar e validar o `signtool.exe`;
- localizar, validar e, quando necessário, criar um certificado em formato `.pfx`;
- trabalhar com assinatura de **arquivo único** ou **lote**;
- operar apenas com extensões conhecidas e suportadas pelo fluxo definido;
- renomear o arquivo original para `_OLD` antes de gerar a versão assinada com o nome original;
- assinar o arquivo usando `SHA256`;
- verificar a assinatura ao final por padrão;
- registrar logs técnicos e visuais;
- explicar falhas críticas e aguardar decisão do usuário em vez de tomar decisões silenciosas.

### Premissas já aprovadas

- Interface em **FMX**.
- Execução **local**.
- Modo de operação **manual e automático**.
- Certificado inicial: **autoassinado**, com preparação para suporte futuro a **Code Signing real**.
- Artefato final do certificado: apenas **`.pfx`**.
- O sistema pode usar criação técnica temporária em store apenas para geração do certificado, com remoção posterior.
- O `signtool` pode ser localizado automaticamente ou configurado manualmente.
- A versão mais nova do `signtool` será a preferida por padrão.
- A verificação pós-assinatura ficará **habilitada por padrão**, mas pode ser desligada pelo usuário.
- Em falha de timestamp, o sistema deverá **perguntar ao usuário** se deseja continuar sem timestamp.
- O sistema trabalhará apenas com estas extensões conhecidas:
  - `.exe`
  - `.dll`
  - `.msi`
  - `.cab`
  - `.cat`

---

## 3. Estratégia geral de implementação

A implementação deve seguir uma abordagem em camadas, separando:

- **UI FMX**
- **orquestração do fluxo**
- **serviços especializados**
- **persistência/configuração**
- **execução de processos externos**
- **logs e diagnósticos**

Essa separação é obrigatória para evitar que a tela principal concentre regras de negócio, validações operacionais e chamadas externas.

### Diretriz central

A UI deve **solicitar ações e exibir resultados**, enquanto o núcleo do sistema deve **decidir o fluxo técnico**.

---

## 4. Ordem correta de implementação

A ordem abaixo foi pensada para diminuir risco e permitir testes reais desde as primeiras fases.

1. Fundamentos do projeto.
2. Modelos e contratos.
3. Configuração e persistência.
4. Logger e diagnóstico.
5. Executor de processos externos.
6. Descoberta e validação do `signtool`.
7. Serviço de arquivos de assinatura.
8. Serviço de certificado.
9. Serviço de assinatura.
10. Serviço de verificação.
11. Orquestrador principal.
12. Interface FMX.
13. Fluxos automáticos.
14. Testes operacionais e validação final.

---

## 5. Fase 1 — Fundação do projeto

### Objetivo
Criar a base estrutural do repositório e do projeto Delphi, com nomenclatura, organização de units e ambiente mínimo para evolução.

### Itens desta fase

- Criar o projeto FMX principal.
- Definir estrutura de pastas.
- Definir padrão de nomenclatura das units.
- Definir local dos arquivos de configuração.
- Definir local de logs.
- Definir local dos artefatos temporários.
- Criar constants centrais do projeto.

### Entregáveis

- Projeto FMX inicial compilando.
- Estrutura de pastas criada.
- Unit de constantes criada.
- Unit base de tipos criada.

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

### Critério de conclusão

Esta fase estará concluída quando o projeto FMX abrir, compilar e possuir uma estrutura mínima estável para receber as próximas units.

---

## 6. Fase 2 — Modelos, tipos e contratos do sistema

### Objetivo
Criar os records, enums, classes e interfaces que representarão o estado do sistema, sem ainda executar lógica pesada.

### Itens desta fase

#### Enums sugeridos

- `TTipoCertificado`
- `TModoAssinatura`
- `TStatusOperacao`
- `TOrigemSigntool`
- `TNivelLog`
- `TResultadoVerificacao`
- `TAcaoUsuarioFalha`

#### Records ou classes sugeridos

- `TConfiguracaoCertificado`
- `TConfiguracaoAssinatura`
- `TConfiguracaoCaminhos`
- `TStatusCertificado`
- `TStatusSigntool`
- `TStatusArquivo`
- `TResultadoExecucao`
- `TResultadoAssinatura`
- `TResultadoValidacao`
- `TItemArquivoAssinatura`

#### Interfaces sugeridas

- `IExecutorProcesso`
- `ILoggerService`
- `ISigntoolService`
- `ICertificadoService`
- `IArquivoAssinaturaService`
- `IAssinaturaService`
- `IVerificacaoAssinaturaService`
- `IOrquestradorAssinatura`

### Entregáveis

- Units de tipos e interfaces prontas.
- Projeto compilando com os contratos definidos.

### Critério de conclusão

A fase termina quando toda a comunicação entre módulos puder ser planejada com base em contratos estáveis, evitando acoplamento direto entre tela e implementação.

---

## 7. Fase 3 — Configuração e persistência local

### Objetivo
Centralizar leitura e gravação das preferências operacionais do sistema.

### Itens desta fase

- Definir formato de persistência local:
  - `.ini` como primeira opção prática para Delphi 10.2.
- Criar serviço de leitura e gravação das configurações.
- Separar configuração por grupo funcional.

### Grupos de configuração

#### Perfil do certificado
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
- tipo do certificado.

#### Configuração da assinatura
- localizar `signtool` automaticamente;
- caminho manual do `signtool`;
- usar versão mais nova;
- URL de timestamp;
- verificar assinatura ao final;
- continuar sem timestamp mediante confirmação;
- tipo de log.

#### Locais e arquivos
- local do PFX;
- nome do PFX;
- pasta de entrada;
- pasta de saída;
- arquivo específico;
- modo arquivo único ou lote.

### Entregáveis

- Unit de configuração pronta.
- Serviço de leitura e gravação funcional.
- Carga inicial dos padrões funcionando.

### Critério de conclusão

A fase termina quando o projeto conseguir salvar, recarregar e reaplicar configurações sem depender de valores fixos no código da tela.

---

## 8. Fase 4 — Logger e diagnóstico técnico

### Objetivo
Criar o subsistema de logs que será usado por todos os módulos.

### Itens desta fase

- Definir formato do log em arquivo.
- Definir se o log será diário, único ou por execução.
- Criar logger com níveis.
- Permitir escrita em:
  - tela;
  - arquivo;
  - ambos.
- Padronizar mensagens técnicas e amigáveis.

### Dados recomendados no log

- data e hora;
- ação executada;
- caminho do arquivo alvo;
- caminho do PFX;
- caminho do `signtool`;
- comando executado;
- código de retorno;
- saída capturada;
- falha ocorrida;
- decisão tomada pelo usuário.

### Entregáveis

- `ILoggerService` implementado.
- Logs sendo gravados localmente.
- Estrutura pronta para integração com a UI.

### Critério de conclusão

Esta fase estará concluída quando qualquer módulo puder registrar eventos sem conhecer detalhes da tela ou do formato do arquivo de log.

---

## 9. Fase 5 — Executor de processos externos

### Objetivo
Criar o mecanismo único e confiável para executar PowerShell, `signtool.exe` e demais comandos externos.

### Itens desta fase

- Implementar execução de processo externo.
- Capturar:
  - código de retorno;
  - saída padrão;
  - erro padrão;
  - tempo de execução.
- Padronizar timeout.
- Permitir execução com ou sem elevação.
- Tratar caracteres especiais em caminhos e parâmetros.

### Justificativa

Toda a operação crítica do projeto dependerá desse executor. Ele precisa ser isolado e robusto, pois será a base para:

- geração do certificado;
- exportação do PFX;
- remoção do certificado temporário do store;
- assinatura;
- verificação da assinatura.

### Entregáveis

- `IExecutorProcesso` implementado.
- Testes básicos com comandos simples funcionando.

### Critério de conclusão

A fase termina quando o sistema conseguir executar comandos externos com retorno confiável, incluindo captura completa da saída.

---

## 10. Fase 6 — Descoberta e validação do signtool

### Objetivo
Localizar e validar o utilitário de assinatura.

### Itens desta fase

- Tentar caminho manual informado na UI.
- Tentar encontrar no `PATH`.
- Procurar em instalações do Windows SDK / Windows Kits.
- Catalogar múltiplas versões.
- Ordenar por versão.
- Selecionar a versão mais nova por padrão.
- Permitir override manual pelo usuário.
- Validar se o executável encontrado responde corretamente.

### Dados a devolver

- caminho final escolhido;
- origem da descoberta;
- versão detectada;
- lista de candidatos encontrados;
- status final de disponibilidade.

### Entregáveis

- `ISigntoolService` implementado.
- Método de descoberta funcional.
- Método de validação funcional.

### Critério de conclusão

A fase termina quando o sistema conseguir localizar com segurança o `signtool` e explicar ao usuário qual executável será usado e por quê.

---

## 11. Fase 7 — Serviço de arquivos para assinatura

### Objetivo
Implementar a preparação técnica dos arquivos antes da assinatura.

### Itens desta fase

- Validar se o arquivo existe.
- Validar se a extensão é suportada.
- Validar leitura e escrita.
- Validar se o arquivo está bloqueado.
- Trabalhar em modo:
  - arquivo único;
  - lote.
- Enumerar arquivos elegíveis em uma pasta.
- Preparar renomeação para `_OLD`.
- Preparar destino do arquivo assinado com o nome original.

### Regras obrigatórias

- O original nunca deve ser perdido silenciosamente.
- Em falha ao renomear para `_OLD`, o sistema deve interromper a operação daquele item.
- O sistema deve impedir conflito com múltiplos `_OLD` quando necessário, definindo política segura.

### Política recomendada para conflito com `_OLD`

Quando já existir um arquivo `_OLD`:

- explicar o problema ao usuário;
- permitir decidir entre:
  - sobrescrever `_OLD`;
  - renomear com sufixo incremental;
  - cancelar o item.

### Entregáveis

- `IArquivoAssinaturaService` implementado.
- Validação de item único funcionando.
- Varredura em lote funcionando.

### Critério de conclusão

A fase termina quando a preparação dos arquivos puder ser executada de forma segura, previsível e independente do módulo de assinatura.

---

## 12. Fase 8 — Serviço de certificado

### Objetivo
Tratar toda a vida útil do certificado em `.pfx`.

### Responsabilidades

- Verificar existência do `.pfx`.
- Validar senha do `.pfx`.
- Verificar integridade.
- Verificar se possui chave privada.
- Verificar vigência.
- Avaliar se é utilizável para assinatura.
- Criar certificado autoassinado quando necessário.
- Exportar `.pfx`.
- Remover o certificado temporário do store após exportação.
- Explicar problemas e aguardar decisão do usuário.

### Fluxo de criação aprovado

1. Criar certificado temporário em `CurrentUser\My`.
2. Exportar para `.pfx`.
3. Remover o certificado do store temporário.
4. Manter apenas o `.pfx` como artefato final.

### Casos que exigem decisão do usuário

- certificado inexistente;
- senha inválida;
- PFX corrompido;
- certificado vencido;
- certificado sem chave privada;
- certificado incompatível com uso esperado.

### Entregáveis

- `ICertificadoService` implementado.
- Criação de certificado funcionando.
- Validação de PFX existente funcionando.

### Critério de conclusão

A fase termina quando o sistema puder operar com PFX novo ou existente, sem depender de intervenção manual externa fora do aplicativo.

---

## 13. Fase 9 — Serviço de assinatura

### Objetivo
Executar efetivamente a assinatura dos arquivos preparados.

### Itens desta fase

- Montar linha de comando do `signtool`.
- Aplicar `SHA256`.
- Aplicar certificado `.pfx` e senha.
- Aplicar timestamp configurado.
- Capturar retorno da operação.
- Devolver resultado detalhado.

### Regras importantes

- Não assinar antes de validar certificado, signtool e arquivo.
- Registrar todo o comando de forma segura para diagnóstico.
- Ocultar a senha em logs visíveis quando necessário.

### Entregáveis

- `IAssinaturaService` implementado.
- Assinatura de arquivo único funcionando.
- Assinatura em lote funcionando.

### Critério de conclusão

A fase termina quando o sistema conseguir assinar arquivos válidos com captura completa do resultado técnico.

---

## 14. Fase 10 — Verificação da assinatura

### Objetivo
Confirmar tecnicamente a assinatura produzida.

### Itens desta fase

- Executar verificação pós-assinatura.
- Confirmar se a assinatura foi aplicada.
- Confirmar se o timestamp foi aplicado quando solicitado.
- Tratar cenário de falha de timestamp.
- Permitir desabilitar a verificação, mantendo o padrão ligado.

### Regra obrigatória em falha de timestamp

Se o timestamp falhar:

1. informar o motivo;
2. explicar impacto;
3. perguntar ao usuário se deseja continuar sem timestamp.

### Entregáveis

- `IVerificacaoAssinaturaService` implementado.
- Verificação funcional integrada ao fluxo.

### Critério de conclusão

A fase termina quando o sistema puder validar de forma clara o resultado da assinatura e refletir isso na UI e no log.

---

## 15. Fase 11 — Orquestrador principal

### Objetivo
Criar o módulo que controla a ordem de execução de todo o fluxo.

### Responsabilidades

O orquestrador deve:

1. carregar configuração;
2. validar signtool;
3. validar arquivos;
4. validar certificado;
5. criar certificado, se necessário;
6. pedir decisão ao usuário em situações críticas;
7. preparar backup `_OLD`;
8. assinar;
9. verificar;
10. registrar log final;
11. devolver resumo de sucesso ou falha.

### Motivo desta fase ser separada

Sem orquestrador, a lógica tende a se espalhar pela tela e pelos serviços, causando acoplamento, duplicação e aumento do risco de inconsistência.

### Entregáveis

- `IOrquestradorAssinatura` implementado.
- Fluxo completo funcional em testes internos, mesmo antes da UI final.

### Critério de conclusão

A fase termina quando o sistema tiver um fluxo central único e reproduzível para conduzir a operação ponta a ponta.

---

## 16. Fase 12 — Interface FMX

### Objetivo
Construir a interface visual definitiva da aplicação.

### Estrutura aprovada

A UI será dividida em **3 abas**.

#### Aba 1 — Perfil do Certificado
Campos técnicos e funcionais do certificado.

#### Aba 2 — Configuração da Assinatura
Comportamento do processo, `signtool`, timestamp, verificação e log.

#### Aba 3 — Locais e Arquivos
Local e nome do PFX, origem dos arquivos, pasta de saída e modo arquivo/lote.

### Itens desta fase

- Construir componentes visuais.
- Fazer binding lógico com a configuração.
- Criar ações de seleção de arquivo, pasta e PFX.
- Criar área de log visual.
- Criar painel de status da operação.
- Criar diálogos de decisão do usuário.

### Regras da UI

- toda decisão crítica deve ser apresentada de forma clara;
- a UI não deve conter regra pesada de negócio;
- a UI deve refletir o estado do orquestrador;
- os valores padrão devem poder ser alterados pelo usuário.

### Entregáveis

- Tela principal funcional.
- Navegação entre abas funcionando.
- Disparo real do fluxo completo a partir da UI.

### Critério de conclusão

A fase termina quando um usuário conseguir configurar, executar, acompanhar e concluir a assinatura sem depender de scripts externos manuais.

---

## 17. Fase 13 — Modo automático e produtividade operacional

### Objetivo
Permitir execução mais rápida e repetível sem retirar a possibilidade de decisão assistida.

### Itens desta fase

- Reaplicar última configuração salva.
- Executar lote com menos interação quando não houver falha crítica.
- Criar perfil de operação padrão.
- Preparar futuras opções de linha de comando, se desejado.

### Entregáveis

- Fluxo semiautomático funcional.
- Reuso de configuração validado.

### Critério de conclusão

A fase termina quando o usuário conseguir executar o cenário comum com mínima intervenção, sem perder segurança nas falhas críticas.

---

## 18. Fase 14 — Testes operacionais e validação final

### Objetivo
Validar o sistema em cenários reais e consolidar o comportamento esperado.

### Cenários mínimos de teste

#### Signtool
- signtool encontrado automaticamente;
- signtool informado manualmente;
- signtool inexistente;
- múltiplas versões instaladas.

#### Certificado
- PFX inexistente;
- PFX válido;
- senha incorreta;
- PFX corrompido;
- certificado vencido;
- certificado sem chave privada.

#### Arquivos
- arquivo inexistente;
- arquivo válido;
- arquivo bloqueado;
- extensão não suportada;
- pasta com múltiplos itens elegíveis.

#### Assinatura
- assinatura com timestamp válido;
- falha de timestamp;
- assinatura sem verificação final;
- assinatura em lote.

#### Saída
- criação correta do `_OLD`;
- preservação do nome original para o assinado;
- conflito com arquivo `_OLD` existente.

### Entregáveis

- Checklist de testes executado.
- Ajustes finais realizados.
- Pronto para uso local controlado.

### Critério de conclusão

A fase termina quando o projeto operar de forma consistente nos cenários esperados e tiver comportamento previsível nas falhas.

---

## 19. Riscos técnicos que devem ser observados

### 1. Dependência externa do PowerShell
A geração do autoassinado dependerá do ambiente PowerShell e da disponibilidade dos comandos necessários.

### 2. Variações de ambiente Windows
A localização do `signtool` pode variar conforme SDK instalado e versão do sistema.

### 3. Arquivos bloqueados
Arquivos em uso podem impedir renomeação, cópia ou assinatura.

### 4. Senha sensível em logs
O projeto deve evitar exposição indevida da senha do PFX em logs ou UI.

### 5. Diferença entre assinatura técnica e confiança pública
Certificado autoassinado permite assinar, mas não fornece a mesma confiança pública de um Code Signing emitido por autoridade certificadora.

---

## 20. Dependências técnicas do projeto

### Dependências funcionais
- Delphi 10.2 FMX
- Windows com suporte às ferramentas de assinatura
- PowerShell
- `signtool.exe`

### Dependências conceituais
- separação entre UI e serviços;
- uso de configuração persistida;
- uso de logs centralizados;
- tratamento explícito de decisão do usuário.

---

## 21. Critérios de aceite do projeto

O projeto **RSign** será considerado tecnicamente aderente ao escopo quando:

- a UI em 3 abas estiver implementada;
- o PFX puder ser localizado, validado e criado pelo sistema;
- o `signtool` puder ser detectado automaticamente e ajustado manualmente;
- o sistema conseguir operar com arquivo único e lote;
- o arquivo original passar para `_OLD`;
- o arquivo assinado permanecer com o nome original;
- a assinatura puder ser verificada ao final;
- falhas críticas forem explicadas ao usuário;
- logs em tela e arquivo estiverem funcionando;
- o fluxo completo puder ser executado sem depender da BAT original.

---

## 22. Próximos documentos recomendados

Após este plano, os próximos artefatos recomendados são:

1. Documento de arquitetura das units.
2. Especificação das interfaces e seus métodos.
3. Mapa do fluxo entre UI, Orquestrador e Services.
4. Checklist de testes por cenário.
5. Documento de regras de negócio consolidado.

---

## 23. Resumo executivo da implementação

O projeto **RSign** não deve ser construído diretamente pela tela nem como simples conversão da BAT atual. A implementação correta exige um núcleo organizado, com serviços especializados, controle explícito das falhas, persistência de configuração, validação de certificado, descoberta do `signtool`, preparação segura dos arquivos e verificação final da assinatura.

A melhor estratégia é evoluir por fases, começando pela base do projeto e pelos contratos, avançando para os serviços técnicos, consolidando a orquestração e só então finalizando a interface FMX definitiva. Essa ordem reduz risco, facilita testes reais, melhora a manutenção futura e mantém o sistema preparado para suportar, mais adiante, certificados reais de Code Signing sem necessidade de reescrever o núcleo do projeto.
