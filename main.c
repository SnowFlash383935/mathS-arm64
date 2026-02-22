#include <stdio.h>

// Объявляем внешнюю функцию из ассемблера
extern long long asm_strlen(const char* str);

int main() {
    const char* test_str = "GitHub Actions on ARM64!";
    long long len = asm_strlen(test_str);
    
    printf("String: %s\n", test_str);
    printf("Detected length: %lld\n", len);
    
    // Простейший unit-test: если длина не 24, выходим с ошибкой
    if (len == 24) return 0;
    return 1;
}
