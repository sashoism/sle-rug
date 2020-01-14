module Eval

import AST;
import Resolve;

/*
 * Implement big-step semantics for QL
 */
 
// NB: Eval may assume the form is type- and name-correct.


// Semantic domain for expressions (values)
data Value
  = vint(int n)
  | vbool(bool b)
  | vstr(str s)
  ;

// The value environment
alias VEnv = map[str name, Value \value];

// Modeling user input
data Input
  = input(str question, Value \value);
  
// produce an environment which for each question has a default value
// (e.g. 0 for int, "" for str etc.)
VEnv initialEnv(AForm f) {
  return ();
}


// Because of out-of-order use and declaration of questions
// we use the solve primitive in Rascal to find the fixpoint of venv.
VEnv eval(AForm f, Input inp, VEnv venv) {
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}

VEnv evalOnce(AForm f, Input inp, VEnv venv) {
  return (); 
}

VEnv eval(AQuestion q, Input inp, VEnv venv) {
  // evaluate conditions for branching,
  // evaluate inp and computed questions to return updated VEnv
  return (); 
}

Value eval(AExpr e, VEnv venv) {
  switch (e) {
  	case ref(str x): return venv[x];
    case mul(Expr lhs, Expr rhs): return eval(lhs, env, penv) * eval(rhs, env, penv);
    case div(Expr lhs, Expr rhs): return eval(lhs, env, penv) / eval(rhs, env, penv);
    case add(Expr lhs, Expr rhs): return eval(lhs, env, penv) + eval(rhs, env, penv);
    case sub(Expr lhs, Expr rhs): return eval(lhs, env, penv) - eval(rhs, env, penv);
    case neg(Expr expr): return !eval(expr, env, penv); 
    case gt(Expr lhs, Expr rhs): return eval(lhs, env, penv) > eval(rhs, env, penv) ? 1 : 0;
    case get(Expr lhs, Expr rhs): return eval(lhs, env, penv) >= eval(rhs, env, penv)? 1 : 0;
    case lt(Expr lhs, Expr rhs): return eval(lhs, env, penv) < eval(rhs, env, penv)? 1 : 0;
    case leq(Expr lhs, Expr rhs): return eval(lhs, env, penv) <= eval(rhs, env, penv)? 1 : 0;
    case eql(Expr lhs, Expr rhs): return eval(lhs, env, penv) == eval(rhs, env, penv)? 1 : 0;
    case neq(Expr lhs, Expr rhs): return eval(lhs, env, penv) != eval(rhs, env, penv)? 1 : 0;
    case and(Expr lhs, Expr rhs): return eval(lhs, env, penv) && eval(rhs, env, penv)? 1 : 0;
    case or(Expr lhs, Expr rhs): return eval(lhs, env, penv) || eval(rhs, env, penv)? 1 : 0;
    case lit(bool x): return vbool(x);
    case lit(int x): return vint(x);
    case lit(str x): return vstr(x);
    default: throw "Unsupported expression <e>";
  }
}