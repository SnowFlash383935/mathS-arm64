CC = aarch64-linux-gnu-gcc
PY_INC ?= /usr/include/python3.11
CFLAGS = -I$(PY_INC) -fPIC
LDFLAGS = -shared

# Имя должно совпадать с тем, что ты импортируешь в Python
all: mathS.so

mathS.so: fast_module.o lib.o
	$(CC) $(LDFLAGS) fast_module.o lib.o -o mathS.so

fast_module.o: fast_module.c
	$(CC) $(CFLAGS) -c fast_module.c -o fast_module.o

lib.o: lib.S
	$(CC) -c lib.S -o lib.o

clean:
	rm -f *.o *.so
