.data
    # Variaveis bobocas
    A:       .quad  0
    texto:   .string  "Ola %s voce e %ld \n"
    nome:    .string  "Jorge"
    nota:    .quad  7
    TAMANHO: .quad 1

    #Variaveis de verdade

    topoInicialHeap: .quad 0
    topoAtualHeap:   .quad 0
    tamAloc:         .quad 0

    plusChar:        .byte 43
    minusChar:       .byte 45

    cabecalho:       .string "################"

.text

.globl falaOi
falaOi:
    mov   $cabecalho , %rdi       # Primeiro argumento printf  
    mov   $nome  , %rsi       # Segundo  argumento printf
    mov   nota   , %rdx       # Terceiro argumento printf
    call  printf              # Chama              printf

ret

.globl imprimeLinha
imprimeLinha:
    mov TAMANHO, %rbx 
    mov $0     , %r10

    while:
        cmp %rbx, %r10
        jge fim

        mov $45    , %rdi 
        call putchar

        add $1, %r10

        jmp while
    fim:
        mov $10, %rdi
        call putchar
ret

.globl iniciaAlocador
iniciaAlocador:
    
    pushq %rbp
    movq  %rsp, %rbp

    mov  $12, %rax               # codigo referente ao brk
    mov  $0 , %rdi               # 0 para retornar o topo da heap
    syscall                      # executa a sycall
    movq %rax, topoInicialHeap   # retorno em %rax e salvo em topoInicialHeap

    popq %rbp

ret

.globl finalizaAlocador
finalizaAlocador:

    pushq %rbp
    movq  %rsp, %rbp

    mov $12, %rax               # codigo referente ao brk
    mov topoInicialHeap, %rdi   # restaura o valor inicial da heap
    syscall                     # executa a syscall

    popq %rbp

ret

.globl alocaMem
alocaMem:

    pushq %rbp
    movq  %rsp, %rbp

    mov %rdi           , tamAloc # salva o tamanho da alocacao
    mov topoInicialHeap, %r10    # Salva o topo da heap em r10

    mov  $12, %rax               # codigo referente ao brk
    mov  $0 , %rdi               # 0 para retornar o topo da heap
    syscall                      # executa a sycall
    movq %rax, topoAtualHeap     # retorno em %rax e salvo em topoAtualHeap

    w0: 
        cmpq %r10 , topoAtualHeap         # compara o topo inicial (r10) com o topo atual (rax)
        je fim_w0

        mov (%r10), %r15                  # bloco de "livre ou não"  -> r15
        cmp $0    , %r15                  # se ocupado, procura proximo bloco
        jne prox_bloc_1

        mov %r10     , %r14               # compara se o tamanho disponível é o suficiente para alocar 
        add $8       , %r10               # o novo tamanho
        mov (%r10)   , %r15 
        cmpq tamAloc , %r15
        jl  prox_bloc_2

        mov $1      ,  %r13               # se nao está ocupado e tem tamanho o suficiente 
        mov %r13    , (%r14)
        add $16     ,  %r14

        mov %r14    , %rax 
        

        jmp fim_aloc             # Termina a alocação

        prox_bloc_1:
        add $8       , %r10
        mov (%r10)   , %r15

        prox_bloc_2:
        add $8       , %r10

        add %r15     , %r10

        jmp w0

    fim_w0:
    # Não tinha um espaço disponivel, é necessário alocar um novo

    mov  $12, %rax               # codigo referente ao brk
    mov  $0 , %rdi               # 0 para retornar o topo da heap
    syscall                      # executa a sycall

    mov %rax    , %r15           # salva o local atual
    
   
    addq tamAloc, %rax           # soma o tamanho da alocação
    add  $16    , %rax           # soma o espaço do cabecalho

    mov %rax    , %rdi           # move o tamanho para a chamado do brk
    mov  $12    , %rax           # codigo referente ao brk
    syscall                      # executa a sycall

    mov $1       ,  %r14         # a[0] espaco alocado
    mov %r14     , (%r15)        #
    add $8       ,  %r15         # a[1]
    movq tamAloc ,  %r14         # 
    mov %r14     , (%r15)        # a[1] = tamanho
    mov %r15     , %rax
    add $8       , %rax

    fim_aloc:

    popq %rbp

ret

.globl liberaMem
liberaMem:

    pushq %rbp
    movq  %rsp, %rbp

    sub $16  , %rdi       # Vai para o lugar que indica se está alocado ou não
    mov $0   , %r14 
    mov %r14 ,(%rdi)      # Bota zero
    mov $1, %rax          # Sucesso ao liberar bloco

    popq %rbp

ret

.globl imprimeMapa
imprimeMapa:

    pushq %rbp
    movq  %rsp, %rbp

    mov topoInicialHeap, %r12    # Salva o topo da heap em r10

    mov  $12, %rax               # codigo referente ao brk
    mov  $0 , %rdi               # 0 para retornar o topo da heap
    syscall                      # executa a sycall
    mov %rax, topoAtualHeap      # salva o topo atual da heap

    w1:
        cmpq topoAtualHeap, %r12     # compara r10 com topoAtualHeap
        je fim_w1                    # se são iguais, nao imprime nada

        mov (%r12)    , %r15         # indica se o bloco está vazio ou não
        cmp $1        , %r15
        je  setPlus
        mov minusChar , %r14 
        jmp fimSet
        setPlus:
        mov plusChar  , %r14
        fimSet:

        mov   $cabecalho , %rdi  
        call  printf

        add $8    , %r12  # lugar do tamanho
        mov (%r12), %r15
        mov $0   , %r13 

        w2: 
            cmp %r15, %r13 
            jge fim_w2

            mov %r14, %rdi 
            call putchar

            add $1, %r13

            jmp w2
        fim_w2:

        add %r15  , %r12  # add tamanho
        add $8    , %r12 

        jmp w1

    fim_w1:

    mov $10, %rdi
    call putchar

    popq %rbp

ret
