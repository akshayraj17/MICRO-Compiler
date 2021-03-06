#include <iostream>
#include <map>
#include <vector>
#include <list>
#include <string>
#include <stack>
#include "stdio.h"
#include "string.h"
#include "../src/SymbolTable.h"
#include "../src/AST.h"
using namespace std;

static ThreeAC toInsert;
vector<ThreeAC> IR;
static stack<string> label_stack; 
static long long tempCntr = 0;
static long long scopeCntr = 0; 
extern 	string findNewReg();
extern int reg_cnt;

string GenTmp(){
	return "!T"+to_string(tempCntr);
}

string GenLabel(string s){
	return (s + to_string(++scopeCntr));
}

string GenV(int i){
	return ( "$" + (to_string(static_cast<long long>(i))));
}

void ThreeAC::Fill(string o,string o1,string o2,string r){
	opcode=o;
	op1=o1;
	op2=o2;
	res=r;
}

void ThreeAC::clear(){
	opcode = op1 = op2 = res = "";
}


string IF_NODE::TOIR(){

	string label1 = GenLabel("ELSE_");
	string label2 = GenLabel("END_IF_ELSE");
	label_stack.push(label1);
	
	if(left){
		left->TOIR();
	}

	for(int i =  mid.size() - 1; i >= 0; i--)
	{
		mid[i]->TOIR();	
	}
	
	toInsert.Fill(";JUMP", label2, "", "");
	IR.push_back(toInsert);
	toInsert.clear();

  	toInsert.Fill(";LABEL", label1, "", "");
	IR.push_back(toInsert);
	toInsert.clear();

	for(int j = right.size() - 1; j >= 0;  j--){
		right[j]->TOIR();
	}

  	toInsert.Fill(";LABEL", label2, "", "");
	IR.push_back(toInsert);
	toInsert.clear();


	return "";
}

string WHILE_NODE::TOIR(){
	
	string label1 = GenLabel("WHILE_START_");

	string label2 = GenLabel("WHILE_END_");

	label_stack.push(label1);
	toInsert.Fill(";LABEL", label_stack.top(), "", "");
	IR.push_back(toInsert);
	toInsert.clear();
	label_stack.push(label2); 

	if(left)
	{
		left->TOIR();
	}


	for(int j = right.size() - 1; j >= 0 ; j--)
	{
		right[j]->TOIR();
	}
	
	label_stack.push(label1);
	toInsert.Fill(";JUMP", label_stack.top(), "", "");
	IR.push_back(toInsert);
	toInsert.clear();
	
	label_stack.push(label2); 

 	toInsert.Fill(";LABEL", label_stack.top(), "", "");
	IR.push_back(toInsert);
	toInsert.clear();   

	return "";

} 


