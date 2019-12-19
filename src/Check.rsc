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

Type convert(AType t) {
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
  return { <id.src, id.name, label, convert(\type)> | /question(label, AId id, AType \type) := f } +
  		 { <id.src, id.name, label, convert(\type)> | /question(label, AId id, AType \type, _) := f };
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
  	case question(str label, AId id, AType t): {
  		name = id.name; src = id.src;
  		if (size({ t | <_, name, _, Type t> <- tenv }) > 1) {
  			msgs += { error("Two questions with the same name but different type", src) };
  		}
  		if (size([src | <loc src, _, label, _> <- tenv]) > 1) {
  			msgs += { warning("Duplicate question labels <label>", src) };
  		}
  	}
  	case question(str label, AId id, AType t, AExpr e): {
  		name = id.name; src = id.src;
  		if (size({ t | <_, name, _, Type t> <- tenv }) > 1) {
  			msgs += { error("Two questions with the same name but different type", src) };
  		}
  		// check typeOf(e) == t
  	}
  	case \if(condition, qs):
  		msgs += { check(q, tenv, useDef) | q <- qs };
  	case \if_else(condition, qs, alt_qs):
  		msgs += { check(q, tenv, useDef) | q <- (qs + alt_qs) }; 
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

    // etc.
  }
  
  return msgs; 
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    case ref(id(_, src = loc u)):  
      if (<u, loc d> <- useDef, <d, x, _, Type t> <- tenv) {
        return t;
      }
    // etc.
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
 
 

