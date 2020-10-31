library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.PKG.all;

entity CPU_PC is
    generic(
        mutant: integer := 0
    );
    Port (
        -- Clock/Reset
        clk    : in  std_logic ;
        rst    : in  std_logic ;

        -- Interface PC to PO
        cmd    : out PO_cmd ;
        status : in  PO_status
    );
end entity;

architecture RTL of CPU_PC is
    type State_type is (
        S_Error, S_Init, S_Pre_Fetch, S_Fetch, S_Decode, -- Etats contrôle
        S_ADDI, S_ADD, S_SUB, -- Arithmétiques
        S_LUI, -- Basique
        S_AUIPC, -- Divers
        S_AND, S_OR, S_XOR, S_ORI, S_ANDI, S_XORI, -- Logiques
        S_SLL, S_SRL, S_SRA, S_SRAI, S_SLLI, S_SRLI, -- Décalages
        S_SLTx, S_SLTIx, -- Sets
        S_Bx, -- Branchements
        S_JAL, S_JALR, -- Sauts
        S_LW, S_LWa, S_LWb, S_LB, S_LBa, S_LBb, S_LBU, S_LBUa, S_LBUb,
        S_LH, S_LHa, S_LHb, S_LHU, S_LHUa, S_LHUb, -- Loads
        S_SX, S_SXa, -- Stores
        S_CSRRW, S_CSRRS, S_MRET, S_CSRRWI -- Interruptions
    );

    signal state_d, state_q : State_type;

