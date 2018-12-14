#include <iostream>
#include <string>
#include <stack>
#include <vector>
#include "SymbolTable.h"
#include "AST.h"
#include "../generated/parser.hpp"

using namespace std;

SymbolTable * treeroot = NULL;

extern int yylex();
extern char* yytext;
extern FILE * yyin;
extern vector<ThreeAC>IR;
int main(int argc, char ** argv)
{
	if ( argc > 1 )
        yyin = fopen( argv[1], "r" );
    else
        yyin = stdin;
	int p = 0;
//	printf("FILE %s, LINE %d\n", __FILE__, __LINE__);
	p = yyparse();

//	printf("FILE %s, LINE %d\n", __FILE__, __LINE__);
	return EXIT_SUCCESS; 
}
