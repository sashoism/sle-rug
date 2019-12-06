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
 = Id \ "true" \ "false" \ "boolean" \ "integer" \ "string"
 | right neg: "!" Expr
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
 > non-assoc (
    eq: Expr "==" Expr
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
