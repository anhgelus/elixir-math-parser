Nonterminals
  root
  statement
  statements
  expr
  exprs
.

Terminals
  int
  var
  break
  '+' '-' '*' '/'
  '='
  '(' ')'
.

Rootsymbol
   root
.

Right 100 '='.
Left 300 '+'.
Left 300 '-'.
Left 400 '*'.
Left 400 '/'.
Left 600 '('.

root -> statements : '$1'.

statements -> statement : ['$1'].
statements -> statement statements : ['$1'|'$2'].
statements -> statement break statements : ['$1'|'$3'].
statements -> break : [].

statement -> var '=' exprs : {assign, '$1', '$3'}.
statement -> exprs : {eval, '$1'}.

exprs -> expr       : '$1'.
exprs -> expr exprs : {mul_op, '$1', '$2'}.

expr -> int : unwrap('$1').
expr -> var : '$1'.
expr -> exprs '+' exprs : {add_op, '$1', '$3'}.
expr -> exprs '-' exprs : {sub_op, '$1', '$3'}.
expr -> exprs '*' exprs : {mul_op, '$1', '$3'}.
expr -> exprs '/' exprs : {div_op, '$1', '$3'}.
expr -> '(' exprs ')' : '$2'.

Erlang code.

unwrap({int, Line, Value}) -> {int, Line, list_to_integer(Value)}.
