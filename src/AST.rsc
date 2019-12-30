module AST

/*
 * Define Abstract Syntax for QL
 *
 * - complete the following data types
 * - make sure there is an almost one-to-one correspondence with the grammar
 */

data AForm(loc src = |tmp:///|)
  = form(str name, list[AQuestion] questions)
  ; 

data AQuestion(loc src = |tmp:///|)
  = question(str label, AId id, AType \type)
  | question(str label, AId id, AType \type, AExpr expr) // maybe rename to computed_question?
  | \if(AExpr condition, list[AQuestion] questions)
  | if_else(AExpr condition, list[AQuestion] questions, list[AQuestion] alt_questions)
  ;

data AExpr(loc src = |tmp:///|)
  = ref(AId id)
  | mul(AExpr lhs, AExpr rhs)
  | div(AExpr lhs, AExpr rhs)
  | add(AExpr lhs, AExpr rhs)
  | sub(AExpr lhs, AExpr rhs)
  | neg(AExpr expr)
  | gt(AExpr lhs, AExpr rhs)
  | geq(AExpr lhs, AExpr rhs)
  | lt(AExpr lhs, AExpr rhs)
  | leq(AExpr lhs, AExpr rhs)
  | eql(AExpr lhs, AExpr rhs)
  | neq(AExpr lhs, AExpr rhs)
  | and(AExpr lhs, AExpr rhs)
  | or(AExpr lhs, AExpr rhs)
  | lit(bool boolean)
  | lit(int integer)
  | lit(str string)
  ;

data AId(loc src = |tmp:///|)
  = id(str name);

data AType(loc src = |tmp:///|)
  = boolean() | integer() | string();