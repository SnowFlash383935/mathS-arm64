.text
.global asm_reverse

asm_reverse:
    // x0 - указатель на строку (передан из Си)
    mov x19, x0
    // Считаем длину вручную для чистоты
    mov x1, x0
    mov x2, #0
len_loop:
    ldrb w3, [x1], #1
    cbz w3, len_done
    add x2, x2, #1
    b len_loop
len_done:
    // x2 - длина, x19 - начало
    add x1, x19, x2
    sub x1, x1, #1    // Конец
    mov x0, x19       // Начало

rev_loop:
    cmp x0, x1
    b.ge done
    ldrb w2, [x0]
    ldrb w3, [x1]
    strb w3, [x0], #1
    strb w2, [x1], #-1
    b rev_loop
done:
    ret
