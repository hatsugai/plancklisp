%include "macro.inc"

    section .text
    BITS 64

    extern cons
    extern error

    global read_char0
read_char0:
    lea rsi,[rel buf]           ; address
    mov byte [rsi],dil
    mov eax,0                   ; read
    mov edi,0                   ; stdin
    mov edx,1                   ; length
    syscall
    or eax,eax
    jz .eof_of_file
    movzx eax,byte [rel buf]
    ret
.eof_of_file:
    mov eax,-1
    ret

    global read_char
read_char:
    mov eax,[rel unread_count]
    or eax,eax
    jz read_char0
    dec eax
    mov [rel unread_count],eax
    mov rdx,unread_buf
    movzx eax,byte [rdx+rax]
    ret

    global unread_char
unread_char:
    mov eax,[rel unread_count]
    mov rdx,unread_buf
    mov [rdx+rax],dil
    inc eax
    mov [rel unread_count],eax
    ret

    global read_vchar
read_vchar: 
    call read_char
    cmp al,0x20
    jz read_vchar
    cmp al,0x09
    jz read_vchar
    cmp al,0x0a
    jz read_vchar
    ret

    global read
read:
    call read_vchar
    cmp al,0xff
    je .end_of_file
    cmp al,'('
    je .list_or_nil
    ;; symbol
    shl eax,1
    or eax,1
    ret

.end_of_file:
    ret

.list_or_nil:
    call read_vchar
    cmp al,')'
    je .nil
    mov rdi,rax
    call unread_char
    call read
    push rax
    call read_cdr
    mov rsi,rax
    pop rdi
    CONS
    ret

.nil:
    mov eax,NIL
    ret

read_cdr:
    call read_vchar
    cmp al,'.'
    je .dotted_list
    cmp al,')'
    je .nil
    mov rdi,rax
    call unread_char
    call read
    push rax
    call read_cdr
    mov rsi,rax
    pop rdi
    CONS
    ret

.nil:
    mov rax,NIL
    ret

.dotted_list:
    call read
    push rax
    call read_vchar
    cmp al,')'
    jne error                   ; missing ')'
    pop rax
    ret

    section .data
unread_count dd 0

    section .bss
    align 16
unread_buf resb 16
buf resb 1
