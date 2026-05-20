.data
    msg_x: .string "Digite x: "
    msg_a: .string "Digite a: "
    msg_b: .string "Digite b: "
    msg_c: .string "Digite c: "
    msg_r: .string "f(x) = "

.text
.globl main

main:
    
    li a7, 4
    la a0, msg_x
    ecall
    li a7, 6
    ecall
    fmv.s fs0, fa0      

   
    li a7, 4
    la a0, msg_a
    ecall
    li a7, 6
    ecall
    fmv.s fs1, fa0      

   
    li a7, 4
    la a0, msg_b
    ecall
    li a7, 6
    ecall
    fmv.s fs2, fa0      

    
    li a7, 4
    la a0, msg_c
    ecall
    li a7, 6
    ecall
    fmv.s fs3, fa0      

    
    fmv.s fa0, fs0      # fa0 = x
    fmv.s fa1, fs1      # fa1 = a
    fmv.s fa2, fs2      # fa2 = b
    fmv.s fa3, fs3      # fa3 = c


    jal fx

    
    fmv.s fs0, fa0     
    li a7, 4
    la a0, msg_r
    ecall
    fmv.s fa0, fs0
    li a7, 2
    ecall

    
    li a7, 10
    ecall


#float fx (float x, float a, float b, float c)

fx:
    fmul.s  ft0, fa2, fa0   # ft0 = b * x
    fmul.s  ft1, fa0, fa0   # ft1 = x^2
    fmul.s  ft2, fa1, ft1   # ft2 = a * x^2
    fadd.s  ft3, ft2, ft0   # ft3 = a*x^2 + b*x
    fadd.s  fa0, ft3, fa3   # fa0 = a*x^2 + b*x + c
    
    ret
