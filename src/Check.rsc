module Check

import AST;
import Resolve;
import Message; // see standard library
import IO;
import Set;
import List;

data Type
  = tint()
  | tbool()
  | tstr()
  | tunknown()
  ;

// the type environment consisting of defined questions in the form 
alias TEnv = rel[loc def, str name, str label, Type \type];

Type atype2type(AType t) {
  switch(t) {
    case integer():
      return tint();
    case boolean():
      return tbool();
    case string():
      return tstr();
    default:
      return tunknown();
  }
}

// To avoid recursively traversing the form, use the `visit` construct
// or deep match (e.g., `for (/question(...) := f) {...}` ) 
TEnv collect(AForm f) {
  return { <id.src, id.name, label, atype2type(\type)> | /question(label, AId id, AType \type) := f } + { <id.src, id.name, label, atype2type(\type)> | /question(label, AId id, AType \type, _) := f };
}

set[Message] check(AForm f, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  for (q <- f.questions) {
    msgs += check(q, tenv, useDef);
  }
  return msgs; 
}

// - produce an error if there are declared questions with the same name but different types.
// - duplicate labels should trigger a warning 
// - the declared type computed questions should match the type of the expression.
set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  switch (q) {
    case question(label, id(name, src = loc this), \type): {
      msgs += { error("Redeclaration of question with a different type", this) | <loc that, name, _, Type t> <- tenv, t != atype2type(\type), this.begin > that.end };
      msgs += { warning("Duplicate question label", q.src) | <loc that, _, label, _> <- tenv, this.begin > that.end };
    }
    case question(label, id(name, src = loc this), \type, e): {
      msgs += { error("Redeclaration of question with a different type", this) | <loc that, name, _, Type t> <- tenv, t != atype2type(\type), this.begin > that.end };
      msgs += { warning("Redeclaration of question label", q.src) | <loc that, _, label, _> <- tenv, this.begin > that.end };
      msgs += { error("Expression type must match declared question type", e.src) | typeOf(e, tenv, useDef) != atype2type(\type) } + check(e, tenv, useDef);
    }
    case \if(condition, qs):
      msgs += check(condition, tenv, useDef) + { error("Condition of `if` statement must be of type `boolean`", condition.src) | typeOf(condition, tenv, useDef) != tbool() } + { *check(q, tenv, useDef) | AQuestion q <- qs };

    case if_else(condition, qs, alt_qs):
      msgs += check(condition, tenv, useDef) + { error("Condition of `if` statement must be of type `boolean`", condition.src) | typeOf(condition, tenv, useDef) != tbool() } + { *check(q, tenv, useDef) | AQuestion q <- (qs + alt_qs) };
  }
  
  return msgs;
}

