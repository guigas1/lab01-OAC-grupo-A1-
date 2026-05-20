.include "MACROSv24.s"

.data
    # Perguntas para o terminal (Run I/O)
    msg_pede_a: .string "Digite o coeficiente A: "
    msg_pede_b: .string "Digite o coeficiente B: "
    msg_pede_c: .string "Digite o coeficiente C: "

    # Textos do Display (Raízes Reais)
    msg_r1_real: .string "R(1) = "
    msg_r2_real: .string "R(2) = "

    # Textos do Display (Raízes Complexas)
    msg_r1_cplx: .string "R(1) = "
    msg_cplx_i1: .string " + "
    msg_cplx_i2: .string " i"
    msg_r2_cplx: .string "R(2) = "
    msg_cplx_i3: .string " - "

    # Textos do Display (Desempenho)
    msg_i:    .string "Instrucoes (I): "
    msg_c:    .string "Ciclos (C): "
    msg_cpi:  .string "CPI: "
    msg_t:    .string "Tempo (ms): "

.text
.globl main

main:
main_loop:
    # 1. Leitura dos coeficientes pelo Teclado
    li a7, 4
    la a0, msg_pede_a
    ecall
    li a7, 6
    ecall
    fmv.s fa1, fa0      #fa1 = c

    li a7, 4
    la a0, msg_pede_b
    ecall
    li a7, 6
    ecall
    fmv.s fa2, fa0      # fa2 = b

    li a7, 4
    la a0, msg_pede_c
    ecall
    li a7, 6
    ecall
    fmv.s fa3, fa0      # fa3 = c

    #fundo preto do BitMap
    li a7, 148
    li a0, 0x00    
    li a1, 0       
    ecall

    # desenha o Gráfico (Leitura dos coeficientes A,B,C que estão em fa1, fa2, fa3)
    jal plot

    # prepara argumentos para o Baskara
    fmv.s fa0, fa1
    fmv.s fa1, fa2
    fmv.s fa2, fa3

   
    csrr s0, instret    # le o contador de instruções
    csrr s1, cycle      # le o contador de ciclos
    csrr s2, time       # le o tempo do sistema

    #calcula Raízes
    jal baskara

    # desliga o cronômetro de desempenho LOGO APÓS baskara
    csrr t2, time
    csrr t1, cycle
    csrr t0, instret

    
    sub s0, t0, s0      # s0 = Instruções totais (I) 
    sub s1, t1, s1      # s1 = Ciclos totais (C) 
    sub s2, t2, s2      # s2 = Tempo total em ms (Texec)

    # mostra as raízes na tela (a0 já tem o tipo de raiz, pilha tem os valores)
    jal show

    # calcula o CPI
    fcvt.s.w ft0, s0   
    fcvt.s.w ft1, s1   
    fdiv.s ft4, ft1, ft0 # ft4 = CPI = Ciclos / I

 
    jal imprime_desempenho

    #ler o próximo caso de teste!
    j main_loop



imprime_desempenho:
    # Imprime Instruções
    li a7, 104
    la a0, msg_i
    li a1, 10           # X
    li a2, 60           # Y (Mais para baixo na tela)
    li a3, 0x001F       
    li a4, 0
    ecall
    li a7, 101
    mv a0, s0
    li a1, 140
    li a2, 60
    li a3, 0x001F
    li a4, 0
    ecall

    #imprime ciclos
    li a7, 104
    la a0, msg_c
    li a1, 10
    li a2, 75
    li a3, 0x001F
    li a4, 0
    ecall
    li a7, 101
    mv a0, s1
    li a1, 140
    li a2, 75
    li a3, 0x001F
    li a4, 0
    ecall

    # imprime CPI
    li a7, 104
    la a0, msg_cpi
    li a1, 10
    li a2, 90
    li a3, 0x001F
    li a4, 0
    ecall
    li a7, 102
    fmv.s fa0, ft4
    li a1, 140
    li a2, 90
    li a3, 0x001F
    li a4, 0
    ecall

    # imprime Tempo (ms)
    li a7, 104
    la a0, msg_t
    li a1, 10
    li a2, 105
    li a3, 0x001F
    li a4, 0
    ecall
    li a7, 101
    mv a0, s2
    li a1, 140
    li a2, 105
    li a3, 0x001F
    li a4, 0
    ecall
    ret

