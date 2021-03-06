%code requires{
#include "../src/SymbolTable.h"
#include "../src/AST.h"
}

%{
	#include <string>
	#include <stdio.h>
	#include <stdlib.h>
	#include <iostream>
	#include <sstream>
	#include <string.h>
	#include <stack>
	#include <list>
	#include <set>
	#include <map>
	#include <vector>
	#include "../src/SymbolTable.h"
	#include "../src/AST.h"
	extern int yylex();
	extern int yylineno;
	extern char* yytext;
	static ThreeAC toInsert;
	extern vector<ThreeAC> IR;
	std::stack<SymbolTable *> symtStack;
	void yyerror(const char* s){}
	long long blockCtr = 0;

	extern int g_local_var_count;
	extern int g_parameter_count;
	extern int g_reg_count;
	
	int offset = 0;
	int reg_cnt = 0;
	int label_cnt = 0;
	int paramater_count = 0;
	int local_var_count = 0;
	stringstream ss; 

	string PARENT_SCOPE;
	string CURRENT_SCOPE;

	using namespace std;
	
	std::string GenS(int i){
		return "$"+std::to_string(static_cast<long long>(i));
	}
	
	std::string GenerateBlock(){
		return "BLOCK " + std::to_string(++blockCtr);
	}
	string tempToreg(string s){
		string a = "r";
		s.replace(0,2,a);
		return s;
	}
	
	ThreeAC BackofIR() {
		return IR.back();
	}


	/////////////////////////////////////////
	string findNewLabel() {
		ss.str("");
		ss << "label" << label_cnt;
		label_cnt++;
		return ss.str();
	}
	string findNewJump() {
		ss.str("");
		ss << "jump" << label_cnt;
		label_cnt++;
		return ss.str();
	}

	string findNewReg() {
		ss.str("");
		ss << "!T" << ++reg_cnt;
		//ss << "!T" << ( ++local_var_count);
		return ss.str();
	}

	//UTILITY - finds and returns a new local
	string findNewLocal() {
		ss.str("");
		ss << "!L" << ++local_var_count;
		return ss.str();
	}

	//UTILITY - finds and returns a new param
	string findNewParam() {
		ss.str("");
		ss << "!P" << ++paramater_count;
		return ss.str();
	}

%}


%union {
	std::string * sstr;
	Symbol * syms;
	std::vector<std::string> * vst;
	std::vector<AST*> * astList;
	AST * astnode; 
}

%type<sstr> id str var_type compop 
%type<syms> string_decl var_decl  
%type<vst>  id_tail id_list
%type<astnode> primary  addop mulop stmt base_stmt read_stmt write_stmt expr expr_prefix call_expr
%type<astnode> factor factor_prefix postfix_expr assign_expr assign_stmt func_decl return_stmt //expr_list expr_list_tail 
%type<astnode> if_stmt while_stmt loop_stmt control_stmt cond 
%type<astList> stmt_list pgm_body func_body func_declarations else_part expr_list expr_list_tail

%start program 

%token _IDENTIFIER
%token _INTLITERAL 
%token _FLOATLITERAL
%token _STRINGLITERAL
%token PROGRAM 
%token _BEGIN
%token END 
%token FUNCTION
%token READ 
%token WRITE
%token IF
%token ELSE
%token ENDIF 
%token WHILE
%token ENDWHILE 
%token RETURN
%token INT
%token VOID
%token STRING
%token FLOAT
%token TRUE
%token FALSE
%token _NEXTSTATE
%token _ADD 
%token _SUB
%token _MUL 
%token _DIVIDE
%token _EQUAL 
%token _NOTEQUAL
%token _LESSTHAN
%token _GREATERTHAN 
%token _LEFTPAREN 
%token _RIGHTPAREN
%token _SEMICOLON 
%token _COMMA 
%token _LESSEQUAL 
%token _GREATEREQUAL 


%% 

