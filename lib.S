.text
.global asm_strlen

asm_strlen:
    mov x1, x0          // Копируем адрес начала строки
    mov x0, #0          // Обнуляем счетчик
loop:
    ldrb w2, [x1], #1   // Читаем байт с автоинкрементом
    cbz w2, done        // Если 0 — выходим
    add x0, x0, #1      // x0++
    b loop
done:
    ret
