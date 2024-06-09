CC=gcc
CFLAGS=-Wall -Wextra -std=c99
LIBS=-lm

.PHONY: all clean run

all: compilador

compilador: lex.yy.c sin.tab.c
	$(CC) $(CFLAGS) -o run lex.yy.c sin.tab.c $(LIBS)

lex.yy.c: lex.l
	flex $<

sin.tab.c: sin.y
	bison -d $<

clean:
	rm -f run.exe lex.yy.c sin.tab.c sin.tab.h output.py

run:
	./run < testeos/test1.c
