module Compile

import AST;
import Resolve;
import IO;
import lang::html5::DOM;
import List;


void compile(AForm f) {
  writeFile(f.src[extension="js"].top, form2js(f));
  writeFile(f.src[extension="html"].top, toString(form2html(f)));
}

HTML5Node form2html(AForm f) {
  return html(
    lang("en"),
    head(
      meta(charset("utf-8")),
      meta(name("viewport"), content("width=device-width, initial-scale=1, shrink-to-fit=no")),
      link(\rel("stylesheet"), href("https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css")),
      title(f.name)
    ),
    body(class("bg-light p-2"),
      div(lang::html5::DOM::id("vm"), class("container"),
        h2("<f.name>", class("bg-primary text-white rounded p-3 mb-2")),
        div(
          [question2html(q) | q <- f.questions] +
          button(\type("button"), class("btn btn-primary btn-lg btn-block mt-1"), "Submit") // dummy
        )
      ),
      script(src("https://cdn.jsdelivr.net/npm/vue/dist/vue.min.js")),
      script(src(f.src[extension="js"].file))
    )
  );
}

HTML5Node question2html(question(label, id(name), \type)) =
  div(
    class("card mt-2"),
    div(class("card-body"),
      h5(class("card-title"), label),
      input(atype2attrs(\type) + vue_model(\type, name))
    )
  );

HTML5Node question2html(question(label, id(name), \type, _)) =
  div(
    class("card mt-2"),
    div(class("card-body"),
      h5(class("card-title"), label),
      input(atype2attrs(\type) + vue_model(\type, name) + readonly("readonly"))
    )
  );

HTML5Node question2html(\if(condition, qs)) =
  fieldset(
    html5attr("v-if", expr2js(condition)) +
    [question2html(q) | q <- qs]
  );

HTML5Node question2html(if_else(condition, qs, alt_qs)) =
  div(
    fieldset(
      html5attr("v-if", expr2js(condition)) + 
      [question2html(q) | q <- qs]
    ),
    fieldset(
      html5attr("v-else", "") + 
      [question2html(q) | q <- alt_qs]
    )
  );

list[HTML5Attr] atype2attrs(boolean()) = [\type("checkbox")];
list[HTML5Attr] atype2attrs(integer()) = [\type("number"), class("form-control")];
list[HTML5Attr] atype2attrs(string()) = [\type("text"), class("form-control")];

HTML5Attr vue_model(boolean(), name) = html5attr("v-model", name);
HTML5Attr vue_model(integer(), name) = html5attr("v-model.number", name);
HTML5Attr vue_model(string(), name) = html5attr("v-model.trim", name);

str form2js(AForm f) =
  "var vm = new Vue({
  '  el: \'#vm\',
  '  data: <vue_data(f)>,
  '  computed: <vue_computed(f)>
  '});";

str vue_data(AForm f) = 
  "{ " + 
  intercalate(", ", ["<name>: <defaultValue(\type)>" | /question(_, id(name), \type) := f])
  + " }";


/* we cannot use arrow-style functions in this context */
str vue_computed(AForm f) =
  "{ " +
  intercalate(", ", ["<name>: function () { return <expr2js(expr)>; }" | /question(_, id(name), _, expr) := f])
  + " }";

str expr2js(AExpr e) {
  switch (e) {
    case ref(AId x):
      return "this.<x.name>"; /* 'this' is required by Vue when referencing variables in computed getters */

    case mul(AExpr lhs, AExpr rhs):
      return "(<expr2js(lhs)> * <expr2js(rhs)>)";

    case div(AExpr lhs, AExpr rhs):
      return "(<expr2js(lhs)> / <expr2js(rhs)>)";

    case add(AExpr lhs, AExpr rhs):
      return "(<expr2js(lhs)> + <expr2js(rhs)>)";

    case sub(AExpr lhs, AExpr rhs):
      return "(<expr2js(lhs)> - <expr2js(rhs)>)";

    case gt(AExpr lhs, AExpr rhs):
      return "(<expr2js(lhs)> \> <expr2js(rhs)>)";

    case geq(AExpr lhs, AExpr rhs):
      return "(<expr2js(lhs)> \>= <expr2js(rhs)>)";

    case lt(AExpr lhs, AExpr rhs):
      return "(<expr2js(lhs)> \< <expr2js(rhs)>)";

    case leq(AExpr lhs, AExpr rhs):
      return "(<expr2js(lhs)> \<= <expr2js(rhs)>)";

    case and(AExpr lhs, AExpr rhs):
      return "(<expr2js(lhs)> && <expr2js(rhs)>)";

    case or(AExpr lhs, AExpr rhs):
      return "(<expr2js(lhs)> || <expr2js(rhs)>)";

    case neg(AExpr expr):
      return "(!<expr2js(expr)>)";

    case eql(AExpr lhs, AExpr rhs):
      return "(<expr2js(lhs)>) == (<expr2js(rhs)>)";

    case neq(AExpr lhs, AExpr rhs):
      return "(<expr2js(lhs)>) != (<expr2js(rhs)>)";

    case lit(bool boolean):
      return "<boolean>";

    case lit(int integer):
      return "<integer>";

    case lit(str string):
      return "\"" + string + "\"";
  }
}

/* (https://vuejs.org/v2/guide/forms.html#Basic-Usage)
  v-model will ignore the initial value, checked or selected attributes found on any
  form elements. It will always treat the Vue instance data as the source of truth. You should
  declare the initial value on the JavaScript side, inside the data option of your component.
*/
value defaultValue(boolean()) = false;
value defaultValue(integer()) = 0;
value defaultValue(string()) = "\'\'";