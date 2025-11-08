Nonterminals
  root
  statement
  statements
  expr
.

Terminals
  int
  atom
  '+'
  '-'
  '*'
  '/'
  '='
  '('
  ')'
  ';;'
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
statements -> statement ';;' statements : ['$1'|'$3'].

statement -> atom '=' expr : {assign, '$1', '$3'}.
statement -> expr : {eval, '$1'}.

expr -> int : unwrap('$1').
expr -> atom : '$1'.
expr -> expr '+' expr : {add_op, '$1', '$3'}.
expr -> expr '-' expr : {sub_op, '$1', '$3'}.
expr -> expr '*' expr : {mul_op, '$1', '$3'}.
expr -> expr '/' expr : {div_op, '$1', '$3'}.
expr -> '(' expr ')'  : '$2'.

Erlang code.

unwrap({int, Line, Value}) -> {int, Line, list_to_integer(Value)}.