/* Program */
program 				:  PROGRAM id _BEGIN 
						{
							SymbolTable * global = new SymbolTable("GLOBAL", NULL);
							CURRENT_SCOPE = "GLOBAL";
							symtStack.push(global);
													}
						pgm_body  END 
						{	
							toInsert.Fill(";PUSH","","","");
							IR.push_back(toInsert);
							toInsert.clear();

							toInsert.Fill(";PUSHREGS","","","");
							IR.push_back(toInsert);
							toInsert.clear();
							for(int i = 0; i < (*$5).size(); ++i)
							{ 	 
								if((*$5)[i]!=NULL)
									{
										FuncNode * temp_func;
										if(temp_func = dynamic_cast<FuncNode*>((*$5)[i])){
											if(temp_func->func_name == "main"){
												
												toInsert.Fill(";PUSH","","","");
												IR.push_back(toInsert);
												toInsert.clear();
											}
										}
									}
							}

							toInsert.Fill(";JSR","","","main");
							IR.push_back(toInsert);
							toInsert.clear();
							
							toInsert.Fill(";HALT","","","");
							IR.push_back(toInsert);
							toInsert.clear();

							vector<ThreeAC>::iterator it;
							string temp, temp1,  temp2, temp3, temp4; 
							for(int i = 0; i < (*$5).size(); ++i)
							{ 	 
								if((*$5)[i]!=NULL)
									{
										(*$5)[i]->TOIR();
									}
							}
							for(it = IR.begin(); it != IR.end(); it++)
							{
								ThreeAC obj = *(it);
								cout<< obj.opcode << " " << obj.op1 << " " << obj.op2 << " " << obj.res << endl;										
							}
							
				 
							symtStack.top()->printvect();
							//

				
							symtStack.top()->PrintTables();			

							for(it = IR.begin(); it != IR.end(); it++)
							{
								temp = temp1 = temp2 = temp3 = temp4 =  ""; 
								ThreeAC obj = *(it);

								if(obj.opcode == ";EQI")
								{
									temp = "cmpi";
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) == "!T")
									{
										//temp2 = tempToreg(obj.op1);
										cout << "pop r1" << endl << "pop r0" << endl; 
										cout << temp << " r0" << " r1" << endl; 
										cout << "jeq " << obj.res << endl; 

									}
									else if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " "  << " r0" << obj.op2 << endl; 
										cout << "jeq " << obj.res << endl; 
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " " << obj.op1  << " r0"  << endl; 
										cout << "jeq " << obj.res << endl; 
									}

									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) != "!T"){
										
											cout << "move " << obj.op1 << " r0" << endl;
											cout << temp << " " << obj.op2 << " r0" << endl; 
											cout << "jeq " << obj.res << endl; 
																				
									}									
								}
								
								if(obj.opcode == ";LEI")
								{
									temp = "cmpi";
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) == "!T")
									{
										//temp2 = tempToreg(obj.op1);
										cout << "pop r1" << endl << "pop r0" << endl; 
										cout << temp << " r0" << " r1" << endl; 
										cout << "jle " << obj.res << endl; 

									}
									else if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " "  << " r0" << obj.op2 << endl; 
										cout << "jle " << obj.res << endl; 
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " " << obj.op1  << " r0"  << endl; 
										cout << "jle " << obj.res << endl; 
									}

									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) != "!T"){
										
											cout << "move " << obj.op1 << " r0" << endl;
											cout << temp << " " << obj.op2 << " r0" << endl; 
											cout << "jle " << obj.res << endl; 
																				
									}									
								}

								if(obj.opcode == ";GTI")
								{
									temp = "cmpi";
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) == "!T")
									{
										//temp2 = tempToreg(obj.op1);
										cout << "pop r1" << endl << "pop r0" << endl; 
										cout << temp << " r0" << " r1" << endl; 
										cout << "jgt " << obj.res << endl; 

									}
									else if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " "  << " r0" << obj.op2 << endl; 
										cout << "jgt " << obj.res << endl; 
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " " << obj.op1  << " r0"  << endl; 
										cout << "jgt " << obj.res << endl; 
									}

									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) != "!T"){
										
											cout << "move " << obj.op1 << " r0" << endl;
											cout << temp << " " << obj.op2 << " r0" << endl; 
											cout << "jgt " << obj.res << endl; 
																				
									}									
								}
								if(obj.opcode == ";LTI")
								{
									temp = "cmpi";
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) == "!T")
									{
										//temp2 = tempToreg(obj.op1);
										cout << "pop r1" << endl << "pop r0" << endl; 
										cout << temp << " r0" << " r1" << endl; 
										cout << "jlt " << obj.res << endl; 

									}
									else if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " "  << " r0" << obj.op2 << endl; 
										cout << "jlt " << obj.res << endl; 
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " " << obj.op1  << " r0"  << endl; 
										cout << "jlt " << obj.res << endl; 
									}

									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) != "!T"){
										
											cout << "move " << obj.op1 << " r0" << endl;
											cout << temp << " " << obj.op2 << " r0" << endl; 
											cout << "jlt " << obj.res << endl; 
																				
									}									
								}

								if(obj.opcode == ";HALT") {
									cout << "sys halt" << endl;	
								}
								if(obj.opcode == ";GEI")
								{
									temp = "cmpi";
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) == "!T")
									{
										//temp2 = tempToreg(obj.op1);
										cout << "pop r1" << endl << "pop r0" << endl; 
										cout << temp << " r0" << " r1" << endl; 
										cout << "jge " << obj.res << endl; 

									}
									else if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " "  << " r0" << obj.op2 << endl; 
										cout << "jge " << obj.res << endl; 
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " " << obj.op1  << " r0"  << endl; 
										cout << "jge " << obj.res << endl; 
									}

									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) != "!T"){
										
											cout << "move " << obj.op1 << " r0" << endl;
											cout << temp << " " << obj.op2 << " r0" << endl; 
											cout << "jge " << obj.res << endl; 
																				
									}									
								}
								if(obj.opcode == ";NEI")
								{
									temp = "cmpi";
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) == "!T")
									{
										//temp2 = tempToreg(obj.op1);
										cout << "pop r1" << endl << "pop r0" << endl; 
										cout << temp << " r0" << " r1" << endl; 
										cout << "jne " << obj.res << endl; 

									}
									else if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " "  << " r0" << obj.op2 << endl; 
										cout << "jne " << obj.res << endl; 
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " " << obj.op1  << " r0"  << endl; 
										cout << "jne " << obj.res << endl; 
									}

									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) != "!T"){
										
											cout << "move " << obj.op1 << " r0" << endl;
											cout << temp << " " << obj.op2 << " r0" << endl; 
											cout << "jne " << obj.res << endl; 
																				
									}									
								}


								if(obj.opcode == ";EQF")
								{
									temp = "cmpr";
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) == "!T")
									{
										//temp2 = tempToreg(obj.op1);
										cout << "pop r1" << endl << "pop r0" << endl; 
										cout << temp << " r0" << " r1" << endl; 
										cout << "jeq " << obj.res << endl; 

									}
									else if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " "  << " r0" << obj.op2 << endl; 
										cout << "jeq " << obj.res << endl; 
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " " << obj.op1  << " r0"  << endl; 
										cout << "jeq " << obj.res << endl; 
									}

									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) != "!T"){
										
											cout << "move " << obj.op1 << " r0" << endl;
											cout << temp << " " << obj.op2 << " r0" << endl; 
											cout << "jeq " << obj.res << endl; 
																				
									}									
								}
								
								if(obj.opcode == ";LEF")
								{
									temp = "cmpr";
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) == "!T")
									{
										//temp2 = tempToreg(obj.op1);
										cout << "pop r1" << endl << "pop r0" << endl; 
										cout << temp << " r0" << " r1" << endl;   //THIS IS IMPORTSNT AND NEEDS TO BE CHANGED IN 11 other places
										cout << "jle " << obj.res << endl; 

									}
									else if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " "  << " r0" << obj.op2 << endl; 
										cout << "jle " << obj.res << endl; 
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " " << obj.op1  << " r0"  << endl; 
										cout << "jle " << obj.res << endl; 
									}

									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) != "!T"){
										
											cout << "move " << obj.op1 << " r0" << endl;
											cout << temp << " " << obj.op2 << " r0" << endl; 
											cout << "jle " << obj.res << endl; 
																				
									}									
								}

								if(obj.opcode == ";GTF")
								{
									temp = "cmpr";
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) == "!T")
									{
										//temp2 = tempToreg(obj.op1);
										cout << "pop r1" << endl << "pop r0" << endl; 
										cout << temp << " r0" << " r1" << endl; 
										cout << "jgt " << obj.res << endl; 

									}
									else if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " "  << " r0" << obj.op2 << endl; 
										cout << "jgt " << obj.res << endl; 
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " " << obj.op1  << " r0"  << endl; 
										cout << "jgt " << obj.res << endl; 
									}

									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) != "!T"){
										
											cout << "move " << obj.op1 << " r0" << endl;
											cout << temp << " " << obj.op2 << " r0" << endl; 
											cout << "jgt " << obj.res << endl; 
																				
									}									
								}
								if(obj.opcode == ";LTF")
								{
									temp = "cmpr";
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) == "!T")
									{
										//temp2 = tempToreg(obj.op1);
										cout << "pop r1" << endl << "pop r0" << endl; 
										cout << temp << " r0" << " r1" << endl; 
										cout << "jlt " << obj.res << endl; 

									}
									else if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp  << " r0" << obj.op2 << endl; 
										cout << "jlt " << obj.res << endl; 
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " " << obj.op1  << " r0"  << endl; 
										cout << "jlt " << obj.res << endl; 
									}

									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) != "!T"){
										
											cout << "move " << obj.op1 << " r0" << endl;
											cout << temp << " " << obj.op2 << " r0" << endl; 
											cout << "jlt " << obj.res << endl; 
																				
									}									
								}

							
								if(obj.opcode == ";GEF")
								{
									temp = "cmpr";
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) == "!T")
									{
										//temp2 = tempToreg(obj.op1);
										cout << "pop r1" << endl << "pop r0" << endl; 
										cout << temp << " r0" << " r1" << endl; 
										cout << "jge " << obj.res << endl; 

									}
									else if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " "  << " r0" << obj.op2 << endl; 
										cout << "jge " << obj.res << endl; 
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " " << obj.op1  << " r0"  << endl; 
										cout << "jge " << obj.res << endl; 
									}

									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) != "!T"){
										
											cout << "move " << obj.op1 << " r0" << endl;
											cout << temp << " " << obj.op2 << " r0" << endl; 
											cout << "jge " << obj.res << endl; 
																				
									}									
								}
								if(obj.opcode == ";NEF")
								{
									temp = "cmpr";
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) == "!T")
									{
										//temp2 = tempToreg(obj.op1);
										cout << "pop r1" << endl << "pop r0" << endl; 
										cout << temp << " r0" << " r1" << endl; 
										cout << "jne " << obj.res << endl; 

									}
									else if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " "  << " r0" << obj.op2 << endl; 
										cout << "jne " << obj.res << endl; 
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " " << obj.op1  << " r0"  << endl; 
										cout << "jne " << obj.res << endl; 
									}

									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) != "!T"){
										
											cout << "move " << obj.op1 << " r0" << endl;
											cout << temp << " " << obj.op2 << " r0" << endl; 
											cout << "jne " << obj.res << endl; 
																				
									}									
								}

								if(obj.opcode == ";LABEL")
								{
									//temp = findNewLabel();
									cout << "label  " << obj.op1  << endl;
								}
								if(obj.opcode == ";JUMP")
								{
									temp = findNewJump();
									cout << "jmp  " << obj.op1 << endl;
								}
								if(obj.opcode == ";STOREI")
								{
									temp = "move"; 
									
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " r0" << " " << obj.op2  << endl; 
										
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{	 
										cout << temp << " " << obj.op1  << " r0"  << endl; 
										cout << "push r0" << endl;
									
									}
										
								}
								if(obj.opcode == ";ADDI")
								{
									temp = "addi";
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) == "!T")
									{
										
										cout << "pop r0" << endl << "pop r1" << endl; 
										cout << temp << " r1" << " r0" << endl; 
										cout << "push r0" << endl;
										

									}
									else if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " "  << " " << obj.op2 << " r0" << endl;
										cout << "push r0" << endl; 
										
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " " << obj.op1  << " r0"  << endl; 
										cout << "push r0" << endl; 
										 
									}

									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) != "!T"){
										
											cout << "move " << obj.op1 << " r0" << endl;
											cout << temp << " " << obj.op2 << " r0" << endl;
											cout << "push r0" << endl; 
										
																							
									}									
								}

								if(obj.opcode == ";SUBI")
								{
									temp = "subi";
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) == "!T")
									{
										
										cout << "pop r1" << endl << "pop r0" << endl; 
										cout << temp << " r1" << " r0" << endl; 
										cout << "push r0" << endl;
										

									}
									else if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " "  << " " << obj.op2 << " r0" << endl;
										cout << "push r0" << endl; 
										
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{
										cout << "move " << obj.op1 << " r0" << endl; 
										cout << "pop r1" << endl;
										cout << temp << " " << "r1"  << " r0"  << endl; 
										cout << "push r0" << endl; 

										
										 
									}

									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) != "!T"){
										
											cout << "move " << obj.op1 << " r0" << endl;
											cout << temp << " " << obj.op2 << " r0" << endl;
											cout << "push r0" << endl; 
										
																							
									}										
								}
								if(obj.opcode == ";MULI")
								{
									temp = "muli";
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) == "!T")
									{
										
										cout << "pop r0" << endl << "pop r1" << endl; 
										cout << temp << " r1" << " r0" << endl; 
										cout << "push r0" << endl;
										

									}
									else if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " "  << " " << obj.op2 << " r0" << endl;
										cout << "push r0" << endl; 
										
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " " << obj.op1  << " r0"  << endl; 
										cout << "push r0" << endl; 
										 
									}

									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) != "!T"){
										
											cout << "move " << obj.op1 << " r0" << endl;
											cout << temp << " " << obj.op2 << " r0" << endl;
											cout << "push r0" << endl; 
										
																							
									}
								}
								if(obj.opcode == ";DIVI")
								{
									temp = "divi";
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) == "!T")
									{
										
										cout << "pop r0" << endl << "pop r1" << endl; 
										cout << temp << " r1" << " r0" << endl; 
										cout << "push r0" << endl;
										

									}
									else if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " "  << " " << obj.op2 << " r0" << endl;
										cout << "push r0" << endl; 
										
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{
										cout << "move " << obj.op1 << " r0" << endl; 
										cout << "pop r1" << endl;
										cout << temp << " " << "r1"  << " r0"  << endl; 
										cout << "push r0" << endl; 
										 
									}

									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) != "!T"){
										
											cout << "move " << obj.op1 << " r0" << endl;
											cout << temp << " " << obj.op2 << " r0" << endl;
											cout << "push r0" << endl; 
										
																							
									}									
								}
								if(obj.opcode == ";STOREF")
								{
									temp = "move"; 
									
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " r0" << " " << obj.op2  << endl; 
										
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{	 
										cout << temp << " " << obj.op1  << " r0"  << endl; 
										cout << "push r0" << endl;
									
									}
																			
								}

								if(obj.opcode == ";ADDF")
								{
									temp = "addr";
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) == "!T")
									{
										
										cout << "pop r0" << endl << "pop r1" << endl; 
										cout << temp << " r1" << " r0" << endl; 
										cout << "push r0" << endl;
										

									}
									else if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " "  << " " << obj.op2 << " r0" << endl;
										cout << "push r0" << endl; 
										
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " " << obj.op1  << " r0"  << endl; 
										cout << "push r0" << endl; 
										 
									}

									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) != "!T"){
										
											cout << "move " << obj.op1 << " r0" << endl;
											cout << temp << " " << obj.op2 << " r0" << endl;
											cout << "push r0" << endl; 
										
																							
									}									
								}

								if(obj.opcode == ";SUBF")
								{
									temp = "subr";
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) == "!T")
									{
										
										cout << "pop r0" << endl << "pop r1" << endl; 
										cout << temp << " r1" << " r0" << endl; 
										cout << "push r0" << endl;
										

									}
									else if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " "  << " " << obj.op2 << " r0" << endl;
										cout << "push r0" << endl; 
										
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{
										cout << "move " << obj.op1 << " r0" << endl; 
										cout << "pop r1" << endl;
										cout << temp << " " << "r1"  << " r0"  << endl; 
										cout << "push r0" << endl; 
									}

									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) != "!T"){
										
											cout << "move " << obj.op1 << " r0" << endl;
											cout << temp << " " << obj.op2 << " r0" << endl;
											cout << "push r0" << endl; 
										
																							
									}									
								}
								if(obj.opcode == ";MULF")
								{
									temp = "mulr";
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) == "!T")
									{
										
										cout << "pop r0" << endl << "pop r1" << endl; 
										cout << temp << " r1" << " r0" << endl; 
										cout << "push r0" << endl;
										

									}
									else if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp  << " " << obj.op2 << " r0" << endl;
										cout << "push r0" << endl; 
										
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{
										cout << "pop r0" << endl; 
										cout << temp << " " << obj.op1  << " r0"  << endl; 
										cout << "push r0" << endl; 
										 
									}

									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) != "!T"){
										
											cout << "move " << obj.op1 << " r0" << endl;
											cout << temp << " " << obj.op2 << " r0" << endl;
											cout << "push r0" << endl; 
										
																							
									}								
								}
								if(obj.opcode == ";DIVF")
								{
									temp = "divr";
									if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) == "!T")
									{
										
										cout << "pop r0" << endl << "pop r1" << endl; 
										cout << temp << " r1" << " r0" << endl; 
										cout << "push r0" << endl;
										

									}
									else if(obj.op1.substr(0,2) == "!T" && obj.op2.substr(0,2) != "!T")
									{
									//	cout << "pop r0" << endl; 
										cout << "move " << obj.op2 << " r1" << endl; 
										cout << temp   << " " << "r1" << " r0" << endl;
										cout << "push r0" << endl; 
										
									}
									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) == "!T")
									{
									//	cout << "pop r0" << endl; 
										cout << "move " << obj.op1 << " r0" << endl; 
										cout << "pop r1" << endl;
										cout << temp << " " << "r1"  << " r0"  << endl; 
										cout << "push r0" << endl; 
										 
									}

									else if(obj.op1.substr(0,2) != "!T" && obj.op2.substr(0,2) != "!T"){
										
											cout << "move " << obj.op1 << " r0" << endl;
											cout << temp << " " << obj.op2 << " r0" << endl;
											cout << "push r0" << endl; 
										
																							
									}									
								}

							//	if(obj.res.substr(0,2) == "!T"){
							//		cout << "push r0 ;result r0" << endl; 
							//	}
								if (obj.opcode == ";READI")
								{
									temp = "sys readi";
									if(obj.op1.substr(0,2) == "!T")
									{
										temp2 = tempToreg(obj.op1);
									}
									else{
										temp2 = obj.op1;
									}
									if(obj.op2.substr(0,2) == "!T")
									{
										temp3 = tempToreg(obj.op2);
									}
									else{
									temp3 = obj.op2;
									}
									if(obj.res.substr(0,2) == "!T")
									{
										temp4 = tempToreg(obj.res);
									}
									else{
									temp4 = obj.res;
									}
									cout << temp << " " << temp2 << " " << temp3 << " " << temp4 << endl; 
								}
								else if (obj.opcode == ";WRITEI")
								{
									temp = "sys writei";
									if(obj.op1.substr(0,2) == "!T")
									{
										temp2 = tempToreg(obj.op1);
									}
									else{
										temp2 = obj.op1;
									}
									if(obj.op2.substr(0,2) == "!T")
									{
										temp3 = tempToreg(obj.op2);
									}
									else{
										temp3 = obj.op2;
									}
									if(obj.res.substr(0,2) == "!T")
									{
										temp4 = tempToreg(obj.res);
									}
									else{
									temp4 = obj.res;
									}
									cout << temp << " " << temp2 << " " << temp3 << " " << temp4 << endl; 
								}
								else if (obj.opcode == ";READF")
								{
									temp = "sys readr";
									if(obj.op1.substr(0,2) == "!T")
									{
										temp2 = tempToreg(obj.op1);
									}
									else{
										temp2 = obj.op1;
									}
									if(obj.op2.substr(0,2) == "!T")
									{
										temp3 = tempToreg(obj.op2);
									}
									else{
									temp3 = obj.op2;
									}
									if(obj.res.substr(0,2) == "!T")
									{
										temp4 = tempToreg(obj.res);
									}
									else{
									temp4 = obj.res;
									}
									cout << temp << " " << temp2 << " " << temp3 << " " << temp4 << endl; 
								}
								else if (obj.opcode == ";WRITEF")
								{
									temp = "sys writer";
									if(obj.op1.substr(0,2) == "!T")
									{
										temp2 = tempToreg(obj.op1);
									}
									else{
										temp2 = obj.op1;
									}
									if(obj.op2.substr(0,2) == "!T")
									{
										temp3 = tempToreg(obj.op2);
									}
									else{
									temp3 = obj.op2;
									}
									if(obj.res.substr(0,2) == "!T")
									{
										temp4 = tempToreg(obj.res);
									}
									else{
									temp4 = obj.res;
									}
									cout << temp << " " << temp2 << " " << temp3 << " " << temp4 << endl; 
								}
								else if (obj.opcode == ";READS")
								{
									temp = "sys reads";
									if(obj.op1.substr(0,2) == "!T")
									{
										temp2 = tempToreg(obj.op1);
									}
									else{
										temp2 = obj.op1;
									}
									if(obj.op2.substr(0,2) == "!T")
									{
										temp3 = tempToreg(obj.op2);
									}
									else{
									temp3 = obj.op2;
									}
									if(obj.res.substr(0,2) == "!T")
									{
										temp4 = tempToreg(obj.res);
									}
									else{
									temp4 = obj.res;
									}
									cout << temp << " " << temp2 << " " << temp3 << " " << temp4 << endl; 
								}
								else if (obj.opcode == ";WRITES")
								{
									temp = "sys writes";
									if(obj.op1.substr(0,2) == "!T")
									{
										temp2 = tempToreg(obj.op1);
									}
									else{
										temp2 = obj.op1;
									}
									if(obj.op2.substr(0,2) == "!T")
									{
										temp3 = tempToreg(obj.op2);
									}
									else{
									temp3 = obj.op2;
									}
									if(obj.res.substr(0,2) == "!T")
									{
										temp4 = tempToreg(obj.res);
									}
									else{
									temp4 = obj.res;
									}
									cout << temp << " " << temp2 << " " << temp3 << " " << temp4 << endl; 
								}
								
								if(obj.opcode == ";LINK"){
									cout << "link "<< obj.res <<endl; 
								}
								if(obj.opcode == ";LABEL func_"){
									cout << "label " << "FUNC_"+obj.op1 << endl; 
								}
								if(obj.opcode == ";PUSH"){
									string x = "";									
									if(obj.op1.substr(0,2) == "!T") {
										cout << "pop r0" << endl;
										cout << "push "<< "r0" <<endl; 									
									}
									else if (obj.op1.substr(0,2) != "!T"){
										cout << "push " << obj.op1 << endl;
									}
									else {
										cout << "push"  << endl; 
									}
								}
								if(obj.opcode == ";PUSHREGS"){
									cout << "push r0"<< endl;
									cout << "push r1"<< endl;
									cout << "push r2"<< endl;
									cout << "push r3"<< endl;
								}
								if(obj.opcode == ";POP"){
									string x = "";
									if(obj.op1.substr(0,2) == "!T") {
										x = tempToreg(obj.op1);
										cout << "pop "<< "r0" <<endl;
										cout << "push " << "r0 ;from pop function" << endl;
									}
									else {
									cout << "pop"  <<endl; 
									} 
								}
								if(obj.opcode == ";POPREGS"){
									cout << "pop r3"<< endl;
									cout << "pop r2"<< endl;
									cout << "pop r1"<< endl;
									cout << "pop r0"<< endl;
								}
								if(obj.opcode == ";JSR"){
									cout << "jsr "<< "FUNC_" + obj.res <<endl; 
								}
								if(obj.opcode == ";UNLINK"){
									cout << "unlnk"<< endl; 
								}
								if(obj.opcode == ";RET"){
									cout << "ret"<< endl; 
								}

						}
							
							
						} 
						; 

