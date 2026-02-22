AS = aarch64-linux-gnu-as
LD = aarch64-linux-gnu-ld

all:
	$(AS) hello.S -o hello.o
	$(LD) hello.o -o hello_pure
