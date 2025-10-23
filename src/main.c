#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h"

extern int yylineno;
extern int yylex(void);

void yyerror(const char *s) {
  if (s)
    fprintf(stderr, "Erro sintatico: %s (linha %d)\n", s, yylineno);
  else
    fprintf(stderr, "Erro sintatico na linha %d\n", yylineno);
}

int main(int argc, char **argv) {
  (void)argc;
  (void)argv;
  
  int rc = yyparse();
  if (rc == 0) {
    printf("Parsed OK\n");
    return 0;
  } else {
    fprintf(stderr, "Parsing falhou (codigo %d)\n", rc);
    return 1;
  }
}