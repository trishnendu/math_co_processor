 bison -d -v -Wno-other grammer.y && flex lexer.l && gcc -w lex.yy.c grammer.tab.c -o codegen