%{
#include<stdio.h>
#define YYDEBUG 1
extern FILE *yyin;
extern int yylineno;
extern char* yytext;
extern char printtype[][10]; 
int bufcnt;
FILE *fpout;
int tmpcnt;
%}

%union {
    struct t{
        char *place;
        char *code;
    } type;
}

%start DEBUG
%token LPAREN_TOK RPAREN_TOK
%token EQ_TOK MINUS_TOK PLUS_TOK MULT_TOK DIVIDE_TOK PLUS_EQ_TOK MINUS_EQ_TOK MULT_EQ_TOK DIVIDE_EQ_TOK SEMICOLON_TOK  
%token MINUS_MINUS_TOK PLUS_PLUS_TOK ERROR_TOK

%token<type> INTCONST
%token<type> ID_TOK

%left PLUS_TOK MINUS_TOK
%left MULT_TOK DIVIDE_TOK
%nonassoc UMINUS

%type<type> var exp0 exp2 exp block statement DEBUG
%%

DEBUG: block {  $$.code = (char *)0; concatcode(&$1.code, "end ",":)\n"); fprintf(fpout, "%s", $1.code);} 
    ;

block: block statement { $$.place = malloc(1); $$.place[0] = 0; $$.code = (char *)0; concatcode(&$$.code, $1.code, $2.code); }
    |  %empty {$$.code = malloc(1); $$.code[0] = 0;}

statement: exp SEMICOLON_TOK
    ;


exp: ID_TOK EQ_TOK exp2     {  $$.place = malloc(1); $$.place[0] = 0; addtocode(&$$.code, $1.code, $3.code, "=", $1.place, "", $3.place); }
    | ID_TOK PLUS_EQ_TOK exp2   {  $$.place = malloc(1); $$.place[0] = 0; addtocode(&$$.code, $1.code, $3.code, "+", $1.place, $3.place, $1.place); }
    | ID_TOK MINUS_EQ_TOK exp2  {  $$.place = malloc(1); $$.place[0] = 0; addtocode(&$$.code, $1.code, $3.code, "-", $1.place, $3.place, $1.place); }
    | ID_TOK MULT_EQ_TOK exp2   {  $$.place = malloc(1); $$.place[0] = 0; addtocode(&$$.code, $1.code, $3.code, "*", $1.place, $3.place, $1.place); }
    | ID_TOK DIVIDE_EQ_TOK exp2 {  $$.place = malloc(1); $$.place[0] = 0; addtocode(&$$.code, $1.code, $3.code, "/", $1.place, $3.place, $1.place); }
    | exp0
    ;

exp2: LPAREN_TOK exp2 RPAREN_TOK    {   $$ = $2; }
    | MINUS_TOK exp2 { addtmptoplace(&$$.place); addtocode(&$$.code, $2.code, "", "-", $$.place, "0", $2.place); } %prec UMINUS
    | exp2 PLUS_TOK exp2    {   addtmptoplace(&$$.place); addtocode(&$$.code, $1.code, $3.code, "+", $$.place, $1.place, $3.place); }
    | exp2 MINUS_TOK exp2   {   addtmptoplace(&$$.place); addtocode(&$$.code, $1.code, $3.code, "-", $$.place, $1.place, $3.place);  }
    | exp2 MULT_TOK exp2    {   addtmptoplace(&$$.place); addtocode(&$$.code, $1.code, $3.code, "*", $$.place, $1.place, $3.place);  }
    | exp2 DIVIDE_TOK exp2   {  addtmptoplace(&$$.place); addtocode(&$$.code, $1.code, $3.code, "/", $$.place, $1.place, $3.place); }
    | exp0
    | var
    ;

exp0: ID_TOK PLUS_PLUS_TOK  { addtoplace(&$$.place, $1.place);  addtocode(&$$.code, $1.code, "", "+",$1.place,"1",$1.place); } 
    | ID_TOK MINUS_MINUS_TOK    { addtoplace(&$$.place, $1.place);  addtocode(&$$.code, $1.code, "", "-",$1.place,"1",$1.place); }
    | PLUS_PLUS_TOK ID_TOK  { addtoplace(&$$.place, $2.place);  addtocode(&$$.code, $2.code, "", "+",$2.place,"1",$2.place); }
    | MINUS_MINUS_TOK ID_TOK    { addtoplace(&$$.place, $2.place); addtocode(&$$.code, $2.code, "", "-",$2.place,"1",$2.place); }
    ;

var: ID_TOK { $$ = $1;  }
    | INTCONST  { $$ = $1;}
    ;
   
%%

void addtmptoplace(char **dest){
    *dest = (char *)malloc(10);
    sprintf(*dest,"tmp%d",++tmpcnt);
}

void addtoplace(char **dest, const char *src){
    *dest = (char *)malloc(strlen(src)+1);
    strcpy(*dest, src);
}

void addtocode(char **dest, const char *code1, const char *code2, const char *op, const char *arg1, const char *arg2, const char *res){
    int l = 0;
    l = strlen(code1) + strlen(code2) + strlen(op) + strlen(arg1) + strlen(arg2) + strlen(res) + 4;
    *dest = (char *)malloc(l+1);
    *dest[0] = (char)0;
    
    strcat(*dest, code1);
    strcat(*dest, code2);
    sprintf(*dest,"%s%s,%s,%s,%s\n",*dest, op, arg1, arg2, res );
}

void concatcode(char **dest, const char *code1, const char *code2){
    int l = 0;
    if(*dest)   l = strlen(*dest);
    
    *dest = realloc(*dest, l+strlen(code1)+strlen(code2)+1); 
    
    if(l){  
        strcat(*dest, code1);
        strcat(*dest, code2);
    }else    sprintf(*dest,"%s%s", code1, code2);
    
}

void concat(char *dest, char *src){
    int l1, l2;
    l1 = strlen(dest);
    l2 = strlen(src);
    dest = malloc(l1 + l2 + 1);
    sprintf(dest,"%s%s", dest, src);
}


int main(int argc, char *argv[]){
    int token;
    yydebug = 0;
    if(argc != 2){
        yytext = stdin;      
    } else {
        yyin = fopen(argv[1], "r");
    }   
    fpout = fopen("threeaddresscode.txt","w");
    if(!yyparse());
        fprintf(stdout, "Total %d line parsed successfully :)\n", yylineno);
    fclose(yyin);
    //printhashtable();
    return 0;
}

void yyerror (char const *s) {
    fprintf(stderr, "%s!! @line no - %d:  @symbol '%s' :(  \n",s ,yylineno, yytext);
}