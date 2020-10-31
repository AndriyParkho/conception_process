# TAG = or
	.text

  # or rd, rs1, rs2
  # le registre x0 vaut toujours 0
    or x31, x0, x0  	# 0 or 0

    lui t0, 0x12345
    or x31, x0, t0

    lui t0, 0x11111
    or x31, t0, t0

    addi t0, zero, -1
    or x31, t0, t0

    addi t1, zero, 0x0FF
    or x31, t1, t0

	# max_cycle 50
	# pout_start
    # 00000000
    # 12345000
    # 11111000
    # FFFFFFFF
    # FFFFFFFF
 	# pout_end
