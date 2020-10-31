# TAG = blt
	.text

  # blt rs1, rs2, label
  # rs1 < rs2 ⇒ pc ← pc + cst

	addi x30, x0, 3
	addi x31, x0, 1
	blt x31, x30, test2

	test0:
		addi x31, x0, -4

	test1:
		addi x30, x0, 6
		addi x31, x0, 5
		blt x31, x30, fin

	test2:
		addi x31, x0, 0
		blt x31, x30, test1

	test3:
		addi x31, x0, 4

	fin:
		addi x30, x0, -5
		addi x31, x0, 1
		blt x31, x30, test0

	# max_cycle 50
	# pout_start
		# 00000001
		# 00000000
    # 00000005
    # 00000001
 	# pout_end
