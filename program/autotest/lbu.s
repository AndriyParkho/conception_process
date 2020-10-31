# TAG = lbu
	.text

  # lbu rd, imm(rs1)
  # le registre x0 vaut toujours 0

    lui t0, %hi(a)
		addi t0, t0, %lo(a)
		lbu x31, 0(t0)

	.data
	a : .word 0xFFFFFFFF

	# max_cycle 50
	# pout_start
    # 000000FF
    # pout_end
