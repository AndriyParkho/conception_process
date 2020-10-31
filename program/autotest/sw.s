# TAG = sw
	.text

  # sw rd, imm(rs1)

    lui t0, 0
		la t1, ADDR1
		sw t0, 4(t1)
		lw x31, 4(t1)

		lui t0, 0x12345
		sw t0, 4(t1)
		lw x31, 4(t1)

		addi t0, zero, 0x123
		sw t0, 4(t1)
		lw x31, 4(t1)

	# max_cycle 50
	# pout_start
  # 00000000
	# 12345000
	# 00000123
  # pout_end

.data
ADDR1: .word 0xF0F000F0
