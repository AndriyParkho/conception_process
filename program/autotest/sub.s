# TAG = sub
	.text

  # sub rd, rs1, rs2
  # le registre x0 vaut toujours 0
    sub x31, x0, x0  # 0 - 0

    addi x20, x0, 1000 		# Chargement de la valeur 1000 dans le registre 20
    sub x31, x20, x20 		# Chargement de la valeur 1000 - 1000

    addi x21, x0, -1400 	# Chargement de la valeur -1400 dans le registre 21
    sub x31, x20, x21 		# 1000 + 1400

    addi x20, x0, -2048 	# Chargement de -2048 dans le registre 20
		sub x31, x20, x20 		# Chargement de la valeur -2048 + 2048 dans x31

    lui x20, 0x12345 			# Chargement d'une val quelconque dans x20
    sub x31, x20, x0 			# Chargement de la valeur qlcq dans x31

	# max_cycle 50
	# pout_start
    # 00000000
    # 00000000
    # 00000960
    # 00000000
    # 12345000
 	# pout_end