string condition::TOIR(){
	
	string x = GenTmp();
	string op1, op2, tmp;
	op1 = op2 = tmp = "";
	if(left){
		op1 = left->TOIR();
	}
	if(right){
		op2 = right->TOIR();
	}
	
	if(operation == "FALSE"){
				toInsert.Fill(";JUMP", label_stack.top(), "", "");
				IR.push_back(toInsert);
				toInsert.clear();
	}

	if(operation == "TRUE"){

	}


	if(operation == "<")
	{
		if(left->type == "INT")
		{ 	
			if(op1.substr(0,1) == "$" && op2.substr(0,1) == "$") {				
				toInsert.Fill(";STOREI", op2, x, "");
				IR.push_back(toInsert);
				toInsert.clear();
				toInsert.Fill(";GEI", op1, x, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
				tempCntr++;
			}
			else if (op2.substr(0,1) != "!T")
			{
				toInsert.Fill(";STOREI",op2, x, "");
				IR.push_back(toInsert);
				toInsert.clear();
			
				toInsert.Fill(";GEI", op1, x, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
				tempCntr++;			

			} 
			else {
				toInsert.Fill(";GEI", op1, op2, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
			}
		}
		else if(left->type == "FLOAT")
		{
			if(op1.substr(0,1) == "$" && op2.substr(0,1) == "$") {				
				toInsert.Fill(";STOREF", op2, x, "");
				IR.push_back(toInsert);
				toInsert.clear();
				toInsert.Fill(";GEF", op1, x, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
				tempCntr++;
			}
			else if (op2.substr(0,1) != "!T")
			{
				toInsert.Fill(";STOREF",op2, x, "");
				IR.push_back(toInsert);
				toInsert.clear();
			
				toInsert.Fill(";GEF", op1, x,label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
				tempCntr++;			

			}
			else
			{
				toInsert.Fill(";GEF", op1, op2, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
			}

		}
	}
	else if(operation == ">")
	{
		if(left->type == "INT")
		{ 	
			if(op1.substr(0,1) == "$" && op2.substr(0,1) == "$") {				
				toInsert.Fill(";STOREI", op2, x, "");
				IR.push_back(toInsert);
				toInsert.clear();
				toInsert.Fill(";LEI", op1, x, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
				tempCntr++;
			} 
			else if (op2.substr(0,1) != "!T")
			{
				toInsert.Fill(";STOREI",op2, x, "");
				IR.push_back(toInsert);
				toInsert.clear();
			
				toInsert.Fill(";LEI", op1, x,label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
				tempCntr++;			

			}
			else {
				toInsert.Fill(";LEI", op1, op2, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
			}
		}
		else if(left->type == "FLOAT")
		{
			if(op1.substr(0,1) == "$" && op2.substr(0,1) == "$") {				
				toInsert.Fill(";STOREF", op2, x, "");
				IR.push_back(toInsert);
				toInsert.clear();
				toInsert.Fill(";LEF", op1, x, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
				tempCntr++;
			} 
			else if (op2.substr(0,1) != "!T")
			{
				toInsert.Fill(";STOREF",op2, x, "");
				IR.push_back(toInsert);
				toInsert.clear();
			
				toInsert.Fill(";LEF", op1, x,label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
				tempCntr++;			

			}
			else {
				toInsert.Fill(";LEF", op1, op2, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
			}
		}
	}

	else if(operation == "=")
	{
		if(left->type == "INT")
		{ 	
			if(op1.substr(0,1) == "$" && op2.substr(0,1) == "$") {				
				toInsert.Fill(";STOREI", op2, x, "");
				IR.push_back(toInsert);
				toInsert.clear();
				toInsert.Fill(";NEI", op1, x, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
				tempCntr++;
			} 
			else if (op2.substr(0,1) != "!T")
			{
				toInsert.Fill(";STOREI",op2, x, "");
				IR.push_back(toInsert);
				toInsert.clear();
			
				toInsert.Fill(";NEI", op1, x,label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
				tempCntr++;			

			}
			else {
				toInsert.Fill(";NEI", op1, op2, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
			}
		}
		else if(left->type == "FLOAT")
		{
			if(op1.substr(0,1) == "$" && op2.substr(0,1) == "$") {				
				toInsert.Fill(";STOREF", op2, x, "");
				IR.push_back(toInsert);
				toInsert.clear();
				toInsert.Fill(";NEF", op1, x, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
				tempCntr++;
			} 
			else if (op2.substr(0,1) != "!T")
			{
			toInsert.Fill(";STOREF",op1, x, "");
			IR.push_back(toInsert);
			toInsert.clear();
			
			toInsert.Fill(";NEF", tmp, x,label_stack.top());
			IR.push_back(toInsert);
			toInsert.clear();
			tempCntr++;			


			}
			else {
				toInsert.Fill(";NEF", op1, op2, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
			}
		}
	}
	else if(operation == "!=")
	{
		if(left->type == "INT")
		{ 	
			if(op1.substr(0,1) == "$" && op2.substr(0,1) == "$") {				
				toInsert.Fill(";STOREI", op2, x, "");
				IR.push_back(toInsert);
				toInsert.clear();
				toInsert.Fill(";EQI", op1, x, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
				tempCntr++;
			} 
			else if (op2.substr(0,1) != "!T")
			{
				toInsert.Fill(";STOREI",op2, x, "");
				IR.push_back(toInsert);
				toInsert.clear();
			
				toInsert.Fill(";EQI", op1, x,label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
				tempCntr++;			

			}
			else {
				toInsert.Fill(";EQI", op1, op2, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
			}
		}
		else if(left->type == "FLOAT")
		{
			if(op1.substr(0,1) == "$" && op2.substr(0,1) == "$") {				
				toInsert.Fill(";STOREF", op2, x, "");
				IR.push_back(toInsert);
				toInsert.clear();
				toInsert.Fill(";EQF", op1, x, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
				tempCntr++;
			} 
			else if (op2.substr(0,1) != "!T")
			{
				toInsert.Fill(";STOREF",op2, x, "");
				IR.push_back(toInsert);
				toInsert.clear();
			
				toInsert.Fill(";EQF", op1, x, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
				tempCntr++;			

			}
			else {
				toInsert.Fill(";EQF", op1, op2, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
			}
		}
	}
	else if(operation == "<=")
	{
		if(left->type == "INT")
		{ 	
			if(op1.substr(0,1) == "$" && op2.substr(0,1) == "$") {				
				toInsert.Fill(";STOREI", op2, x, "");
				IR.push_back(toInsert);
				toInsert.clear();
				toInsert.Fill(";GTI", op1, x, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
				tempCntr++;
			} 
			else if (op2.substr(0,1) != "!T")
			{
			toInsert.Fill(";STOREI",op2, x, "");
			IR.push_back(toInsert);
			toInsert.clear();
			
			toInsert.Fill(";GTI", op1, x,label_stack.top());
			IR.push_back(toInsert);
			toInsert.clear();
			tempCntr++;			


			}
			else {
				toInsert.Fill(";GTI", op1, op2, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
			}
		}
		else if(left->type == "FLOAT")
		{
			if(op1.substr(0,1) == "$" && op2.substr(0,1) == "$") {				
				toInsert.Fill(";STOREF", op2, x, "");
				IR.push_back(toInsert);
				toInsert.clear();
				toInsert.Fill(";GTF", op1, x, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
				tempCntr++;
			} 
			else if (op2.substr(0,1) != "!T")
			{
			toInsert.Fill(";STOREF",op2, x, "");
			IR.push_back(toInsert);
			toInsert.clear();
			
			toInsert.Fill(";GTF", op1, x, label_stack.top());
			IR.push_back(toInsert);
			toInsert.clear();
			tempCntr++;			


			}
			else {
				toInsert.Fill(";GTF", op1, op2, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
			}
		}
	}
	else if(operation == ">=")
	{
		if(left->type == "INT")
		{ 	
			if(op1.substr(0,1) == "$" && op2.substr(0,1) == "$") {				
				toInsert.Fill(";STOREI", op2, x, "");
				IR.push_back(toInsert);
				toInsert.clear();
				toInsert.Fill(";LTI", op1, x, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
				tempCntr++;
			} 
			else if (op2.substr(0,1) != "!T")
			{
			toInsert.Fill(";STOREI",op2, x, "");
			IR.push_back(toInsert);
			toInsert.clear();
			
			toInsert.Fill(";LTI", op1, x, label_stack.top());
			IR.push_back(toInsert);
			toInsert.clear();
			tempCntr++;			


			}
			else {
				toInsert.Fill(";LTI", op1, op2, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
			}
		}
		else if(left->type == "FLOAT")
		{
			if(op1.substr(0,1) == "$" && op2.substr(0,1) == "$") {				
				toInsert.Fill(";STOREF", op2, x, "");
				IR.push_back(toInsert);
				toInsert.clear();
				toInsert.Fill(";LTF", op1, x, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
				tempCntr++;
			} 
			else if (op2.substr(0,1) != "!T")
			{
			toInsert.Fill(";STOREF",op2, x, "");
			IR.push_back(toInsert);
			toInsert.clear();
			
			toInsert.Fill(";LTF", op1, x, label_stack.top());
			IR.push_back(toInsert);
			toInsert.clear();
			tempCntr++;			


			}
			else {
				toInsert.Fill(";LTF", op1, op2, label_stack.top());
				IR.push_back(toInsert);
				toInsert.clear();
			}
		}
	}
			
	return "";

}


string FuncNode::TOIR(){
	
	toInsert.Fill(";LABEL func_",func_name,"","");
	IR.push_back(toInsert);
	toInsert.clear();
	//cout << func_name << " XXXXXXXX " << local_count << endl;
	toInsert.Fill(";LINK","","",to_string(static_cast<long long>(local_count)));
	IR.push_back(toInsert);
	toInsert.clear();
	
	for(int i = stmt_list.size() - 1; i >=0; --i){
		if(stmt_list[i] != NULL){
			stmt_list[i]->TOIR();
		}	
	}
	
	toInsert.Fill(";UNLINK","","","");
	IR.push_back(toInsert);
	toInsert.clear();

	toInsert.Fill(";RET","","","");
	IR.push_back(toInsert);
	toInsert.clear();
	return ""; 
}

string CallNode::TOIR() {
	///lookup the id and see what type of function it is. Set the type for that type
	//type = ;	
	toInsert.Fill(";PUSH","","","");
	IR.push_back(toInsert);
	toInsert.clear();

	toInsert.Fill(";PUSHREGS","","","");
	IR.push_back(toInsert);
	toInsert.clear();

	for(int i = 0; i < expr_list.size(); i++){
		if(expr_list[i]){
			string x = expr_list[i]->TOIR();
			toInsert.Fill(";PUSH",x,"","");
			IR.push_back(toInsert);
			toInsert.clear();
		
		}
		else
			cout<<"LINE: "<<__LINE__<<"\n";
	}
	toInsert.Fill(";JSR","","",id);
	IR.push_back(toInsert);
	toInsert.clear();

	for(int i = 0; i < expr_list.size(); i++){
		toInsert.Fill(";POP","","","");
		IR.push_back(toInsert);
		toInsert.clear();
	}
	tempCntr++;
	string r = GenTmp();

	toInsert.Fill(";POPREGS","","","");
	IR.push_back(toInsert);
	toInsert.clear();
	toInsert.Fill(";POP",r,"","");
	IR.push_back(toInsert);
	toInsert.clear();

	return r;
};

string RetNode::TOIR(){
	  
	string r_val = GenV(ret_val);
	string op2 = GenTmp();
	string op1 = expr->TOIR();
	cout << ";op1: " << op1 << endl; 
	//cout << r_val << "   " << op2 << "   " << op1 << "XXXXXX" << endl;
///most current function, number of params + 2 for the offset,look in symtStack until you reach func_node & see num params	
	if(op1 != "") {
		if(expr->type == "INT"){
		/*	if(op1.substr(0,2) == "!T")
			{	
			toInsert.Fill(";STOREI",op2,r_val,""); 
			IR.push_back(toInsert);
			toInsert.clear();
			} */
		//	else{
		//{
				cout << ";op1: " << op1 << endl; 

				toInsert.Fill(";STOREI",op1,op2,";op1:"+op1);
				IR.push_back(toInsert);
				toInsert.clear();
			
				toInsert.Fill(";STOREI",op2,r_val,""); 
				IR.push_back(toInsert);
				toInsert.clear();			
		//	}
		}
		else if (expr->type == "FLOAT"){
			if(op1.substr(0,2) == "!T")
			{	
			toInsert.Fill(";STOREF",op2,r_val,"");
			IR.push_back(toInsert);
			toInsert.clear();
			} 
			else{
				toInsert.Fill(";STOREF",op1,op2,"");
				IR.push_back(toInsert);
				toInsert.clear();
			
				toInsert.Fill(";STOREF",op2,r_val,""); 
				IR.push_back(toInsert);
				toInsert.clear();			
			}
		}
		else{
			toInsert.Fill(";STOREI",op1,op2,";op1:"+op1);
				IR.push_back(toInsert);
				toInsert.clear();
			
				toInsert.Fill(";STOREI",op2,r_val,""); 
				IR.push_back(toInsert);
				toInsert.clear();	
		}
	}
	
	toInsert.Fill(";UNLINK","","","");
	IR.push_back(toInsert);
	toInsert.clear();

	toInsert.Fill(";RET","","","");
	IR.push_back(toInsert);
	toInsert.clear();
	tempCntr++;
	return r_val;
}


string VAR::TOIR()
{
	if ( sym->offset != 0) {
		sym->name = GenV(sym->offset);
	}
	return (sym->name);
}

string LITERAL::TOIR()
{
//	printf("FILE %s, LINE %d\n", __FILE__, __LINE__);
	string tmp = GenTmp();
	if(type == "INT"){
		toInsert.Fill(";STOREI",varval, tmp, "");
		IR.push_back(toInsert);
		toInsert.clear();
		tempCntr++;
		return tmp;
	} 
	else if (type == "FLOAT") {
		if (varval.substr(0,2) == "!T" || tmp.substr(0,2) == "!T")
		{
			toInsert.Fill(";STOREF",varval, tmp, "");
			IR.push_back(toInsert);
			tempCntr++;
			toInsert.clear();
		}
		return tmp;
	}
	return varval;

}

string ARITH::TOIR()
{

	string op1, op2, tmp;
	op1 = op2 = tmp = "";
	if(left){

		op1 = left->TOIR();
	}

	if(right){

		op2 = right->TOIR();
	}
	tmp = GenTmp();	

	if(left->type == "INT" || right->type == "INT") {
		if(operate == ":=")
		{

			if (op1.substr(0,1) == "$" && op2.substr(0,1) == "$")
			{
			toInsert.Fill(";STOREI",op1, tmp, "");
			IR.push_back(toInsert);
			toInsert.clear();
			
			toInsert.Fill(";STOREI", tmp, op2, "");
			IR.push_back(toInsert);
			toInsert.clear();
			tempCntr++;			


			}
			else if (op2.substr(0,1) != "!T")
			{
			toInsert.Fill(";STOREI",op1, tmp, "");
			IR.push_back(toInsert);
			toInsert.clear();
			
			toInsert.Fill(";STOREI", tmp, op2, "");
			IR.push_back(toInsert);
			toInsert.clear();
			tempCntr++;			


			}
			else {

			toInsert.Fill(";STOREI",op1, op2, "");
			IR.push_back(toInsert);
			toInsert.clear();
			
			}

			return tmp;
		}

		if(operate == "+"){
			toInsert.Fill(";ADDI",op1, op2, tmp);
			IR.push_back(toInsert);
			toInsert.clear();
			tempCntr++;
			return tmp;
		} 
		if(operate == "-"){
			toInsert.Fill(";SUBI",op1, op2, tmp);
			IR.push_back(toInsert);
			toInsert.clear();
			tempCntr++;

			return tmp;
		} 
		if(operate == "*"){
			toInsert.Fill(";MULI",op1, op2, tmp);
			IR.push_back(toInsert);
			toInsert.clear();
			tempCntr++;

			return tmp;
		} 
		if(operate == "/"){
			toInsert.Fill(";DIVI",op1, op2, tmp);
			IR.push_back(toInsert);
			toInsert.clear();
			tempCntr++;
			return tmp;
		} 

	}
	else //if(left->type == "FLOAT" && right->type == "FLOAT")
	{
		if(operate == ":=")
		{	
			if (op1.substr(0,1) == "$" && op2.substr(0,1) == "$")
			{
			toInsert.Fill(";STOREF",op1, tmp, "");
			IR.push_back(toInsert);
			toInsert.clear();
			
			toInsert.Fill(";STOREF", tmp, op2, "");
			IR.push_back(toInsert);
			toInsert.clear();
			tempCntr++;			


			}
			else if (op2.substr(0,1) != "!T")
			{
			toInsert.Fill(";STOREF",op1, tmp, "");
			IR.push_back(toInsert);
			toInsert.clear();
			
			toInsert.Fill(";STOREF", tmp, op2, "");
			IR.push_back(toInsert);
			toInsert.clear();
			tempCntr++;			


			}
			else {

			toInsert.Fill(";STOREF",op1, op2, "");
			IR.push_back(toInsert);
			toInsert.clear();
			
			}

			return tmp;

		}

		if(operate == "+"){
		toInsert.Fill(";ADDF",op1, op2, tmp);
		IR.push_back(toInsert);
		toInsert.clear();
		tempCntr++;

		return tmp;
		} 
		if(operate == "-"){
			toInsert.Fill(";SUBF",op1, op2, tmp);
			IR.push_back(toInsert);
			toInsert.clear();
			tempCntr++;

			return tmp;
		} 
		if(operate == "*"){
			toInsert.Fill(";MULF",op1, op2, tmp);
			IR.push_back(toInsert);
			toInsert.clear();
			tempCntr++;

			return tmp;
		} 
		if(operate == "/"){
			toInsert.Fill(";DIVF",op1, op2, tmp);
			IR.push_back(toInsert);
			toInsert.clear();
			tempCntr++;

			return tmp;
		} 

	
	}
//	return "";
}

void ARITH::leftchild( AST * node)
{
	left = node;
}
void ARITH::rightchild( AST * node)
{
	right = node;
}

string IO::TOIR()
{
	string myID, tmp;
	myID = tmp = "";
	tmp = GenTmp();
	if(name == "READ")
	{
		for (int i = 0; i < vst.size(); i++) {
		Symbol* mysym = vst[i];
	/*	cout << "THIS IS A TEST IN READ " << vst[i]->name << endl; */
		if(mysym->type == "INT")
		{
				toInsert.Fill(";READI",mysym->name, "", ""  );
				IR.push_back(toInsert);
				toInsert.clear();
		}
		else if(mysym->type == "FLOAT")
		{
			toInsert.Fill(";READF",mysym->name, "", ""  );
			IR.push_back(toInsert);
			toInsert.clear();
		}
		else
		{
			toInsert.Fill(";READS",mysym->name, "", ""  );
			IR.push_back(toInsert);
			toInsert.clear();
		}	
		}
		return tmp;
	}
	else if(name == "WRITE")
	{
		for (int i = 0; i < vst.size(); i++)
/*	for(int i = vst.size()-1; i >= 0; --i)	*/
		{
		Symbol* mysym = vst[i];
	/*	cout << "THIS IS A TEST IN WRITE " << vst[i]->name << endl; */

		if(mysym->type == "INT")
		{
			toInsert.Fill(";WRITEI",mysym->name, "", ""  );
			IR.push_back(toInsert);
			toInsert.clear();

		}
		else if(mysym->type == "FLOAT")
		{
			toInsert.Fill(";WRITEF",mysym->name, "", ""  );
			IR.push_back(toInsert);
			toInsert.clear();
		}
		else
		{
			toInsert.Fill(";WRITES",mysym->name, "", ""  );
			IR.push_back(toInsert);
			toInsert.clear();
		}
		}
		return tmp;
	}

}