id 						: _IDENTIFIER {$$ = new std::string(yytext);}
						;

pgm_body 				:  decl func_declarations {$$ = $2;} 
						;

decl 					:  string_decl decl 
						| var_decl decl 
						|  
						;

/* Global String Declaration */
string_decl 			: STRING id _NEXTSTATE str _SEMICOLON 
						{
							if(CURRENT_SCOPE == "GLOBAL") {
								Symbol * mysym = new Symbol(*$2, "str", *$4, 0);
								symtStack.top()->InsertSymbol(mysym);
							}
							else {
								string l = findNewLocal();
								Symbol * mysym = new Symbol(*$2, "str", *$4, 0);
								symtStack.top()->InsertSymbol(mysym);
							}
							
						}
						;

str 					: _STRINGLITERAL {$$ = new std::string(yytext);} 
						; 

/* Variable Declaration */
var_decl 				: var_type id_list _SEMICOLON 
						{
							for (int i = 0; i < ($2)->size(); i++) 
							{ 
								if(CURRENT_SCOPE == "GLOBAL") {
									Symbol * varsym = new Symbol((*$2)[i], *$1, "", 0);
									symtStack.top()->InsertSymbol(varsym);
								}
								else {
									string l = findNewLocal();
									Symbol * varsym = new Symbol((*$2)[i], *$1, "",offset--);
									symtStack.top()->InsertSymbol(varsym);
								}
							}
						} 
						;

