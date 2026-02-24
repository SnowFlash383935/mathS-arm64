import array
import time
import mathS
import random

class NeonLayer:
    def __init__(self, in_features, out_features):
        self.M = out_features # Количество нейронов
        self.K = in_features  # Входные признаки
        self.N = 1            # Мы обрабатываем 1 вектор (batch_size=1)
        
        # Инициализируем веса и bias
        self.weights = array.array('f', [random.uniform(-1, 1) for _ in range(self.M * self.K)])
        self.bias = array.array('f', [0.1] * self.M)
        self.output = array.array('f', [0.0] * self.M)
        self.temp = array.array('f', [0.0] * self.M)

    def forward(self, x_input):
        # 1. MatMul: Temp = Weights * Input
        # matrix_mul(A, B, C, M, N, K) - тут 6 аргументов, всё верно
        mathS.matrix_mul(self.weights, x_input, self.temp, self.M, self.N, self.K)
        
        # 2. Add Bias: Temp = Temp + Bias
        # В твоем C-коде vector_add ждет только (A, B, Out)
        mathS.vector_add(self.temp, self.bias, self.temp) # <-- УБРАЛИ self.M
        
        # 3. Activation: Output = ReLU(Temp)
        # В твоем C-коде vector_relu ждет только (In, Out)
        mathS.vector_relu(self.temp, self.output) # <-- УБРАЛИ self.M
        
        return self.output

# --- ТЕСТ ДРАЙВ ---
print("\n🚀 ЗАПУСК НЕЙРОННОГО СЛОЯ НА ARM64 ASM 🚀")

# Слой: 1024 входа -> 512 нейронов
layer = NeonLayer(1024, 512)
input_vector = array.array('f', [random.random() for _ in range(1024)])

# Замеряем время инференса
start = time.perf_counter()
for _ in range(1000): # Делаем 1000 предсказаний
    res = layer.forward(input_vector)
end = time.perf_counter()

print(f"Среднее время одного прохода (инференс): {(end - start):.6f} ms")
print(f"Результат (первые 5 значений): {res[:5]}")
