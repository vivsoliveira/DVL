# DVL - Data Visualization Language

**DVL** é uma linguagem de programação de alto nível criada para **análise de dados simples**, **estatísticas básicas** e **modelagem preditiva introdutória**.  
Inspirada em R e em linguagens funcionais de análise, o DVL foi projetado para ser **fácil de aprender**, com uma **sintaxe enxuta** e recursos essenciais para manipulação de dados em uma máquina virtual (VM) própria.

---

## Motivação

A criação do **DVL** surgiu da necessidade de uma linguagem:

- **Didática**: que sirva como exemplo acadêmico no estudo de compiladores.  
- **Simples**: evitando complexidade excessiva em análise de gráficos ou bibliotecas externas.  
- **Voltada a dados**: com suporte nativo para operações estatísticas e condicionais.  
- **Expansível**: permitindo no futuro a inclusão de gráficos comparativos e modelos preditivos mais avançados.

---

## Características Principais

- **Declaração de variáveis** com `var nome := valor .`  
- **Atribuição** usando `:=`  
- **Delimitação de instruções** com `.` (ponto final, no lugar do `;`)  
- **Condicionais** (`if/else`)  
- **Laços de repetição** (`loop`)  
- **Entrada e saída**:  
  - `read()` → lê um valor do usuário  
  - `print()` → exibe valores na tela  
- **Listas** entre colchetes: `[1, 2, 3]`  
- **Strings** entre aspas: `"Olá Mundo"`  
- **Comentários**:  
  - Linha única: `// exemplo`  
  - Bloco: `/* exemplo */`  
- **Definição de funções** com `func nome(parametros) { ... }`  
- **Retorno de valores** em funções com `return valor .`  
- **Operadores relacionais e lógicos**:  
  - Relacionais: `>`, `<`, `>=`, `<=`, `==`, `!=`  
  - Lógicos: `&&`, `||`, `!`  
- **Funções estatísticas nativas** prefixadas por `@`:  
  - `@mean(lista)`  
  - `@sum(lista)`  
  - `@min(lista)`  
  - `@max(lista)`
 
---

## Gramática (EBNF)

A gramática completa encontra-se no arquivo [`gramatica.ebnf`](./gramatica.ebnf).  

---

## Exemplo de Código

Há dois arquivos de exemplo de utilização de código que podem ser encontrados em [`exemplo_simplificado.dvl`](./exemplo_simplificado.dvl) e [`exemplo_avancado.dvl`](./exemplo_avancado.dvl).

---
