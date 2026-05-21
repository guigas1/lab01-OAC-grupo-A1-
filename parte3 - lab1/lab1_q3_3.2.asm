.include "MACROSv24.s"

.data
    #valores de teste para a equação a*x^2 + b*x + c
    val_a: .float 1.0
    val_b: .float 0.0
    val_c: .float -9.8696

.text
.globl main


main:
    # tela preta 
    li a7, 148
    li a0, 0x00    
    li a1, 0       
    ecall

    #carregar os coeficientes
    la t0, val_a
    flw fa1, 0(t0)
    la t0, val_b
    flw fa2, 0(t0)
    la t0, val_c
    flw fa3, 0(t0)

    #chama o procedimento do desenho
    jal plot

    
    li a7, 10
    ecall



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

    
    #Eixo X
    li a0, 0          
    li a1, 120        
    li a2, 319        
    li a3, 120        
    li a4, 0x00FFFFFF 
    li a5, 0          
    li a7, 47         
    ecall

    # Eixo Y
    li a0, 160        
    li a1, 0          
    li a2, 160        
    li a3, 239        
    li a4, 0x00FFFFFF
    li a5, 0          
    li a7, 47         
    ecall

    #desenho
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

    #
    mv a0, s2         
    mv a1, s1         
    mv a2, s0         
    mv a3, t1         
    li a4, 0xFFFFFFFF 
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
    fmul.s ft0, fa0, fa0      # x^2
    fmul.s ft0, ft0, fa1      # a*x^2
    fmul.s ft1, fa2, fa0      # b*x
    fadd.s ft0, ft0, ft1      # ax^2 + bx
    fadd.s fa0, ft0, fa3      # ax^2 + bx + c
    ret


.include "SYSTEMv24.s"
