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

    %token <str> ID INT_LIT FLOAT_LIT STR_LIT BOOL_LIT

    %token DECL VAL VAR FUNCAO DATASET
    %token SE SENAO ENQUANTO RETORNA MOSTRAR LER
    %token REG SENSOR
    %token OR_WORD AND_WORD NOT_WORD
    %token PIPE
    %token EQ NEQ LT GT LE GE
    %token ASSIGN COLON END COMMA
    %token OPEN_PAR CLOSE_PAR OPEN_BRACE CLOSE_BRACE OPEN_BRACK CLOSE_BRACK DOT HASH
    %token PLUS MINUS MULT DIV MOD

%type <str> program units unit decl decl_variavel registrador_decl sensor_decl decl_funcao decl_dataset comando atribuicao mostrar ler_stmt retorno se_senao enquanto bloco item block_items
%type <str> expressao pipeline aplicacao membro operacao_binaria logico_ou logico_e igualdade relacional aditiva multiplicativa unaria primario lista lista_expressoes tabela campos_tabela campo_tabela chamada_estatistica expressao_or_lista acesso_coluna maybe_type expr_list_opt expr_list maybe_else lista_parametros lista_argumentos
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
        char *name = $3; // ID agora é $3, não $4
        char *typ = $4? $4 : sdup_local("any"); // maybe_type agora é $4, não $5
        char *expr = $6; // expressao agora é $6, não $7
        char *tmp = (char*)malloc(strlen(name)+strlen(typ)+strlen(expr)+64);
        snprintf(tmp, strlen(name)+strlen(typ)+strlen(expr)+64, "(decl_val %s %s %s)", name, typ, expr); // Ajuste o TAG para 'decl_val'
        $$ = tmp;
        safe_free(name); if($4) safe_free($4); safe_free(expr);
        }
    | DECL VAR ID maybe_type ASSIGN expressao END
        {
        char *name = $3;
        char *typ = $4? $4 : sdup_local("any");
        char *expr = $6;
        char *tmp = (char*)malloc(strlen(name)+strlen(typ)+strlen(expr)+64);
        snprintf(tmp, strlen(name)+strlen(typ)+strlen(expr)+64, "(decl_var %s %s %s)", name, typ, expr); // Ajuste o TAG para 'decl_var'
        $$ = tmp;
        safe_free(name); if($4) safe_free($4); safe_free(expr);
        }
    ;

    registrador_decl:
        REG VAL ID maybe_type ASSIGN expressao END
        {
        char *name = $3; // ID agora é $3
        char *typ = $4? $4 : sdup_local("any"); // maybe_type agora é $4
        char *expr = $6; // expressao agora é $6
        char *tmp = (char*)malloc(strlen(name)+strlen(typ)+strlen(expr)+80);
        snprintf(tmp, strlen(name)+strlen(typ)+strlen(expr)+80, "(reg_val %s %s %s)", name, typ, expr); // Ajuste o TAG para 'reg_val'
        $$ = tmp;
        safe_free(name); if($4) safe_free($4); safe_free(expr);
        }
    | REG VAR ID maybe_type ASSIGN expressao END
        {
        char *name = $3;
        char *typ = $4? $4 : sdup_local("any");
        char *expr = $6;
        char *tmp = (char*)malloc(strlen(name)+strlen(typ)+strlen(expr)+80);
        snprintf(tmp, strlen(name)+strlen(typ)+strlen(expr)+80, "(reg_var %s %s %s)", name, typ, expr); // Ajuste o TAG para 'reg_var'
        $$ = tmp;
        safe_free(name); if($4) safe_free($4); safe_free(expr);
        }
    ;
    
    sensor_decl:
        SENSOR ID COLON ID END
        {
        char *name = $2;
        char *typ = $4;
        char *tmp = (char*)malloc(strlen(name)+strlen(typ)+32);
        snprintf(tmp, strlen(name)+strlen(typ)+32, "(sensor %s %s)", name, typ);
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
        char *tmp = (char*)malloc(strlen($2)+strlen($4)+strlen($6)+64);
        snprintf(tmp, strlen($2)+strlen($4)+strlen($6)+64, "(func %s %s %s)", $2, $4, $6);
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
        char *tmp = (char*)malloc(strlen($2)+strlen($4)+32);
        snprintf(tmp, strlen($2)+strlen($4)+32, "(dataset \"%s\" %s)", $2, $4);
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
        char *tmp = (char*)malloc(strlen($1)+strlen($3)+32);
        snprintf(tmp, strlen($1)+strlen($3)+32, "(assign %s %s)", $1, $3);
        $$ = tmp;
        safe_free($1); safe_free($3);
        }
    ;

    mostrar:
        MOSTRAR OPEN_PAR expr_list_opt CLOSE_PAR END
        {
        char *tmp = (char*)malloc(strlen($3)+32);
        snprintf(tmp, strlen($3)+32, "(mostrar %s)", $3);
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
        char *tmp = (char*)malloc(strlen($1)+32);
        snprintf(tmp, strlen($1)+32, "(ler %s)", $1);
        $$ = tmp;
        safe_free($1);
        }
    ;

    retorno:
        RETORNA expressao END
        {
        char *tmp = (char*)malloc(strlen($2)+32);
        snprintf(tmp, strlen($2)+32, "(retorna %s)", $2);
        $$ = tmp;
        safe_free($2);
        }
    ;

    se_senao:
        SE OPEN_PAR expressao CLOSE_PAR bloco maybe_else
        {
        char *tmp = (char*)malloc(strlen($3)+strlen($5)+strlen($6)+64); // $3=expr, $5=bloco_if, $6=maybe_else
        snprintf(tmp, strlen(tmp), "(if %s %s %s)", $3, $5, $6);
        $$ = tmp;
        safe_free($3); safe_free($5); safe_free($6); // Liberando $5 e $6
        }
    ;

    maybe_else:
        /* empty */ { $$ = sdup_local("(noelse)"); }
    | SENAO bloco { $$ = $2; }
    ;


    enquanto:
        ENQUANTO OPEN_PAR expressao CLOSE_PAR bloco
        {
        char *tmp = (char*)malloc(strlen($3)+strlen($5)+32);
        snprintf(tmp, strlen($3)+strlen($5)+32, "(while %s %s)", $3, $5);
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
        char *tmp = (char*)malloc(strlen($1)+strlen($3)+32);
        snprintf(tmp, strlen($1)+strlen($3)+32, "(pipe %s %s)", $1, $3);
        $$ = tmp; safe_free($1); safe_free($3);
        }
    ;

    aplicacao:
        membro { $$ = $1; }
    | aplicacao OPEN_PAR lista_argumentos CLOSE_PAR
        {
        char *tmp = (char*)malloc(strlen($1)+strlen($3)+32);
        snprintf(tmp, strlen($1)+strlen($3)+32, "(call %s %s)", $1, $3);
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
        char *tmp = (char*)malloc(strlen($1)+strlen($3)+32);
        snprintf(tmp, strlen($1)+strlen($3)+32, "(or %s %s)", $1, $3);
        $$ = tmp; safe_free($1); safe_free($3);
        }
    ;

    logico_e:
        igualdade { $$ = $1; }
    | logico_e AND_WORD igualdade
        {
        char *tmp = (char*)malloc(strlen($1)+strlen($3)+32);
        snprintf(tmp, strlen($1)+strlen($3)+32, "(and %s %s)", $1, $3);
        $$ = tmp; safe_free($1); safe_free($3);
        }
    ;

    igualdade:
        relacional { $$ = $1; }
    | igualdade EQ relacional
        {
            char *tmp = (char*)malloc(strlen($1)+strlen($3)+32);
            snprintf(tmp, strlen($1)+strlen($3)+32, "(eq %s %s)", $1, $3);
            $$ = tmp; safe_free($1); safe_free($3);
        }
    | igualdade NEQ relacional
        {
            char *tmp = (char*)malloc(strlen($1)+strlen($3)+32);
            snprintf(tmp, strlen($1)+strlen($3)+32, "(neq %s %s)", $1, $3);
            $$ = tmp; safe_free($1); safe_free($3);
        }
    ;

    relacional:
        aditiva { $$ = $1; }
    | relacional LT aditiva
        {
        char *tmp = (char*)malloc(strlen($1)+strlen($3)+32);
        snprintf(tmp, strlen($1)+strlen($3)+32, "(lt %s %s)", $1, $3);
        $$ = tmp; safe_free($1); safe_free($3);
        }
    | relacional GT aditiva
        {
        char *tmp = (char*)malloc(strlen($1)+strlen($3)+32);
        snprintf(tmp, strlen($1)+strlen($3)+32, "(gt %s %s)", $1, $3);
        $$ = tmp; safe_free($1); safe_free($3);
        }
    | relacional LE aditiva
        {
        char *tmp = (char*)malloc(strlen($1)+strlen($3)+32);
        snprintf(tmp, strlen($1)+strlen($3)+32, "(le %s %s)", $1, $3);
        $$ = tmp; safe_free($1); safe_free($3);
        }
    | relacional GE aditiva
        {
        char *tmp = (char*)malloc(strlen($1)+strlen($3)+32);
        snprintf(tmp, strlen($1)+strlen($3)+32, "(ge %s %s)", $1, $3);
        $$ = tmp; safe_free($1); safe_free($3);
        }
    ;

    aditiva:
        multiplicativa { $$ = $1; }
    | aditiva PLUS multiplicativa
        {
        char *tmp = (char*)malloc(strlen($1)+strlen($3)+32);
        snprintf(tmp, strlen($1)+strlen($3)+32, "(add %s %s)", $1, $3);
        $$ = tmp; safe_free($1); safe_free($3);
        }
    | aditiva MINUS multiplicativa
        {
        char *tmp = (char*)malloc(strlen($1)+strlen($3)+32);
        snprintf(tmp, strlen($1)+strlen($3)+32, "(sub %s %s)", $1, $3);
        $$ = tmp; safe_free($1); safe_free($3);
        }
    ;

    multiplicativa:
        unaria { $$ = $1; }
    | multiplicativa MULT unaria
        {
        char *tmp = (char*)malloc(strlen($1)+strlen($3)+32);
        snprintf(tmp, strlen($1)+strlen($3)+32, "(mul %s %s)", $1, $3);
        $$ = tmp; safe_free($1); safe_free($3);
        }
    | multiplicativa DIV unaria
        {
        char *tmp = (char*)malloc(strlen($1)+strlen($3)+32);
        snprintf(tmp, strlen($1)+strlen($3)+32, "(div %s %s)", $1, $3);
        $$ = tmp; safe_free($1); safe_free($3);
        }
    | multiplicativa MOD unaria
        {
        char *tmp = (char*)malloc(strlen($1)+strlen($3)+32);
        snprintf(tmp, strlen($1)+strlen($3)+32, "(mod %s %s)", $1, $3);
        $$ = tmp; safe_free($1); safe_free($3);
        }
    ;

    unaria:
        NOT_WORD unaria { char *tmp = (char*)malloc(strlen($2)+32); snprintf(tmp, strlen($2)+32, "(not %s)", $2); $$ = tmp; safe_free($2); }
    | PLUS unaria { $$ = $2; }
    | MINUS unaria { char *tmp = (char*)malloc(strlen($2)+32); snprintf(tmp, strlen($2)+32, "(neg %s)", $2); $$ = tmp; safe_free($2); }
    | primario { $$ = $1; }
    ;

    primario:
        INT_LIT { char *tmp = (char*)malloc(strlen($1)+16); snprintf(tmp, strlen($1)+16, "(int %s)", $1); $$ = tmp; safe_free($1); }
    | FLOAT_LIT { char *tmp = (char*)malloc(strlen($1)+20); snprintf(tmp, strlen($1)+20, "(float %s)", $1); $$ = tmp; safe_free($1); }
    | STR_LIT { char *tmp = (char*)malloc(strlen($1)+32); snprintf(tmp, strlen($1)+32, "(str \"%s\")", $1); $$ = tmp; safe_free($1); }
    | BOOL_LIT { char *tmp = (char*)malloc(strlen($1)+16); snprintf(tmp, strlen($1)+16, "(bool %s)", $1); $$ = tmp; safe_free($1); }
    | ID { char *tmp = (char*)malloc(strlen($1)+32); snprintf(tmp, strlen($1)+32, "(id %s)", $1); $$ = tmp; safe_free($1); }
    | OPEN_PAR expressao CLOSE_PAR { $$ = $2; }
    | lista { $$ = $1; }
    | tabela { $$ = $1; }
    | chamada_estatistica { $$ = $1; }
    | acesso_coluna { $$ = $1; }
    ;

    lista:
        OPEN_BRACK lista_expressoes CLOSE_BRACK
        {
        char *tmp = (char*)malloc(strlen($2)+32);
        snprintf(tmp, strlen($2)+32, "(list %s)", $2);
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
        char *tmp = (char*)malloc(strlen($2)+32);
        snprintf(tmp, strlen($2)+32, "(table %s)", $2);
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
        char *tmp = (char*)malloc(strlen($1)+strlen($3)+32);
        snprintf(tmp, strlen($1)+strlen($3)+32, "(tfield %s %s)", $1, $3);
        $$ = tmp; safe_free($1); safe_free($3);
        }
    ;

    chamada_estatistica:
        HASH ID OPEN_PAR expressao_or_lista CLOSE_PAR
        {
        char *tmp = (char*)malloc(strlen($2)+strlen($4)+32);
        snprintf(tmp, strlen($2)+strlen($4)+32, "(stat %s %s)", $2, $4);
        $$ = tmp; safe_free($2); safe_free($4);
        }
    ;

    expressao_or_lista:
        expressao { $$ = $1; }
    ;

    acesso_coluna:
        ID DOT ID
        {
        char *tmp = (char*)malloc(strlen($1)+strlen($3)+32);
        snprintf(tmp, strlen($1)+strlen($3)+32, "(col %s %s)", $1, $3);
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
