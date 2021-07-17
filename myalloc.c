#include <stdio.h>
#include <unistd.h>

void *topoInicialHeap;

void iniciaAlocador();
void finalizaAlocador();
void *alocaMem(long int);
int liberaMem(void *);
void imprimeMapa();

int main(){
    long int *alo, *carai, *jorge;
    printf("beep beep memoria hmmm\n");
    iniciaAlocador();
    fflush(stdout);
    printf("%p\n", topoInicialHeap);
    alo = (long int *)alocaMem(sizeof(long int)*3);
    imprimeMapa();
    alo[0] = 65;
    alo[1] = 76;
    alo[2] = 79;
    fflush(stdout);
    // printf("%p %p, %d %d %c %c %c\n", sbrk(0), alo, alo[-2], alo[-1], 0[alo], alo[1], alo[2]);
    liberaMem(alo);
    imprimeMapa();
    carai = alocaMem(sizeof(long int));
    imprimeMapa();
    *carai = 67; 
    // printf("%p %p %p, %d %d %c\n", sbrk(0), alo, carai, carai[-2], carai[-1], carai[0]);
    jorge = alocaMem(8);
    imprimeMapa();
    // printf("%p\n", sbrk(0));
}

void iniciaAlocador(){
    topoInicialHeap = sbrk(0);
}

void *alocaMem(long int num_bytes){
    long int *a = topoInicialHeap;
    void *topoAtual = sbrk(0);
    while(a != topoAtual){
        if(a[0] == 0){
            if(a[1] >= num_bytes){
                long int *info;
                // abre 8 bytes para um long que indica se o bloco esta ocupado
                a[0] = 1;
                // abre outros 8 bytes para guardar o tamanho do bloco
                // a[1] = num_bytes; 
                // aloca o espaco necessario do bloco
                return ((char*)&a[2]);
            }
        }
        a += 2 + (a[1]/8);
    }
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
    trata[-2] = 0;
    endereco = NULL;
    return 1;
}

void finalizaAlocador(){
    brk(topoInicialHeap);
}

void imprimeMapa(){
    char c;
    long int *a = topoInicialHeap;
    void *topoAtual = sbrk(0);
        
    while(a != topoAtual){
        printf("##");
        if(a[0] == 1)
            c = '+';
        else
            c = '-';
        for(int i = 0; i < a[1]; i++)
            putchar(c);

        a += 2 + (a[1]/8);
    }
    putchar('\n');
}