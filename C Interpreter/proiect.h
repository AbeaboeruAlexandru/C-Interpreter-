typedef enum { typeCon, typeId, typeOper } nodeEnum;

typedef struct {
	int val; 
	float fval;
} conNodeType;

typedef struct {
	int i; 
} idNodeType;

typedef struct {
	int oper; 
	int nops; 
	struct nodeTypeTag *op[1]; 
} oprNodeType;

typedef struct nodeTypeTag {
	nodeEnum type; 
	union {
		conNodeType con; 
		idNodeType id; 
		oprNodeType opr; 
	};
} nodeType;

extern int sym[26]; 