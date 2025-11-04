Definitions.
INT        = [0-9]+
NAME       = :[a-zA-Z_][a-zA-Z0-9_]*
WHITESPACE = [\s\t\n\r]|;{2}

Rules.
\+            : {token, {'+',  TokenLine}}.
\-            : {token, {'-',  TokenLine}}.
\*            : {token, {'*',  TokenLine}}.
\/            : {token, {'/',  TokenLine}}.
\=            : {token, {'=',  TokenLine}}.
{NAME}        : {token, {atom, TokenLine, to_atom(TokenChars)}}.
{INT}         : {token, {int,  TokenLine, TokenChars}}.
{WHITESPACE}+ : skip_token.

Erlang code.
% Given a ":name", chop off : and return name as an atom.
to_atom([$:|Chars]) ->
    list_to_atom(Chars).