show:
    mv t0, a0        # t0 = Tipo de raiz (1=Real, 2=Cplx) que veio da main
    
    #desempilha os valores deixados pelo Baskara
    flw ft0, 0(sp)   # ft0 = Raiz 1 / Parte Real
    flw ft1, 4(sp)   # ft1 = Raiz 2 / Parte Imag
    addi sp, sp, 8   #limpar a pilha para a proxima execucao

    #salva o contexto local do show
    addi sp, sp, -16
    sw ra, 12(sp)
    fsw fs0, 8(sp)
    fsw fs1, 4(sp)

    #passa as raizes para registradores s salvos
    fmv.s fs0, ft0
    fmv.s fs1, ft1

    li t1, 2
    beq t0, t1, show_complex

show_real:
    # R(1) = Raiz Real
    li a7, 104
    la a0, msg_r1_real
    li a1, 10
    li a2, 10
    li a3, 0x003
    li a4, 0
    ecall
    li a7, 102
    fmv.s fa0, fs0
    li a1, 70
    li a2, 10
    li a3, 0x0038
    li a4, 0
    ecall

    # R(2) = Raiz Real
    li a7, 104
    la a0, msg_r2_real
    li a1, 10
    li a2, 25
    li a3, 0x0038
    li a4, 0
    ecall
    li a7, 102
    fmv.s fa0, fs1
    li a1, 70
    li a2, 25
    li a3, 0x0038
    li a4, 0
    ecall
    j fim_show

show_complex:
    # R(1) = Real + Imag i
    li a7, 104
    la a0, msg_r1_cplx
    li a1, 10
    li a2, 10
    li a3, 0x0038
    li a4, 0
    ecall
    li a7, 102
    fmv.s fa0, fs0
    li a1, 70
    li a2, 10
    li a3, 0x0038
    li a4, 0
    ecall
    li a7, 104
    la a0, msg_cplx_i1  
    li a1, 185
    li a2, 10
    li a3, 0x0038
    li a4, 0
    ecall
    li a7, 102
    fmv.s fa0, fs1
    li a1, 215
    li a2, 10
    li a3, 0x0038
    li a4, 0
    ecall
    li a7, 104
    la a0, msg_cplx_i2 
    li a1, 305
    li a2, 10
    li a3, 0x0038
    li a4, 0
    ecall

    # R(2) = Real - Imag i
    li a7, 104
    la a0, msg_r2_cplx
    li a1, 10
    li a2, 25
    li a3, 0x0038
    li a4, 0
    ecall
    li a7, 102
    fmv.s fa0, fs0
    li a1, 70
    li a2, 25
    li a3, 0x0038
    li a4, 0
    ecall
    li a7, 104
    la a0, msg_cplx_i3  
    li a1, 185
    li a2, 25
    li a3, 0x0038
    li a4, 0
    ecall
    li a7, 102
    fmv.s fa0, fs1
    li a1, 215
    li a2, 25
    li a3, 0x0038
    li a4, 0
    ecall
    li a7, 104
    la a0, msg_cplx_i2  
    li a1, 305
    li a2, 25
    li a3, 0x0038
    li a4, 0
    ecall

fim_show:
    lw ra, 12(sp)
    flw fs0, 8(sp)
    flw fs1, 4(sp)
    addi sp, sp, 16
    ret


baskara:
    fmul.s ft0, fa1, fa1      
    li t0, 4
    fcvt.s.w ft1, t0          
    fmul.s ft1, ft1, fa0      
    fmul.s ft1, ft1, fa2      
    fsub.s ft0, ft0, ft1      
    fmv.w.x ft2, zero         
    flt.s t1, ft0, ft2        
    li t0, 2
    fcvt.s.w ft2, t0          
    fmul.s ft2, ft2, fa0      
    fneg.s ft3, fa1           
    bnez t1, raizes_complexas
raizes_reais:
    fsqrt.s ft0, ft0          
    fadd.s ft4, ft3, ft0      
    fdiv.s ft4, ft4, ft2      
    fsub.s ft5, ft3, ft0      
    fdiv.s ft5, ft5, ft2      
    addi sp, sp, -8           
    fsw ft4, 0(sp)            
    fsw ft5, 4(sp)            
    li a0, 1                  
    ret