begin

    FSM_synchrone : process(clk)
    begin
        if clk'event and clk='1' then
            if rst='1' then
                state_q <= S_Init;
            else
                state_q <= state_d;
            end if;
        end if;
    end process FSM_synchrone;

    FSM_comb : process (state_q, status)
    begin

        -- Valeurs par défaut de cmd à définir selon les préférences de chacun

        cmd.ALU_op            <= UNDEFINED;
        cmd.LOGICAL_op        <= UNDEFINED;
        cmd.ALU_Y_sel         <= UNDEFINED;

        cmd.SHIFTER_op        <= UNDEFINED;
        cmd.SHIFTER_Y_sel     <= UNDEFINED;

        cmd.RF_we             <= '0';
        cmd.RF_SIZE_sel       <= UNDEFINED;
        cmd.RF_SIGN_enable    <= 'U';
        cmd.DATA_sel          <= UNDEFINED;

        cmd.PC_we             <= '0';
        cmd.PC_sel            <= UNDEFINED;

        cmd.PC_X_sel          <= UNDEFINED;
        cmd.PC_Y_sel          <= UNDEFINED;

        cmd.TO_PC_Y_sel       <= UNDEFINED;

        cmd.AD_we             <= '0';
        cmd.AD_Y_sel          <= UNDEFINED;

        cmd.IR_we             <= '0';

        cmd.ADDR_sel          <= UNDEFINED;
        cmd.mem_we            <= '0';
        cmd.mem_ce            <= '0';

        cmd.cs.CSR_we            <= UNDEFINED;

        cmd.cs.TO_CSR_sel        <= UNDEFINED;
        cmd.cs.CSR_sel           <= UNDEFINED;
        cmd.cs.MEPC_sel          <= UNDEFINED;

        cmd.cs.MSTATUS_mie_set   <= 'U';
        cmd.cs.MSTATUS_mie_reset <= 'U';

        cmd.cs.CSR_WRITE_mode    <= UNDEFINED;

        state_d <= state_q;

        case state_q is
            when S_Error =>
                -- Etat transitoire en cas d'instruction non reconnue
                -- Aucune action
                state_d <= S_Init;

            when S_Init =>
                -- PC <- RESET_VECTOR
                cmd.PC_we  <= '1';
                cmd.PC_sel <= PC_rstvec;
                state_d    <= S_Pre_Fetch;

            when S_Pre_Fetch =>
                -- mem[PC]
                cmd.mem_we   <= '0';
                cmd.mem_ce   <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                state_d      <= S_Fetch;

            when S_Fetch =>
                -- IR <- mem_datain
                cmd.IR_we <= '1';
                state_d   <= S_Decode;

            when S_Decode =>

                if status.IR(6 downto 0) = "1110011" then
                  cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                  cmd.PC_sel <= PC_from_pc;
                  cmd.PC_we <= '1';
                  -- CSRRW
                  if status.IR(14 downto 12) = "001" then
                      state_d <= S_CSRRW;
                  -- CSRRS
                  elsif status.IR(14 downto 12) = "010" then
                      state_d <= S_CSRRS;
                  -- MRET
                  elsif status.IR(14 downto 12) = "000" then
                      state_d <= S_MRET;
                  -- CSRRWI
                  elsif status.IR(14 downto 12) = "101" then
                      state_d <= S_CSRRWI;
                  end if;
                -- LUI
                elsif status.IR(6 downto 0) = "0110111" then
                  cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                  cmd.PC_sel <= PC_from_pc;
                  cmd.PC_we <= '1';
                  state_d <= S_LUI;
                elsif status.IR(6 downto 0) = "0010011" then
                  -- Même famille d'encodage de 0 à 6
                  cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                  cmd.PC_sel <= PC_from_pc;
                  cmd.PC_we <= '1';
                  -- ADDI
                  if status.IR(14 downto 12) = "000" then
                      state_d <= S_ADDI;
                  -- ORI
                  elsif status.IR(14 downto 12) = "110" then
                      state_d <= S_ORI;
                  -- ANDI
                  elsif status.IR(14 downto 12) = "111" then
                      state_d <= S_ANDI;
                  -- XORI
                  elsif status.IR(14 downto 12) = "100" then
                      state_d <= S_XORI;
                  -- SLTI ; SLTIU
                  elsif status.IR(14 downto 12) = "010" or status.IR(14 downto 12) = "011" then
                      state_d <= S_SLTIx;

                  elsif status.IR(14 downto 12) = "101" then
                      -- Même famille d'encodage de 12 à 14
                      -- SRAI
                      if status.IR(31 downto 25) = "0100000" then
                          state_d <= S_SRAI;
                      -- SRLI
                      elsif status.IR(31 downto 25) = "0000000" then
                          state_d <= S_SRLI;
                      end if;
                  -- SLLI
                  elsif status.IR(14 downto 12) = "001" then
                      state_d <= S_SLLI;
                  end if;
                elsif status.IR(6 downto 0) = "0110011" then
                  -- Même famille d'encodage de 0 à 6
                  cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                  cmd.PC_sel <= PC_from_pc;
                  cmd.PC_we <= '1';

                  if status.IR(14 downto 12) = "000" then
                      -- Même famille d'encodage de 12 à 14
                      -- ADD
                      if status.IR(31 downto 25) = "0000000" then
                          state_d <= S_ADD;
                      -- SUB
                      elsif status.IR(31 downto 25) = "0100000" then
                          state_d <= S_SUB;
                      end if;
                  -- SLL
                  elsif status.IR(14 downto 12) = "001" then
                      state_d <= S_SLL;

                  elsif status.IR(14 downto 12) = "101" then
                      -- Même famille d'encodage de 12 à 14
                      --SRL
                      if status.IR(31 downto 25) = "0000000" then
                          state_d <= S_SRL;
                      -- SRA
                      elsif status.IR(31 downto 25) = "0100000" then
                          state_d <= S_SRA;
                      end if;
                -- SLT ; SLTU
                elsif status.IR(14 downto 12) = "010" or status.IR(14 downto 12) = "011" then
                      state_d <= S_SLTx;
                  -- OR
                  elsif status.IR(14 downto 12) = "110" then
                      state_d <= S_OR;
                  -- AND
                  elsif status.IR(14 downto 12) = "111" then
                      state_d <= S_AND;
                  -- XOR
                  elsif status.IR(14 downto 12) = "100" then
                      state_d <= S_XOR;
                  end if;
                -- AUIPC
                elsif status.IR(6 downto 0) = "0010111" then
                  -- On n'incrèmente pas la PC
                  state_d <= S_AUIPC;
                -- BEQ ; BNE ; BLT ; BGE ; BLTU ; BGEU
                elsif status.IR(6 downto 0) = "1100011" then
                  state_d <= S_Bx;

                elsif status.IR(6 downto 0) = "0000011" then
                  -- Même famille d'encodage de 0 à 6
                  cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                  cmd.PC_sel <= PC_from_pc;
                  cmd.PC_we <= '1';
                  -- LW
                  if status.IR(14 downto 12) = "010" then
                      state_d <= S_LW;
                  -- LB
                  elsif status.IR(14 downto 12) = "000" then
                      state_d <= S_LB;
                  -- LBU
                  elsif status.IR(14 downto 12) = "100" then
                      state_d <= S_LBU;
                  -- LH
                  elsif status.IR(14 downto 12) = "001" then
                      state_d <= S_LH;
                  -- LHU
                  elsif status.IR(14 downto 12) = "101" then
                      state_d <= S_LHU;
                  end if;
                -- SW ; SH ; SB
                elsif status.IR(6 downto 0) = "0100011" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_SX;
                -- JAL
                elsif status.IR(6 downto 0) = "1101111" then
                    state_d <= S_JAL;
                -- JALR
                elsif status.IR(6 downto 0) = "1100111" then
                    state_d <= S_JALR;

                else
                  state_d <= S_Error;
                end if;


