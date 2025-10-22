CC = gcc
CFLAGS = -O2 -Wall
LEX = flex
YACC = bison
TARGET = dvl_parser

all: $(TARGET)

parser.tab.c parser.tab.h: parser.y
	$(YACC) -d -v parser.y

lex.yy.c: lexer.l parser.tab.h
	$(LEX) lexer.l

$(TARGET): parser.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o $(TARGET) parser.tab.c lex.yy.c -lfl

clean:
	rm -f parser.tab.c parser.tab.h parser.output lex.yy.c $(TARGET) *.o

.PHONY: all clean