raizes_complexas:
    fdiv.s ft4, ft3, ft2      
    fneg.s ft0, ft0           
    fsqrt.s ft0, ft0          
    fdiv.s ft5, ft0, ft2      
    addi sp, sp, -8           
    fsw ft4, 0(sp)            
    fsw ft5, 4(sp)            
    li a0, 2                  
    ret

plot:
    addi sp, sp, -36
    sw ra, 32(sp)
    sw s0, 28(sp)
    sw s1, 24(sp)
    sw s2, 20(sp)
    fsw fs0, 16(sp)
    fsw fs1, 12(sp)
    fsw fs2, 8(sp)
    fsw fs3, 4(sp)
    fsw fs4, 0(sp)
    fmv.s fs0, fa1
    fmv.s fs1, fa2
    fmv.s fs2, fa3
    fmv.w.x ft0, zero
    feq.s t0, fs0, ft0
    bnez t0, a_is_zero
    li t0, 2
    fcvt.s.w ft1, t0
    fmul.s ft1, ft1, fs0 
    fdiv.s ft2, fs1, ft1 
    fabs.s ft2, ft2      
    li t0, 2
    fcvt.s.w ft3, t0
    fmul.s ft2, ft2, ft3 
    li t0, 10
    fcvt.s.w ft3, t0
    fadd.s ft2, ft2, ft3 
    j calc_scalex
a_is_zero:
    li t0, 20
    fcvt.s.w ft2, t0    
calc_scalex:
    li t0, 160
    fcvt.s.w ft3, t0
    fdiv.s fs3, ft3, ft2 
    li t0, 1
    fcvt.s.w fs4, t0    
    li s0, 0            
loop_scan:
    li t0, 320
    bge s0, t0, fim_scan
    addi t1, s0, -160
    fcvt.s.w ft0, t1    
    fdiv.s fa0, ft0, fs3 
    fmv.s fa1, fs0
    fmv.s fa2, fs1
    fmv.s fa3, fs2
    jal fx              
    fabs.s ft0, fa0
    flt.s t0, fs4, ft0
    beqz t0, next_scan
    fmv.s fs4, ft0      
next_scan:
    addi s0, s0, 1
    j loop_scan
fim_scan:
    li t0, 120
    fcvt.s.w ft0, t0
    fdiv.s fs4, ft0, fs4
    li a0, 0          
    li a1, 120        
    li a2, 319        
    li a3, 120        
    li a4, 0x00FFFFFF 
    li a5, 0          
    li a7, 47         
    ecall
    li a0, 160        
    li a1, 0          
    li a2, 160        
    li a3, 239        
    li a4, 0x00FFFFFF 
    li a5, 0          
    li a7, 47         
    ecall
    li s0, 0          
    li s1, -1         
    li s2, 0          
loop_plot:
    li t0, 320
    bge s0, t0, fim_plot
    addi t1, s0, -160
    fcvt.s.w ft0, t1
    fdiv.s fa0, ft0, fs3
    fmv.s fa1, fs0
    fmv.s fa2, fs1
    fmv.s fa3, fs2
    jal fx              
    fmul.s ft0, fa0, fs4
    fcvt.w.s t1, ft0    
    li t2, 120
    sub t1, t2, t1    
    bltz t1, next_pixel
    li t2, 240
    bge t1, t2, next_pixel
    bltz s1, guarda_ponto
    mv a0, s2         
    mv a1, s1         
    mv a2, s0         
    mv a3, t1         
    li a4, 0x00FFFFFF 
    li a5, 0          
    li a7, 47         
    ecall
guarda_ponto:
    mv s2, s0         
    mv s1, t1         
next_pixel:
    addi s0, s0, 1
    j loop_plot
fim_plot:
    lw ra, 32(sp)
    lw s0, 28(sp)
    lw s1, 24(sp)
    lw s2, 20(sp)
    flw fs0, 16(sp)
    flw fs1, 12(sp)
    flw fs2, 8(sp)
    flw fs3, 4(sp)
    flw fs4, 0(sp)
    addi sp, sp, 36
    ret

fx:
    fmul.s ft0, fa0, fa0      
    fmul.s ft0, ft0, fa1      
    fmul.s ft1, fa2, fa0      
    fadd.s ft0, ft0, ft1      
    fadd.s fa0, ft0, fa3      
    ret

.include "SYSTEMv24.s"
