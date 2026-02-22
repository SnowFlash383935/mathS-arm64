CC = aarch64-linux-gnu-gcc
# Путь к заголовкам python в среде ubuntu-arm64
PY_INC = /usr/include/python3.12

CFLAGS = -I$(PY_INC) -fPIC
LDFLAGS = -shared

all: fast_arm.so

fast_arm.so: fast_module.o lib.o
	$(CC) $(LDFLAGS) fast_module.o lib.o -o fast_arm.so

fast_module.o: fast_module.c
	$(CC) $(CFLAGS) -c fast_module.c -o fast_module.o

lib.o: lib.S
	$(CC) -c lib.S -o lib.o

clean:
	rm -f *.o *.so
