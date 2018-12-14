#ifndef AST_H
#define AST_H
#include <map>
#include <vector>
#include <list>
#include <iostream>
#include <set>
#include <string>
#include "../src/SymbolTable.h"

using namespace std; 

static int g_local_var_count = 0;
static int g_parameter_count = 0;
static int g_reg_count = 0;


class ThreeAC{
	public:
		string opcode, op1, op2, res;
		set<string> gen, kill, live_in, live_out;
		int successor, predecessor; 
		ThreeAC(){}
		ThreeAC(string o,string o1,string o2,string r):opcode(o), op1(o1), op2(o2), res(r){}
		void Fill(string o, string o1, string o2, string r);
		void clear();
};


class AST {
	public:
		AST(string t): type(t){}
		AST(){}
		virtual ~AST(){}
		string type;
		virtual string TOIR() = 0;

};

class IF_NODE: public AST{
	public: 
		IF_NODE(AST * l, vector<AST*> m, vector<AST*> r) {
			this->left = l;
			vector<AST*>::iterator i,j;
			for ( i = m.begin(); i != m.end(); i++)
			{
				mid.push_back(*i); 
			}
			for ( j = r.begin(); j != r.end(); j++)
			{

				right.push_back(*j); 
			}

		}
		~IF_NODE(){}
		AST * left;
		vector<AST*> mid;
		vector<AST*> right;
		string TOIR();

};

class condition: public AST{
	public: 
		condition(AST * l, string o, AST * r): left(l), operation(o), right(r) {}
		~condition(){}
		string operation;
		AST * left;
		AST * right;
		string TOIR();

};

class WHILE_NODE: public AST{
	public: 
		WHILE_NODE(AST * l, vector<AST*> r): left(l), right(r){}
		~WHILE_NODE(){}
		AST * left;
		vector <AST*> right;
		string TOIR();
};

class VAR: public AST{ 
	public:
		VAR(Symbol *s): sym(s), AST(s->type){}
		~VAR(){}
		Symbol * sym;
		string TOIR();

};

class LITERAL: public AST {
	public:
		LITERAL(string s, string t): varval(s) , AST(t) {}
		~LITERAL(){}
		string varval; 
		string TOIR();

};

class FuncNode : public AST{
	public:
		string func_name;
		int local_count;
  		int paramater_count;
  		int register_count;

		vector<AST*> stmt_list;
		string TOIR();
		~FuncNode(){}
		FuncNode(string fn, vector<AST*> sl,int lc):func_name(fn), stmt_list(sl),local_count(lc){}


};

class CallNode: public AST {
	public:
		CallNode(string i, vector<AST*> anode, int r): id(i), expr_list(anode), ret(r){}
		~CallNode(){}
		string id;
		int ret;
		vector<AST*> expr_list;
		string TOIR();
};

class RetNode : public AST{
	public:
		int ret_val;
		string TOIR();
		AST * expr;
		RetNode(AST * e,int re):expr(e), ret_val(re){}
		~RetNode(){};
		RetNode(){};
};

class ARITH: public AST {
	public:
		ARITH(string s):operate(s){}
		~ARITH(){}
		string operate;
		AST * left;
		AST * right;
		void leftchild(AST * node);
		void rightchild(AST * node);
		string TOIR();
};
class IO: public AST {
	public:
		IO(string s):name(s){}
		IO(string s, Symbol * mys): name(s), mysym(mys) {}
		~IO(){}
		vector<Symbol *> vst;
		string name;
		Symbol * mysym;
		string TOIR();
};




#endif /*AST_H*/
