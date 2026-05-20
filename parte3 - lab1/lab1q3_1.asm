.data

.text
#float fx (float x, float a, float b, float c)

	li	a7, 6
	ecall
	fmv.s	fs0, fa0	# x
	
	li	a7, 6
	ecall
	fmv.s	fs1, fa0	# a
	
	li	a7, 6
	ecall
	fmv.s	fs2, fa0	# b
	
	li	a7, 6
	ecall
	fmv.s	fs3, fa0	# c
	
	fmul.s  ft0, fa2, fa0   # ft0 = b * x
    fmul.s  ft1, fa0, fa0   # ft1 = x^2
    fmul.s  ft2, fa1, ft1   # ft2 = a * x^2
    fadd.s  ft3, ft2, ft0   # ft3 = a*x^2 + b*x
    fadd.s  fa0, ft3, fa3   # fa0 = a*x^2 + b*x + c
	
	li	a7, 2		# print float f(x)
	ecall
	
	ret
