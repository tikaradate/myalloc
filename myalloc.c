#include <stdio.h>
#include <unistd.h>

void *topoInicialHeap;

void iniciaAlocador();
void finalizaAlocador();
void *alocaMem(long int);
int liberaMem(void *);

int main(){
    long int *alo;
    printf("beep beep memoria hmmm\n");
    iniciaAlocador();
    fflush(stdout);
    printf("%p\n", topoInicialHeap);
    alo = (long int *)alocaMem(sizeof(long int)*3);
    alo[0] = 65;
    alo[1] = 76;
    alo[2] = 79;
    fflush(stdout);
    printf("%p %p, %d %d %c %c %c\n", sbrk(0), alo, alo[-2], alo[-1], 0[alo], alo[1], alo[2]);
    liberaMem(alo);
}

void iniciaAlocador(){
    topoInicialHeap = sbrk(0);
}

void *alocaMem(long int num_bytes){
    long int *info;
    // abre 8 bytes para um long que indica se o bloco esta ocupado
    info = (long int *)sbrk(8);
    *info = 1;
    // abre outros 8 bytes para guardar o tamanho do bloco
    info = (long int *)sbrk(8);
    *info = num_bytes;
    // aloca o espaco necessario do bloco
    void *endereco = sbrk(num_bytes);
    return ((char*)endereco);
}

int liberaMem(void *endereco){
    long int *trata;
    trata = endereco;
    trata -= 16;
    *trata = 0;
    // (endereco - 16 bytes) = 0;
    return 1;
}

void finalizaAlocador(){
    brk(topoInicialHeap);
}