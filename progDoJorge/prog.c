
#include "prog.h"
#include <stdio.h>
#include <unistd.h>

int 
main()
{
    long int *a, *b, *c, *d, *e, *f, *g;
    
    iniciaAlocador();

    a=alocaMem(8);
    imprimeMapa();

    b=alocaMem(32);
    imprimeMapa();

    c=alocaMem(16);
    imprimeMapa();

    liberaMem(a);
    imprimeMapa();
    liberaMem(b);
    imprimeMapa();
    liberaMem(c);
    imprimeMapa();

    d=alocaMem(24);
    imprimeMapa();

    e = alocaMem(56);
    imprimeMapa();

    f = alocaMem(15);
    imprimeMapa();

   finalizaAlocador();

    return 0;
}
