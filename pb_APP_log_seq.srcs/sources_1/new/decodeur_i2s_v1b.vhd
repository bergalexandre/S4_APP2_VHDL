---------------------------------------------------------------------------------------------
-- circuit decodeur_i2s_v1b.vhd
---------------------------------------------------------------------------------------------
-- Université de Sherbrooke - Département de GEGI
-- Version         : 1.0
-- Nomenclature    : 0.8 GRAMS
-- Date            : 22 mai 2019
-- Auteur(s)       : Daniel Dalle
-- Technologies    : FPGA Zynq (carte ZYBO Z7-10 ZYBO Z7-20)
--
-- Outils          : vivado 2019.1
---------------------------------------------------------------------------------------------
-- Description:
-- Decodeur I2Ss
-- Version préliminaire réalisée avec un compteur pour le controle du décodeur
--
-- notes  
-- frequences (peuvent varier un peu selon les contraintes de mise en oeuvre)
-- i_lrc        ~ 48.    KHz    (~ 20.8    us)
-- d_ac_mclk,   ~ 12.288 MHz    (~ 80,715  ns) (non utilisee dans le codeur)
-- i_bclk       ~ 3,10   MHz    (~ 322,857 ns) freq mclk/4 
-- La durée d'une période reclrc est de 64,5 périodes de bclk ...
--
-- Revision 15 mai 2019 (version ..._v1b) composants dans entités et fichiers distincts
-- 
---------------------------------------------------------------------------------------------
-- À faire :
-- 
-- 
---------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- pour les additions dans les compteurs

entity decodeur_i2s_v1b is
  Port ( 
    i_bclk      : in std_logic; -- bit clock ... horloge I2S digital audio
    i_reset     : in std_logic; -- 
    i_lrc       : in std_logic; -- I²S (Record Channel Clock)
    i_dat       : in std_logic; -- signal I2S  en entree
    o_dat_left  : out  std_logic_vector(23 downto 0);  -- sortie decodee canal gauche
    o_dat_right : out  std_logic_vector(23 downto 0);  -- sortie decodee canal droite
    o_str_dat   : out std_logic -- impulsion de synchronisation donnees valides
);
end decodeur_i2s_v1b;

architecture Behavioral of decodeur_i2s_v1b is

component mef_decod_i2s_v1b is
  Port ( 
    i_bclk      : in std_logic;
    i_reset     : in    std_logic; 
    i_lrc       : in std_logic;
    i_cpt_bits  : in std_logic_vector(6 downto 0);
  --  
    o_bit_enable     : out std_logic ;  --
    o_load_left      : out std_logic ;  --
    o_load_right     : out std_logic ;  --
    o_str_dat        : out std_logic ;  --  
    o_cpt_bit_reset  : out std_logic   -- 
    
);
end component;


component reg_dec_24b 
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


    signal   d_bit_enable    : std_logic ;  --
    signal   d_load_left     : std_logic ;  --
    signal   d_load_right    : std_logic ;  --
    signal   d_str_dat       : std_logic ;  --    
    -- 
    signal   q_ech_left      : std_logic_vector(23 downto 0);   -- registre canal gauche (sortie)
    signal   q_ech_right     : std_logic_vector(23 downto 0);   -- registre canal droite (sortie)
    signal   q_shift_reg     : std_logic_vector(23 downto 0);   -- registre a decalage
    
   -- signal   cpt_bit_enable  : std_logic ;  --   
    signal   d_cpt_bit_reset : std_logic ;  --   
    signal   d_cpt_bits      : std_logic_vector(6 downto 0) ;  -- compteur bits 



begin

inst_MEF_decod1b : mef_decod_i2s_v1b
port  map
 ( 
  i_bclk           => i_bclk,  
  i_reset          => i_reset,
  i_lrc            => i_lrc,
  i_cpt_bits       => d_cpt_bits,
--  
  o_bit_enable     => d_bit_enable,
  o_load_left      => d_load_left,
  o_load_right     => d_load_right,
  o_str_dat        => d_str_dat, 
  o_cpt_bit_reset  => d_cpt_bit_reset
  
  );



inst_cpt_bits : compteur_nbits
generic map (nbits => 7)
port  map
 ( clk        => i_bclk,
  i_en        => '1',     -- compteur toujours actif
  reset       => d_cpt_bit_reset,
  o_val_cpt   => d_cpt_bits
  );

   -- registre a décalage
  reg_shift_I2S: reg_dec_24b
    port  map  ( 
          i_clk      => i_bclk,
          i_reset     => i_reset,
          i_load      => '0',
          i_en        => d_bit_enable,
          i_dat_bit   => i_dat,
          i_dat_load  => x"000000",
          o_dat       => q_shift_reg
      );
      
    -- registre de sortie Gauche
    reg_L:  reg_24b 
        Port map ( 
          i_clk        => i_bclk,
          i_reset     => i_reset,
          i_en        => d_load_left,
          i_dat       => q_shift_reg,
          o_dat       => q_ech_left
      );

    -- registre de sortie Droite
        reg_R:  reg_24b 
        Port map ( 
          i_clk        => i_bclk,
          i_reset     => i_reset,
          i_en        => d_load_right,
          i_dat       => q_shift_reg,
          o_dat       => q_ech_right
      );


    o_dat_left  <=  q_ech_left;
    o_dat_right <=  q_ech_right;
    o_str_dat   <=  d_str_dat;

end Behavioral;

