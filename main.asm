%include "macro.inc"

    section .text
    BITS 64

    extern read
    extern eval
    extern print

    global _start
_start:
    call read
    mov rdi,rax
    mov rsi,NIL
    call eval
    mov rdi,rax
    call print
    jmp _start

    global error
error:
    mov eax,60                  ; exit
    mov edi,1
    syscall
