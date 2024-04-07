#include <stdio.h>
#include "proiect.h"
#include "proiect.tab.h"
#include<ctype.h>

extern FILE *yyout;

int ex(nodeType *p) {
	if (!p) return 0;
	switch(p->type) {
		case typeCon: return p->con.val;
		case typeId: return sym[p->id.i];
		case typeOper:
		switch(p->opr.oper) {
			case FOR:
			for(ex(p->opr.op[0]); ex(p->opr.op[1]); ex(p->opr.op[2]))
				ex(p->opr.op[3]);
				return 0;
			case WHILE: while(ex(p->opr.op[0])) ex(p->opr.op[1]); return 0;
			case IF: if (ex(p->opr.op[0]))
			ex(p->opr.op[1]);
			else if (p->opr.nops > 2)
			ex(p->opr.op[2]);
			return 0;
			case WRITE: fprintf(yyout,"%d\n", ex(p->opr.op[0])); return 0;
			case ';': ex(p->opr.op[0]); return ex(p->opr.op[1]);
			case '=': return sym[p->opr.op[0]->id.i] = ex(p->opr.op[1]);
			case ',': ex(p->opr.op[0]); return ex(p->opr.op[1]);
			case UMINUS: return -ex(p->opr.op[0]);
			case '+': return ex(p->opr.op[0]) + ex(p->opr.op[1]);
			case '-': return ex(p->opr.op[0]) - ex(p->opr.op[1]);
			case '*': return ex(p->opr.op[0]) * ex(p->opr.op[1]);
			case '/': return ex(p->opr.op[0]) / ex(p->opr.op[1]);
			case '<': return ex(p->opr.op[0]) < ex(p->opr.op[1]);
			case '>': return ex(p->opr.op[0]) > ex(p->opr.op[1]);
			case GE: return ex(p->opr.op[0]) >= ex(p->opr.op[1]);
			case LE: return ex(p->opr.op[0]) <= ex(p->opr.op[1]);
			case NE: return ex(p->opr.op[0]) != ex(p->opr.op[1]);
			case EQ: return ex(p->opr.op[0]) == ex(p->opr.op[1]);
			case preINC: return ++sym[p->opr.op[0]->id.i];
			case preDEC: return --sym[p->opr.op[0]->id.i];
			case postINC: {int aux = sym[p->opr.op[0]->id.i];
				sym[p->opr.op[0]->id.i]++;
				return aux;
				}
			case postDEC: {int aux = sym[p->opr.op[0]->id.i];
				sym[p->opr.op[0]->id.i]--;
				return aux;
				}
			case PQ:
				return sym[p->opr.op[0]->id.i] += ex(p->opr.op[1]);
			case MQ:
				return sym[p->opr.op[0]->id.i] -= ex(p->opr.op[1]);
			case MMQ:
				return sym[p->opr.op[0]->id.i] *= ex(p->opr.op[1]);
			case DQ:
				return sym[p->opr.op[0]->id.i] /= ex(p->opr.op[1]);
			
		}
	}

	return 0;
}