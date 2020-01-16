module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */


keyword Reserved = "form" | "if" | "else" | "boolean" | "integer" | "string" | "true" | "false";

start syntax Form 
 = "form" Id \ Reserved "{" Question* "}";

syntax Question
 = Str Id \ Reserved ":" Type
 | Str Id \ Reserved ":" Type "=" Expr
 | "if (" Expr ")" "{" Question* "}"
 | "if (" Expr ")" "{" Question* "}" "else" "{" Question* "}"
 ;

syntax Expr 
 = Id \ Reserved
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
