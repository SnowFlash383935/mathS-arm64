import mathS
import array
import time
import math

print("\n--- Тест Hypot ---")

n = 1_000_000
# Создаем массивы float (тип 'f')
a = array.array('f', [3.0] * n)
b = array.array('f', [4.0] * n)
out = array.array('f', [0.0] * n)

# Тест Python (math.hypot в цикле)
start = time.perf_counter()
for i in range(n):
    out[i] = math.hypot(a[i], b[i])
print(f"Python time: {time.perf_counter() - start:.5f}s")

# Тест mathS (ASM NEON)
start = time.perf_counter()
mathS.vector_hypot(a, b, out)
print(f"mathS time:  {time.perf_counter() - start:.5f}s")

print(f"Result check: {out[0]}") # Должно быть 5.0

# --- Тест Fast Inverse Square Root ---
print("\n--- Тест Fast Inverse Square Root (1/sqrt(x)) ---")

n = 1_000_000
data_in = array.array('f', [float(i + 1) for i in range(n)])
data_out_py = array.array('f', [0.0] * n)
data_out_asm = array.array('f', [0.0] * n)

# 1. Тест Python (стандартный подход)
start_py = time.perf_counter()
for i in range(n):
    data_out_py[i] = 1.0 / math.sqrt(data_in[i])
time_py = time.perf_counter() - start_py
print(f"Python (1.0/sqrt): {time_py:.5f}s")

# 2. Тест mathS (ASM NEON)
# Не забудь добавить метод vector_inv_sqrt в fast_module.c и lib.S
try:
    start_asm = time.perf_counter()
    mathS.vector_inv_sqrt(data_in, data_out_asm)
    time_asm = time.perf_counter() - start_asm
    print(f"mathS (inv_sqrt):  {time_asm:.5f}s")
    
    # Считаем ускорение
    print(f"Ускорение: {time_py / time_asm:.2f}x")

    # Проверка точности (сравним первый результат)
    diff = abs(data_out_py[0] - data_out_asm[0])
    print(f"Результат [0]: Python={data_out_py[0]:.6f}, ASM={data_out_asm[0]:.6f}")
    print(f"Абсолютная ошибка: {diff:.10f}")
    
    if diff < 1e-6:
        print("Точность: ОТЛИЧНО (в пределах погрешности float)")
    else:
        print("Точность: ТРЕБУЕТ ВНИМАНИЯ")

except AttributeError:
    print("Ошибка: Метод vector_inv_sqrt еще не добавлен в модуль mathS!")
