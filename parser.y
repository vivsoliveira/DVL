%{
/* Prologue */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* utilitários para strings (AST textual) */
static char *sdup_local(const char *s) {
    if (!s) return NULL;
    size_t n = strlen(s);
    char *r = (char*)malloc(n+1);
    memcpy(r, s, n+1);
    return r;
}

static char *concat_space(const char *a, const char *b) {
    if (!a) return sdup_local(b?b:"");
    if (!b) return sdup_local(a);
    size_t la = strlen(a), lb = strlen(b);
    char *r = (char*)malloc(la + 1 + lb + 1);
    snprintf(r, la+1+lb+1, "%s %s", a, b);
    return r;
}

static char *wrap_tag(const char *tag, const char *content) {
    if (!content) {
        char *r = (char*)malloc(strlen(tag)+4);
        snprintf(r, strlen(tag)+4, "(%s)", tag);
        return r;
    }
    size_t lt = strlen(tag), lc = strlen(content);
    char *r = (char*)malloc(lt + 2 + 1 + lc + 1);
    snprintf(r, lt+2+1+lc+1, "(%s %s)", tag, content);
    return r;
}

static void safe_free(char *p){ if(p) free(p); }

%}

%union {
    char *str;
}

/* tokens com atributo string */
%token <str> ID INT_LIT FLOAT_LIT STR_LIT BOOL_LIT

/* palavras e símbolos (sem valor semântico no union) */
%token DECL VAL VAR REG SENSOR FUNCAO DATASET
%token SE SENAO ENQUANTO RETORNA MOSTRAR LER
%token TYPE_INT TYPE_FLOAT TYPE_BOOL TYPE_STRING TYPE_LISTA
%token NOT_WORD AND_WORD OR_WORD
%token PIPE
%token EQ NEQ LT GT LE GE
%token ASSIGN COLON END COMMA
%token OPEN_PAR CLOSE_PAR OPEN_BRACE CLOSE_BRACE OPEN_BRACK CLOSE_BRACK DOT HASH
%token PLUS MINUS MULT DIV MOD

%type <str> program units unit decl decl_variavel registrador_decl sensor_decl decl_funcao decl_dataset comando atribuicao mostrar ler_stmt retorno se_senao enquanto bloco item block_items
%type <str> expressao pipeline aplicacao membro operacao_binaria logico_ou logico_e igualdade relacional aditiva multiplicativa unaria primario lista lista_expressoes tabela campos_tabela campo_tabela chamada_estatistica expressao_or_lista acesso_coluna expr_list_opt expr_list lista_parametros lista_argumentos
%start program

/* precedence */
%left OR_WORD
%left AND_WORD
%left EQ NEQ
%left LT GT LE GE
%left PLUS MINUS
%left MULT DIV MOD
%left PIPE

%%

program:
    units
    {
        printf("PARSE_OK\n%s\n", $1 ? $1 : "(empty)");
        safe_free($1);
    }
;

units:
    /* empty */ { $$ = sdup_local("(units)"); }
  | units unit
    {
      char *comb = concat_space($1, $2);
      $$ = wrap_tag("units", comb);
      safe_free($1); safe_free($2); safe_free(comb);
    }
;

unit:
    decl    { $$ = $1; }
  | comando { $$ = $1; }
;

/* declarations */
decl:
    decl_variavel       { $$ = $1; }
  | registrador_decl   { $$ = $1; }
  | sensor_decl        { $$ = $1; }
  | decl_funcao        { $$ = $1; }
  | decl_dataset       { $$ = $1; }
;

decl_variavel:
    DECL VAL ID maybe_type ASSIGN expressao END
    {
      char *name = $3;
      char *typ  = $4 ? $4 : sdup_local("any");
      char *expr = $6 ? $6 : sdup_local("(none)");
      size_t need = strlen(name)+strlen(typ)+strlen(expr)+64;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(decl_val %s %s %s)", name, typ, expr);
      $$ = tmp;
      safe_free(name); if($4) safe_free($4); safe_free(expr);
    }
  | DECL VAR ID maybe_type ASSIGN expressao END
    {
      char *name = $3;
      char *typ  = $4 ? $4 : sdup_local("any");
      char *expr = $6 ? $6 : sdup_local("(none)");
      size_t need = strlen(name)+strlen(typ)+strlen(expr)+64;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(decl_var %s %s %s)", name, typ, expr);
      $$ = tmp;
      safe_free(name); if($4) safe_free($4); safe_free(expr);
    }
;

