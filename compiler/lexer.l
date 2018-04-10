%{
#include "grammer.tab.h"  
int lineno = 1;
%}
lalpha [a-z]
calpha [A-Z]
dgt [0-9]
%%
{dgt}+ {yylval.type.place = (char *)malloc(strlen(yytext)+1); 
		strcpy(yylval.type.place, yytext); 
		yylval.type.code = malloc(1); 
		yylval.type.code[0] = 0; 
		return INTCONST;}
[a-zA-Z_][a-zA-Z0-9_]* {yylval.type.place = (char *)malloc(strlen(yytext)+1); 
						strcpy(yylval.type.place, yytext); 
						yylval.type.code = malloc(1); 
						yylval.type.code[0] = 0; 
						return ID_TOK;}
"/*"([^*]|\*+[^*/])*"*/" {}
"+=" {return PLUS_EQ_TOK;}
"-=" {return MINUS_EQ_TOK;}
"*=" {return MULT_EQ_TOK;}
"/=" {return DIVIDE_EQ_TOK;}
";" {return SEMICOLON_TOK;}
"-" {return MINUS_TOK;}
"+" {return PLUS_TOK;}
"*" {return MULT_TOK;}
"/" {return DIVIDE_TOK;}
"(" {return LPAREN_TOK;}
")" {return RPAREN_TOK;}
"=" {return EQ_TOK;}
"\n" {yylineno++;}
[ \t\n] ;
%%

int yywrap(){
    return 1;
}