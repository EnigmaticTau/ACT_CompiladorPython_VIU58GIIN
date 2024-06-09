%{
#include "sin.tab.h"
extern FILE *yyin;
%}

%%

"for"          { return FOR; }
"while"        { return WHILE; }
"if"           { return IF; }
"else"         { return ELSE; }
"print"        { return PRINT; }
"("            { return LPAREN; }
")"            { return RPAREN; }
"{"            { return LBRACE; }
"}"            { return RBRACE; }
";"            { return SEMICOLON; }
"="            { return ASSIGN; }
"=="           { return EQ; }
"<"            { return LT; }         
">"            { return GT; }         
"+"            { return PLUS; }
"-"            { return MINUS; }
"*"            { return TIMES; }
"/"            { return DIVIDE; }
[0-9]+         { yylval.intval = atoi(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]*  { yylval.strval = strdup(yytext); return IDENTIFIER; }
[ \t\n]        { /* Ignore whitespace */ }
.              { /* Catch all other characters */ }

%%

int yywrap() {
    return 1;
}
