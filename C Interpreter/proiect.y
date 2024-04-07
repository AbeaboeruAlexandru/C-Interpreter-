%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <stdarg.h>
	#include "proiect.h"

	extern FILE* yyin;
	extern FILE* yyout;

	nodeType 	*opr(int oper, int nops, ...);
	nodeType 	*id(int i);
	nodeType 	*con(int value);
	void freeNode(nodeType *p);
	int ex(nodeType *p);
	int yylex(void);

	void yyerror(char *s);
	int sym[26]; 
%}

%union 	{
			int iValue; /* integer value */
			double dValue; /* integer value */
			float fValue; /* float value */
			char sIndex; /* symbol table index */
			nodeType *nPtr; /* node pointer */
		};


%token <iValue> INTEGER
%token <iValue> UNSIGNED_INTEGER
%token <iValue> LONG_INTEGER
%token <iValue> UNSIGNED_LONG_INTEGER
%token <iValue> SHORT_INTEGER
%token <iValue> UNSIGNED_SHORT_INTEGER
%token <sIndex> VARIABLE
%token <dValue> DOUBLE
%token <fValue> FLOAT
%token WHILE IF PRINT FOR WRITE
%nonassoc IFX
%nonassoc ELSE

%left GE LE EQ NE '>' '<' PQ MQ MMQ DQ
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS
%nonassoc INC
%nonassoc DEC
%left preINC preDEC
%right postINC postDEC

%type <nPtr> stmt expr stmt_list

%%

program:
		function { exit(0); }
		;
		
function:
		function stmt { ex($2); freeNode($2); }
		| /* NULL */
		;
		
stmt:
		';' { $$ = opr(';', 2, NULL, NULL); }
		| expr ';' { $$ = $1; }
		| expr ',' { $$ = $1; }
		| WRITE expr ';' { $$ = opr(WRITE, 1, $2); }
		| VARIABLE '=' expr ';' { $$ = opr('=', 2, id($1), $3); }
		| WHILE '(' expr ')' stmt { $$ = opr(WHILE, 2, $3, $5); }
		| FOR '(' stmt expr ';' expr ')' stmt { $$ = opr(FOR, 4, $3, $4, $6, $8); }
		| IF '(' expr ')' stmt %prec IFX { $$ = opr(IF, 2, $3, $5); }
		| IF '(' expr ')' stmt ELSE stmt { $$ = opr(IF, 3, $3, $5, $7); }
		| '{' stmt_list '}' { $$ = $2; }
		;
		
stmt_list:
		stmt { $$ = $1; }
		| stmt_list stmt { $$ = opr(';', 2, $1, $2); }
		;

expr:
		INTEGER { $$ = con($1); }
		| UNSIGNED_INTEGER { $$ = con($1); }
    	| LONG_INTEGER { $$ = con($1); }
   	 	| UNSIGNED_LONG_INTEGER { $$ = con($1); }
    	| SHORT_INTEGER { $$ = con($1); }
    	| UNSIGNED_SHORT_INTEGER { $$ = con($1); }
		| VARIABLE { $$ = id($1); }
		| '-' expr %prec UMINUS { $$ = opr(UMINUS, 1, $2); }
		| expr '+' expr { $$ = opr('+', 2, $1, $3); }
		| expr '-' expr { $$ = opr('-', 2, $1, $3); }
		| expr '*' expr { $$ = opr('*', 2, $1, $3); }
		| expr '/' expr { $$ = opr('/', 2, $1, $3); }
		| expr '<' expr { $$ = opr('<', 2, $1, $3); }
		| expr '>' expr { $$ = opr('>', 2, $1, $3); }
		| expr GE expr { $$ = opr(GE, 2, $1, $3); }
		| expr LE expr { $$ = opr(LE, 2, $1, $3); }
		| expr NE expr { $$ = opr(NE, 2, $1, $3); }
		| expr EQ expr { $$ = opr(EQ, 2, $1, $3); }
		| '(' expr ')' { $$ = $2; } 
		| INC expr {$$ = opr(preINC,1,$2);}
		| DEC expr {$$ = opr(preDEC,1,$2);}
		| expr INC {$$ = opr(postINC,1,$1);}
		| expr DEC {$$ = opr(postDEC,1,$1);}
		| expr PQ expr { $$ = opr(PQ, 2, $1, $3); }
		| expr MQ expr { $$ = opr(MQ, 2, $1, $3); }
		| expr MMQ expr { $$ = opr(MMQ, 2, $1, $3); }
		| expr DQ expr { $$ = opr(DQ, 2, $1, $3); }
		;
		
%%

nodeType *con(int value) 	{
						nodeType *p;
						
						/* allocate node */
						if ((p = malloc(sizeof(nodeType))) == NULL)
							yyerror("out of memory");
						
						/* copy information */
						p->type = typeCon;
						p->con.val = value;
						
						return p;
					}
					
nodeType *id(int i) 	{
					nodeType *p;
					
					/* allocate node */
					if ((p = malloc(sizeof(nodeType))) == NULL)
						yyerror("out of memory");
						
					/* copy information */
					p->type = typeId;
					p->id.i = i;
					
					return p;
				}
nodeType *opr(int oper, int nops, ...) {
								va_list ap;
								nodeType *p;
								int i;
								
								/* allocate node, extending op array */
								if ((p = malloc(sizeof(nodeType) + (nops-1) * sizeof(nodeType *))) ==NULL)
									yyerror("out of memory");
								
								/* copy information */
								p->type = typeOper;
								p->opr.oper = oper;
								p->opr.nops = nops;
								va_start(ap, nops);
								for (i = 0; i < nops; i++)
									p->opr.op[i] = va_arg(ap, nodeType*);
								va_end(ap);
								
								return p;
							}
							
void freeNode(nodeType *p) 	{
							int i;
							
							if (!p) return;
							if (p->type == typeOper) 
							{
								for (i = 0; i < p->opr.nops; i++)
								freeNode(p->opr.op[i]);
							}
							free (p);
						}
						
void yyerror(char *s) 	{
						fprintf(stdout, "%s\n", s);
					}
					
int main(int argc, char **argv) 
{
	if (argc == 3)
	{
		yyin = fopen(argv[1], "r");
		
		if(yyin == NULL)
		{ 
			printf("Eroare fisisier intrare\n");
		    return -1;
		}
		
		yyout = fopen(argv[2], "w");
		if(yyout == NULL) 
		{
		    printf("Eroare fisisier iesire\n");
		    return -2;
		}
	}
	else if (argc ==2)
	{
			printf("Argumente insuficiente\n");
		    return -1;
	}
	else
	{
		yyin = stdin;
	}

	yyparse();
	fclose(yyin);
	fclose(yyout);
	return 1;
}