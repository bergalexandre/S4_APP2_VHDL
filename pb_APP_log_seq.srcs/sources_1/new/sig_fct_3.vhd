---------------------------------------------------------------------------------------------
--    sig_fct_3.vhd   (temporaire)
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--    Université de Sherbrooke - Département de GEGI
--
--    Version         : 5.0
--    Nomenclature    : inspiree de la nomenclature 0.2 GRAMS
--    Date            : 29 janvier 2019
--    Auteur(s)       : 
--    Technologie     : ZYNQ 7000 Zybo Z7-10 (xc7z010clg400-1) 
--    Outils          : vivado 2018.2 64 bits
--
---------------------------------------------------------------------------------------------
--  Description 
--  fonction temporaire, aucun calcul
---------------------------------------------------------------------------------------------
--
---------------------------------------------------------------------------------------------
--   À FAIRE:
--   Voir le guide de la problématique
---------------------------------------------------------------------------------------------
--
---------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
USE ieee.numeric_std.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;

---------------------------------------------------------------------------------------------
--    Description comportementale
---------------------------------------------------------------------------------------------
entity sig_fct_3 is
    Port (  
    i_ech       : in   std_logic_vector (23 downto 0);
    o_ech_fct   : out  std_logic_vector (23 downto 0)                                    
    );
end sig_fct_3;

----------------------------------------------------------------------------------

architecture Behavioral of sig_fct_3 is

---------------------------------------------------------------------------------
-- Signaux
----------------------------------------------------------------------------------
    signal d_ech             : std_logic_vector (23 downto 0);   -- 
    signal d_ech_fct         : std_logic_vector (23 downto 0);   --   
    signal d_ech_u24         : unsigned (23 downto 0);      --  
   
---------------------------------------------------------------------------------------------
-- 
begin 
    -- simple transfert...
    d_ech_u24   <=  unsigned (i_ech);
    o_ech_fct   <=  std_logic_vector( d_ech_u24);    
                 
end Behavioral;
