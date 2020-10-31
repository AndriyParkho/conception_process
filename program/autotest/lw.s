# TAG = lw
	.text

  # lw rd, imm(rs1)

    lui t0, %hi(a)
		addi t0, t0, %lo(a)
		lw x31, 0(t0)

	.data
	a : .word 0xfeedbacc

	# max_cycle 50
	# pout_start
    # feedbacc
    # pout_end