---------- Instructions avec immediat de type U ----------

            when S_LUI =>
                -- rd ← ImmU + 0
                cmd.PC_X_sel <= PC_X_cst_x00;
                cmd.PC_Y_sel <= PC_Y_immU;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_pc;
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_AUIPC =>
                -- rd ← ImmU + pc
                cmd.PC_X_sel <= PC_X_pc;
                cmd.PC_Y_sel <= PC_Y_immU;
                cmd.DATA_sel <= DATA_from_pc;
                cmd.RF_we <= '1';
                -- On incrémente la PC
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;


---------- Instructions arithmétiques et logiques ----------

            when S_ADDI =>
                -- rd ← rs1 + ImmI
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.ALU_op <= ALU_plus;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_alu;
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_ADD =>
                -- rd ← rs1 + rs2
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.ALU_op <= ALU_plus;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_alu;
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_SUB =>
                -- rd ← rs1 - rs2
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.ALU_op <= ALU_minus;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_alu;
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_SLL =>
                -- rd ← rs1 << rs2[4...0]
                cmd.SHIFTER_op <= SHIFT_ll;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_SRL =>
                -- rd ← rs1 >> rs2[4...0] (logique)
                cmd.SHIFTER_op <= SHIFT_rl;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_SRA =>
                -- rd ← rs1 >> rs2[4...0] (arithmétique)
                cmd.SHIFTER_op <= SHIFT_ra;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_SRAI =>
                -- rd ← rs1 >> shamt (arithmétique)
                cmd.SHIFTER_op <= SHIFT_ra;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_SLLI =>
                -- rd ← rs1 << shamt
                cmd.SHIFTER_op <= SHIFT_ll;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_SRLI =>
                -- rd ← rs1 >> shamt (logique)
                cmd.SHIFTER_op <= SHIFT_rl;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_AND =>
                -- rd ← rs1 and rs2
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.LOGICAL_op <= LOGICAL_and;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_OR =>
                -- rd ← rs1 or rs2
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.LOGICAL_op <= LOGICAL_or;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_XOR =>
                -- rd ← rs1 xor rs2
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.LOGICAL_op <= LOGICAL_xor;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_ORI =>
                -- rd ← ImmI or rs1
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.LOGICAL_op <= LOGICAL_or;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_ANDI =>
                -- rd ← ImmI or rs1
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.LOGICAL_op <= LOGICAL_and;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_XORI =>
                -- rd ← ImmI xor rs1
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.LOGICAL_op <= LOGICAL_xor;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

---------- Instructions de saut ----------

            when S_Bx =>
                -- rs1 = rs2 ⇒ pc ← pc + cst
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                if status.JCOND then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                else
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                end if;
                -- Lecture PC
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;

            when S_SLTx =>
            -- rs1 < rs2 ⇒ rd ← 0^31 ‖ 1	rd prend la valeur ’1’
          	-- rs1 ≥ rs2 ⇒ rd← 0^32				rd prend la valeur ’0’
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.DATA_sel <= DATA_from_slt;
                cmd.RF_we <= '1';
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_SLTIx =>
            -- rs1 < imm ⇒ rd ← 0^31 ‖ 1	rd prend la valeur ’1’
          	-- rs1 ≥ imm ⇒ rd← 0^32				rd prend la valeur ’0’
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.DATA_sel <= DATA_from_slt;
                cmd.RF_we <= '1';
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_JAL =>
                -- rd ← pc + 4
                -- pc ← pc + ImmJ
                cmd.PC_Y_sel <= PC_Y_cst_x04;
                cmd.PC_X_sel <= PC_X_pc;
                cmd.DATA_sel <= DATA_from_pc;
                cmd.RF_we <= '1';
                cmd.TO_PC_Y_sel <= TO_PC_Y_immJ;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;

            when S_JALR =>
                -- rd ← pc + 4
                -- pc ← rs1 + ImmI
                cmd.PC_Y_sel <= PC_Y_cst_x04;
                cmd.PC_X_sel <= PC_X_pc;
                cmd.DATA_sel <= DATA_from_pc;
                cmd.RF_we <= '1';
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.ALU_op <= ALU_plus;
                cmd.PC_sel <= PC_from_alu;
                cmd.PC_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;


