# TAG = sh
	.text

  # sh rd, imm(rs1)

    lui t0, 0
		la t1, ADDR1
		sh t0, 4(t1)
		lh x31, 4(t1)

		lui t0, 0x12345
		sh t0, 4(t1)
		lh x31, 4(t1)

		addi t0, zero, 0x123
		sh t0, 4(t1)
		lh x31, 4(t1)

	# max_cycle 50
	# pout_start
  # 00000000
	# 00005000
	# 00000123
  # pout_end

.data
ADDR1: .word 0xF0F000F0