registrador_decl:
    REG VAL ID maybe_type ASSIGN expressao END
    {
      char *name = $3;
      char *typ  = $4 ? $4 : sdup_local("any");
      char *expr = $6 ? $6 : sdup_local("(none)");
      size_t need = strlen(name)+strlen(typ)+strlen(expr)+80;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(reg_val %s %s %s)", name, typ, expr);
      $$ = tmp;
      safe_free(name); if($4) safe_free($4); safe_free(expr);
    }
  | REG VAR ID maybe_type ASSIGN expressao END
    {
      char *name = $3;
      char *typ  = $4 ? $4 : sdup_local("any");
      char *expr = $6 ? $6 : sdup_local("(none)");
      size_t need = strlen(name)+strlen(typ)+strlen(expr)+80;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(reg_var %s %s %s)", name, typ, expr);
      $$ = tmp;
      safe_free(name); if($4) safe_free($4); safe_free(expr);
    }
;

sensor_decl:
    SENSOR ID COLON ID END
    {
      char *name = $2;
      char *typ  = $4;
      size_t need = strlen(name)+strlen(typ)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(sensor %s %s)", name, typ);
      $$ = tmp;
      safe_free(name); safe_free(typ);
    }
;

maybe_type:
    /* empty */ { $$ = NULL; }
  | COLON ID { $$ = $2; }
;

/* funcao */
decl_funcao:
    FUNCAO ID OPEN_PAR lista_parametros CLOSE_PAR bloco
    {
      size_t need = strlen($2)+strlen($4)+strlen($6)+64;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(func %s %s %s)", $2, $4, $6);
      $$ = tmp;
      safe_free($2); safe_free($4); safe_free($6);
    }
;

lista_parametros:
    /* empty */ { $$ = sdup_local("(params)"); }
  | ID { char *t = (char*)malloc(strlen($1)+16); snprintf(t, strlen($1)+16, "(params %s)", $1); $$ = t; safe_free($1); }
  | lista_parametros COMMA ID
    {
      char *comb = concat_space($1, $3);
      char *tmp = wrap_tag("params", comb);
      $$ = tmp;
      safe_free($1); safe_free($3); safe_free(comb);
    }
;

decl_dataset:
    DATASET STR_LIT OPEN_BRACE campos_tabela CLOSE_BRACE END
    {
      size_t need = strlen($2)+strlen($4)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(dataset \"%s\" %s)", $2, $4);
      $$ = tmp;
      safe_free($2); safe_free($4);
    }
;

/* comandos */
comando:
    atribuicao       { $$ = $1; }
  | mostrar          { $$ = $1; }
  | ler_stmt         { $$ = $1; }
  | se_senao         { $$ = $1; }
  | enquanto         { $$ = $1; }
  | retorno          { $$ = $1; }
  | bloco            { $$ = $1; }
  | expressao END
    {
      char *tmp = wrap_tag("expr_stmt", $1);
      $$ = tmp;
      safe_free($1);
    }
;

atribuicao:
    ID ASSIGN expressao END
    {
      size_t need = strlen($1)+strlen($3)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(assign %s %s)", $1, $3);
      $$ = tmp;
      safe_free($1); safe_free($3);
    }
;

mostrar:
    MOSTRAR OPEN_PAR expr_list_opt CLOSE_PAR END
    {
      size_t need = strlen($3)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(mostrar %s)", $3);
      $$ = tmp;
      safe_free($3);
    }
;

expr_list_opt:
    /* empty */ { $$ = sdup_local("(noargs)"); }
  | expr_list { $$ = $1; }
;

expr_list:
    expressao { char *t=(char*)malloc(strlen($1)+32); snprintf(t, strlen($1)+32, "(args %s)", $1); $$ = t; safe_free($1); }
  | expr_list COMMA expressao
    {
      char *comb = concat_space($1, $3);
      char *tmp = wrap_tag("args", comb);
      $$ = tmp; safe_free($1); safe_free($3); safe_free(comb);
    }
;

ler_stmt:
    ID ASSIGN LER OPEN_PAR CLOSE_PAR END
    {
      size_t need = strlen($1)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(ler %s)", $1);
      $$ = tmp;
      safe_free($1);
    }
;

retorno:
    RETORNA expressao END
    {
      size_t need = strlen($2)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(retorna %s)", $2);
      $$ = tmp;
      safe_free($2);
    }
;

se_senao:
    SE OPEN_PAR expressao CLOSE_PAR bloco maybe_else
    {
      char *e = $3 ? $3 : sdup_local("(cond)");
      char *b = $5 ? $5 : sdup_local("(then)");
      char *m = $6 ? $6 : sdup_local("(else)");
      size_t need = strlen(e)+strlen(b)+strlen(m)+64;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(if %s %s %s)", e, b, m);
      $$ = tmp;
      safe_free(e); safe_free(b); safe_free(m);
    }
