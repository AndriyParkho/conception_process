# TAG = slti
	.text

  # slt rd, rs1, rs2
	# rs1 < imm ⇒ rd ← 0^31 ‖ 1		rd prend la valeur ’1’
	# rs1 ≥ imm ⇒ rd← 0^32				rd prend la valeur ’0’

  addi x18, x0, -2

  slti x31, x18, -1
	slti x31, x18, -2
  slti x31, x18, -3

	# max_cycle 50
	# pout_start
    # 00000001
    # 00000000
    # 00000000
 	# pout_end
