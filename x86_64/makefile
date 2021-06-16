CC = gcc
ASMBIN=nasm
CFLAGS = -Wall -m64 -no-pie
LDFLAGS=-L/usr/lib -lallegro -lallegro_primitives -lallegro_image -lm

INCLUDE=-I. -I/usr/local/include/allegro5/


all : asm cc link

asm :

	$(ASMBIN) -o f.o -f elf64 -g -l f.lst f.s

cc :

	$(CC) $(CFLAGS) -c -g -O0 main.c -std=c11 -lm

link :

	$(CC) $(CFLAGS) -g -o bezier main.o f.o $(INCLUDE) $(LDFLAGS)

gdb :
	gdb bezier
clean:
	rm -f *.o bezier f.lst

