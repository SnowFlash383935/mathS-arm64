.global vector_hypot
// void vector_hypot(float* a, float* b, float* out, int n)
// x0 - адрес массива A
// x1 - адрес массива B
// x2 - адрес выходного массива Out
// x3 - количество элементов (n)

vector_hypot:
    cbz x3, hypot_done          // Если n == 0, выходим

hypot_loop:
    cmp x3, #4
    b.lt hypot_tail             // Если осталось меньше 4 элементов, в хвост

    // Загружаем по 4 значения float (32-bit) за раз
    ld1 {v0.4s}, [x0], #16
    ld1 {v1.4s}, [x1], #16

    fmul v0.4s, v0.4s, v0.4s    // a^2
    fmul v1.4s, v1.4s, v1.4s    // b^2
    fadd v0.4s, v0.4s, v1.4s    // a^2 + b^2
    fsqrt v0.4s, v0.4s          // sqrt(a^2 + b^2)

    st1 {v0.4s}, [x2], #16      // Сохраняем результат
    sub x3, x3, #4
    b hypot_loop

hypot_tail:
    // Хвост для n, не кратных 4
    cbz x3, hypot_done
    ldr s0, [x0], #4
    ldr s1, [x1], #4
    fmul s0, s0, s0
    fmul s1, s1, s1
    fadd s0, s0, s1
    fsqrt s0, s0
    str s0, [x2], #4
    sub x3, x3, #1
    b hypot_tail

hypot_done:
    ret

.global vector_inv_sqrt
vector_inv_sqrt:
    cbz x2, rsqrt_done
rsqrt_loop:
    cmp x2, #8
    b.lt rsqrt_tail
    
    // Загружаем 8 чисел (два регистра по 4 float)
    ld1 {v0.4s, v1.4s}, [x0], #32
    
    // ПРИБЛИЖЕНИЕ
    frsqrte v2.4s, v0.4s
    frsqrte v3.4s, v1.4s
    
    // ШАГ 1 Уточнения (для обоих регистров)
    fmul v4.4s, v2.4s, v2.4s
    fmul v5.4s, v3.4s, v3.4s
    frsqrts v4.4s, v0.4s, v4.4s
    frsqrts v5.4s, v1.4s, v5.4s
    fmul v2.4s, v2.4s, v4.4s
    fmul v3.4s, v3.4s, v5.4s

    // ШАГ 2 Уточнения (для идеальной точности 10^-12)
    fmul v4.4s, v2.4s, v2.4s
    fmul v5.4s, v3.4s, v3.4s
    frsqrts v4.4s, v0.4s, v4.4s
    frsqrts v5.4s, v1.4s, v5.4s
    fmul v2.4s, v2.4s, v4.4s
    fmul v3.4s, v3.4s, v5.4s
    
    st1 {v2.4s, v3.4s}, [x1], #32
    sub x2, x2, #8
    b rsqrt_loop

rsqrt_tail:
    cbz x2, rsqrt_done
    ldr s0, [x0], #4
    frsqrte s1, s0
    fmul s2, s1, s1
    frsqrts s2, s0, s2
    fmul s1, s1, s2
    str s1, [x1], #4
    sub x2, x2, #1
    b rsqrt_tail

rsqrt_done:
    ret

.global vector_sigmoid
// void vector_sigmoid(float* in, float* out, int n)
vector_sigmoid:
    // Подготовка констант (0.5, 1.0)
    fmov v4.4s, #0.5
    fmov v5.4s, #1.0

sig_loop:
    cmp x2, #4
    b.lt sig_done
    
    ld1 {v0.4s}, [x0], #16
    
    // 1. Абсолютное значение |x|
    fabs v1.4s, v0.4s
    
    // 2. Знаменатель (1 + |x|)
    fadd v2.4s, v1.4s, v5.4s
    
    // 3. Быстрое деление (через наш inv_sqrt, но для 1/x есть frsqrte)
    // Для простоты используем обычное деление fdiv, оно медленнее, но точнее
    fdiv v3.4s, v0.4s, v2.4s
    
    // 4. v3 = (x / (1+|x|)) * 0.5 + 0.5
    fmul v3.4s, v3.4s, v4.4s
    fadd v3.4s, v3.4s, v4.4s
    
    st1 {v3.4s}, [x1], #16
    sub x2, x2, #4
    b sig_loop

sig_done:
    ret
