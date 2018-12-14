%{
	#include <iostream>
	#include <string>
	#include <stack>
	#include <vector>
	#include "../src/SymbolTable.h"
	#include "../src/AST.h"

	#include "../generated/parser.hpp"
	extern char* yytext;
%}

%option noyywrap 

%%
[0-9]*\.[0-9]+	return _FLOATLITERAL;
[0-9]+			return _INTLITERAL;
\"[^\"]*\"		return _STRINGLITERAL;
\-\-.*\n	;
PROGRAM		return PROGRAM;
BEGIN		return _BEGIN;
END			return END;
FUNCTION	return FUNCTION;
READ		return READ;
WRITE		return WRITE;
IF			return IF;
ELSE		return ELSE;
ENDIF		return ENDIF;
WHILE		return WHILE;
ENDWHILE	return ENDWHILE;
RETURN		return RETURN;
INT			return INT;
VOID		return VOID;
STRING		return STRING;
FLOAT		return FLOAT;
TRUE		return TRUE;
FALSE		return FALSE;

[a-zA-Z][a-zA-Z0-9]*	return _IDENTIFIER;

:=		return _NEXTSTATE;
\+		return _ADD;
\- 		return _SUB;
\*		return _MUL;
\/		return _DIVIDE;
\=		return _EQUAL;
!=		return _NOTEQUAL;
\<		return _LESSTHAN;
\>		return _GREATERTHAN;
\(		return _LEFTPAREN;
\) 		return _RIGHTPAREN;
\;		return _SEMICOLON;
\,		return _COMMA;
\<=		return _LESSEQUAL;
\>=		return _GREATEREQUAL;
[ \t\n\r]	 ;
.			;


%%
