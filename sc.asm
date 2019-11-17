section .text
    global _start
_start:
    xor rsi, rsi
    mul rsi

    ;;; memfd_create()
    mov ax, 319
    lea r8, [rel string]
    mov rdi, r8
    inc rsi
    syscall

    xor r10, r10
    mov r10b, 10

    ;;; dup2(memfd, 10)
    mov rdi, rax
    mov rsi, r10

    xor rax, rax
    mov al, 33
    syscall

    ;;; open("somefile", O_RDONLY)
    xor rax, rax
    mov al, 2
    lea rdi, [r8 + 17]
    mov r8, rdi
    xor rsi, rsi
    syscall

    test rax, rax
    js end

    mov r9, rax

    lea rsi, [rsp - 0x1000]
    mov dx, 0x1000

rwloop:
    ;;; read
    xor rax, rax
    mov rdi, r9
    syscall

    test rax, rax
    je rwend

    ;;; write
    mov rdx, rax
    xor rax, rax
    inc al

    mov rdi, r10
    syscall

    jmp rwloop

rwend:

    mov rbx, rsi
    mov rdi, r8
    xor rax, rax
    mov rcx, rdi

array_loop:
    mov qword [rbx], rdi
    repne scasb

    add rbx, 8

    mov r9, [rdi]
    test r9d, r9d
    jne array_loop

    mov qword [rbx], rax

    ;;; execve("/proc/self/fd/10", ["args.."], NULL);

    xor rdx, rdx
    mov al, 59
    lea rdi, [r8 - 17]

    syscall

end:
    xor rax, rax
    mov al, 60
    syscall

string:
    db '/proc/self/fd/10', 0x0
