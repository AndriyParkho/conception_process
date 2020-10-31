# TAG = and
	.text

  # and rd, rs1, rs2
  # le registre x0 vaut toujours 0
    and x31, x0, x0  			# 0 & 0

    lui t0, 0x12345
    and x31, x0, t0				# 0 & 0x12345

    lui t0, 0x11111
    and x31, t0, t0				# 0x11111 & 0x11111

    addi t0, zero, -1
    and x31, t0, t0				# 0xFFF & 0xFFF

    addi t1, zero, 0x0FF
    and x31, t1, t0				# 0x0FF & 0xFFF

	# max_cycle 50
	# pout_start
    # 00000000
    # 00000000
    # 11111000
    # FFFFFFFF
    # 000000FF
 	# pout_end