// Check operand compatibility with operators.
// E.g. for an addition node add(lhs, rhs), 
//   the requirement is that typeOf(lhs) == typeOf(rhs) == tint()
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch (e) {
    case ref(AId x):
      msgs += { error("Undeclared question", x.src) | useDef[x.src] == {} };

    case mul(AExpr lhs, AExpr rhs):
      msgs += { error("Left operand of `*` must be of type `integer`", lhs.src) | typeOf(lhs, tenv, useDef) != tint() } + { error("Right operand of `*` must be of type `integer`", rhs.src) | typeOf(rhs, tenv, useDef) != tint() } + check(lhs, tenv, useDef) + check(rhs, tenv, useDef);

    case div(AExpr lhs, AExpr rhs):
      msgs += { error("Left operand of `/` must be of type `integer`", lhs.src) | typeOf(lhs, tenv, useDef) != tint() } + { error("Right operand of `/` must be of type `integer`", rhs.src) | typeOf(rhs, tenv, useDef) != tint() } + check(lhs, tenv, useDef) + check(rhs, tenv, useDef);

    case add(AExpr lhs, AExpr rhs):
      msgs += { error("Left operand of `+` must be of type `integer`", lhs.src) | typeOf(lhs, tenv, useDef) != tint() } + { error("Right operand of `+` must be of type `integer`", rhs.src) | typeOf(rhs, tenv, useDef) != tint() } + check(lhs, tenv, useDef) + check(rhs, tenv, useDef);

    case sub(AExpr lhs, AExpr rhs):
      msgs += { error("Left operand of `-` must be of type `integer`", lhs.src) | typeOf(lhs, tenv, useDef) != tint() } + { error("Right operand of `-` must be of type `integer`", rhs.src) | typeOf(rhs, tenv, useDef) != tint() } + check(lhs, tenv, useDef) + check(rhs, tenv, useDef);

    case gt(AExpr lhs, AExpr rhs):
      msgs += { error("Left operand of `\>` must be of type `integer`", lhs.src) | typeOf(lhs, tenv, useDef) != tint() } + { error("Right operand of `\>` must be of type `integer`", e.src) | typeOf(rhs, tenv, useDef) != tint() } + check(lhs, tenv, useDef) + check(rhs, tenv, useDef);

    case geq(AExpr lhs, AExpr rhs):
      msgs += { error("Left operand of `\>=` must be of type `integer`", lhs.src) | typeOf(lhs, tenv, useDef) != tint() } + { error("Right operand of `\>=` must be of type `integer`", e.src) | typeOf(rhs, tenv, useDef) != tint() } + check(lhs, tenv, useDef) + check(rhs, tenv, useDef);

    case lt(AExpr lhs, AExpr rhs):
      msgs += { error("Left operand of `\<` must be of type `integer`", lhs.src) | typeOf(lhs, tenv, useDef) != tint() } + { error("Right operand of `\<` must be of type `integer`", e.src) | typeOf(rhs, tenv, useDef) != tint() } + check(lhs, tenv, useDef) + check(rhs, tenv, useDef);

    case leq(AExpr lhs, AExpr rhs):
      msgs += { error("Left operand of `\<=` must be of type `integer`", lhs.src) | typeOf(lhs, tenv, useDef) != tint() } + { error("Right operand of `\<=` must be of type `integer`", e.src) | typeOf(rhs, tenv, useDef) != tint() } + check(lhs, tenv, useDef) + check(rhs, tenv, useDef);

    case and(AExpr lhs, AExpr rhs):
      msgs += { error("Left operand of `&&` must be of type `boolean`", lhs.src) | typeOf(lhs, tenv, useDef) != tint() } + { error("Right operand of `&&` must be of type `boolean`", rhs.src) | typeOf(rhs, tenv, useDef) != tint() } + check(lhs, tenv, useDef) + check(rhs, tenv, useDef);

    case or(AExpr lhs, AExpr rhs):
      msgs += { error("Left operand of `||` must be of type `boolean`", lhs.src) | typeOf(lhs, tenv, useDef) != tint() } + { error("Right operand of `||` must be of type `boolean`", rhs.src) | typeOf(rhs, tenv, useDef) != tint() } + check(lhs, tenv, useDef) + check(rhs, tenv, useDef);

    case neg(AExpr expr):
      msgs += { error("Operand of `!` must be of type `boolean`", expr.src) | typeOf(expr) != tbool() } + check(expr, tenv, useDef);

    case eql(AExpr lhs, AExpr rhs):
      msgs += { error("Operands of `==` must be of the same type", e.src) | typeOf(lhs, tenv, useDef) != typeOf(rhs, tenv, useDef) } + check(lhs, tenv, useDef) + check(rhs, tenv, useDef);

    case neq(AExpr lhs, AExpr rhs):
      msgs += { error("Operands of `!=` must be of the same type", e.src) | typeOf(lhs, tenv, useDef) != typeOf(rhs, tenv, useDef) } + check(lhs, tenv, useDef) + check(rhs, tenv, useDef);
  }
  
  return msgs; 
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    // variables
    case ref(id(_, src = loc u)):  
      if (<u, loc d> <- useDef, <d, x, _, Type t> <- tenv) {
        return t;
      }

    // arithmetic
    case mul(_, _):
      return tint();
    case div(_, _):
      return tint();
    case add(_, _):
      return tint();
    case sub(_, _):
      return tint();

    // conditionals
    case neg(_):
      return tbool();
    case gt(_, _):
      return tbool();
    case geq(_, _):
      return tbool();
    case lt(_, _):
      return tbool();
    case leq(_, _):
      return tbool();
    case eql(_, _):
      return tbool();
    case neq(_, _):
      return tbool();
    case and(_, _):
      return tbool();
    case or(_, _):
      return tbool();

    // literals
    case lit(bool _):
      return tbool();
    case lit(int _):
      return tint();
    case lit(str _):
      return tstr();
  }

  return tunknown(); 
}

/* 
 * Pattern-based dispatch style:
 * 
 * Type typeOf(ref(id(_, src = loc u)), TEnv tenv, UseDef useDef) = t
 *   when <u, loc d> <- useDef, <d, x, _, Type t> <- tenv
 *
 * ... etc.
 * 
 * default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();
 *
 */
 
 

