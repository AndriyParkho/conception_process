# TAG = auipc
	.text

	# auipc rd, ImmU

	auipc x31, 0      		# Chargement de la même valeur que pc
	addi x30, x0, 0       # Instruction quelconque
	auipc x31, 0x00000    # Chargement de la même valeur que pc
	auipc x31, 0x12345 		# Chargement d'une valeur quelconque + pc

	# max_cycle 50
	# pout_start
				# 00001000
        # 00001008
        # 1234600c
  # pout_end
