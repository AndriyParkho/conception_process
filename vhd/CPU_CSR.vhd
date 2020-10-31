library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG.all;

entity CPU_CSR is
    generic (
        INTERRUPT_VECTOR : waddr   := w32_zero;
        mutant           : integer := 0
    );
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;

        -- Interface de et vers la PO
        cmd         : in  PO_cs_cmd;
        it          : out std_logic;
        pc          : in  w32;
        rs1         : in  w32;
        imm         : in  W32;
        csr         : out w32;
        mtvec       : out w32;
        mepc        : out w32;

        -- Interface de et vers les IP d'interruption
        irq         : in  std_logic;
        meip        : in  std_logic;
        mtip        : in  std_logic;
        mie         : out w32;
        mip         : out w32;
        mcause      : in  w32
    );
end entity;

architecture RTL of CPU_CSR is

    -- registres
    signal mcause_d, mcause_q : w32;
    signal mip_d, mip_q : w32;
    signal mie_d, mie_q : w32;
    signal mstatus_d, mstatus_q : w32;
    signal mtvec_d, mtvec_q : w32;
    signal mepc_d, mepc_q : w32;
    signal TO_CSR, mepc_mult : w32;
    -- Fonction retournant la valeur à écrire dans un csr en fonction
    -- du « mode » d'écriture, qui dépend de l'instruction
    function CSR_write (CSR        : w32;
                         CSR_reg    : w32;
                         WRITE_mode : CSR_WRITE_mode_type)
        return w32 is
        variable res : w32;
    begin
        case WRITE_mode is
            when WRITE_mode_simple =>
                res := CSR;
            when WRITE_mode_set =>
                res := CSR_reg or CSR;
            when WRITE_mode_clear =>
                res := CSR_reg and (not CSR);
            when others => null;
        end case;
        return res;
    end CSR_write;

begin
    -- Registres à usages général
    maj_reg : process (clk)
    begin
      if clk'event and clk='1' then
        if rst = '1' then
            mcause_q <= w32_zero;
            mip_q <= w32_zero;
            mie_q <= w32_zero;
            mstatus_q <= w32_zero;
            mtvec_q <= w32_zero;
            mepc_q <= w32_zero;
        else
            mcause_q <= mcause_d;
            mip_q <= mip_d;
            mie_q <= mie_d;
            mstatus_q <= mstatus_d;
            mtvec_q <= mtvec_d;
            mepc_q <= mepc_d;
        end if;
      end if;
    end process maj_reg;

    TO_CSR <= rs1 when cmd.TO_CSR_sel = TO_CSR_from_rs1 else imm;
    mepc_mult <= TO_CSR when cmd.MEPC_sel = MEPC_from_csr else pc;

    reg_input_selection : process (all)
    begin

          -- On fait d'abord les registres particulier
          mcause_d <= mcause_q;

          if irq = '1' then
              mcause_d <= mcause;
          end if;

          mip_d <= mip(31 downto 12) & meip & mip(10 downto 8) & mtip & mip(6 downto 0);

          -- Registre utilisant la focntion CSR_write

          case cmd.CSR_we is
              when CSR_mie =>
                  mie_d <= CSR_write(mie_q, TO_CSR, cmd.CSR_WRITE_mode);

              when CSR_mstatus =>
                  mstatus_d <= CSR_write(mstatus_q, TO_CSR, cmd.CSR_WRITE_mode);
                  if cmd.MSTATUS_mie_set = '1' then
                      mstatus_d(3) <= '1';
                  end if;
                  if cmd.MSTATUS_mie_reset = '1' then
                      mstatus_d(3) <= '0';
                  end if;

              when CSR_mtvec =>
                  mtvec_d <= CSR_write(mtvec_q, TO_CSR, cmd.CSR_WRITE_mode);

              when CSR_mepc =>
                  mepc_d <= CSR_write(mepc_q, mepc_mult, cmd.CSR_WRITE_mode);
              when others => null;
          end case;
    end process reg_input_selection;

    -- On associe les sorties
    mip <= mip_q;

    mie <= mie_q;
    csr_out_case : process(all)
    begin
        case (cmd.CSR_sel) is
            when CSR_from_mcause =>
                CSR <= mcause_q;
            when CSR_from_mip =>
                CSR <= mip_q;
            when CSR_from_mie =>
                CSR <= mie_q;
            when CSR_from_mstatus =>
                CSR <= mstatus_q;
            when CSR_from_mtvec =>
                CSR <= mtvec_q;
            when CSR_from_mepc =>
                CSR <= mepc_q;
            when others => null;
        end case;
    end process csr_out_case;

    it <= irq and mstatus_q(3);

    mtvec <= mtvec_q;

    mepc <= mepc_q;

end architecture;