---------- Instructions de chargement à partir de la mémoire ----------

            when S_LW =>
                -- AD = immI + rs1
                cmd.AD_Y_sel <= AD_Y_immI;
                cmd.AD_we <= '1';
                --next state
                state_d <= S_LWa;

            when S_LWa =>
                -- Positionnement sur le bus
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_LWb;

            when S_LWb =>
                -- rd = mem[AD]
                cmd.RF_SIZE_sel <= RF_SIZE_word;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_mem;
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_LB =>
                -- AD = immI + rs1
                cmd.AD_Y_sel <= AD_Y_immI;
                cmd.AD_we <= '1';
                --next state
                state_d <= S_LBa;

            when S_LBa =>
                -- Positionnement sur le bus
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_LBb;

            when S_LBb =>
                -- rd = mem[AD]
                cmd.RF_SIZE_sel <= RF_SIZE_byte;
                cmd.RF_SIGN_enable <= '1';
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_mem;
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_LBU =>
                -- AD = immI + rs1
                cmd.AD_Y_sel <= AD_Y_immI;
                cmd.AD_we <= '1';
                --next state
                state_d <= S_LBUa;

            when S_LBUa =>
                -- Positionnement sur le bus
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_LBUb;

            when S_LBUb =>
                -- rd = mem[AD]
                cmd.RF_SIZE_sel <= RF_SIZE_byte;
                cmd.RF_SIGN_enable <= '0';
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_mem;
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_LH =>
                -- AD = immI + rs1
                cmd.AD_Y_sel <= AD_Y_immI;
                cmd.AD_we <= '1';
                --next state
                state_d <= S_LHa;

            when S_LHa =>
                -- Positionnement sur le bus
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_LHb;

            when S_LHb =>
                -- rd = mem[AD]
                cmd.RF_SIZE_sel <= RF_SIZE_half;
                cmd.RF_SIGN_enable <= '1';
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_mem;
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_LHU =>
                -- AD = immI + rs1
                cmd.AD_Y_sel <= AD_Y_immI;
                cmd.AD_we <= '1';
                --next state
                state_d <= S_LHUa;

            when S_LHUa =>
                -- Positionnement sur le bus
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_LHUb;

            when S_LHUb =>
                -- rd = mem[AD]
                cmd.RF_SIZE_sel <= RF_SIZE_half;
                cmd.RF_SIGN_enable <= '0';
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_mem;
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;


---------- Instructions de sauvegarde en mémoire ----------

            when S_SX =>
                -- AD = immS + rs1
                cmd.AD_Y_sel <= AD_Y_immS;
                cmd.AD_we <= '1';
                -- next state
                state_d <= S_SXa;

            when S_SXa =>
                -- Positionnement du bus d'adresse
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '1';
                -- SW
                if status.IR(14 downto 12) = "010" then
                    cmd.RF_SIZE_sel <= RF_SIZE_word;
                -- SB
                elsif status.IR(14 downto 12) = "000" then
                    cmd.RF_SIZE_sel <= RF_SIZE_byte;
                -- SH
                elsif status.IR(14 downto 12) = "001" then
                    cmd.RF_SIZE_sel <= RF_SIZE_half;
                end if;
                cmd.RF_SIGN_enable <= '1';
                -- next state
                state_d <= S_PRE_Fetch;


---------- Instructions d'accès aux CSR ----------

            when S_CSRRW =>
                -- rd ← csr
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_csr;
                -- csr ← rs1
                cmd.CSR_we <= CSR_mie;
                cmd.TO_CSR_sel <= TO_CSR_from_rs1;
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_CSRRWI =>
                -- csrrw rd, csr, rs1
                -- rd ← csr
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_csr;
                -- csr ← imm
                cmd.CSR_we <= CSR_mie;
                cmd.TO_CSR_sel <= TO_CSR_from_imm;
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_MRET =>
                -- pc ← mepc
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                -- mstatus(3) ← 1
                cmd.MSTATUS_mie_set <= '1';
                -- Lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when others => null;
        end case;

    end process FSM_comb;

end architecture;
