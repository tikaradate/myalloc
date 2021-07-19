#include <stdio.h>
#include <unistd.h>

int main(){
    iniciaAlocador();
    printf("%p", sbrk(0));
}