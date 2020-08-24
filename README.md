# plancklisp

Lisp interpreter in x86 assembler language for Linux

## Syntax

- ``'`` quote
- ``#`` lambda
- ``?`` if
- ``@`` atom
- ``+`` cons
- ``<`` car
- ``>`` cdr

## Examples

```
(((# (x) (# (y) (+ x y))) (' a)) (' b))
=> (a . b)
```