;

maybe_else:
    /* empty */ { $$ = sdup_local("(noelse)"); }
  | SENAO bloco { $$ = $2; }
;

enquanto:
    ENQUANTO OPEN_PAR expressao CLOSE_PAR bloco
    {
      size_t need = strlen($3)+strlen($5)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(while %s %s)", $3, $5);
      $$ = tmp;
      safe_free($3); safe_free($5);
    }
;

bloco:
    OPEN_BRACE block_items CLOSE_BRACE
    {
      char *tmp = wrap_tag("block", $2);
      $$ = tmp;
      safe_free($2);
    }
;

block_items:
    /* empty */ { $$ = sdup_local("(empty)"); }
  | block_items item
    {
      char *comb = concat_space($1, $2);
      $$ = comb; safe_free($1); safe_free($2);
    }
;

item:
    decl    { $$ = $1; }
  | comando { $$ = $1; }
;

/* EXPRESSÕES */

expressao:
    pipeline { $$ = $1; }
;

pipeline:
    aplicacao { $$ = $1; }
  | pipeline PIPE aplicacao
    {
      size_t need = strlen($1)+strlen($3)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(pipe %s %s)", $1, $3);
      $$ = tmp; safe_free($1); safe_free($3);
    }
;

aplicacao:
    membro { $$ = $1; }
  | aplicacao OPEN_PAR lista_argumentos CLOSE_PAR
    {
      size_t need = strlen($1)+strlen($3)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(call %s %s)", $1, $3);
      $$ = tmp; safe_free($1); safe_free($3);
    }
;

lista_argumentos:
    /* empty */ { $$ = sdup_local("(noargs)"); }
  | expressao { char *t=(char*)malloc(strlen($1)+32); snprintf(t, strlen($1)+32, "(args %s)", $1); $$ = t; safe_free($1); }
  | lista_argumentos COMMA expressao
    {
      char *comb = concat_space($1, $3);
      char *tmp = wrap_tag("args", comb);
      $$ = tmp; safe_free($1); safe_free($3); safe_free(comb);
    }
;

membro:
    operacao_binaria { $$ = $1; }
;

operacao_binaria:
    logico_ou { $$ = $1; }
;

logico_ou:
    logico_e { $$ = $1; }
  | logico_ou OR_WORD logico_e
    {
      size_t need = strlen($1)+strlen($3)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(or %s %s)", $1, $3);
      $$ = tmp; safe_free($1); safe_free($3);
    }
;

logico_e:
    igualdade { $$ = $1; }
  | logico_e AND_WORD igualdade
    {
      size_t need = strlen($1)+strlen($3)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(and %s %s)", $1, $3);
      $$ = tmp; safe_free($1); safe_free($3);
    }
;

igualdade:
    relacional { $$ = $1; }
  | igualdade EQ relacional
    {
      size_t need = strlen($1)+strlen($3)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(eq %s %s)", $1, $3);
      $$ = tmp; safe_free($1); safe_free($3);
    }
  | igualdade NEQ relacional
    {
      size_t need = strlen($1)+strlen($3)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(neq %s %s)", $1, $3);
      $$ = tmp; safe_free($1); safe_free($3);
    }
;

relacional:
    aditiva { $$ = $1; }
  | relacional LT aditiva
    {
      size_t need = strlen($1)+strlen($3)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(lt %s %s)", $1, $3);
      $$ = tmp; safe_free($1); safe_free($3);
    }
  | relacional GT aditiva
    {
      size_t need = strlen($1)+strlen($3)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(gt %s %s)", $1, $3);
      $$ = tmp; safe_free($1); safe_free($3);
    }
  | relacional LE aditiva
    {
      size_t need = strlen($1)+strlen($3)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(le %s %s)", $1, $3);
      $$ = tmp; safe_free($1); safe_free($3);
    }
  | relacional GE aditiva
    {
      size_t need = strlen($1)+strlen($3)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(ge %s %s)", $1, $3);
      $$ = tmp; safe_free($1); safe_free($3);
    }
;

aditiva:
    multiplicativa { $$ = $1; }
  | aditiva PLUS multiplicativa
    {
      size_t need = strlen($1)+strlen($3)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(add %s %s)", $1, $3);
      $$ = tmp; safe_free($1); safe_free($3);
    }
  | aditiva MINUS multiplicativa
    {
      size_t need = strlen($1)+strlen($3)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(sub %s %s)", $1, $3);
      $$ = tmp; safe_free($1); safe_free($3);
    }
;

