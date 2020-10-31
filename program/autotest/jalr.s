# TAG = jalr
	.text

	lui x31, 5
	jal t0, test
	addi x31, x0, 1
	jalr x0, 0(t0)
	test:
		addi x31, x0, 3
		jalr t0, 0(t0)
		addi x31, x0, 7

	# max_cycle 50
	# pout_start
		# 00000005
		# 00000003
		# 00000001
		# 00000007
	# pout_end