var_type 				: FLOAT {$$ = new std::string(yytext);} 
						| INT {$$ = new std::string(yytext); } 
						;

any_type 				: var_type 
						| VOID
						;

id_list 				: id id_tail {$$=$2; 
							 std::vector<std::string>::iterator it;
							 it = $$->begin();
							 it = $$->insert(it, *($1));
						} 
						;

id_tail 				: _COMMA id id_tail 
						{
							$$=$3; 
							std::vector<std::string>::iterator it2;
							it2 = $$->begin();
							it2 = $$->insert(it2, *($2));
						} 
						| {$$ = new std::vector<std::string>;}
						;

/* Function Paramater List */
param_decl_list 		:  param_decl param_decl_tail 
						|  
						;

param_decl 				: var_type id 
						{
							string l = findNewParam();
							Symbol * param_sym = new Symbol(*($2), *($1), "",offset++);
							symtStack.top()->InsertSymbol(param_sym);
						}
						;

param_decl_tail 		: _COMMA param_decl param_decl_tail 
						|  
						;

/* Function Declarations */
func_declarations 		: func_decl func_declarations 
						{
							$$ = $2; 
							$$->push_back($1);
						}
						| {$$ = new vector <AST*>;}
						;
								
func_decl 				: FUNCTION any_type id 
						{
							SymbolTable * function = new SymbolTable(*$3, symtStack.top(),1);
							symtStack.top()->children.push_back(function);
							symtStack.push(function);
							PARENT_SCOPE = CURRENT_SCOPE;
							CURRENT_SCOPE = *$3;
							offset = 2;
							//reg_cnt = 0;
							local_var_count = 0;
							paramater_count = 0;
							
							
							
						} 
						_LEFTPAREN param_decl_list _RIGHTPAREN _BEGIN {offset = -1;} func_body END 
						{	
							int lc = symtStack.top()->findLocalCount();
							$$ = new FuncNode(*$3,*$10,lc);//, symtStack.top());
							//$$->count_params();
							//$$->print_counts();	
							CURRENT_SCOPE = PARENT_SCOPE;
							PARENT_SCOPE = symtStack.top()->parent->scopes;							
							symtStack.pop();	
												
						}
						;

