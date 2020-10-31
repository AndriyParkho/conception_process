# TAG = andi
	.text

  # andi rd, rs1, immI
  # le registre x0 vaut toujours 0
    andi x31, x0, 0  # 0 + 0

    andi x31, x0, 0x123

    lui t0, 0x11111
    andi x31, t0, -239

    addi t0, zero, -1
    andi x31, t0, -1

    addi t1, zero, 0x0FF
    andi x31, t1, -1

	# max_cycle 50
	# pout_start
    # 00000000
    # 00000000
    # 11111000
    # FFFFFFFF
    # 000000FF
 	# pout_end
