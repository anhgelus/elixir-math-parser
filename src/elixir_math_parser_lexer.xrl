Definitions.
INT        = [0-9_]+
FLOAT      = [0-9_]*\.[0-9]+
NAME       = [a-zA-Z_][a-zA-Z0-9_]*
WHITESPACE = [\s\t\r]
COMMENT    = #[^\n]*\n?
BREAK      = [\n;;]

Rules.
\+            : {token, {'+',  TokenLine}}.
\-            : {token, {'-',  TokenLine}}.
\*            : {token, {'*',  TokenLine}}.
\/            : {token, {'/',  TokenLine}}.
\=            : {token, {'=',  TokenLine}}.
\(            : {token, {'(',  TokenLine}}.
\)            : {token, {')',  TokenLine}}.
!             : {token, {'!',  TokenLine}}.
\^            : {token, {'^',  TokenLine}}.
{BREAK}+      : {token, {break,  TokenLine}}.
{NAME}        : {token, {var, TokenLine, TokenChars}}.
{FLOAT}       : {token, {float, TokenLine, TokenChars}}.
{INT}         : {token, {int,  TokenLine, TokenChars}}.
{WHITESPACE}+ : skip_token.
{COMMENT}+    : skip_token.

Erlang code.
