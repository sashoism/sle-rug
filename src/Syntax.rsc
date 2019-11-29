module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form 
 = "form" Id "{" Question* "}";

// TODO: question, computed question, block, if-then-else, if-then
syntax Question
 = Str Id ":" Type
 | Str Id ":" Type "=" Expr
 | "if (" Expr ")" "{" Question* "}"
 | "if (" Expr ")" "{" Question* "}" "else" "{" Question* "}"
 ;

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr 
 = Id \ Bool \ Type
 | right "!" Expr
 > left Expr ("*" | "/") Expr
 > left Expr ("+" | "-") Expr
 > left Expr ("\<" | "\<=" | "\>" | "\>=") Expr
 > left Expr ("==" | "!=") Expr
 > left Expr "&&" Expr
 > left Expr "||" Expr
 | Bool
 | Int
 | Str
 ;

syntax Type
 = "boolean"
 | "integer"
 | "string"
 ;

lexical Bool
 = "true"
 | "false"
 ;

lexical Int
 = "0"
 | [1-9][0-9]*
 ;

lexical Str = [\"] ![\"]* [\"];
