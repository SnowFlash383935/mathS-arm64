#include <stdio.h>
#include <string.h>

// Объявляем внешнюю функцию из ассемблера
extern long long asm_strlen(const char* str);
extern char* asm_reverse(const char* str);

int main() {
    // Используем [] вместо *, чтобы создать массив в стеке
    char test_str[] = "GitHub Actions on ARM64!"; 
    
    long long len = asm_strlen(test_str);
    
    // Передаем массив в функцию реверса
    asm_reverse(test_str); 
    
    printf("String: %s\n", test_str);
    printf("Detected length: %lld\n", len);
    
    // Сравнение строк в Си делается через strcmp, а не ==
    if (len == 24 && strcmp(test_str, "!46MRA no snoitcA buHtiG") == 0) return 0;
    return 1;
}
