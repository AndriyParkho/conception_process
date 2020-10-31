# TAG = lb
	.text

  # lb rd, imm(rs1)
  # le registre x0 vaut toujours 0

    lui t0, %hi(a)
		addi t0, t0, %lo(a)
		lb x31, 0(t0)

	.data
	a : .word 0xfeedbacc

	# max_cycle 50
	# pout_start
    # FFFFFFcc
    # pout_end
