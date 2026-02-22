.global asm_reverse
asm_reverse:
    mov x1, x0          // x1 - левый указатель
    mov x8, x0
    
find_null:
    ldrb w9, [x8], #1
    cbnz w9, find_null
    sub x2, x8, #2      // x2 - последний символ

neon_loop_16:
    sub x10, x2, x1
    cmp x10, #31        // Нужно 32 байта разницы для безопасного обмена по 16
    b.lt tail_byte

    ld1 {v0.16b}, [x1]   // Читаем 16 байт слева
    ld1 {v1.16b}, [x2], #-16 // Сдвигаем x2 назад (временно, потом поправим)
    // Ошибка была тут, заменим на два шага:
    ld1 {v1.16b}, [x2]   
    sub x2, x2, #16      // Теперь x2 указывает на начало следующего блока

    rev64 v0.16b, v0.16b
    ext v0.16b, v0.16b, v0.16b, #8
    rev64 v1.16b, v1.16b
    ext v1.16b, v1.16b, v1.16b, #8

    st1 {v0.16b}, [x2, #16] // Пишем левый блок на место правого
    st1 {v1.16b}, [x1], #16  // Пишем правый на место левого
    b neon_loop_16

tail_byte:
    cmp x1, x2
    b.ge rev_done
    ldrb w3, [x1]
    ldrb w4, [x2]
    strb w3, [x2], #-1
    strb w4, [x1], #1
    b tail_byte

rev_done:
    ret
