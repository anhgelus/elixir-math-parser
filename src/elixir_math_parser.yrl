Nonterminals
  root
  statement
  statements
  expr
  exprs
  % function specific
  vars params
.

Terminals
  int float
  var
  break
  % eval
  '+' '-' '*' '/' '!' '^'
  '(' ')'
  % assign
  '='
  % function specific
  ':' ','
.

Rootsymbol
   root
.

Right 100 '='.
Left 300 '+'.
Left 300 '-'.
Left 400 '*'.
Left 400 '/'.
Right 500 '!'.
Left 600 '^'.
Left 700 '('.

root -> statements : '$1'.

statements -> statement : ['$1'].
statements -> statement statements : ['$1'|'$2'].
statements -> statement break statements : ['$1'|'$3'].
statements -> break : [].

statement -> var '=' exprs : {assign, '$1', '$3'}.
statement -> exprs : {eval, '$1'}.
statement -> var ':' vars '=' exprs : {assign_func, '$1', '$3', '$5'}.

vars -> var : ['$1'].
vars -> var ',' vars : ['$1' | '$3'].

exprs -> expr : '$1'.
exprs -> expr exprs : {mul_op, '$1', '$2'}.

params -> expr : ['$1'].
params -> expr ',' : ['$1'].
params -> expr ',' params : ['$1' | '$3'].

expr -> int : unwrap('$1').
expr -> float : unwrap('$1').
expr -> var : '$1'.

expr -> exprs '+' exprs : {add_op, '$1', '$3'}.
expr -> exprs '-' exprs : {sub_op, '$1', '$3'}.
expr -> exprs '*' exprs : {mul_op, '$1', '$3'}.
expr -> exprs '/' exprs : {div_op, '$1', '$3'}.
expr -> expr '!' : {factor_op, '$1'}.
expr -> exprs '^' exprs : {exp_op, '$1', '$3'}.
expr -> '(' exprs ')' : '$2'.
expr -> '-' exprs : {sub_op, {int, 0, 0}, '$2'}.

expr -> var '(' params ')' : {eval_func, '$1', '$3'}.

Erlang code.

% 95 is the unicode of "_"
numberMatch(X) -> not(X == 95).

unwrap({int, Line, Value}) -> {int, Line, list_to_integer(lists:filter(fun numberMatch/1, Value))};
% 48 is the unicode of "0"
unwrap({float, Line, Value}) -> {float, Line, [48 | lists:filter(fun numberMatch/1, Value)]}.
