%include "macro.inc"

    section .text
    BITS 64

    extern error
    
   	global eval
;;; expr:   rdi
;;; env:    rsi
;;; DESTROY: rdx
eval:
    atom(dil)
    jz .eval_list
    ;; atom
    cmp dil,NIL
    jnz .eval_var
    mov rax,rdi                 ; nil
    ret
.eval_var:
    call assq
    mov rax,cdr(rax)
    ret
    ;; list
.eval_list:
    mov rdx,car(rdi)
    atom(dl)
    jz apply
    cmp dl,OP_QUOTE
    jz .eval_quote
    cmp dl,OP_LAMBDA
    jz .eval_lambda
    cmp dl,OP_IF
    jz .eval_if
    cmp dl,OP_ATOM
    jz .eval_atom
    cmp dl,OP_CONS
    jz .eval_cons
    cmp dl,OP_CAR
    jz .eval_car
    cmp dl,OP_CDR
    jz .eval_cdr
    jmp apply

.eval_quote:
    mov rax,cdr(rdi)
    mov rax,car(rax)
    ret

.eval_lambda:
    ;; cons(CLOSURE, cons(cdr(x), r))
    mov rdi,cdr(rdi)
    CONS
    mov rsi,rax
    mov rdi,CLOSURE
    CONS
    ret

.eval_if:
    mov rdi,cdr(rdi)
    push rdi                    ; save cdr(expr)
    mov rdi,car(rdi)            ; test
    call eval
    pop rdi
    cmp al,NIL
    jnz .eval_if_true
    mov rdi,cdr(rdi)
.eval_if_true:
    mov rdi,cdr(rdi)
    mov rdi,car(rdi)
    jmp eval
    
.eval_atom:
    mov rdi,cdr(rdi)
    mov rdi,car(rdi)
    call eval
    atom(al)
    jnz .eval_atom_true
    mov rax,NIL
    ret
.eval_atom_true:
    mov rax,TRUE
    ret

.eval_cons:
    mov rdi,cdr(rdi)
    push rdi                    ; save cdr(expr)
    mov rdi,car(rdi)
    call eval
    pop rdi
    push rax
    mov rdi,cdr(rdi)
    mov rdi,car(rdi)
    call eval
    mov rsi,rax
    pop rdi
    CONS
    ret

.eval_car:
    mov rdi,cdr(rdi)
    mov rdi,car(rdi)
    call eval
    mov rax,car(rax)
    ret

.eval_cdr:
    mov rdi,cdr(rdi)
    mov rdi,car(rdi)
    call eval
    mov rax,cdr(rax)
    ret

    global evlis
;;; list:   rdi
;;; env:    rsi
evlis:
    atom(dil)
    jnz .done
    push rdi
    mov rdi,car(rdi)
    call eval
    pop rdi
    push rax
    mov rdi,cdr(rdi)
    call evlis
    mov rsi,rax
    pop rdi
    CONS
    ret
.done:
    mov rax,NIL
    ret

    global apply
;;; expr:    rdi
;;; env:     rsi
;;; DESTORY: rdi rdx
apply:
    push rbx
    push r12
    mov r12,rsi                 ; env
    call evlis
    mov rbx,rax                 ; save (f arg ...)
    mov rax,car(rax)            ; function (CLOSURE (ps . body) . env)
    mov rdx,car(rax)            ; closure mark is expected
    cmp dl,CLOSURE
    jne error
    mov rax,cdr(rax)            ; ((ps . body) . env)
    mov rdx,cdr(rax)            ; closed env, 3rd arg
    mov rax,car(rax)            ; (ps . body)
    mov rdi,car(rax)            ; ps, 1st arg
    mov rsi,cdr(rbx)            ; (arg ...), 2nd arg
    mov rbx,cdr(rax)            ; body
    call extend_env
    mov rsi,rax                 ; extended env
.eval_body_loop:
    atom(bl)
    jnz .done
    mov rdi,car(rbx)
    call eval
    mov rbx,cdr(rbx)
    jmp .eval_body_loop
.done:
    mov rsi,r12
    pop r12
    pop rbx
    ret

    global extend_env
;;; rdi parameter list
;;; rsi argument list
;;; rdx env
;;; DESTORY: rdi rsi rdx
extend_env:
    push rbx
    push r12
    push r13
    mov rbx,rdi                 ; ps
    mov r12,rsi                 ; args
    mov r13,rdx                 ; env
.loop:
    atom(bl)
    jnz .done
    atom(r12b)
    jnz .done
    mov rdi,car(rbx)
    mov rsi,car(r12)
    CONS
    mov rdi,rax
    mov rsi,r13
    CONS
    mov r13,rax
    mov rbx,cdr(rbx)
    mov r12,cdr(r12)
    jmp .loop
.done:
    mov rax,r13
    pop r13
    pop r12
    pop rbx
    ret

    global assq
;;; x:       rdi
;;; alist:   rsi
;;; DESTROY: rdx
assq:
    mov rdx,rsi
.loop:
    atom(dl)
    jnz .not_found
    mov rax,car(rdx)
    cmp rdi,car(rax)
    mov rdx,cdr(rdx)
    jne .loop
    ret
.not_found:
    ret

    global cons
;;; x:   rdi
;;; y:   rsi
;;; DESTROY: rdx
cons:
    mov rax,[rel heap_ptr]
    lea rdx,[rax+WORD_SIZE*2]
    mov [rel heap_ptr],rdx
    mov car(rax),rdi
    mov cdr(rax),rsi
    ret

    section .data
    global heap_ptr
heap_ptr    dq  heap

    section .bss
heap    resq 1000000
