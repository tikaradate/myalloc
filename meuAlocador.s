.section .data
    topoInicialHeap: .quad 0
.section .text
.globl iniciaAlocador  # _finalizaAlocador  alocaMem liberaMem imprimeMapa
; exemplo:
;     pushq %rbp          # manda pra pilha rbp
;     movq %rsp, %rbp     # rbp aponta pra rsp

;     popq %rbp
;     ret

iniciaAlocador:
    pushq %rbp          # manda pra pilha rbp
    movq %rsp, %rbp     # rbp aponta pra rsp
    movq $0, %rdi       # parâmetro do brk()
    movq $12, %rax      # número de syscall do brk()
    syscall             # chamada do brk()
    movq %rax, topoInicialHeap  # retorno do brk(0), topo da heap atual
    popq %rbp           # desempilha rbp
    ret                 # retorna

; _finalizaAlocador:
;     pushq %rbp          # manda pra pilha rbp
;     movq %rsp, %rbp     # rbp aponta pra rsp
;     movq topoInicialHeap, %rdi  # parâmetro do brk()
;     movq $12, %rax      # número de syscall do brk()
;     syscall             # chamada do brk()
;     popq %rbp           # desempilha rbp
;     ret                 # retorna
