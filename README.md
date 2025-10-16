# DVL - Data Visualization Language

**DVL** é uma linguagem de programação de alto nível criada para **análise de dados simples**, **estatísticas básicas** e **modelagem preditiva introdutória**.
Inspirada em R e em linguagens funcionais de análise, o DVL foi projetado para ser **fácil de aprender**, com uma **sintaxe enxuta** e recursos essenciais para manipulação de dados em uma máquina virtual (VM) própria.

---

## Motivação

A criação do **DVL** surgiu da necessidade de uma linguagem:

* **Didática**: que sirva como exemplo acadêmico no estudo de compiladores.
* **Simples**: evitando complexidade excessiva em análise de gráficos ou bibliotecas externas.
* **Voltada a dados**: com suporte nativo para operações estatísticas e condicionais.
* **Expansível**: permitindo no futuro a inclusão de gráficos comparativos e modelos preditivos mais avançados.

---

## Características Principais

* **Declarações explícitas** com `decl val` (imutável) ou `decl var` (mutável).
* **Tipos opcionais** em variáveis: `int`, `float`, `bool`, `string`, `lista`.
* **Delimitação de instruções** com `;` (ponto e vírgula, padrão das linguagens estruturadas).
* **Condicionais** (`se` / `senao`).
* **Laços de repetição** (`enquanto`).
* **Entrada e saída**:

  * `ler()` → lê um valor do usuário.
  * `mostrar()` → exibe valores na tela.
* **Coleções**:

  * Listas: `[1, 2, 3]`.
  * Datasets tabulares:

    ```dvl
    dataset "vendas" { dia: [1,2,3], valor: [100,200,300] };
    ```

    Acesso direto a colunas: `vendas.valor`.
* **Funções estatísticas nativas** prefixadas por `#`:

  * `#soma(lista)`
  * `#media(lista)`
  * `#minimo(lista)`
  * `#maximo(lista)`
* **Encadeamento de operações** com o operador de pipeline `->>`:

  ```dvl
  vendas.valor ->> #media ;
  ```
* **Definição de funções** com `funcao nome(parametros) { ... }`.
* **Retorno de valores** em funções com `retorna valor ;`.
* **Comentários**:

  * Linha única: `# exemplo` ou `// exemplo`.
  * Bloco: `/* exemplo */`.

---

## Gramática (EBNF)

A gramática completa encontra-se no arquivo [`gramatica_atualizada.ebnf`](./gramatica_atualizada.ebnf).

---

## Exemplo de Código

Há dois arquivos de exemplo de utilização de código que podem ser encontrados em [`exemplo_simplificado.dvl`](./exemplo_simplificado.dvl) e [`exemplo_avancado.dvl`](./exemplo_avancado.dvl).

---

## Diferenciais

O DVL não busca competir com linguagens como Python, R ou C, mas sim oferecer uma alternativa **didática e simplificada**, voltada para **análise de dados em contextos acadêmicos e experimentais**.
Entre os principais diferenciais, destacam-se:

**Sintaxe minimalista e em português:**

* Uso de `;` para encerrar instruções.
* Palavras-chave claras e acessíveis: `se`, `senao`, `enquanto`, `mostrar`, `ler`.
* Declarações explícitas com `decl val` e `decl var`.

**Funções estatísticas nativas:**

* `#media`, `#soma`, `#minimo`, `#maximo` incorporadas diretamente à linguagem.
* Podem operar sobre listas ou colunas de datasets sem importações externas.

**Identidade própria:**

* Comentários em três estilos (`#`, `//`, `/* ... */`).
* Suporte a `dataset` nativo com acesso direto por coluna (`dados.coluna`).
* Operador de pipeline `->>` exclusivo, para encadear transformações de dados.
* Funções definidas pelo usuário com retorno explícito.

Em resumo, o DVL é uma linguagem feita para **aprender, ensinar e explorar conceitos de compiladores e análise de dados**, com uma **sintaxe original, legível e coerente com o português técnico**.

---

## Mudanças Realizadas nesta Versão

| Categoria                    | Antes                                           | Agora                                                    |
| ---------------------------- | ----------------------------------------------- | -------------------------------------------------------- |
| **Terminador de instruções** | `.` (ponto)                                     | `;` (padrão mais legível)                                |
| **Palavras-chave**           | Inglês (`if`, `else`, `while`, `print`, `read`) | Português (`se`, `senao`, `enquanto`, `mostrar`, `ler`)  |
| **Declarações**              | `var nome := valor`                             | `decl val` (imutável) / `decl var` (mutável)             |
| **Coleções**                 | Somente listas                                  | Listas e `dataset` tabulares com colunas acessíveis      |
| **Funções estatísticas**     | Prefixadas com `@`                              | Prefixadas com `#`                                       |
| **Pipeline**                 | Não existia                                     | `->>` para encadear cálculos e filtros                   |
| **Comentários**              | `//` e `/*...*/`                                | `#`, `//`, e `/*...*/`                                   |
| **Sintaxe geral**            | Tradução de linguagens como R/C                 | Sintaxe original em português e sem equivalentes diretos |
