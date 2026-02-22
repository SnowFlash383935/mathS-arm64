.global asm_reverse
asm_reverse:
    mov x8, x0          
    
find_end_neon:
    ld1 {v0.16b}, [x8], #16
    uminv b1, v0.16b    
    fmov w9, s1
    cbz w9, found_null_neon  
    b find_end_neon

found_null_neon:
    sub x10, x8, x0      // Длина (примерная)
    add x2, x0, x10
    sub x2, x2, #32      // Указатель на правый блок (32 байта от конца)
    mov x1, x0           // Указатель на левый блок

neon_loop_32:
    cmp x1, x2
    b.ge simple_tail     // Если перехлест — на выход

    // Загружаем блоки (номера v0, v1 и v2, v3 идут по возрастанию)
    ld1 {v0.16b, v1.16b}, [x1]
    ld1 {v2.16b, v3.16b}, [x2]

    // Реверс внутри каждого регистра
    rev64 v0.16b, v0.16b
    ext v0.16b, v0.16b, v0.16b, #8
    rev64 v1.16b, v1.16b
    ext v1.16b, v1.16b, v1.16b, #8
    rev64 v2.16b, v2.16b
    ext v2.16b, v2.16b, v2.16b, #8
    rev64 v3.16b, v3.16b
    ext v3.16b, v3.16b, v3.16b, #8

    // Записываем: то что было слева (v0,v1) пишем направо в обратном порядке
    // Чтобы записать v1 перед v0, нам нужно два вызова st1, 
    // так как в одном списке порядок всегда v0, v1
    st1 {v2.16b, v3.16b}, [x1], #32
    
    // Пишем вторую пару (v1, v0) в обратном порядке вручную
    st1 {v1.16b}, [x2]
    add x2, x2, #16
    st1 {v0.16b}, [x2]
    sub x2, x2, #48      // Возвращаем указатель x2 назад (16+32)
    
    b neon_loop_32

simple_tail:
    ret
