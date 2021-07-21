.section .data
    topoInicialHeap: .quad 0
.globl topoInicialHeap
str:    .string "################"

.section .text

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
        movq tamAloc,  %r14
        mov %r14    , (%r15)

        add $8      , %r15 

        mov %r15    , %rax 
        

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


.globl iniciaAlocador 
iniciaAlocador:
    pushq %rbp          # manda pra pilha rbp
    movq %rsp, %rbp     # rbp aponta pra rsp
    movq $0, %rdi       # parâmetro do brk()
    movq $12, %rax      # número de syscall do brk()
    syscall             # chamada do brk()
    movq %rax, topoInicialHeap  # retorno do brk(0), topo da heap atual
    popq %rbp           # desempilha rbp
    ret                 # retorna

.globl finalizaAlocador  
finalizaAlocador:
    pushq %rbp          # manda pra pilha rbp
    movq %rsp, %rbp     # rbp aponta pra rsp
    movq topoInicialHeap, %rdi  # parâmetro do brk()
    movq $12, %rax      # número de syscall do brk()
    syscall             # chamada do brk()
    popq %rbp           # desempilha rbp
    ret                 # retorna

.globl imprimeMapa
imprimeMapa:
    pushq %rbp                  # manda pra pilha rbp
    movq %rsp, %rbp             # rbp aponta pra rsp
    subq $16, %rsp              # aloca espaco para 1 variavel
    movq topoInicialHeap, %rbx  # a := topoInicialHeap

    movq $0, %rdi       # parâmetro do brk()
    movq $12, %rax      # número de syscall do brk()
    syscall             # chamada do brk()

while:
    cmpq %rbx, %rax     # compara com o topo atual da heap
    je fim_while        # quando forem iguais pula pro fim

    # lea str(%rip), %rdi
    # mov $0, %al
    # call printf

    movq (%rbx), %rcx   # %rcx := *a
    movq $1, %r15       # %r15 := 1
    cmpq %rcx, %r15     # a[0] == 1 ?
    jne else
    movq $43, %rdx      # %rdx := '+'
else:
    movq $45, %rdx      # %rdx := '-'

    movq $0, %r10       # %r10 := 0
    movq %rbx, %r11     # %r11 := %rbx
    addq $8, %r11       # %r11 += 8
    movq (%r11), %r11   # %r11 += a[1] // tamanho da area alocada
for:
    cmpq %r11, %r10     # a[1] <= %r10? %r10 >= a[1]
    jge fim_for         # se sim sai do for
    movq %rdx, %rdi     # bota + ou - como argumento de putchar
    call putchar        
    addq $1, %r10       # i++
    jmp for             # volta pro começo
fim_for:
    addq $16, %r11      # a[1] += 16
    addq %r11, %rbx     # a += a[1]  // pula n_bytes + 16 para frente
    jmp while
fim_while:
    movq $10, %rdi      # \n como argumento de putchar
    call putchar
    addq $16, %rsp
    popq %rbp           # desempilha rbp
    ret                 # retorna
