---------------------------------------------------------------------------------------------
-- Circuit conditionne_btn_v7.vhd
---------------------------------------------------------------------------------------------
-- Université de Sherbrooke - Département de GEGI
-- Version         : 7.0
-- Nomenclature    : 0.8 GRAMS
-- Date            : 9 novembre 2018, 27 novembre 2018, 31 janvier 2019, 30 avril 2019, 
--                   10 janvier 2020
-- Auteur(s)       : Réjean Fontaine, Daniel Dalle
-- Technologies    : FPGA Zynq (carte ZYBO Z7-10 ZYBO Z7-20)
--
-- Outils          : vivado 2019.1
---------------------------------------------------------------------------------------------
-- Description:
-- Circuit conditionnement des boutons avec horloge générique
-- V7 strobe sur transition descendante du bouton (relachement)
---------------------------------------------------------------------------------------------
-- À faire :
-- 
-- automatiser les calculs de constantes de délai (non requis si frequence 50 MHz pour CLK)
---------------------------------------------------------------------------------------------

library IEEE;
use     IEEE.std_logic_arith.all;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.STD_LOGIC_UNSIGNED.ALL;  -- pour les additions dans les compteurs

entity conditionne_btn_v7 is
generic (nbtn : integer := 4;  mode_simul: std_logic := '0');
port (
   CLK :    in std_logic;                          -- horloge
   i_btn :  in std_logic_vector (nbtn-1 downto 0); -- signaux directs des boutons
   --
   o_btn_db :  out  std_logic_vector (nbtn-1 downto 0);  -- signaux nettoyés 
                                                         -- (debounced) des boutons
   o_strobe_btn : out std_logic_vector (nbtn-1 downto 0) -- impulsion 
                                                         -- synchrone sur front CLK et transition descendante du bouton (relachement)
    ); 
end conditionne_btn_v7;


architecture Behavioral of conditionne_btn_v7 is

component strb_gen is
       Port ( 
           CLK      : in STD_LOGIC;    -- Entrée  horloge 
           i_don    : in  STD_LOGIC;   -- signal pour generer strobe au front montant          
           o_stb    : out  STD_LOGIC   -- strobe synchrone resultant
           );                           
   end component;
 
 signal  d_btn: std_logic_vector  (nbtn-1 downto 0);   
 signal  q0_btn: std_logic_vector (nbtn-1 downto 0);
 signal  q1_btn: std_logic_vector (nbtn-1 downto 0);  
 signal  q2_btn: std_logic_vector (nbtn-1 downto 0);   
     
 signal ValueCounter  : std_logic_vector(21 downto 0)  := "0000000000000000000000";
 -- note a 5 MHz, le bit 15 change a une frequende de 76 Hz environ
 -- note a 50 MHz, le bit 18 change a une frequende de 95 Hz environ
 -- note a 50 MHz, le bit 16 change a une frequende de 381 Hz environ
 signal  d_strobe_bit: std_logic;    
 signal  d_bit_count: std_logic;  

begin
--  version temporaire ..... 
--  automatiser les calculs de constantes de délai

process(CLK)
begin
   if (CLK'event and CLK = '1') then                -- sur front
            ValueCounter <= ValueCounter + 1;  
            d_btn <= i_btn;             
   end if;
end process;


process (ValueCounter)
begin
   if mode_simul = '1' then 
        d_bit_count <= ValueCounter(2);     -- pour temps simulation: court delai
    else
      -- d_bit_count <=  ValueCounter(21);  -- pour temps reel: long delai (trop) 
       d_bit_count <=  ValueCounter(16);    -- pour temps reel: 
    end if;
end process;


inst_strb_bit : strb_gen 
    Port map ( 
      CLK     =>  CLK,
      i_don   =>  d_bit_count,
      o_stb   =>  d_strobe_bit
      );           

debnc0_process : process (CLK)
   begin
      if (rising_edge(CLK)) then
         q0_btn <= d_btn;
      end if;      
   end process;

debnc1_process : process (CLK, d_strobe_bit )
   begin
      if ( rising_edge(CLK) and d_strobe_bit = '1') then 
         q1_btn <= q0_btn;
      end if;
   end process;  
   
debnc2_process : process (CLK)
   begin
      if (rising_edge(CLK)) then
         q2_btn <= q1_btn;
      end if;      
   end process;

o_btn_db     <= q1_btn;
o_strobe_btn <= not q1_btn AND q2_btn;  -- transition descendante
--o_strobe_btn <= q1_btn AND not q2_btn;  -- transition montante

end Behavioral;
