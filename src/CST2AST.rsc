module CST2AST

import Syntax;
import AST;

import ParseTree;
import String;

import Boolean;

/*
 * Implement a mapping from concrete syntax trees (CSTs) to abstract syntax trees (ASTs)
 *
 * - Use switch to do case distinction with concrete patterns (like in Hack your JS) 
 * - Map regular CST arguments (e.g., *, +, ?) to lists 
 *   (NB: you can iterate over * / + arguments using `<-` in comprehensions or for-loops).
 * - Map lexical nodes to Rascal primitive types (bool, int, str)
 * - See the ref example on how to obtain and propagate source locations.
 */

AForm cst2ast(start[Form] sf) {
  Form f = sf.top; // remove layout before and after form
  switch (f) {
	case (Form) `form <Ident title> { <Question* qs> }`:
	  return form("<title>", [ cst2ast(q) | Question q <- qs ], src=f@\loc);
	default: throw "Unhandled form expression: <f>";
  }
}

AQuestion cst2ast(Question q) {
  switch (q) {
  	case (Question) `<Str label> <Id var> : <Type t>`:
  		return question("<label>"[1..-1], id("<var>"), cst2ast(t));
  	case (Question) `<Str label> <Id var> : <Type t> = <Expr expr>`:
  		return question("<label>"[1..-1], id("<var>"), cst2ast(t), cst2ast(expr));
  	case (Question) `if ( <Expr condition> ) { <Question* qs> }`:
  		return \if(cst2ast(condition), [ cst2ast(q) | Question q <- qs ]);
	case (Question) `if ( <Expr condition> ) { <Question* qs> } else { <Question* alt_qs> }`:
  		return \if_else(cst2ast(condition),
					[ cst2ast(q) | Question q <- qs ],
  					[ cst2ast(q) | Question q <- alt_qs ]
  				);
  }
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Ident x>`: return ref(id("<x>", src=x@\loc), src=x@\loc);
    case (Expr)`( <Expr expr> )`: return cst2ast(expr);
    case (Expr)`!<Expr expr>`: return neg(cst2ast(expr));
    case (Expr)`<Expr lhs> * <Expr rhs>`: return mul(cst2ast(lhs), cst2ast(rhs));
    case (Expr)`<Expr lhs> / <Expr rhs>`: return div(cst2ast(lhs), cst2ast(rhs));
    case (Expr)`<Expr lhs> + <Expr rhs>`: return add(cst2ast(lhs), cst2ast(rhs));
    case (Expr)`<Expr lhs> - <Expr rhs>`: return sub(cst2ast(lhs), cst2ast(rhs));
    case (Expr)`<Expr lhs> \> <Expr rhs>`: return gt(cst2ast(lhs), cst2ast(rhs));
    case (Expr)`<Expr lhs> \>= <Expr rhs>`: return geq(cst2ast(lhs), cst2ast(rhs));
    case (Expr)`<Expr lhs> \< <Expr rhs>`: return lt(cst2ast(lhs), cst2ast(rhs));
    case (Expr)`<Expr lhs> \<= <Expr rhs>`: return leq(cst2ast(lhs), cst2ast(rhs));
    case (Expr)`<Expr lhs> == <Expr rhs>`: return eql(cst2ast(lhs), cst2ast(rhs));
    case (Expr)`<Expr lhs> != <Expr rhs>`: return neq(cst2ast(lhs), cst2ast(rhs));
    case (Expr)`<Expr lhs> && <Expr rhs>`: return and(cst2ast(lhs), cst2ast(rhs));
    case (Expr)`<Expr lhs> || <Expr rhs>`: return or(cst2ast(lhs), cst2ast(rhs));
    case (Expr)`<Bool val>`: return \bool(fromString("<val>"));
    case (Expr)`<Int val>`: return \int(toInt("<val>"));
    case (Expr)`<Str val>`: return \str("<val>"[1..-1]);
    default: throw "Unhandled expression: <e>";
  }
}

AType cst2ast(Type t) {
  switch (t) {
  	case (Type) `boolean`:
  		return boolean();
  	case (Type) `integer`:
  		return integer();
  	case (Type) `string`:
  		return string();
  }
}
