/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_SRC_PARSER_TAB_H_INCLUDED
# define YY_YY_SRC_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    DECL = 258,                    /* DECL  */
    VAL = 259,                     /* VAL  */
    VAR = 260,                     /* VAR  */
    REG = 261,                     /* REG  */
    SENSOR = 262,                  /* SENSOR  */
    FUNC = 263,                    /* FUNC  */
    RETORNA = 264,                 /* RETORNA  */
    DATASET = 265,                 /* DATASET  */
    MOSTRAR = 266,                 /* MOSTRAR  */
    LER = 267,                     /* LER  */
    SE = 268,                      /* SE  */
    SENAO = 269,                   /* SENAO  */
    ENQUANTO = 270,                /* ENQUANTO  */
    AND = 271,                     /* AND  */
    OR = 272,                      /* OR  */
    NOT = 273,                     /* NOT  */
    INT_TYPE = 274,                /* INT_TYPE  */
    FLOAT_TYPE = 275,              /* FLOAT_TYPE  */
    BOOL_TYPE = 276,               /* BOOL_TYPE  */
    STRING_TYPE = 277,             /* STRING_TYPE  */
    LIST_TYPE = 278,               /* LIST_TYPE  */
    EQ = 279,                      /* EQ  */
    NE = 280,                      /* NE  */
    LE = 281,                      /* LE  */
    GE = 282,                      /* GE  */
    LT = 283,                      /* LT  */
    GT = 284,                      /* GT  */
    ASSIGN = 285,                  /* ASSIGN  */
    PIPE = 286,                    /* PIPE  */
    SEMI = 287,                    /* SEMI  */
    COMMA = 288,                   /* COMMA  */
    COLON = 289,                   /* COLON  */
    LPAREN = 290,                  /* LPAREN  */
    RPAREN = 291,                  /* RPAREN  */
    LBRACE = 292,                  /* LBRACE  */
    RBRACE = 293,                  /* RBRACE  */
    LBRACKET = 294,                /* LBRACKET  */
    RBRACKET = 295,                /* RBRACKET  */
    DOT = 296,                     /* DOT  */
    INT_LITERAL = 297,             /* INT_LITERAL  */
    FLOAT_LITERAL = 298,           /* FLOAT_LITERAL  */
    STRING_LITERAL = 299,          /* STRING_LITERAL  */
    STAT_NAME = 300,               /* STAT_NAME  */
    IDENT = 301,                   /* IDENT  */
    LEX_ERROR = 302,               /* LEX_ERROR  */
    UMINUS = 303                   /* UMINUS  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 16 "src/parser.y"

  int    ival;
  double fval;
  char* sval;

#line 118 "src/parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_SRC_PARSER_TAB_H_INCLUDED  */
