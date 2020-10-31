# TAG = xor
	.text

  # xor rd, rs1, rs2
  # le registre x0 vaut toujours 0
    xor x31, x0, x0  	# 0 XOR 0

    lui t0, 0x12345
    xor x31, x0, t0

    lui t0, 0x11111
    xor x31, t0, t0

    addi t0, zero, -1
    xor x31, t0, t0

    addi t1, zero, 0x0FF
    xor x31, t1, t0

	# max_cycle 50
	# pout_start
    # 00000000
    # 12345000
    # 00000000
    # 00000000
    # FFFFFF00
 	# pout_end
