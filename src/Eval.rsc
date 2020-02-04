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

// Default values
Value defaultValue(integer()) = vint(0);
Value defaultValue(boolean()) = vbool(false);
Value defaultValue(string()) = vstr("");

// produce an environment which for each question has a default value
// (e.g. 0 for int, "" for str etc.)
VEnv initialEnv(AForm f) {
  return ( name: defaultValue(t) | /question(_, id(str name), t) <- f.questions );
}

// Because of out-of-order use and declaration of questions
// we use the solve primitive in Rascal to find the fixpoint of venv.
VEnv eval(AForm f, Input inp, VEnv venv) {
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}

VEnv evalOnce(AForm f, Input inp, VEnv venv) {
  for (q <- f.questions) {
    venv = eval(q, inp, venv);
  }
  return venv;
}

VEnv eval(AQuestion q, Input inp, VEnv venv) {
  // evaluate conditions for branching,
  // evaluate inp and computed questions to return updated VEnv
  switch(q) {
    case question(str label, AId id, AType \type): venv(id, inp);
    case question(str label, AId id, AType \type, AExpr expr): venv(id, eval(expr, venv));
    case \if(AExpr condition, list[AQuestion] questions): 
      if (eval(condition, venv)) {
        for (q <- questions) {
          venv = eval(q, inp, venv);
        }
      }  
  }
  
  return venv; 
}

Value eval(AExpr e, VEnv venv) {
  switch (e) {
    case ref(id(str x)): return venv[x];

    case mul(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n * eval(rhs, venv).n);
    case div(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n / eval(rhs, venv).n);
    case add(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n + eval(rhs, venv).n);
    case sub(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n - eval(rhs, venv).n);

    case neg(AExpr expr): return vbool(!eval(expr, venv).b);
    case gt(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n > eval(rhs, venv).n);
    case geq(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n >= eval(rhs, venv).n);
    case lt(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n < eval(rhs, venv).n);
    case leq(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n <= eval(rhs, venv).n);

    case eql(AExpr lhs, AExpr rhs): switch(<eval(lhs, venv), eval(rhs, venv)>) {
      case <vint(a), vint(b)>: return vbool(a == b);
      case <vbool(a), vbool(b)>: return vbool(a == b);
      case <vstr(a), vstr(b)>: return vbool(a == b);
    }
    case neq(AExpr lhs, AExpr rhs): return eval(neg(eql(lhs, rhs)), venv); // !=

    case lit(int n): return vint(n);
    case lit(bool b): return vbool(b);
    case lit(str s): return vstr(s);

    default: throw "Unsupported expression <e>";
  }
}