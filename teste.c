#include <stdio.h>
#include <unistd.h>

extern topoInicialHeap;

int main(){
    iniciaAlocador();
    printf("%p\n", sbrk(0));
    printf("%p\n", topoInicialHeap);
    imprimeMapa();
    finalizaAlocador();
}