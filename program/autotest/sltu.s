# TAG = sltu
	.text

  # slt rd, rs1, rs2
	# rs1 < rs2 ⇒ rd ← 0^31 ‖ 1		rd prend la valeur ’1’
	# rs1 ≥ rs2 ⇒ rd← 0^32				rd prend la valeur ’0’

	addi x18, x0, 2
  addi x19, x0, 3

  sltu x31, x18, x19
	sltu x31, x18, x18
  sltu x31, x19, x18

	# max_cycle 50
	# pout_start
    # 00000001
    # 00000000
    # 00000000
 	# pout_end