func_body 				:  decl stmt_list
							{
								$$=$2;
							} 
						;

/* Statement List */
stmt_list 				:  stmt stmt_list 
						{
							$$ = $2; 
							$$->push_back($1);
							//printf("LINE %d\n",__LINE__); 
						} 
						| {$$ = new vector <AST*>;} 
						;

stmt 					: base_stmt {$$ = $1;} 
						| if_stmt {$$ = $1;} 
						| loop_stmt {$$ = $1;} 
						;

base_stmt 				: assign_stmt{$$ = $1;} 
						| read_stmt {$$ = $1;} 
						| write_stmt {$$ = $1;} 
						| control_stmt {$$ = $1;} 
						;

/* Basic Statements */
assign_stmt 			:  assign_expr _SEMICOLON {$$ = $1;}   
						;

assign_expr				:  id _NEXTSTATE expr  
						{	
							VAR * vid = new VAR(symtStack.top()->FindSymbol(*$1));	
							ARITH* tmp = new ARITH(":="); 
							tmp ->rightchild(vid); 
							tmp->leftchild($3);
							tmp->type = $3->type;
							$$ = tmp;
						} 
						;

read_stmt 				:  READ _LEFTPAREN  id_list  _RIGHTPAREN _SEMICOLON 
						{
							IO* tmp = new IO("READ");
							std::vector<std::string>::iterator it; 
							for( it = (*$3).begin(); it != (*$3).end(); it++)
							{ 	 
								if( symtStack.top()->FindSymbol(*it)->offset != 0) {
									string t = GenS(symtStack.top()->FindSymbol(*it)->offset);
									symtStack.top()->FindSymbol(*it)->name = t ; 
								}
								//cout << symtStack.top()->FindSymbol(*it)->name << "  TEST" << endl; 
								tmp->vst.push_back(symtStack.top()->FindSymbol(*it));
								
							}
							$$ = tmp;

						} 
						;

