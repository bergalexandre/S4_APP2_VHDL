---------------------------------------------------------------------------------------------
-- circuit reg_dec_24b.vhd
---------------------------------------------------------------------------------------------
-- Université de Sherbrooke - Département de GEGI
-- Version         : 1.0
-- Nomenclature    : 0.8 GRAMS
-- Date            : 15 mai 2019
-- Auteur(s)       : Daniel Dalle
-- Technologies    : FPGA Zynq (carte ZYBO Z7-10 ZYBO Z7-20)
--
-- Outils          : vivado 2018.2
---------------------------------------------------------------------------------------------
-- Description:
-- Registre à décalages de 24 bits
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

entity reg_dec_24b is
  Port ( 
    i_clk       : in std_logic;      -- horloge
    i_reset     : in std_logic;      -- reinitialisation
    i_load      : in std_logic;      -- activation chargement parallele
    i_en        : in std_logic;      -- activation decalage
    i_dat_bit   : in std_logic;      -- entree serie
    i_dat_load  : in std_logic_vector(23 downto 0);    -- entree parallele
    o_dat       : out  std_logic_vector(23 downto 0)   -- sortie parallele
);
end reg_dec_24b;

architecture Behavioral of reg_dec_24b is

  --
    signal   q_shift_reg   : std_logic_vector(23 downto 0);   -- registre 
    
  begin 
  -- registre a décalage,  MSB arrive premier, entre par la droite, decalage a gauche  
  reg_dec: process (i_clk, i_reset)
     begin    
       if (i_reset = '1')  then
          q_shift_reg  <= (others =>'0');
      elsif rising_edge(i_clk) then  
                if (i_load = '1')  then
                   q_shift_reg  <= i_dat_load;
                elsif (i_en = '1') then
                   q_shift_reg(23 downto 0) <= q_shift_reg(22 downto 0) & i_dat_bit;
                end if;
       end if;
     end process;
 
     o_dat   <=  q_shift_reg;

end Behavioral;
