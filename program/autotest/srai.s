# TAG = srai
	.text

  # srai rd, rs1, imm

		srai x31, x0, 0  # 0 >> 0

    addi t0, zero, 0
    srai x31, t0, 5

    addi t0, x0, 32
		srai x31, t0, 1

    addi t0, x0, -32
    srai x31, t0, 0

	# max_cycle 50
	# pout_start
    # 00000000
    # 00000000
    # 00000010
    # FFFFFFE0
  # pout_end