write_stmt 				:  WRITE _LEFTPAREN id_list _RIGHTPAREN _SEMICOLON
						{
							IO* tmp = new IO("WRITE");
							std::vector<std::string>::iterator it; 
							for( it = (*$3).begin(); it != (*$3).end(); it++)
							{
								if( symtStack.top()->FindSymbol(*it)->offset != 0) {
									string t = GenS(symtStack.top()->FindSymbol(*it)->offset);
									symtStack.top()->FindSymbol(*it)->name = t ; 
								}
								//cout << symtStack.top()->FindSymbol(*it)->name << "  TEST" << endl; 
								tmp->vst.push_back(symtStack.top()->FindSymbol(*it));
							}
							$$ = tmp;
						} 
						;

return_stmt 			: RETURN expr _SEMICOLON 
						{
							int ret_val = symtStack.top()->findFuncParam();
							if(ret_val == 0) { ret_val = symtStack.top()->parent -> findFuncParam();}
							RetNode * tmp = new RetNode($2,ret_val+4);	
							CURRENT_SCOPE = PARENT_SCOPE;
							PARENT_SCOPE = symtStack.top()->parent->scopes;
							
							$$ = tmp;
						}
						; 

/* Expressions */
expr 					:  expr_prefix factor 
						{
							/*printf("FILE %s, LINE %d\n", __FILE__, __LINE__);*/
							if($1 == NULL){
								$$= $2;
							}
							else{
								$$ = $1;
								ARITH * one, *two;
								if(one = dynamic_cast<ARITH*>($1)){
									one->right=$2;
								}
							}
							///$$->type = $2->type;
						  }
						  ;

