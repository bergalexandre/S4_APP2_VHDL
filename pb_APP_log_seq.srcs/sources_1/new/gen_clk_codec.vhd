---------------------------------------------------------------------------------------------
--	gen_clk_codec.vhd
---------------------------------------------------------------------------------------------
--	Generation d'horloge et de signaux de synchronisation
---------------------------------------------------------------------------------------------
--	Université de Sherbrooke - Département de GEGI
--	
--	Version 		: 1.0
--	Nomenclature	: ref GRAMS
--	Date			: 30 octobre 2018, ..., 24 janvier 2019, 25 janvier
--	Auteur(s)		: Daniel Dalle
--  Technologie     : ZYNQ 7000 Zybo Z7-10 (xc7z010clg400-1)
--  Outils          : vivado 2018.2 64 bits
--	
--------------------------------
--	Description
--------------------------------
-- Génération de signaux de synchronisation, incluant des "strobes"
-- (utilise un PLL)
-- Ref:
-- 7 Series Libraries Guide www.xilinx.com 418 UG953 (v2016.3) October 5, 2016
--   (pages 425 PLLE2_BASE)
--
-- revisions
-- mise a jour   D Dalle 24 janvier 2019   commentaires
-- mise a jour   D Dalle 18 janvier 2019   synchronisation o_reclrc
-- mise a jour   D Dalle  9 janvier 2019   bufg sur o_bclk 
-- Développement D Dalle 30 octobre 2018, 7 novembre 2018, 4 janvier 2019
---------------------------------------------------------------------------------------------
--	À FAIRE:
---------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- pour les additions dans les compteurs
library UNISIM;
use UNISIM.VComponents.all;

entity gen_clk_codec is
port  (
   i_rst    : in STD_LOGIC;   -- entree reset
   m_clk    : in STD_LOGIC;   -- Entrée horloge maitre codec  12.389 MHz
   o_bclk   : out  STD_LOGIC; -- horloge bit clk:  freq m_clk MHz / 4 soit 3,097 MHz 
   o_reclrc : out  STD_LOGIC  -- horloge record, play back, sampling rate clock, left right channel 48,021 KHz 
  );
end gen_clk_codec;

architecture Behavioral of gen_clk_codec is

    signal d_bclk       : std_logic := '0';   -- horloge I2S digital audio (50 MHz pour cet exemple)
    signal d_reclrc     : std_logic := '0';   -- I²S (Record Channel Clock)  
    signal q_reclrc     : std_logic;          -- I²S (Record Channel Clock)  synchronisation
    signal d_cpt_reclrc : std_logic_vector (7 downto 0) := "00000000";  
    signal d_cpt_bclk   : std_logic_vector (1 downto 0) := "00"; 
    
    
    begin

-- generateur horloge echantillonnage (ADC sampling Rate) et transfert binaire 
------------------------------------------------------------------------
-- ref SSM2603 data sheet page 25 (defaut pour MCLK = 12.288 MHz)
-- RECLRC : MCLK / 256   BCLK : RECLRC / 4

reclrc_proc: process(m_clk)
       begin
           if rising_edge(m_clk) then
              if i_rst = '1' then
                 d_reclrc <= '0';
                 d_cpt_reclrc  <= "00000000"; 
              else
                 if d_cpt_reclrc = 128 then -- 256/2
                    d_cpt_reclrc <= "00000000"; 
                    d_reclrc <= not d_reclrc;
                 else
                    d_cpt_reclrc <= d_cpt_reclrc + 1;
                 end if;
              end if;
           end if;
        end process reclrc_proc;
  
bclk_proc: process(m_clk)    
       begin
           if rising_edge(m_clk) then
              if i_rst = '1' then
                 d_bclk <= '0';
                 d_cpt_bclk <= "00"; 
              else
                 if d_cpt_bclk = 01 then
                    d_cpt_bclk <= "00"; 
                    d_bclk <= not d_bclk;
                 else
                    d_cpt_bclk <= d_cpt_bclk + 1;
                 end if;
              end if;
           end if;
        end process bclk_proc;
  
--  lrc_proc: process(m_clk)    
--    begin
--       if falling_edge(m_clk) then
--              q_reclrc <= d_reclrc;  
--          end if;
--       end process lrc_proc;
 
 -- forme 25 janvier
  lrc_proc: process(d_bclk)    
    begin
       if falling_edge(d_bclk) then
              q_reclrc <= d_reclrc;  
          end if;
       end process lrc_proc; 
 
 
  o_reclrc <= q_reclrc;    
  
  -- o_bclk <= d_bclk;  
  ClockBufer1: bufg           -- revision 9 janvier 2018
      port map(
          I    => d_bclk,
          O    => o_bclk
          );
        
end Behavioral;
