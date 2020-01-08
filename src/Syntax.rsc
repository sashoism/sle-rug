module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */
 
keyword Reserved = "form" | "if" | "else" | "boolean" | "integer" | "string" | "true" | "false";
lexical Ident = Id \ Reserved;

start syntax Form 
 = "form" Ident "{" Question* "}";

// TODO: question, computed question, block, if-then-else, if-then
syntax Question
 = Str Ident ":" Type
 | Str Ident ":" Type "=" Expr
 | "if (" Expr ")" "{" Question* "}"
 | "if (" Expr ")" "{" Question* "}" "else" "{" Question* "}"
 ;

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)

syntax Expr 
 = Ident
 | bracket "(" Expr ")"
 > right neg: "!" Expr
 > left (
    mul: Expr "*" Expr
  | div: Expr "/" Expr
 )
 > left (
    add: Expr "+" Expr
  | sub: Expr "-" Expr
 )
 > non-assoc (
    gt: Expr "\>" Expr
  | geq: Expr "\>=" Expr
  | lt: Expr "\<" Expr
  | leq: Expr "\<=" Expr
 )
 > non-assoc ( // the (in-) equality operator is better off non-associative, enforcing parentheses
    eql: Expr "==" Expr
  | neq: Expr "!=" Expr
 )
 > left and: Expr "&&" Expr
 > left or: Expr "||" Expr
 | \bool: Bool
 | \int: Int
 | \str: Str
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
