# TAG = ori
	.text

  # ori rd, rs1, ImmI
  # le registre x0 vaut toujours 0

    ori x31, x0, 0  		# 0 or 0

    ori x31, x0, 0x123

    lui t0, 0x11111
    ori x31, t0, 0x111

    addi t0, zero, -1
    ori x31, t0, -1

    addi t1, zero, 0x0FF
    ori x31, t1, -1

	# max_cycle 50
	# pout_start
    # 00000000
    # 00000123
    # 11111111
		# FFFFFFFF
		# FFFFFFFF
 	# pout_end
