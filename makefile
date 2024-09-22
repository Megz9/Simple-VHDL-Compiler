vhdl: lex.yy.c y.tab.c
	gcc -g lex.yy.c y.tab.c -o myvhdl

lex.yy.c: y.tab.c myvhdl.l
	lex myvhdl.l

y.tab.c: myvhdl.y
	yacc -d myvhdl.y

clean:
	rm -rf lex.yy.c y.tab.c y.tab.h myvhdl myvhdl.dSYM                                                    
