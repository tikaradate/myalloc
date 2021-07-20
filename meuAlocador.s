.section .data
    topoInicialHeap: .quad 0
.globl topoInicialHeap
str:    .string "################"

.section .text

# alocaMem liberaMem imprimeMapa
; exemplo:
;     pushq %rbp          # manda pra pilha rbp
;     movq %rsp, %rbp     # rbp aponta pra rsp

;     popq %rbp
;     ret
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
