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
  = Str Type
  | "if (" Expr ")" "{" Question* "}" ("else {" Question "}")?
  ; 

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr 
  = Id \ "true" \ "false" // true/false are reserved keywords.
  | right "!" Expr 
  > left Expr ("+" | "-" | "*" | "/" | "&&" | "||" | "\>" | "\<" | "\>=" | "\<=" | "==" | "!=") Expr
  | Bool
  | Int
  | Str
  ;
  
syntax Type = Id ":" ("boolean" | "integer" | "string") ("=" Expr)?;
  
lexical Str = [\"] ![\"]* [\"];

lexical Int
 = "0"
 | [1-9][0-9]*
 ;

lexical Bool
 = "true"
 | "false"
 ;
