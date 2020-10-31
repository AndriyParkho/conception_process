# TAG = slli
	.text

  # slli rd, rs1, imm

		slli x31, x0, 0  # 0 << 0

    addi t0, zero, 0
    slli x31, t0, 5

    addi t0, x0, 2
		slli x31, t0, 5

    addi t0, x0, -4
    slli x31, t0, 3

	# max_cycle 50
	# pout_start
    # 00000000
    # 00000000
    # 00000040
    # FFFFFFE0
  # pout_end
