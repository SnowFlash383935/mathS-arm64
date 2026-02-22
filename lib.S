.section .data
    msg:    .ascii "Hello from pure ARM64 Syscall!\n"
    len = . - msg

.section .text
.global _start

_start:
    // Системный вызов write(1, msg, len)
    mov x0, #1      // stdout
    adr x1, msg     // адрес строки
    mov x2, len     // длина
    mov x8, #64     // номер syscall write для ARM64
    svc #0          // Прыжок в ядро!

    // Системный вызов exit(0)
    mov x0, #0      // код возврата
    mov x8, #93     // номер syscall exit для ARM64
    svc #0
