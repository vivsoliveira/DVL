# DVL - Data Visualization Language

**DVL** é uma linguagem de programação de alto nível criada para **análise de dados simples**, **estatísticas básicas** e **modelagem preditiva introdutória**.  
Inspirada em R e em linguagens funcionais de análise, o DVL foi projetado para ser **fácil de aprender**, com uma **sintaxe enxuta** e recursos essenciais para manipulação de dados em uma máquina virtual (VM) própria.

---

## 🚀 Motivação

A criação do **DVL** surgiu da necessidade de uma linguagem:

- **Didática**: que sirva como exemplo acadêmico no estudo de compiladores.  
- **Simples**: evitando complexidade excessiva em análise de gráficos ou bibliotecas externas.  
- **Voltada a dados**: com suporte nativo para operações estatísticas e condicionais.  
- **Expansível**: permitindo no futuro a inclusão de gráficos comparativos e modelos preditivos mais avançados.

---

## Características Principais

- **Atribuição** com `:=`  
- **Delimitação de instruções** com `.` (ponto final, no lugar do `;`)  
- **Condicionais** (`if/else`)  
- **Laços de repetição** (`loop`)  
- **Entrada e saída**:  
  - `read()` → lê um valor do usuário  
  - `print()` → exibe valores na tela  
- **Operadores relacionais e lógicos**:  
  - Relacionais: `>`, `<`, `>=`, `<=`, `==`, `!=`  
  - Lógicos: `&&`, `||`, `!`  
- **Funções estatísticas nativas** prefixadas por `@`:  
  - `@mean(expr_list)`  
  - `@sum(expr_list)`  
  - `@min(expr_list)`  
  - `@max(expr_list)` 

---

## Gramática (EBNF)

A gramática completa encontra-se no arquivo [`grammar.ebnf`](./gramatica.ebnf).  
A seguir, um trecho resumido:

program = { statement } ;

statement = assignment | print_stmt | read_stmt | if_stmt | loop_stmt | block ;

assignment = identifier ":=" expression "." ;
print_stmt = "print" "(" expression ")" "." ;
read_stmt = identifier ":=" "read" "()" "." ;

if_stmt = "if" "(" expression ")" block [ "else" block ] ;
loop_stmt = "loop" "(" expression ")" block ;

block = "{" { statement } "}" ;

expression = logical_or ;

logical_or = logical_and { "||" logical_and } ;
logical_and = equality { "&&" equality } ;
equality = relational { ("==" | "!=") relational } ;
relational = additive { ("<" | ">" | "<=" | ">=") additive } ;
additive = multiplicative { ("+" | "-" ) multiplicative } ;
multiplicative= unary { ("*" | "/" | "%") unary } ;
unary = [ "!" | "-" ] primary ;

primary = number
| identifier
| "(" expression ")"
| stat_func ;

stat_func = ("@mean" | "@sum" | "@min" | "@max") "(" expr_list ")" ;
expr_list = expression { "," expression } ;

number = digit { digit } ;
identifier = letter { letter | digit | "_" } ;

digit = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
letter = "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j"
| "k" | "l" | "m" | "n" | "o" | "p" | "q" | "r" | "s" | "t"
| "u" | "v" | "w" | "x" | "y" | "z"
| "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J"
| "K" | "L" | "M" | "N" | "O" | "P" | "Q" | "R" | "S" | "T"
| "U" | "V" | "W" | "X" | "Y" | "Z" ;
---

## Exemplo de Código

```dvl
x := read().
y := 3.

if (x > y) {
  print(x).
} else {
  print(y).
}

n := 10.
print(@sum(x, y, n)).
print(@mean(x, y, n)).
```

## Iterações Futuras

Adicionar arrays e tabelas para manipulação de dados tabulares.

Ampliar as funções estatísticas nativas (@var, @median, @std).

Desenvolver a VM para rodar o código Assembly gerado.

Futuramente: incluir gráficos comparativos (@plot, @hist).
