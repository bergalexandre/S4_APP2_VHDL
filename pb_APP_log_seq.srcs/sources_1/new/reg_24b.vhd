---------------------------------------------------------------------------------------------
-- circuit reg_24b.vhd
---------------------------------------------------------------------------------------------
-- Université de Sherbrooke - Département de GEGI
-- Version         : 1.0
-- Nomenclature    : 0.8 GRAMS
-- Date            : 10 janvier 2019, rev 29 janvier,  2 mai 2019, 5 mai 2019
-- Auteur(s)       : Daniel Dalle
-- Technologies    : FPGA Zynq (carte ZYBO Z7-10 ZYBO Z7-20)
--
-- Outils          : vivado 2018.2
---------------------------------------------------------------------------------------------
-- Description:
-- Registre de 24 bits
--
-- Revision 14 mai 2019 
---------------------------------------------------------------------------------------------
-- À faire :
-- 
-- 
---------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- pour les additions dans les compteurs

entity reg_24b is
  Port ( 
    i_clk       : in std_logic;
    i_reset     : in std_logic;
    i_en        : in std_logic;
    i_dat       : in std_logic_vector(23 downto 0);
    o_dat       : out  std_logic_vector(23 downto 0)
);
end reg_24b;

architecture Behavioral of reg_24b is

  --
    signal   q_reg   : std_logic_vector(23 downto 0);   -- registre
    
  begin
  -- registre  
  reg_dec: process (i_clk, i_reset)
     begin    
         if (i_reset = '1')  then
            q_reg  <= (others =>'0');
         elsif rising_edge(i_clk) and  (i_en = '1')  then
            q_reg  <= i_dat;
        end if;
     end process;
 
     o_dat   <=  q_reg;

end Behavioral;
