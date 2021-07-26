
all:
	as main.s -o main.o -g
	gcc -c prog.c -g
	gcc -static main.o prog.o -o prog -g


clear:
	rm  *.o

purge: clear
	rm prog