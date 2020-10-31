# TAG = xori
	.text

  # xori rd, rs1, rs2
  # le registre x0 vaut toujours 0
    xori x31, x0, 0  	# 0 XOR 0

    xori x31, x0, 0x123

    lui t0, 0x11111
    xori x31, t0, 0x111

    addi t0, zero, -1
    xori x31, t0, -1

    addi t1, zero, 0x0FF
    xori x31, t1, -1

	# max_cycle 50
	# pout_start
    # 00000000
    # 00000123
    # 11111111
    # 00000000
    # FFFFFF00
 	# pout_end
