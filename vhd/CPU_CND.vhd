library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG.all;

entity CPU_CND is
    generic (
        mutant      : integer := 0
    );
    port (
        rs1         : in w32;
        alu_y       : in w32;
        IR          : in w32;
        slt         : out std_logic;
        jcond       : out std_logic
    );
end entity;

architecture RTL of CPU_CND is

      signal res : std_logic_vector(32 downto 0);
      signal extension_signe, z, s : std_logic;

begin

    extension_signe <= ((not IR(12)) and (not IR(6))) or (IR(6) and not (IR(13)));
    res <= std_logic_vector((rs1(31) & rs1) - (alu_y(31) & alu_y)) when extension_signe = '1' else std_logic_vector(('0' & rs1) - ('0' & alu_y));
    s <= res(32);
    z <= '1' when res = (res'range => '0') else '0';
    jcond <= (not IR(14) and (IR(12) xor z)) or ((IR(12) xor s) and IR(14));
    slt <= s;


end architecture;
