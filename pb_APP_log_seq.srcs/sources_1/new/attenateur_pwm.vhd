---------------------------------------------------------------------------------------------
-- attenuateur_pwm.vhd 
---------------------------------------------------------------------------------------------
-- Generation d'horloge et de signaux de synchronisation
---------------------------------------------------------------------------------------------
-- Université de Sherbrooke - Département de GEGI
-- 
-- Version        : 1.0
-- Nomenclature   : ref GRAMS
-- Date           : 17 sept. 2018
-- Auteur(s)      : Daniel Dalle
-- Technologies   : FPGA Zynq (carte ZYBO Z7-10 ZYBO Z7-20)
-- Outils         : vivado 2018.2 64 bits
-- 
--------------------------------
-- Description
--------------------------------
-- Attenuateur par modulation pwm pour sorties leds
--
-- 
---------------------------------------------------------------------------------------------
-- À FAIRE:
-- 
--
---------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;     -- requis pour les constantes  etc.
use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- pour les additions dans les compteurs

Library UNISIM;
use UNISIM.vcomponents.all;

entity attenuateur_pwm is
generic (c_val_seuil: std_logic_vector(7 downto 0)  := "00000111"); 
    Port ( 
           CLK        : in STD_LOGIC;      -- Entrée horloge 
           i_signal    : in  STD_LOGIC;    -- entree 
           o_signal    : out  STD_LOGIC    -- sortie          
           );                  
end attenuateur_pwm;

architecture Behavioral of attenuateur_pwm is
 
 -- constantes pour les diviseurs
  
 constant c_seuil         : std_logic_vector(7 downto 0)  := c_val_seuil;
 signal   d_val_compteur  : std_logic_vector(7 downto 0)  := "00000000";
 signal   d_signal_on      : std_logic := '1';


begin
                        
o_signal  <= d_signal_on AND i_signal;

process(CLK)
begin
   if(CLK'event and CLK = '1') then
       d_val_compteur <= d_val_compteur + 1;
       if (d_val_compteur = "00000000") then  
            d_signal_on <= '1';                  -- on
       else if (d_val_compteur = c_seuil) then 
            d_signal_on <= '0';                  -- off           
            end if;
       end if;
   end if;
end process;

end Behavioral;

