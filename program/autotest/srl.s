# TAG = srl
	.text

  # srl rd, rs1, rs2

		srl x31, x0, x0  # 0 >> 0

    addi t0, zero, 0
    addi t1, zero, 5
    srl x31, t0, t1

    addi t0, x0, 32
    addi t1, x0, 1
		srl x31, t0, t1

    addi t0, x0, -32
    addi t1, x0, 0
    srl x31, t0, t1

	# max_cycle 50
	# pout_start
    # 00000000
    # 00000000
    # 00000010
    # FFFFFFE0
  # pout_end
