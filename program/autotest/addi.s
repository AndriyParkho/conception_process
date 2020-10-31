# TAG = addi
	.text

  # addi rd, rs1, immI
  # le registre x0 vaut toujours 0

	addi x31, x0, 0
  addi x31, x0, -1 			# Chargement de la valeur -1 dans x31
	addi x31, x0, -2048 	# Chargement de la valeur -2048 dans x31
  addi x31, x0, 2047 		# Chargement de la valeur 2047 dans x31

	# max_cycle 50
	# pout_start
  # 00000000
  # FFFFFFFF
	# FFFFF800
	# 000007FF
	# pout_end
