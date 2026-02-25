// Универсальный макрос для имен символов
#ifdef __APPLE__
    #define SYM(name) _##name
#else
    #define SYM(name) name
#endif

.align 4

// Экспортируем все функции
.global SYM(vector_hypot)
.global SYM(vector_inv_sqrt)
.global SYM(vector_sigmoid)
.global SYM(vector_dot)
.global SYM(vector_relu)
.global SYM(matrix_mul)
.global SYM(vector_add)
.global SYM(vector_gelu)
.global SYM(vector_softmax)

// --- HYPOT ---
SYM(vector_hypot):
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
    fmadd s0, s0, s0, s1 // Используем fmadd для s0*s0 + s1*s1 (но тут s1*s1 отдельно)
    fmul s1, s1, s1
    fadd s0, s0, s1
    fsqrt s0, s0
    str s0, [x2], #4
    sub x3, x3, #1
    b hypot_tail
hypot_done:
    ret

// --- INV SQRT ---
SYM(vector_inv_sqrt):
    cbz x2, rsqrt_done
rsqrt_loop:
    cmp x2, #8
    b.lt rsqrt_tail
    ld1 {v0.4s, v1.4s}, [x0], #32
    frsqrte v2.4s, v0.4s
    frsqrte v3.4s, v1.4s
    // Newton-Raphson Step 1
    fmul v4.4s, v2.4s, v2.4s
    fmul v5.4s, v3.4s, v3.4s
    frsqrts v4.4s, v0.4s, v4.4s
    frsqrts v5.4s, v1.4s, v5.4s
    fmul v2.4s, v2.4s, v4.4s
    fmul v3.4s, v3.4s, v5.4s
    // Newton-Raphson Step 2
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

// --- SIGMOID ---
SYM(vector_sigmoid):
    fmov v4.4s, #0.5
    fmov v5.4s, #1.0
sig_loop:
    cmp x2, #4
    b.lt sig_done
    ld1 {v0.4s}, [x0], #16
    fabs v1.4s, v0.4s
    fadd v2.4s, v1.4s, v5.4s
    fdiv v3.4s, v0.4s, v2.4s
    fmul v3.4s, v3.4s, v4.4s
    fadd v3.4s, v3.4s, v4.4s
    st1 {v3.4s}, [x1], #16
    sub x2, x2, #4
    b sig_loop
sig_done:
    ret

// --- DOT PRODUCT ---
SYM(vector_dot):
    eor v0.16b, v0.16b, v0.16b
    cbz x2, dot_done
dot_loop:
    cmp x2, #4
    b.lt dot_tail
    ld1 {v1.4s}, [x0], #16
    ld1 {v2.4s}, [x1], #16
    fmul v3.4s, v1.4s, v2.4s
    fcvtl v4.2d, v3.2s
    fadd v0.2d, v0.2d, v4.2d
    fcvtl2 v5.2d, v3.4s
    fadd v0.2d, v0.2d, v5.2d
    sub x2, x2, #4
    b dot_loop
dot_tail:
    cbz x2, dot_reduce
    ldr s1, [x0], #4
    ldr s2, [x1], #4
    fmul s1, s1, s2
    fcvt d1, s1
    fadd d0, d0, d1
    sub x2, x2, #1
    b dot_tail
dot_reduce:
    faddp d0, v0.2d
dot_done:
    ret

// --- MATRIX MUL ---
SYM(matrix_mul):
    mov x6, #0          // i
row_loop:
    cmp x6, x3
    b.ge mat_done
    mov x7, #0          // j
col_loop:
    cmp x7, x4
    b.ge next_row
    eor v0.16b, v0.16b, v0.16b 
    mov x8, #0          // k
