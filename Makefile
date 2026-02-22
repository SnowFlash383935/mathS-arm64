# По умолчанию используем системный gcc
CC = gcc

all: program

program: main.o lib.o
	$(CC) main.o lib.o -o program

main.o: main.c
	$(CC) -c main.c -o main.o

lib.o: lib.S
	$(CC) -c lib.S -o lib.o

clean:
	rm -f *.o program
