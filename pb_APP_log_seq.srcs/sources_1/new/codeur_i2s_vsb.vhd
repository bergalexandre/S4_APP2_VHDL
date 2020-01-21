---------------------------------------------------------------------------------------------
-- circuit codeur_i2s_vsb.vhd
---------------------------------------------------------------------------------------------
-- Université de Sherbrooke - Département de GEGI
-- Version         : 1.0
-- Nomenclature    : 0.8 GRAMS
-- Date            : 10 janvier 2019, rev 29 janvier, 2 février 2019, 2 mai 2019, 22 mai 2019
-- Auteur(s)       : Daniel Dalle
-- Technologies    : FPGA Zynq (carte ZYBO Z7-10 ZYBO Z7-20)
--
-- Outils          : vivado 2018.2
---------------------------------------------------------------------------------------------
-- Description:
-- Codeur I2S
--
-- notes
-- frequences (peuvent varier un peu selon les contraintes de mise en oeuvre)
-- i_lrc        ~ 48.    KHz    (~ 20.8    us)
-- d_ac_mclk,   ~ 12.288 MHz    (~ 80,715  ns) (non utilisee dans le codeur)
-- i_bclk       ~ 3,10   MHz    (~ 322,857 ns) freq mclk/4
-- La durée d'une période reclrc est de 64,5 périodes de bclk ...
--
-- Revision 12 janvier 2019, 19 janvier (front lrc), 5 mai 2019 transitions codeur-decodeur
---------------------------------------------------------------------------------------------
-- À faire :
--
--
---------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- pour les additions dans les compteurs

entity codeur_i2s_vsb is
  Port (
      i_bclk      : in std_logic;     -- bit clock ... horloge I2S digital audio
      i_reset     : in    std_logic;  --
      i_lrc       : in std_logic;     -- I²S (Record Channel Clock, ADC Sampling Rate Clock)
      i_dat_left  : in  std_logic_vector(23 downto 0); -- entrée canal gauche
      i_dat_right : in  std_logic_vector(23 downto 0); -- entrée canal droite
      o_dat       : out std_logic                      -- sortie codee I2S  
      
  );
end codeur_i2s_vsb;

architecture Behavioral of codeur_i2s_vsb is
 
 
component mef_cod_i2s_vsb is
  Port ( 
    i_bclk      : in std_logic;
    i_reset     : in    std_logic; 
    i_lrc       : in std_logic;
    i_cpt_bits  : in std_logic_vector(6 downto 0);
  --  
    o_bit_enable     : out std_logic ;  --
    o_load_left      : out std_logic ;  --
    o_load_right     : out std_logic ;  -- 
    o_cpt_bit_reset  : out std_logic   -- 
    
);
end component;
  
   
component reg_dec_24b_fd
  Port ( 
    i_clk       : in std_logic;
    i_reset     : in std_logic;
    i_load      : in std_logic;
    i_en        : in std_logic;
    i_dat_bit   : in std_logic;
    i_dat_load  : in std_logic_vector(23 downto 0);
    o_dat       : out  std_logic_vector(23 downto 0)
);
end component;

component reg_24b 
  Port ( 
    i_clk       : in std_logic;
    i_reset     : in std_logic;
    i_en        : in std_logic;
    i_dat       : in std_logic_vector(23 downto 0);
    o_dat       : out  std_logic_vector(23 downto 0)
);
end component;


component compteur_nbits 
generic (nbits : integer := 8);
   port ( clk             : in    std_logic; 
          i_en            : in    std_logic; 
          reset           : in    std_logic; 
          o_val_cpt       : out   std_logic_vector (nbits-1 downto 0)
          );
end component;

   
   
   
   
    signal   d_bit_enable : std_logic ;  --

    
    signal   q_shift_reg   : std_logic_vector(23 downto 0);   -- registre a decalage
    signal   d_load_reg_dec: std_logic_vector(23 downto 0);   -- registre a decalage

    signal   d_cpt_bit_reset   : std_logic ;  --
    signal   d_cpt_bits      : std_logic_vector(6 downto 0) ;  -- compteur bits  
    signal   d_load          : std_logic ;  -- (codeur)
    signal   d_load_left     : std_logic ;  -- (codeur)
    signal   d_load_right    : std_logic ;  -- (codeur)
    signal   dat_bit_enable  : std_logic ;  --


begin


inst_MEF_cod : mef_cod_i2s_vsb
port  map
 ( 
  i_bclk      => i_bclk,  
  i_reset     => i_reset,
  i_lrc       => i_lrc,
  i_cpt_bits  => d_cpt_bits,
--  
  o_bit_enable     => d_bit_enable,
  o_load_left      => d_load_left,
  o_load_right     => d_load_right,
 -- o_str_dat        => d_str_dat, 
  o_cpt_bit_reset  => d_cpt_bit_reset
  
  );


inst_cpt_bits_cod : compteur_nbits
generic map (nbits => 7)
port  map
 ( clk  => i_bclk,
  i_en   => d_bit_enable,
  reset   => d_cpt_bit_reset,
  o_val_cpt   => d_cpt_bits
  );

  reg_shift_load_mpx: process (d_load_left, d_load_right, i_dat_right, i_dat_left) is
    begin
       if (d_load_left = '1')  then
         d_load_reg_dec  <= i_dat_left;
       elsif (d_load_right = '1') then
          d_load_reg_dec  <= i_dat_right;
       else
          d_load_reg_dec <= x"000000";
       end if;

   end process;

    d_load <= d_load_left  or d_load_right;

   -- registre a décalage (fonctionnement sur front descendant pour le codeur)
  reg_shift_I2S: reg_dec_24b_fd
    port  map  ( 
          i_clk       => i_bclk,
          i_reset     => i_reset,
          i_load      => d_load ,
          i_en        => d_bit_enable,
          i_dat_bit   => '1',
          i_dat_load  => d_load_reg_dec,
          o_dat       => q_shift_reg
      );
      

    o_dat       <= q_shift_reg(23) ;
  
end Behavioral;