# RSign — Índice Oficial da Documentação

## 1. Objetivo deste documento

Este arquivo define a **ordem oficial de leitura** da documentação do projeto **RSign**.

Seu objetivo é evitar interpretação incorreta dos arquivos, impedir conflito entre documentos, manter o contexto técnico estável e garantir que qualquer leitura feita por desenvolvedor, IA ou revisores siga a mesma sequência lógica e arquitetural.

Este arquivo deve ser sempre o **primeiro documento lido** dentro da pasta `docs`.

---

## 2. Regra principal de leitura

A documentação do projeto deve ser lida **exatamente na ordem numérica apresentada nesta pasta**.

A numeração foi definida para que o entendimento siga a sequência correta:

1. decisões estruturais que alteram a interpretação do projeto;
2. contexto técnico oficial;
3. comportamento funcional;
4. visão geral do projeto;
5. arquitetura;
6. contratos;
7. implementação;
8. configuração, mensagens, testes e evolução.

---

## 3. Ordem oficial de leitura

### 00. Índice
- `00_INDICE_DOCS.md`

### 01. Decisão arquitetural obrigatória
- `01_DECISAO_RENOMEAR_VIEW_PARA_APP.md`

### 02. Contexto técnico oficial
- `02_CONTEXTO_TECNICO.md`

### 03. Referência funcional oficial
- `03_REFERENCIA_FUNCIONAL.md`

### 04. Descrição geral do projeto
- `04_DESCRICAO_PROJETO.md`

### 05. Arquitetura das units
- `05_ARQUITETURA_UNITS_RSIGN.md`

### 06. Interfaces e contratos
- `06_CONTRATOS_INTERFACES_RSIGN.md`

### 07. Matriz de implementação
- `07_MATRIZ_IMPLEMENTACAO_RSIGN.md`

### 08. ADR — decisões técnicas
- `08_ADR_DECISOES_TECNICAS.md`

### 09. Especificação do arquivo INI
- `09_ESPECIFICACAO_INI.md`

### 10. Catálogo de mensagens e erros
- `10_CATALOGO_MENSAGENS_ERROS.md`

### 11. Guia de codificação
- `11_GUIA_CODIFICACAO_RSIGN.md`

### 12. Plano de testes
- `12_PLANO_TESTES_RSIGN.md`

### 13. Plano de implementação
- `13_PLANO_IMPLEMENTACAO_RSIGN.md`

### 14. Roadmap
- `14_ROADMAP.md`

### 15. Changelog
- `15_CHANGELOG.md`

### 16. Checklist de release
- `16_CHECKLIST_RELEASE.md`

---

## 4. Regra de precedência em caso de conflito

Se dois ou mais documentos apresentarem informação diferente, prevalece a seguinte ordem de autoridade:

1. `01_DECISAO_*`
2. `08_ADR_*`
3. `05_ARQUITETURA_*`
4. `06_CONTRATOS_*`
5. `07_MATRIZ_IMPLEMENTACAO_*`
6. `11_GUIA_CODIFICACAO_*`
7. `13_PLANO_IMPLEMENTACAO_*`
8. `14_ROADMAP.md`
9. `15_CHANGELOG.md`

### Observação importante
A ordem numérica continua sendo a ordem oficial de leitura, mas a precedência acima define **qual documento vence** quando houver divergência.

---

## 5. Regra oficial sobre a separação entre UI e App

Antes de interpretar qualquer parte da arquitetura ou do código, deve-se considerar obrigatoriamente a decisão documentada em:

- `01_DECISAO_RENOMEAR_VIEW_PARA_APP.md`

Essa decisão altera a interpretação oficial da arquitetura.

### Regra válida do projeto
- `UI` = camada visual real, composta por forms, frames e arquivos `.fmx`
- `App` = camada de coordenação, composição e integração da aplicação
- `App` não representa, por padrão, camada visual
- units da camada `App` não devem induzir expectativa de `.fmx`

Essa regra deve ser aplicada em toda leitura posterior da documentação.

---

## 6. Regra sobre arquivos em `legacy`

Arquivos localizados na pasta `legacy/`:

- **não são referência principal de implementação**;
- devem ser tratados como material histórico;
- podem ser úteis para rastrear origem, evolução e versões anteriores da documentação;
- não devem prevalecer sobre documentos numerados na raiz de `docs`.

### Exemplo de uso correto de `legacy`
- consulta histórica;
- comparação entre decisões antigas e atuais;
- recuperação de contexto anterior.

### Exemplo de uso incorreto de `legacy`
- usar como base principal para criar novas units;
- usar como autoridade maior que os documentos numerados atuais;
- ignorar decisões formais mais novas.

---

## 7. Regra sobre arquivos fora de `docs`

Arquivos técnicos auxiliares que não fazem parte da documentação principal não devem permanecer na raiz de `docs`.

Exemplo:
- scripts
- arquivos `.bat`
- ferramentas de apoio operacional

### Exemplo já aplicado
- `Gerador.bat` foi movido para `../tools/Gerador.bat`

Isso evita que materiais operacionais sejam confundidos com documentação oficial.

---

## 8. Como usar este índice com IA ou com outro desenvolvedor

Ao pedir para uma IA ou para outro desenvolvedor continuar o projeto, a instrução recomendada é:

### Modelo sugerido de orientação
> Leia primeiro o arquivo `00_INDICE_DOCS.md` e siga estritamente a ordem oficial de leitura dos documentos.  
> Em caso de conflito, respeite a regra de precedência definida no índice.  
> Arquivos em `legacy/` devem ser tratados apenas como histórico e não como regra principal de implementação.

---

## 9. Objetivo prático desta organização

Esta estrutura foi criada para evitar:

- perda de contexto;
- leitura fora de ordem;
- conflito entre documentos antigos e atuais;
- reconstrução da arquitetura com nomes superados;
- interpretações erradas sobre `UI`, `App`, `Core`, `Services`, `Config` e `Types`.

A organização documental do RSign deve sempre priorizar:

- clareza;
- rastreabilidade;
- contexto único;
- continuidade segura da implementação.

---

## 10. Conclusão

Fica definido que:

- `00_INDICE_DOCS.md` é o ponto de entrada oficial da documentação;
- os documentos devem ser lidos na ordem numérica estabelecida;
- a decisão `View -> App` é obrigatória antes da leitura da arquitetura;
- arquivos em `legacy/` são apenas históricos;
- a documentação da raiz de `docs` é a base oficial da implementação atual do projeto **RSign**.
