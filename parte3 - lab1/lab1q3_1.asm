.data

.text
#float fx (float x, float a, float b, float c)
#?(?)=?.?2+?.?+c

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
	
	fmul.s	fs4, fs2, fs0	# b*x fs2 liberado
	fmul.s	fs0, fs0, fs0	# fs2 = x^2
	fmul.s	fs1, fs1, fs0	# a*x^2
	fadd.s	fs2, fs1, fs4	# a*x^2 + b*x
	fadd.s	fa0, fs2, fs3	# a*x^2 + b*x + c
	
	li	a7, 2		# print float f(x)
	ecall
	
	li	a7, 10		# exit
	ecall