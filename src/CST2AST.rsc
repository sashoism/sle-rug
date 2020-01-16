module CST2AST

import Syntax;
import AST;

import ParseTree;
import String;

import Boolean;

AForm cst2ast(start[Form] sf) {
  Form f = sf.top;
  switch (f) {
	case (Form) `form <Id title> { <Question* qs> }`:
	  return form("<title>", [ cst2ast(q) | Question q <- qs ], src=f@\loc);
	default: throw "Unhandled form: <f>";
  }
}

AQuestion cst2ast(Question q) {
  switch (q) {
  	case (Question) `<Str label> <Id x> : <Type t>`:
  		return question("<label>"[1..-1], id("<x>", src=x@\loc), cst2ast(t), src=q@\loc);
  	case (Question) `<Str label> <Id x> : <Type t> = <Expr expr>`:
  		return question("<label>"[1..-1], id("<x>", src=x@\loc), cst2ast(t), cst2ast(expr), src=q@\loc);
  	case (Question) `if ( <Expr condition> ) { <Question* qs> }`:
  		return \if(cst2ast(condition), [ cst2ast(q) | Question q <- qs ], src=q@\loc);
	case (Question) `if ( <Expr condition> ) { <Question* qs> } else { <Question* alt_qs> }`:
  		return if_else(cst2ast(condition),
					[ cst2ast(q) | Question q <- qs ],
					[ cst2ast(q) | Question q <- alt_qs ], src=q@\loc
  				);
	default: throw "Unhandled question: <q>";
  }
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Id x>`: return ref(id("<x>", src=x@\loc), src=x@\loc);
    case (Expr)`( <Expr expr> )`: return cst2ast(expr);

    case (Expr)`<Expr lhs> * <Expr rhs>`: return mul(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case (Expr)`<Expr lhs> / <Expr rhs>`: return div(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case (Expr)`<Expr lhs> + <Expr rhs>`: return add(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case (Expr)`<Expr lhs> - <Expr rhs>`: return sub(cst2ast(lhs), cst2ast(rhs), src=e@\loc);

    case (Expr)`!<Expr expr>`: return neg(cst2ast(expr), src=e@\loc);
    case (Expr)`<Expr lhs> \> <Expr rhs>`: return gt(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case (Expr)`<Expr lhs> \>= <Expr rhs>`: return geq(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case (Expr)`<Expr lhs> \< <Expr rhs>`: return lt(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case (Expr)`<Expr lhs> \<= <Expr rhs>`: return leq(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case (Expr)`<Expr lhs> == <Expr rhs>`: return eql(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case (Expr)`<Expr lhs> != <Expr rhs>`: return neq(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case (Expr)`<Expr lhs> && <Expr rhs>`: return and(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case (Expr)`<Expr lhs> || <Expr rhs>`: return or(cst2ast(lhs), cst2ast(rhs), src=e@\loc);

    case (Expr)`<Bool val>`: return lit(fromString("<val>"), src=val@\loc);
    case (Expr)`<Int val>`: return lit(toInt("<val>"), src=val@\loc);
    case (Expr)`<Str val>`: return lit("<val>"[1..-1], src=val@\loc);

    default: throw "Unhandled expression: <e>";
  }
}

AType cst2ast(Type t) {
  switch (t) {
  	case (Type) `boolean`:
  		return boolean(src = t@\loc);
  	case (Type) `integer`:
  		return integer(src = t@\loc);
  	case (Type) `string`:
  		return string(src = t@\loc);
  }
}
