
tinyC: lex.yy.c y.tab.c
	gcc lex.yy.c y.tab.c -o tinyC && ./tinyC
lex.yy.c: main.l
	flex main.l
y.tab.c: main.y
	yacc -vd main.y

.PHONY: open opencomplete

open: tinyC salida.txt
	less salida.txt
opencomplete: tinyC salida.txt
	less salidacompleta.txt

