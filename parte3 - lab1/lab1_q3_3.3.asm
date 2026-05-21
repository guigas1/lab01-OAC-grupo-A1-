.data
    float_a: .float 1.0    # Coeficiente a
    float_b: .float -5.0   # Coeficiente b
    float_c: .float 6.0    # Coeficiente c

    msg_tipo: .asciz "Tipo (1=Reais, 2=Complexas): "
    msg_r1:   .asciz "Raiz 1 (ou Parte Real): "
    msg_r2:   .asciz "Raiz 2 (ou Parte complexa): "
    nl:       .asciz "\n"

.text
.globl main

main:
    
    la t0, float_a
    flw fa0, 0(t0)       # fa0 = a
    
    la t0, float_b
    flw fa1, 0(t0)       # fa1 = b
    
    la t0, float_c
    flw fa2, 0(t0)       # fa2 = c

    jal baskara #bhaskara

   
    mv s0, a0

    
    flw fs0, 0(sp)       # fs0 = R1 (Parte Real)
    flw fs1, 4(sp)       # fs1 = R2 (Parte Imaginária)
    addi sp, sp, 8       

    # imprime o tipo (1 ou 2)
    la a0, msg_tipo
    li a7, 4
    ecall
    mv a0, s0
    li a7, 1
    ecall
    la a0, nl
    li a7, 4
    ecall

    la a0, msg_r1
    li a7, 4
    ecall
    fmv.s fa0, fs0       
    li a7, 2
    ecall
    la a0, nl
    li a7, 4
    ecall

    la a0, msg_r2
    li a7, 4
    ecall
    fmv.s fa0, fs1       
    li a7, 2
    ecall
    la a0, nl
    li a7, 4
    ecall

    li a7, 10
    ecall

baskara:
    # calcula Delta = b^2 - 4ac
    fmul.s ft0, fa1, fa1      
    li t0, 4
    fcvt.s.w ft1, t0          
    fmul.s ft1, ft1, fa0      
    fmul.s ft1, ft1, fa2      
    fsub.s ft0, ft0, ft1      
    
    # verifica se Delta < 0
    fmv.w.x ft2, zero         
    flt.s t1, ft0, ft2        
    
    # denominador = 2a
    li t0, 2
    fcvt.s.w ft2, t0          
    fmul.s ft2, ft2, fa0      
    
    # prepara -b
    fneg.s ft3, fa1           
    
    bnez t1, raizes_complexas

raizes_reais:
    fsqrt.s ft0, ft0          
    
    # R1 e R2
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
    # parte Real
    fdiv.s ft4, ft3, ft2      
    
    # parte Imaginária
    fneg.s ft0, ft0           
    fsqrt.s ft0, ft0          
    fdiv.s ft5, ft0, ft2      
    
    addi sp, sp, -8           
    fsw ft4, 0(sp)            
    fsw ft5, 4(sp)            
    
    li a0, 2                  
    ret
