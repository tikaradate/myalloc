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
    topoAlocado:     .quad 0
    blockSize:       .quad 4096

    tamanhoBestFit:  .quad 0xffffffff
    enderecoBestFit: .quad 0

    plusChar:        .byte 43
    minusChar:       .byte 45

    cabecalho:       .string "################"

.text

.globl falaOi
falaOi:
    mov   $cabecalho , %rdi   # Primeiro argumento printf  
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
    movq %rax, topoAlocado

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

    mov  %rdi           , tamAloc # salva o tamanho da alocacao
    mov  topoInicialHeap, %r12    # Salva o topo da heap em r12
    movq $0, enderecoBestFit      # enderecoBestFit = NULL


    movq topoAlocado, %rbx

    w0: 
        cmpq %r12 , topoAlocado           # compara o topo inicial com o topo atual já alocado
        je fim_w0
        
        mov %r12     , %r14               # salva o endereco inicial 

        mov (%r12), %r15                  # bloco de "livre ou não"  -> r15
        cmp $0    , %r15                  # se ocupado, procura proximo bloco
        jne prox_bloc_1                   # pula para o próximo bloco

        add $8       , %r12               # vai para o espaço do tamanho
        mov (%r12)   , %r15               # salva o tamanho em r15
        cmpq tamAloc , %r15               # compara se o espaço disponivel é suficiente
        jl  prox_bloc_2                   # pula para o próximo bloco

        cmp tamanhoBestFit, %r15          # comparo para ver se o tamanho atual é o ideal
        jge prox_bloc_2                   # se nao for, procuro o proximo bloco

        movq %r14, enderecoBestFit        # salva o endereço do bloco ideal
        movq %r15, tamanhoBestFit         # salva o tamanho  do bloco ideal
        
        jmp prox_bloc_2                   # pula para o proximo bloco

        prox_bloc_1:
        add $8       , %r12
        mov (%r12)   , %r15

        prox_bloc_2:
        add $8       , %r12

        add %r15     , %r12

        jmp w0                            # volta para o inicio do loop

    fim_w0:

    mov $0  , %r13                        # move 0 para r13
    cmp %r13, enderecoBestFit             # compara o enderecoBestFit com 0
    je inicio_alocacao                    # se forem iguais, inicia uma nova alocação
                                          # senão, usa o endereco salvo em enderecoBestFit

    # Achou o melhor lugar para armazenar os novos dados sem a necessidade de uma nova alocação

    movq enderecoBestFit, %r12        # salva o endereço ideal em r12

    mov $1      ,  %r13               # marca o bloco como indisponivel 
    mov %r13    , (%r12)              # 
    add $16     ,  %r12               # como nao podemos mudar o tamanho do bloco, pula 16 bytes

    mov %r12    , %rax                # salva r12 no registrador de retorno 



    jmp fim_aloc                      # pula para o fim da alocação

    inicio_alocacao:
    # Não tinha um espaço disponivel, confere se pode botar no final do espaço já alocado

    # se ((tamanho + 16) > (topoAtualHeap - topoAlocado)) -> aloca
    # senão, bota ali mesmo e atualiza o valor de topoAlocado

    mov  $12, %rax               # codigo referente ao brk
    mov  $0 , %rdi               # 0 para retornar o topo da heap
    syscall                      # executa a sycall
    movq %rax, topoAtualHeap     # retorno em %rax e salvo em topoAtualHeap

    movq topoAtualHeap, %rax     # salva o topo atual em rax
    subq topoAlocado  , %rax     # diminuiu o topo alocado de rax para termos o tamanho total disponivel

    movq tamAloc      , %rbx     # move o tamanho da alocação atual para rbx 
    add  $16          , %rbx     # adiciona os 16 bytes de cabeçalho

    cmp %rax          , %rbx     # ve se tem espaço disponivel sem a necessidade 
    jle nao_aloca_4096           #  de fazer uma nova alocação de tamanho = blockSize

                                 # foi necessária a alocação
    movq %rbx  , %r12            # joga o tamanho que eu quero alocar em r12
    subq %rax  , %r12            # diminui o resto do espaço que ainda tem disponivel

    mov %r12   , %rax            # salva o espaço que vai ser alocado em rax          

    movq blockSize, %r12         # move o tamanho do bloco para r12
    mov $0        , %rdx         # acho que precisa para funcionar a divisão 
    idivq %r12                   # divide o tamanho da alocação por blocksize (rax = rax / 4096)

    mov $0, %r13                 # bota zero em r13
    cmp %rdx, %r13               # ve se o resto da divisão é zero
    je nao_soma                  # se for, nao precisa somar 1 no quociente

    add $1, %rax                 # soma 1 porque a divisão é apenas de inteiros
    
    nao_soma:
    mulq %r12                    # multiplica o resultado por blockSize para saber quantos bytes alocar
                                 # a partir do número de blocos 

    movq topoAtualHeap, %rdi     # salva o topo atual em rdi
    add  %rax         , %rdi     # adiciona o tamanho da alocação atual

    mov $12, %rax                #
    syscall                      # chama a syscall de alocação

    nao_aloca_4096:

    movq topoAlocado,  %r12      # salva o endereço do topoAlocado em r12
    movq $1         ,  %r13      # 
    mov %r13        , (%r12)     # informa que o bloco está alocado
    add $8          ,  %r12      # 
    movq tamAloc    ,  %r13      #
    mov %r13        , (%r12)     # informa o tamanho do bloco alocado
    add $8          ,  %r12      #

    mov %r12        , %rax       # Envia o endereço para reg de retorno

    addq tamAloc    , %r12
    movq %r12, topoAlocado       # Atualiza o valor do topo Alocado

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

    mov topoInicialHeap, %r12        # Salva o topo da heap em r12

    w1:
        cmpq topoAlocado, %r12       # compara r10 com topoAtualHeap
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
        mov $0    , %r13 

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