expr_prefix 			:  expr_prefix factor addop
						{
							/*printf("FILE %s, LINE %d\n", __FILE__, __LINE__);*/
							ARITH *one,*two,*three;
							three = dynamic_cast<ARITH*>($3);
							if($1== NULL){
								three->left = $2;
							}
							else{
								if(one = dynamic_cast<ARITH*>($1)){
									one->right=$2;
									three->left=$1;
								}
							}
							$$ = $3; 
							$$->type = $2->type;
																			
						} 
						| {$$ = NULL; }  
						;

factor 					:  factor_prefix postfix_expr 
						{
							/*printf("FILE %s, LINE %d\n", __FILE__, __LINE__);*/		
							if($1 == NULL)
							{
								$$ = $2;
							}
							else{
								ARITH * one, *two;
								if(one = dynamic_cast<ARITH*>($1)){
									one->right=$2;
								}
								$$ = $1; 

							} 
							$$->type = $2->type;
						} 
						;

factor_prefix 			:  factor_prefix postfix_expr mulop 
						{ 
							/*printf("FILE %s, LINE %d\n", __FILE__, __LINE__);*/
							ARITH* one = dynamic_cast<ARITH*>($1);
							ARITH * three = dynamic_cast<ARITH*>($3);

							$$ = $3;
							$$->type = $2->type;
							if($1 != NULL)
							{
								one->right=$2;
								three->left=$1;
							}
							else{
								three->left=$2;
							}

						} 
						| {$$ = NULL;}  
						;