multiplicativa:
    unaria { $$ = $1; }
  | multiplicativa MULT unaria
    {
      size_t need = strlen($1)+strlen($3)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(mul %s %s)", $1, $3);
      $$ = tmp; safe_free($1); safe_free($3);
    }
  | multiplicativa DIV unaria
    {
      size_t need = strlen($1)+strlen($3)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(div %s %s)", $1, $3);
      $$ = tmp; safe_free($1); safe_free($3);
    }
  | multiplicativa MOD unaria
    {
      size_t need = strlen($1)+strlen($3)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(mod %s %s)", $1, $3);
      $$ = tmp; safe_free($1); safe_free($3);
    }
;

unaria:
    NOT_WORD unaria { size_t need = strlen($2)+32; char *tmp = (char*)malloc(need); snprintf(tmp, need, "(not %s)", $2); $$ = tmp; safe_free($2); }
  | PLUS unaria { $$ = $2; }
  | MINUS unaria { size_t need = strlen($2)+32; char *tmp = (char*)malloc(need); snprintf(tmp, need, "(neg %s)", $2); $$ = tmp; safe_free($2); }
  | primario { $$ = $1; }
;

primario:
    INT_LIT { size_t need = strlen($1)+16; char *tmp = (char*)malloc(need); snprintf(tmp, need, "(int %s)", $1); $$ = tmp; safe_free($1); }
  | FLOAT_LIT { size_t need = strlen($1)+20; char *tmp = (char*)malloc(need); snprintf(tmp, need, "(float %s)", $1); $$ = tmp; safe_free($1); }
  | STR_LIT { size_t need = strlen($1)+32; char *tmp = (char*)malloc(need); snprintf(tmp, need, "(str \"%s\")", $1); $$ = tmp; safe_free($1); }
  | BOOL_LIT { size_t need = strlen($1)+16; char *tmp = (char*)malloc(need); snprintf(tmp, need, "(bool %s)", $1); $$ = tmp; safe_free($1); }
  | ID { size_t need = strlen($1)+32; char *tmp = (char*)malloc(need); snprintf(tmp, need, "(id %s)", $1); $$ = tmp; safe_free($1); }
  | OPEN_PAR expressao CLOSE_PAR { $$ = $2; }
  | lista { $$ = $1; }
  | tabela { $$ = $1; }
  | chamada_estatistica { $$ = $1; }
  | acesso_coluna { $$ = $1; }
;

lista:
    OPEN_BRACK lista_expressoes CLOSE_BRACK
    {
      size_t need = strlen($2)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(list %s)", $2);
      $$ = tmp; safe_free($2);
    }
;

lista_expressoes:
    expressao { char *t=(char*)malloc(strlen($1)+32); snprintf(t, strlen($1)+32, "(listvals %s)", $1); $$ = t; safe_free($1); }
  | lista_expressoes COMMA expressao
    {
      char *comb = concat_space($1, $3);
      char *tmp = wrap_tag("listvals", comb);
      $$ = tmp; safe_free($1); safe_free($3); safe_free(comb);
    }
;

tabela:
    OPEN_BRACE campos_tabela CLOSE_BRACE
    {
      size_t need = strlen($2)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(table %s)", $2);
      $$ = tmp; safe_free($2);
    }
;

campos_tabela:
    campo_tabela { $$ = $1; }
  | campos_tabela COMMA campo_tabela
    {
      char *comb = concat_space($1, $3);
      char *tmp = wrap_tag("tablefields", comb);
      $$ = tmp; safe_free($1); safe_free($3); safe_free(comb);
    }
;

campo_tabela:
    ID COLON lista
    {
      size_t need = strlen($1)+strlen($3)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(tfield %s %s)", $1, $3);
      $$ = tmp; safe_free($1); safe_free($3);
    }
;

chamada_estatistica:
    HASH ID OPEN_PAR expressao_or_lista CLOSE_PAR
    {
      size_t need = strlen($2)+strlen($4)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(stat %s %s)", $2, $4);
      $$ = tmp; safe_free($2); safe_free($4);
    }
;

expressao_or_lista:
    expressao { $$ = $1; }
;

acesso_coluna:
    ID DOT ID
    {
      size_t need = strlen($1)+strlen($3)+32;
      char *tmp = (char*)malloc(need);
      snprintf(tmp, need, "(col %s %s)", $1, $3);
      $$ = tmp; safe_free($1); safe_free($3);
    }
;

%%

/* epilogue */
int yyerror(const char *s) {
    fprintf(stderr, "ERROR: %s\n", s);
    return 0;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <file.dvl>\n", argv[0]);
        return 1;
    }
    FILE *f = fopen(argv[1], "r");
    if (!f) { perror("fopen"); return 2; }
    yyin = f;
    yyparse();
    fclose(f);
    return 0;
}
