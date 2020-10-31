# TAG = jal
	.text

	# jal rd, label

	jal x0, test2

	test0:
		addi x31, x0, 4

	test1:
		addi x31, x0, 5
		jal x0, fin

	test2:
		addi x31, x0, 0
		jal x0, test1

	test3:
		addi x31, x0, 2

	fin:
		addi x31, x0, 3

	# max_cycle 50
	# pout_start
		# 00000000
		# 00000005
		# 00000003
 	# pout_end
