module Transform

import Syntax;
import Resolve;
import AST;
import ParseTree; // necessary for `x@\loc`

/* 
 * Transforming QL forms
 */
 
 
/* Normalization:
 *  wrt to the semantics of QL the following
 *     q0: "" int; 
 *     if (a) { 
 *        if (b) { 
 *          q1: "" int; 
 *        } 
 *        q2: "" int; 
 *      }
 *
 *  is equivalent to
 *     if (true) q0: "" int;
 *     if (true && a && b) q1: "" int;
 *     if (true && a) q2: "" int;
 *
 * Write a transformation that performs this flattening transformation.
 *
 */
 
AForm flatten(AForm f) {
  return f; 
}

start[Form] rename(start[Form] f, loc useOrDef, str newName, RefGraph refs) {
  Id new = [Id] newName;

  return visit(f) {
    case (Expr) `<Id x>` => (Expr) `<Id new>`
      when
        (<useOrDef, loc def> <- refs.useDef || def := useOrDef), // assign definition location to `def`
        use := x@\loc, <use, def> <- refs.useDef // transform if current node is in the uses of `def`

    case (Question) `<Str label> <Id x> : <Type t>` => (Question) `<Str label> <Id new> : <Type t>`
      when
        (<useOrDef, loc def> <- refs.useDef || def := useOrDef),
        def == x@\loc

    case (Question) `<Str label> <Id x> : <Type t> = <Expr expr>` => (Question) `<Str label> <Id new> : <Type t> = <Expr expr>`
      when
        (<useOrDef, loc def> <- refs.useDef || def := useOrDef),
        def == x@\loc
  }
}
