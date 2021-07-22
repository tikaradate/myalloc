
#include "prog.h"
#include <stdio.h>
#include <unistd.h>

int 
main()
{
    // printf("oi\n");
    long int *a, *b, *c, *d;
    


    iniciaAlocador();
    // printf("%p\n", sbrk(0));
    // printf("%p\n", sbrk(0)+16);
    // printf("%p\n", sbrk(0)+112);

    a = alocaMem(8);
    imprimeMapa();

    b = alocaMem(16);
    imprimeMapa();
    // printf("b: %p free: %ld  size: %ld\n",b, b[-2], b[-1]);

    c = alocaMem(32);
    imprimeMapa();
    // printf("c: %p free: %ld  size: %ld\n",c, c[-2], c[-1]);

    liberaMem(b);
    imprimeMapa();
    // printf("b: %p free: %ld  size: %ld\n",b, b[-2], b[-1]);

    d = alocaMem(8);
    imprimeMapa();
    // printf("d: %p free: %ld  size: %ld\n",d, d[-2], d[-1]);
    // falaOi();
    // imprimeLinha();




    finalizaAlocador();

    return 0;
}