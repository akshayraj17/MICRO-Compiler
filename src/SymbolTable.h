#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include <map>
#include <vector>
#include <iostream>
#include <string>

using namespace std; 

class Symbol {
public: 
	Symbol(std::string n, std::string t, std::string v, int o): name(n), type(t), value(v), offset(o) {}
	Symbol(std::string n, std::string t, std::string v,std::string label, int o): name(n), type(t),value(v), offset(o){
		local_map[n] = label;
		lflag = 1;
	}

	~Symbol(){}
	std::string  name;
	std::string type;
	std::string value;
	int lflag;
	int offset;
	map <string, string> local_map;
};



class SymbolTable {
public:
	SymbolTable(std::string s, SymbolTable* p): scopes(s), parent(p){num_param = 0; funcflag = 0;};
	SymbolTable(std::string s, SymbolTable* p, int f): scopes(s), parent(p), funcflag(f){num_param = 0;};
	~SymbolTable(){};
	std::string scopes;  
	SymbolTable* parent; 
	std::vector<SymbolTable *>children;
	std::map<std::string, Symbol*>table;
	std::vector<Symbol*> myvect;
	int funcflag;
	int num_param;
	int local_count;
	//add a flag to check if func
	
	void printvect()
	{
		for (int i = 0; i < myvect.size(); i++) {
				if(myvect[i]->type == "str")
				{
				//	cout << "str " << myvect[i]->name << " " << myvect[i]->value << endl;
				}
				else{
				cout << "var " << myvect[i]->name << endl;
				}

		}
	}
	int findOffset() {
		for (int i = 0; i < myvect.size(); i++) {
			if(myvect[i]->offset < 0)
			{
				return 1;
			}
		}
	}
	
	int findFuncParam() {
		if(funcflag != 0) {
			return num_param + 2;
		}
		
		parent->findFuncParam();

	}	
	
	int findLocalCount() {
		if(funcflag != 0) {
			return local_count;
			
		}
		parent -> findLocalCount();
		return 0;
	}

	Symbol* FindSymbol(string s) {
		auto found = table.find(s);
		if(found == table.end()){
			if(parent != NULL)
				return parent->FindSymbol(s);
			else{
				cout<<"Couldn't find symbol at all\n";
				exit(0);
			}	
		}
		return found->second;
	}

	void InsertSymbol(Symbol* sym){
		if(table.find(sym->name) != table.end()){
			exit(0);
		}

		table.insert(std::make_pair(sym->name, sym));
		myvect.push_back(sym);
		if(sym->offset > 0 ){ ++num_param;}
		if(sym->offset < 0 ){ ++local_count;}
	}
	void PrintTables(){
				
		//std::cout<<"Symbol table "<<scopes<<"\n";
		for(int i = 0; i < myvect.size(); ++i){
		if(myvect[i]->type == "str"){
			std::cout<<myvect[i]->type<< " "<<myvect[i]->name<<" "<<myvect[i]->value  << endl;     // <<myvect[i]->offset<<"\n";
			}

	}
		
	for(int i = 0; i < children.size(); ++i){
			children[i]->PrintTables();
	}
	}
		
};


#endif /*SYMBOLTABLE_H*/
