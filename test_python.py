import fast_arm
import time

# Создаем огромную строку (10 мегабайт)
size = 10_000_000
test_data = "A" * size + "B" * size

print(f"--- Тест на строке в {len(test_data)} символов ---")

# 1. Тест Python (Native slice)
start_py = time.perf_counter()
result_py = test_data[::-1]
end_py = time.perf_counter()
py_time = end_py - start_py
print(f"Python (slice): {py_time:.6f} сек")

# 2. Тест ARM64 ASM
# Напоминаю: наш модуль внутри делает strdup(), так что это честный тест с копированием
start_asm = time.perf_counter()
result_asm = fast_arm.reverse(test_data)
end_asm = time.perf_counter()
asm_time = end_asm - start_asm
print(f"ARM64 ASM:      {asm_time:.6f} сек")

# Проверка корректности
if result_py == result_asm:
    print(f"\nРЕЗУЛЬТАТ: Ускорение в {py_time / asm_time:.2f} раз!")
else:
    print("\nОШИБКА: Результаты не совпадают!")