postfix_expr 			:  primary {$$ = $1; } 
						| call_expr {$$ = $1; }  
						;

call_expr 				:  id _LEFTPAREN expr_list _RIGHTPAREN 
						{
							int r = symtStack.top()->findFuncParam();
							CallNode *tmp = new CallNode(*$1, *$3,r);
							
							//int i = symtStack.top()->parent->findOffset();
							$$ = tmp;
						}
						;

expr_list 				:  expr expr_list_tail {$$ = $2; $$->push_back($1);}
						|  {$$ = new vector <AST*>;}
						;

expr_list_tail 			: _COMMA expr expr_list_tail  {$$ = $3; $$->push_back($2);}
						|  {$$ = new vector <AST*>;}
						;

primary 				: _LEFTPAREN expr _RIGHTPAREN {$$ = $2;} 
						| id {$$ = new VAR(symtStack.top()->FindSymbol(*$1));}
						| _INTLITERAL {$$ = new LITERAL (string(yytext), "INT"); } 
						| _FLOATLITERAL {$$ = new LITERAL (string(yytext), "FLOAT"); } 
						;

addop 					:  _ADD  {$$ = new ARITH("+");}
						| _SUB {$$ = new ARITH("-");}
						;

mulop 					: _MUL   {$$ = new ARITH("*");} 
						| _DIVIDE {$$ = new ARITH("/");}
						; 

/* Complex Statements and Condition */ 
if_stmt 				: IF _LEFTPAREN cond            
						{
							SymbolTable * function = new SymbolTable(GenerateBlock(), symtStack.top());
							symtStack.top()->children.push_back(function);
							symtStack.push(function);
						
						} 
						_RIGHTPAREN decl stmt_list 
						{
							symtStack.pop();
						}
						else_part ENDIF 
						{
							$$ = new IF_NODE($3, *$7, *$9);
						}
						;

else_part 				:  ELSE 
						{
							SymbolTable * block = new SymbolTable(GenerateBlock(), symtStack.top());
							symtStack.top()->children.push_back(block);
							symtStack.push(block);
						}
						decl stmt_list 
						{
							symtStack.pop();
							$$ = $4;
						}
						| {$$ = new vector<AST*>;} 
						;

cond 					:  expr compop expr
						{

							$$ = new condition($1, *$2, $3);

						}
						| TRUE 
						{
							$$ = new condition(NULL, "TRUE", NULL);
						}
						| FALSE 
						{
							$$ = new condition(NULL, "FALSE", NULL);
						}
						;

compop 					:  _LESSTHAN {$$ = new string(yytext);}
						| _GREATERTHAN {$$ = new string(yytext);}
						| _EQUAL {$$ = new string(yytext);}
						| _NOTEQUAL {$$ = new string(yytext);}
						| _LESSEQUAL {$$ = new string(yytext);}
						| _GREATEREQUAL {$$ = new string(yytext);}
						;

while_stmt 				:  WHILE 
						{
							SymbolTable * block = new SymbolTable(GenerateBlock(), symtStack.top());
							symtStack.top()->children.push_back(block);
							symtStack.push(block);
					 	}
						_LEFTPAREN cond _RIGHTPAREN decl stmt_list ENDWHILE 
						{
							symtStack.pop();
							$$ = new WHILE_NODE($4, *$7);
						}
						; 

/*ECE468 ONLY*/
control_stmt 			:  return_stmt {$$ = $1;}
						;
loop_stmt 				:  while_stmt {$$ = $1;}
						;

%%

