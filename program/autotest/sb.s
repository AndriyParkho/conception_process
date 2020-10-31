# TAG = sb
	.text

  # sb rd, imm(rs1)

    lui t0, 0
		la t1, ADDR1
		sb t0, 4(t1)
		lb x31, 4(t1)

		li t0, 1
		sb t0, 4(t1)
		lb x31, 4(t1)

		li t0, 0x123
		sb t0, 4(t1)
		lb x31, 4(t1)

	# max_cycle 50
	# pout_start
  # 00000000
	# 00000001
	# 00000023
  # pout_end

.data
ADDR1: .word 0xF0F000F0
