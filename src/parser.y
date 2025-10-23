%define parse.error verbose
%expect 0

%{
  /* cabeçalhos e protótipos */
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  int yylex(void);
  void yyerror(const char *s);
  extern int yylineno;
%}

/* ----- valor semântico ----- */
%union {
  int    ival;
  double fval;
  char* sval;
}

/* ----- Tokens (deve refletir o lexer) ----- */
%token DECL VAL VAR
%token REG SENSOR
%token FUNC RETORNA
%token DATASET

%token MOSTRAR LER
%token SE SENAO ENQUANTO

%token AND OR NOT

%token INT_TYPE FLOAT_TYPE BOOL_TYPE STRING_TYPE LIST_TYPE

%token EQ NE LE GE LT GT
%token ASSIGN         /* := */
%token PIPE           /* ->> */

%token SEMI COMMA COLON
%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET DOT

%token <ival> INT_LITERAL
%token <fval> FLOAT_LITERAL
%token <sval> STRING_LITERAL

/* STATFUNC removido para simplificar e evitar R/R, STAT_NAME permanece */
%token <sval> STAT_NAME  /* e.g. #soma */

%token <sval> IDENT

%token LEX_ERROR

/* Precedência / associatividade para operadores binários e unários */
%left OR
%left AND
%left EQ NE
%left LT LE GT GE
%left '+' '-'
%left '*' '/' '%'
%right NOT
%right UMINUS   /* unary - */

%type <sval> identificador
%type <sval> expressao logico_ou logico_e igualdade relacional aditiva multiplicativa unaria
%type <sval> pipeline aplicacao primario

/* Tipos para as sub-regras de primario */
%type <sval> lista tabela chamada_estatistica

/* Tipos e unificação para as regras de lista */
%type <sval> opt_lista_generica_expressoes
%type <sval> lista_generica_expressoes

/* Tipos para campos_tabela */
%type <sval> campos_tabela campo_tabela

%start programa

%%

/* ----------------- programa ----------------- */
programa
  : unidades /* CORREÇÃO FINAL: Removida a regra vazia para programa */
  ;

unidades
  : /* empty */
  | unidades unidade
  ;

unidade
  : declaracao
  | comando
  ;

/* ----------------- declarações ----------------- */
declaracao
  : decl_variavel
  | decl_funcao
  | decl_dataset
  | registrador_decl
  | sensor_decl
  ;

decl_variavel
  : DECL VAL identificador opt_tipo ASSIGN expressao SEMI
    { /* definição de variável (stub) */ }
  | DECL VAR identificador opt_tipo ASSIGN expressao SEMI
    { /* definição de variável (stub) */ }
  ;

registrador_decl
  : REG VAL identificador opt_tipo ASSIGN expressao SEMI
    { /* registrador */ }
  | REG VAR identificador opt_tipo ASSIGN expressao SEMI
    { /* registrador */ }
  ;

sensor_decl
  : SENSOR identificador COLON tipo SEMI
    { /* sensor readonly */ }
  ;

opt_tipo
  : /* empty */ { }
  | COLON tipo { }
  ;

tipo
  : INT_TYPE
  | FLOAT_TYPE
  | BOOL_TYPE
  | STRING_TYPE
  | LIST_TYPE
  ;

/* função */
decl_funcao
  : FUNC identificador LPAREN opt_lista_parametros RPAREN bloco
    { /* função */ }
  ;

opt_lista_parametros
  : /* empty */
  | lista_parametros
  ;

lista_parametros
  : identificador
  | lista_parametros COMMA identificador
  ;

/* dataset */
decl_dataset
  : DATASET STRING_LITERAL LBRACE campos_dataset RBRACE SEMI
  ;

campos_dataset
  : campo_dataset
  | campos_dataset COMMA campo_dataset
  ;

campo_dataset
  : identificador COLON lista
  ;