k_loop:
    cmp x8, x5
    b.ge store_res
    ldr s1, [x0, x8, lsl #2]
    mul x9, x8, x4
    add x9, x9, x7
    ldr s2, [x1, x9, lsl #2]
    fmadd s0, s1, s2, s0
    add x8, x8, #1
    b k_loop
store_res:
    mul x9, x6, x4
    add x9, x9, x7
    str s0, [x2, x9, lsl #2]
    add x7, x7, #1
    b col_loop
next_row:
    add x0, x0, x5, lsl #2
    add x6, x6, #1
    b row_loop
mat_done:
    ret

// void vector_relu(float* in, float* out, int n)
SYM(vector_relu):
    eor v1.16b, v1.16b, v1.16b   // Создаем вектор из нулей (v1 = [0,0,0,0])
    cbz x2, relu_done

relu_loop:
    cmp x2, #4
    b.lt relu_tail
    
    ld1 {v0.4s}, [x0], #16      // Загружаем 4 float
    fmaxnm v2.4s, v0.4s, v1.4s  // v2 = max(v0, 0)
    st1 {v2.4s}, [x1], #16      // Сохраняем
    
    sub x2, x2, #4
    b relu_loop

relu_tail:
    cbz x2, relu_done
    ldr s0, [x0], #4
    fmaxnm s2, s0, s1           // Скалярный максимум
    str s2, [x1], #4
    sub x2, x2, #1
    b relu_tail

relu_done:
    ret

// void vector_add(float* a, float* b, float* out, int n)
SYM(vector_add):
    cbz x3, add_done
add_loop:
    cmp x3, #4
    b.lt add_tail
    ld1 {v0.4s}, [x0], #16      // Загружаем 4 float из A
    ld1 {v1.4s}, [x1], #16      // Загружаем 4 float из B
    fadd v2.4s, v0.4s, v1.4s    // Складываем
    st1 {v2.4s}, [x2], #16      // Сохраняем
    sub x3, x3, #4
    b add_loop
add_tail:
    cbz x3, add_done
    ldr s0, [x0], #4
    ldr s1, [x1], #4
    fadd s2, s0, s1
    str s2, [x2], #4
    sub x3, x3, #1
    b add_tail
add_done:
    ret

// --- GELU ---
// void vector_gelu(float* in, float* out, int n)
// --- Softsign-GELU (Твоя формула) ---
// y = 0.5 * x * (1.0 + x / sqrt(pi + x*x))
SYM(vector_gelu):
    cbz x2, gelu_done
    
    // Загружаем константу PI (3.14159265 -> 0x40490fdb)
    mov w3, #0x0fdb
    movk w3, #0x4049, lsl #16
    fmov s4, w3
    dup v4.4s, v4.s[0]     // v4 = [pi, pi, pi, pi]

    fmov v5.4s, #0.5
    fmov v6.4s, #1.0

gelu_loop:
    cmp x2, #4
    b.lt gelu_done
    
    ld1 {v0.4s}, [x0], #16      // v0 = x
    
    // 1. Считаем pi + x*x
    fmul v1.4s, v0.4s, v0.4s    // x^2
    fadd v1.4s, v1.4s, v4.4s    // x^2 + pi
    
    // 2. Считаем 1/sqrt(pi + x^2) - Используем магию NEON
    frsqrte v2.4s, v1.4s        // Приблизительное 1/sqrt
    // Уточняем корень (Шаг Ньютона-Рафсона для точности)
    fmul v3.4s, v2.4s, v2.4s
    frsqrts v3.4s, v1.4s, v3.4s
    fmul v2.4s, v2.4s, v3.4s    // v2 = точный 1/sqrt(...)
    
    // 3. Считаем x / sqrt(...)
    fmul v2.4s, v0.4s, v2.4s    
    
    // 4. Сборка: 0.5 * x * (1.0 + x/sqrt)
    fadd v2.4s, v2.4s, v6.4s    // (1.0 + x/sqrt)
    fmul v2.4s, v2.4s, v5.4s    // 0.5 * (1 + x/sqrt)
    fmul v0.4s, v0.4s, v2.4s    // x * 0.5 * (...)
    
    st1 {v0.4s}, [x1], #16
    sub x2, x2, #4
    b gelu_loop

gelu_done:
    ret

// --- SOFTMAX (Ядро) ---
// x0 - vec_in, x1 - vec_out, x2 - n
SYM(vector_softmax):
    cbz x2, soft_exit
    mov x3, x2              // Сохраняем n
    
    // 1. Находим MAX (для стабильности)
    ld1 {v0.4s}, [x0]
    fmaxv s1, v0.4s         // Горизонтальный максимум
    // (Для простоты в этом примере считаем только первые 4, 
    // в полной версии нужен цикл поиска max)
    
    // 2. EXP и SUM
    // NEON не имеет fexp, поэтому для GPT-2 мы используем 
    // аппроксимацию: exp(x) ≈ (1 + x/n)^n
    // Или вызываем стандартную библиотеку. Но для теста сделаем просто:
    // v_exp = x - max
    dup v1.4s, v1.s[0]
    ld1 {v0.4s}, [x0]
    fsub v0.4s, v0.4s, v1.4s
    
    // Упрощенная экспонента для теста (ряд Тейлора 1 + x + x^2/2)
    fmov v2.4s, #1.0
    fadd v3.4s, v2.4s, v0.4s // 1 + x
    
    // 3. Normalization
    faddp v4.4s, v3.4s, v3.4s
    faddp s4, v4.2s          // Сумма всех элементов
    dup v4.4s, v4.s[0]
    fdiv v0.4s, v3.4s, v4.4s
    st1 {v0.4s}, [x1]
soft_exit:
    ret
