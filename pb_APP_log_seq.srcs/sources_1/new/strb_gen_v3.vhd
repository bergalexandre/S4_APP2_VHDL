---------------------------------------------------------------------------------------------
--	str_gen_v3_v3.vhd 
---------------------------------------------------------------------------------------------
--	Generation d'horloge et de signaux de synchronisation
---------------------------------------------------------------------------------------------
--	Université de Sherbrooke - Département de GEGI
--	
--	Version 		: 3.0						révision de la nomenclature
--	Nomenclature	: ref GRAMS
--	Date			: 26 mai 2016, 19 juillet 2016, 31 août 2018, 11 septembre 2018, 31 octobre 2018
--	Auteur(s)		: Daniel Dalle
--  Technologie     : ZYNQ 7000 PYNQ-Z1 (xc7z020clg400-1) antérieurement sur Artix 7 ( xc7a35tcpg236-1 ) 
--  Outils          : vivado 2018.2 64 bits
--	
--------------------------------
--	Description
--------------------------------
-- Génération de signaux de synchronisation, incluant des "strobes"
-- 11 septembre 2018: élimination des horloges internes pour réduire le nombre d signaux d'horloges
--------------------------------
--	À FAIRE:
--------------------------------
--
--
---------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity strb_gen is

    Port ( 
           CLK      : in STD_LOGIC;    -- Entrée  horloge maitre 
           i_don    : in  STD_LOGIC;   -- signal pour generer strobe au front montant          
           o_stb    : out  STD_LOGIC   -- strobe synchrone 
           );    
                  
end strb_gen;

architecture Behavioral of strb_gen is

 signal qstrobe : std_logic := '0';
 signal q_don : std_logic:= '0';

begin

process(CLK, i_don)   -- bascule synchro de l entree
begin
	if(CLK'event and CLK = '1') then
		q_don <= i_don;
	end if;
end process;

process(i_don, q_don)   -- sortie impulsion synchrone
begin
		o_stb <= i_don and not(q_don);
end process;

-- autres version pour synchroniser l'entree si necessaire
--process(CLK, i_don)   -- bascule second niveau
--begin
--	if(CLK'event and CLK = '1') then
--		qq_don <= q_don;
--	end if;
--end process;

--process(i_don, q_don, qq_don)   -- sortie impulsion synchrone
--begin
--		qstrobe <= q_don and not(qq_don);
--end process;

end Behavioral;

