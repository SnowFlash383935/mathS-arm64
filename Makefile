all: program

program: main.o lib.o
	gcc main.o lib.o -o program

main.o: main.c
	gcc -c main.c -o main.o

lib.o: lib.S
	gcc -c lib.S -o lib.o

clean:
	rm -f *.o program
