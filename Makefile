# Makefile para projeto DVL (Flex + Bison)
CC      := gcc
CFLAGS  := -O2 -Wall -Wextra
LEX     := flex
YACC    := bison
LEX_SRC := src/lexer.l
YACC_SRC:= src/parser.y
LEX_OUT := src/lex.yy.c
YACC_OUT:= src/parser.tab.c
YACC_H  := src/parser.tab.h
BIN     := dvl
SRCS    := src/main.c $(YACC_OUT) $(LEX_OUT)
LDFLAGS := -lfl

.PHONY: all clean test

all: $(BIN)

# regra principal para gerar executável
$(BIN): $(SRCS)
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^) $(LDFLAGS)

# gera parser (bison) — produz .c e .h
$(YACC_OUT) $(YACC_H): $(YACC_SRC)
	$(YACC) -d -v -o $(YACC_OUT) $(YACC_SRC)

# gera lexer (flex) — depende do header do parser para tokens
$(LEX_OUT): $(LEX_SRC) $(YACC_H)
	$(LEX) -o $(LEX_OUT) $(LEX_SRC)

# alvos úteis de desenvolvimento
clean:
	rm -f $(BIN) $(YACC_OUT) $(YACC_H) $(LEX_OUT) *.output src/*.output

# executa o parser lendo de stdin (útil para testar)
run:
	@echo "Executando $(BIN) — leia do stdin (Ctrl+D para terminar)"
	./$(BIN)

# exemplo de teste (se houver arquivo de exemplo em examples/)
test: all
	@if [ -f examples/demo.dvl ]; then \
	  ./$(BIN) < examples/demo.dvl; \
	else \
	  echo "Sem examples/demo.dvl — coloque um arquivo de teste em examples/"; \
	fi
