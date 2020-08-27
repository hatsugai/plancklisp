# plancklisp

Lisp interpreter in x86 assembler language for Linux

## Syntax

- ``'`` quote
- ``#`` lambda
- ``?`` if
- ``!`` setq
- ``@`` atom
- ``=`` eq
- ``+`` cons
- ``<`` car
- ``>`` cdr
- ``$`` read
- ``%`` print

## Examples

```
(((# (x) (# (y) (+ x y))) (' a)) (' b))
=> (a . b)
```

```
(((# (r)
     (! r
        (# (x y)
           (? (@ x)
              y
              (r (> x) (+ (< x) y)))))
     r)
  ())
 (' (a b c d e f)) ())
=> (f e d c b a)
```

```
(((# (r a)
     (! r
        (# (x)
           (? (@ x)
              ()
              (a (r (> x)) (+ (< x) ())))))
     (! a
        (# (x y)
           (? (@ x)
              y
              (a (r (> (r x)))
                 (+ (< (r x)) y)))))
     r)
  () ())
 (' (a b c d e f)))
=> (f e d c b a)
```

```
(((# (f) (f f))
  (# (f)
     (# (x y) (? (= x ()) y (+ (< x) ((f f) (> x) y))))))
 (' (a b c))
 (' (d e f)))
=> (a b c d e f)
```

```
((>
  ((# (f) (f f))
   (# (f)
      (+
       (# (x y)
          (? (= x ())
             y
             (+ (< x) ((< (f f)) (> x) y))))
       (# (x)
          (? (= x ())
             ()
             ((< (f f))
              ((> (f f)) (> x))
              (+ (< x) ()) )))))))
 (' (a b c d e f)))
=> (f e d c b a)
```
