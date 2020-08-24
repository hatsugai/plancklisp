%define chr(x)      (((x) << 1) | 1)

    WORD_SIZE equ 8

    NIL       equ chr(0)
    TRUE      equ chr('T')
    CLOSURE   equ chr(1)
    OP_EQ     equ chr('=')
    OP_QUOTE  equ chr(39)       ; single-quote
    OP_LAMBDA equ chr('#')
    OP_IF     equ chr('?')
    OP_ATOM   equ chr('@')
    OP_CONS   equ chr('+')
    OP_CAR    equ chr('<')
    OP_CDR    equ chr('>')
    OP_SET    equ chr('!')

%define car(x)      [x]
%define cdr(x)      [x + WORD_SIZE]
%define atom(x)     test x,1
%define asc(x)      shr x,1
%define CONS        call cons

