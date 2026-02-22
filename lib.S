// Макрос для кроссплатформенности имен
#ifdef __APPLE__
    #define SYMBOL(name) _##name
#else
    #define SYMBOL(name) name
#endif

.text
.align 4

// --- VECTOR HYPOT ---
.global SYMBOL(vector_hypot)
SYMBOL(vector_hypot):
    cbz x3, hypot_done
hypot_loop:
    cmp x3, #4
    b.lt hypot_tail
    ld1 {v0.4s}, [x0], #16
    ld1 {v1.4s}, [x1], #16
    fmul v0.4s, v0.4s, v0.4s
    fmul v1.4s, v1.4s, v1.4s
    fadd v0.4s, v0.4s, v1.4s
    fsqrt v0.4s, v0.4s
    st1 {v0.4s}, [x2], #16
    sub x3, x3, #4
    b hypot_loop
hypot_tail:
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

// --- VECTOR INV_SQRT ---
.global SYMBOL(vector_inv_sqrt)
SYMBOL(vector_inv_sqrt):
    cbz x2, rsqrt_done // В коде C передается n в x2
rsqrt_loop:
    cmp x2, #8
    b.lt rsqrt_tail
    ld1 {v0.4s, v1.4s}, [x0], #32
    
    // Приближение
    frsqrte v2.4s, v0.4s
    frsqrte v3.4s, v1.4s
    
    // Шаг 1
    fmul v4.4s, v2.4s, v2.4s
    fmul v5.4s, v3.4s, v3.4s
    frsqrts v4.4s, v0.4s, v4.4s
    frsqrts v5.4s, v1.4s, v5.4s
    fmul v2.4s, v2.4s, v4.4s
    fmul v3.4s, v3.4s, v5.4s

    // Шаг 2
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
    // Для идеальной точности в хвосте тоже 2 шага:
    fmul s2, s1, s1
    frsqrts s2, s0, s2
    fmul s1, s1, s2
    str s1, [x1], #4
    sub x2, x2, #1
    b rsqrt_tail
rsqrt_done:
    ret
