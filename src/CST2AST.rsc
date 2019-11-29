module CST2AST

import Syntax;
import AST;

import ParseTree;
import String;

/*
 * Implement a mapping from concrete syntax trees (CSTs) to abstract syntax trees (ASTs)
 *
 * - Use switch to do case distinction with concrete patterns (like in Hack your JS) 
 * - Map regular CST arguments (e.g., *, +, ?) to lists 
 *   (NB: you can iterate over * / + arguments using `<-` in comprehensions or for-loops).
 * - Map lexical nodes to Rascal primitive types (bool, int, str)
 * - See the ref example on how to obtain and propagate source locations.
 */

AForm cst2ast(start[Form] sf)
 = cst2ast(sf.top);

AForm cst2ast((Form) `form <Id title> { <Question* qs> }`)
 = form("<title>", [ cst2ast(q) | Question q <- qs ]);

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
    case (Expr)`<Id x>`: return ref(id("<x>"));
    
    // etc.
    
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
