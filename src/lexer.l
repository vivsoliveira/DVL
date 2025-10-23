
%option noyywrap
%option yylineno
%option noinput
%option nounput
%option nodefault

%{
#include "parser.tab.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

static char* duptext(const char* s) {
	size_t n = strlen(s);
	char* p = (char*)malloc(n+1);
	if (!p) { fprintf(stderr, "mem error\n"); exit(1); }
	memcpy(p, s, n+1);
	return p;
}
%}

DIGIT [0-9]
INT {DIGIT}+
FLOAT {DIGIT}+"."{DIGIT}+
LETTER [A-Za-z]
ID {LETTER}({LETTER}|{DIGIT}|_)*
WS [ \t\r]+

%%

{WS}				{ /* ignore whitespace */ }
\n				{ /* newline */ }

"/*"([^*]|\*+[^*/])*\*+"/"	{ /* block comment */ }
"//"[^\n]*			{ /* line comment */ }

"#"{ID}				{
					yylval.sval = duptext(yytext + 1);
					return STAT_NAME;
				}

"decl"				{ return DECL; }
"val"				{ return VAL; }
"var"				{ return VAR; }
"reg"				{ return REG; }
"sensor"			{ return SENSOR; }
"funcao"			{ return FUNC; }
"retorna"			{ return RETORNA; }
"dataset"			{ return DATASET; }
"mostrar"			{ return MOSTRAR; }
"ler"				{ return LER; }
"se"				{ return SE; }
"senao"				{ return SENAO; }
"enquanto"			{ return ENQUANTO; }
"e"				{ return AND; }
"ou"				{ return OR; }
"nao"				{ return NOT; }

"int"				{ return INT_TYPE; }
"float"				{ return FLOAT_TYPE; }
"bool"				{ return BOOL_TYPE; }
"string"			{ return STRING_TYPE; }
"lista"				{ return LIST_TYPE; }

"&&"				{ return AND; }
"||"				{ return OR; }
"!"				{ return NOT; }

"=="				{ return EQ; }
"!="				{ return NE; }
"eh"				{ return EQ; }
"<="				{ return LE; }
">="				{ return GE; }
"<"				{ return LT; }
">"				{ return GT; }

"+"				{ return '+'; }
"-"				{ return '-'; }
"*"				{ return '*'; }
"/"				{ return '/'; }
"%"				{ return '%'; }

":="				{ return ASSIGN; }
"->>"				{ return PIPE; }
";"				{ return SEMI; }
","				{ return COMMA; }
":"				{ return COLON; }
"("				{ return LPAREN; }
")"				{ return RPAREN; }
"{"				{ return LBRACE; }
"}"				{ return RBRACE; }
"["				{ return LBRACKET; }
"]"				{ return RBRACKET; }
"."				{ return DOT; }

{FLOAT}				{
					yylval.fval = atof(yytext);
					return FLOAT_LITERAL;
				}

{INT}				{
					yylval.ival = atoi(yytext);
					return INT_LITERAL;
				}

\"([^\"\\\n]|\\.)*\"		{
					size_t n = yyleng;
					char* buf = (char*)malloc(n);
					if (!buf) { fprintf(stderr,"mem error\n"); exit(1); }
					size_t i, j;
					for (i = 1, j = 0; i < n-1; ++i, ++j) {
						if (yytext[i] == '\\' && i+1 < n-1) {
							++i;
							if (yytext[i] == 'n') buf[j] = '\n';
							else if (yytext[i] == 't') buf[j] = '\t';
							else buf[j] = yytext[i];
						} else {
							buf[j] = yytext[i];
						}
					}
					buf[j] = '\0';
					yylval.sval = buf;
					return STRING_LITERAL;
				}

{ID}				{
					yylval.sval = duptext(yytext);
					return IDENT;
				}

.				{
					fprintf(stderr, "Erro lexico na linha %d: '%s'\n", yylineno, yytext);
					return LEX_ERROR;
				}

%%
