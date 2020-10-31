# TAG = lh
	.text

  # lh rd, imm(rs1)
  # le registre x0 vaut toujours 0

    lui t0, %hi(a)
		addi t0, t0, %lo(a)
		lh x31, 0(t0)

	.data
	a : .word 0xfeedbacc

	# max_cycle 50
	# pout_start
    # FFFFbacc
    # pout_end
