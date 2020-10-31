# TAG = sll
	.text

  # sll rd, rs1, rs2
  # le registre x0 vaut toujours 0

		sll x31, x0, x0  # 0 << 0

    addi t0, zero, 0
    addi t1, zero, 5
    sll x31, t0, t1

    addi t0, x0, 2
    addi t1, x0, 5
		sll x31, t0, t1

    addi t0, x0, -4
    addi t1, x0, 3
    sll x31, t0, t1

	# max_cycle 50
	# pout_start
    # 00000000
    # 00000000
    # 00000040
    # FFFFFFE0
  # pout_end
