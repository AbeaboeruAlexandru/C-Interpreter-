%{
#include <stdlib.h>
#include "proiect.h"
#include "proiect.tab.h"
void yyerror(char *);
%}

%%
[a-zA-Z] {
        yylval.sIndex = *yytext - 'A';
        return VARIABLE;
    }
    
0     {
        yylval.iValue = atoi(yytext);
        return INTEGER;
    }
    
[1-9][0-9]*    {
                yylval.iValue = atoi(yytext);
                return INTEGER;
            }

[0-9]+\.[0-9]+([eE][-+]?[0-9]+)? {
    yylval.fValue = atof(yytext);
    return FLOAT;
}

0[xX][0-9A-Fa-f]+     {
        yylval.iValue = strtol(yytext, NULL, 16);
        return INTEGER;
        }
        
0[0-7]+     {
        yylval.iValue = strtol(yytext, NULL, 8);
        return INTEGER;
        }

[1-9][0-9]*[uU] {
    yylval.iValue = strtoul(yytext, NULL, 10);
    return UNSIGNED_INTEGER;
}

[1-9][0-9]*[lL] {
    yylval.iValue = strtol(yytext, NULL, 10);
    return LONG_INTEGER;
}

[1-9][0-9]*[uU][lL] {
    yylval.iValue = strtoul(yytext, NULL, 10);
    return UNSIGNED_LONG_INTEGER;
}

[1-9][0-9]*[sS] {
    yylval.iValue = strtol(yytext, NULL, 10);
    return SHORT_INTEGER;
}

[1-9][0-9]*[uU][sS] {
    yylval.iValue = strtoul(yytext, NULL, 10);
    return UNSIGNED_SHORT_INTEGER;
}
                    
[-()<>=+*/;{}.]     {
                    return *yytext;
                }
                
","     {
        return *yytext;
        }

">="     return GE;
"<="     return LE;
"=="     return EQ;
"!="         return NE;
"++"     return INC;
"--"         return DEC;
"while"     return WHILE;
"if"         return IF;
"else"     return ELSE;
"write"     return WRITE;
"for"    return FOR; 
"+="     return PQ;
"-="     return MQ;
"*="     return MMQ;
"/="     return DQ;

[ \t\n]+     ; /* ignore whitespace */

\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/ ; /* ignora comentariile pe mai multe linii */

 "//"[^}\n]* ;    /* ignora comentariile pe o linie */
 
. yyerror("Unknown character");

%%

int yywrap(void) 
{
    return 1;
}