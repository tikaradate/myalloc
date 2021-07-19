#include <stdio.h>
#include <unistd.h>

void *topoInicialHeap;

void iniciaAlocador();
void finalizaAlocador();
void *alocaMem(long int);
int liberaMem(void *);
void imprimeMapa();

int main(){
    long int *alo, *carai, *jorge, *lucas;
    printf("beep beep memoria hmmm\n");

    iniciaAlocador();
    imprimeMapa();

    fflush(stdout);
    printf("%p\n", topoInicialHeap);

    carai = alocaMem(sizeof(long int));
    imprimeMapa();

    alo = alocaMem(sizeof(long int)*2);
    imprimeMapa();

    jorge = alocaMem(sizeof(long int)*3);
    imprimeMapa();

    lucas = alocaMem(sizeof(long int)*4);
    imprimeMapa();

    liberaMem(alo);
    imprimeMapa();

    liberaMem(jorge);
    imprimeMapa();

    liberaMem(lucas);
    imprimeMapa();

    alo = alocaMem(sizeof(long int)*5);
    jorge = alocaMem(sizeof(long int)*1);
    lucas = alocaMem(sizeof(long int)*4);
    imprimeMapa();
}

void iniciaAlocador(){
    topoInicialHeap = sbrk(0);
}

void *alocaMem(long int num_bytes){
    long int *bestfit = NULL;
    long int bftam = 0xffffff;
    long int *a = topoInicialHeap;
    void *topoAtual = sbrk(0);
    while(a != topoAtual){
        if(a[0] == 0){
            if(a[1] >= num_bytes){
                if(a[1] < bftam){
                    bftam = a[1];
                    bestfit = a;
                }
            }
        }
        a += 2 + (a[1]/8);
    }
    if(!bestfit){
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
    } else {
        bestfit[0] = 1;
        bestfit[1] = bftam;
        //bestfit + 16 bytes
        return ((char*) &bestfit[2]);
    }
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