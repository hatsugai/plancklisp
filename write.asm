%include "macro.inc"

%macro putchar 1
    mov edi,%1
    call write_char
%endmacro

    section .text
    BITS 64

    global write_char
;;; rdi   char
write_char: 
    mov rsi,buf                 ; address
    mov byte [rsi],dil
    mov eax,1                   ; write
    mov edi,1                   ; stdout
    mov edx,1                   ; length
    syscall
    ret

    global write
;;; rdi   expr
write:
    atom(dil)
    jz .list
    cmp dil,NIL
    jne .symbol
    putchar '('
    putchar ')'
    ret
.symbol:
    asc(dil)
    call write_char
    ret
.list:
    push rbx
    mov rbx,rdi                 ; save
    putchar '('
    mov rdi,car(rbx)
    call write
    mov rdi,cdr(rbx)
    pop rbx
    ;; fall through

write_cdr:
    atom(dil)
    jz .list
    cmp dil,NIL
    jne .atom
    putchar ')'
    ret
.atom:
    push rdi
    putchar ' '
    putchar '.'
    putchar ' '
    pop rdi
    asc(dil)
    call write_char
    putchar ')'
    ret
.list:
    push rbx
    mov rbx,rdi                 ; save
    putchar ' '
    mov rdi,car(rbx)
    call write
    mov rdi,cdr(rbx)
    pop rbx
    jmp write_cdr

    global print
print:
    call write
    putchar 0x0a

    section .bss
    align 16
buf resb 1

