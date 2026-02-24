import array
import time
import math
import mathS

print("\n--- Тест Vector GELU (Gaussian Error Linear Unit) ---")

def python_gelu(x):
    # Стандартная формула аппроксимации GELU
    return 0.5 * x * (1.0 + math.tanh(math.sqrt(2.0 / math.pi) * (x + 0.044715 * x**3)))

n = 100000
data_in = array.array('f', [(i - n//2) / 10000.0 for i in range(n)]) # Значения от -5 до 5
res_asm = array.array('f', [0.0] * n)

# 1. Тест Python
start_py = time.perf_counter()
res_py = [python_gelu(x) for x in data_in]
time_py = time.perf_counter() - start_py

# 2. Тест mathS (ASM)
start_asm = time.perf_counter()
mathS.vector_gelu(data_in, res_asm)
time_asm = time.perf_counter() - start_asm

print(f"Python time: {time_py:.5f}s")
print(f"mathS time:  {time_asm:.5f}s")
print(f"Ускорение:   {time_py / time_asm:.2f}x")

# Проверка точности (GELU — плавная функция, допустим небольшой разброс)
max_diff = 0
for i in range(n):
    diff = abs(res_py[i] - res_asm[i])
    if diff > max_diff: max_diff = diff

print(f"Максимальное отклонение: {max_diff:.6f}")
if max_diff < 0.05: # Для нашей быстрой аппроксимации это отлично
    print("ТОЧНОСТЬ: ПРИЕМЛЕМО (для инференса GPT-2)")
    
