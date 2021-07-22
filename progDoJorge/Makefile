
all:
	as main.s -o main.o -g
	gcc -c prog.c       
	gcc -static main.o prog.o -o prog


clear:
	rm  *.o

purge: clear
	rm prog