import mathS
import array
import time
import math

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