/* ----------------- comandos ----------------- */
comando
  : atribuicao
  | mostrar
  | ler
  | se_senao
  | enquanto
  | retorno
  | bloco
  | expressao SEMI
  | error SEMI { fprintf(stderr, "Erro de sintaxe na linha %d. Recuperado.\n", yylineno); yyerrok; }
  ;

atribuicao
  : identificador ASSIGN expressao SEMI
  ;

mostrar
  : MOSTRAR LPAREN lista_generica_expressoes RPAREN SEMI
  ;

ler
  : identificador ASSIGN LER LPAREN RPAREN SEMI
  ;

retorno
  : RETORNA expressao SEMI
  ;

/* se / senao */
se_senao
  : SE LPAREN expressao RPAREN bloco opt_senao
  ;

opt_senao
  : /* empty */
  | SENAO bloco
  ;

enquanto
  : ENQUANTO LPAREN expressao RPAREN bloco
  ;

bloco
  : LBRACE bloco_conteudo RBRACE
  ;

bloco_conteudo
  : /* vazio */
  | bloco_conteudo_item_list
  ;

bloco_conteudo_item_list
  : bloco_conteudo_item
  | bloco_conteudo_item_list bloco_conteudo_item
  ;

bloco_conteudo_item
  : declaracao
  | comando
  ;

/* ----------------- expressões e precedência ----------------- */
expressao
  : logico_ou
  ;

logico_ou
  : logico_e
  | logico_ou OR logico_e
  ;

logico_e
  : igualdade
  | logico_e AND igualdade
  ;

igualdade
  : relacional
  | igualdade EQ relacional
  | igualdade NE relacional
  ;

relacional
  : aditiva
  | relacional LT aditiva
  | relacional GT aditiva
  | relacional LE aditiva
  | relacional GE aditiva
  ;

aditiva
  : multiplicativa
  | aditiva '+' multiplicativa
  | aditiva '-' multiplicativa
  ;

multiplicativa
  : unaria
  | multiplicativa '*' unaria
  | multiplicativa '/' unaria
  | multiplicativa '%' unaria
  ;

unaria
  : NOT unaria            { /* Ação padrão: $$ = $2; */ }
  | '-' unaria %prec UMINUS { /* Ação padrão: $$ = $2; */ }
  | pipeline
  ;

pipeline
  : aplicacao
  | pipeline PIPE aplicacao
  ;

aplicacao
  : primario
  | aplicacao LPAREN opt_lista_generica_expressoes RPAREN    /* Chamada de função */
  | aplicacao DOT IDENT                             /* Acesso: base.ident */
  ;

/* E ajuste as regras de uso: */
opt_lista_generica_expressoes
  : /* empty */ { $$ = NULL; }
  | expressao /* Novo caso para elemento único */
  | lista_generica_expressoes
  ;

lista_generica_expressoes: expressao COMMA expressao /* Novo caso base */
                         | lista_generica_expressoes COMMA expressao;

primario
  /* Ações explícitas para literais de número para evitar Type Clash com <sval> */
  : INT_LITERAL    { $$ = NULL; } 
  | FLOAT_LITERAL  { $$ = NULL; } 
  | STRING_LITERAL
  
  | identificador
  | LPAREN expressao RPAREN { $$ = $2; }
  | lista
  | tabela
  | chamada_estatistica
  ;

lista
  : LBRACKET opt_lista_generica_expressoes RBRACKET { $$ = $2; } /* Ação de cópia */
  ;

tabela
  : LBRACE campos_tabela RBRACE { $$ = $2; } /* Ação de cópia. campos_tabela é tipado. */
  ;
  
campos_tabela
  : campo_tabela
  | campos_tabela COMMA campo_tabela
  ;

campo_tabela
  : identificador COLON lista
  ;

/* Chamada estatística */
chamada_estatistica
  : STAT_NAME LPAREN opt_lista_generica_expressoes RPAREN { $$ = $3; } /* Ação de cópia */
  ;

/* identificador */
identificador
  : IDENT
  ;

/* lexical error token forwarded from lexer */
%%