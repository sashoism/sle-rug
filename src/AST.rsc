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
  = question(str label, AAnswer answer)
  ; 

data AExpr(loc src = |tmp:///|)
  = ref(AId id)
  ;

data AId(loc src = |tmp:///|)
  = id(str name);

data AType(loc src = |tmp:///|)
  = \type(str \type);

data AAnswer(loc src = |tmp:///|)
  = answer(AId name, AType \type)
  | answer(AId name, AType \type, AExpr expr)
  ;

AForm implode(start[Form] m)
  = implode(m.top);

AForm implode((Form)`form <Id name> { <Question* qs> }`)
  = form("<name>", []);