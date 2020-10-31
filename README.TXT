==== Projet CEP - Conception d’un processeur RISC-V ====
========= Andriy Parkhomenko & Thibault Launay =========

Implemantation :
- Instructions arithmetiques (ADDI, ADD, SUB)
- Instructions basiques (REBOUCLAGE, LUI)
- Instructions divers (AUIPC)
- Instructions logiques (OR, ORI, AND, ANDI, XOR, XORI)
- Instructions décalages (SLL, SLLI, SRA, SRAI, SRL, SRLI)
- Instructions sets (SLT, SLTI, SLTIU, SLTU)
- Instructions branchements (BEQ, BGE, BGEU, BLT, BLTU, BNE)
- Instructions sauts (JAL, JALR)
- Instructions loads (LB, LBU, LH, LHU, LW)
- Instructions stores (SB, SH, SW)
- Instructions Interruptions (CSRRW, CSRRWI, MRET non testée)

L'ensemble des tests de ces instructions ont été réalisé (voir program/autotest/),
à l'exception de celui de JALR qui ne semble pas fonctionner.
Chaque test a le même nom que l'instruction qu'il test avec l'extention ".s" à la fin.

Fichiers VHD modifiés :
- CPU_PC  (PC)
- CPU_CND (PO)
- CPU_CSR (PO)

Aucune extension n'a été ajoutée.
