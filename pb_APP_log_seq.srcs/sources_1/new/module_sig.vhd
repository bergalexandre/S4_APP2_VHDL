
---------------------------------------------------------------------------------------------
-- module_sig.vhd  
-- 
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--    Université de Sherbrooke - Département de GEGI
--
--    Version         : 1.0
--    Nomenclature    : inspiree de la nomenclature 0.2 GRAMS
--    Date            : 27 janvier 2019, rev 22 mai 2019, 29 août 2019
--    Auteur(s)       : 
--    Technologie     : ZYNQ 7000 Zybo Z7-10 (xc7z010clg400-1)
--    Outils          : vivado 2018.2 64 bits
--
---------------------------------------------------------------------------------------------
--    Description (sur une carte Zybo)
---------------------------------------------------------------------------------------------
-- V1: voir énoncé problématique
--
---------------------------------------------------------------------------------------------
--  Tests codec sur une carte Zybo
--
--
---------------------------------------------------------------------------------------------
--    À FAIRE:
--
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
---------------------------------------------------------------------------------------------
entity module_sig is
    Port (
    i_reset   : in    std_logic;  -- reset
    i_bclk    : in    std_logic;  -- bit clock I2S digital audio clk ~  3.1 MHz 
    i_lrc     : in    std_logic;  -- I²S (Playback Channel Clock)    ~ 48.3 KHz
    i_recdat  : in    std_logic;  -- I²S (Record Data) en provenance du CODEC
    o_pbdat   : out   std_logic;  -- I²S (Playback Data) vers le CODEC
    --
    i_sel_fct : in    std_logic_vector (1 downto 0); -- selecteur de la fonction
    i_sel_par : in    std_logic_vector (1 downto 0); -- selecteur de parametre
    o_param   : out std_logic_vector (7 downto 0);   -- sortie des parametre
    o_statut  : out std_logic_vector (3 downto 0)    -- statut des selecteurs
                                                     -- de fonction 
                                                     -- et de parametre
    );
end  module_sig;


----------------------------------------------------------------------------------

architecture Behavioral of module_sig is

component fct_dure is
    Port (
        i_dat24 :   IN STD_LOGIC_VECTOR(23 downto 0);
        o_dat24 :   OUT STD_LOGIC_VECTOR(23 downto 0)
    );
end component;

component fct_douce is
    Port (
        i_dat24: in std_logic_vector(23 downto 0);
        o_dat24: out std_logic_vector(23 downto 0)      
    );
end component;

component mux_function is
    Port (
        fct_1  : in STD_LOGIC_VECTOR(23 downto 0);
        fct_2  : in STD_LOGIC_VECTOR(23 downto 0);
        fct_3  : in STD_LOGIC_VECTOR(23 downto 0);
        fct_4  : in STD_LOGIC_VECTOR(23 downto 0);
        selection : in STD_LOGIC_VECTOR(1 downto 0);
        sortie : out STD_LOGIC_VECTOR(23 downto 0)
    );
end component;

component param_amplitude is
    Port ( 
        i_value     : in STD_LOGIC_VECTOR(23 downto 0);
        i_dat_str   : in STD_LOGIC;
        o_value     : out STD_LOGIC_VECTOR(7 downto 0)
    );
end component;

component MEF_frequence is
   Port ( 
        i_dat24     : in std_logic_vector(23 downto 0);
        i_bclk      : in std_logic;
        i_reset     : in std_logic; 
        i_lrc       : in std_logic;
        i_cpt_bits  : in std_logic_vector(6 downto 0);
        o_dat8     : out std_logic_vector(7 downto 0) 
   
);
end component;

component param_puissance is
    Port (
        i_value : in STD_LOGIC_VECTOR(23 downto 0);
        i_dat_str : in STD_LOGIC;
        i_puissance : in STD_LOGIC_VECTOR(15 downto 0);
        o_puissance : out STD_LOGIC_VECTOR(15 downto 0);
        o_aff : out STD_LOGIC_VECTOR(7 downto 0)
    );
end component;

component mux_param is
Port (
        param_1 : in STD_LOGIC_VECTOR(7 downto 0);
        param_2 : in STD_LOGIC_VECTOR(7 downto 0);
        param_3 : in STD_LOGIC_VECTOR(7 downto 0);
        param_4 : in STD_LOGIC_VECTOR(7 downto 0);
        selection : in STD_LOGIC_VECTOR(1 downto 0);
        sortie : out STD_LOGIC_VECTOR(7 downto 0)
    );
end component;

component decodeur_i2s_v1b
  Port (
      i_bclk      : in  std_logic;
      i_reset     : in  std_logic;  -- reset
      i_lrc       : in  std_logic;
      i_dat       : in  std_logic;
      o_dat_left  : out std_logic_vector(23 downto 0);
      o_dat_right : out std_logic_vector(23 downto 0);
      o_str_dat   : out std_logic
      );
end component;
 
component codeur_i2s_vsb
   port (
      i_bclk      : in std_logic;
      i_reset     : in    std_logic;  --
      i_lrc       : in std_logic;
      i_dat_left  : in  std_logic_vector(23 downto 0);
      i_dat_right : in  std_logic_vector(23 downto 0);
      o_dat       : out std_logic
      );
   end component;
-------------------------------------------------------------------------------
-- Signaux
----------------------------------------------------------------------------------

    signal d_sel_fct    :    std_logic_vector (1 downto 0);
    signal d_sel_par    :    std_logic_vector (1 downto 0);
    
    signal d_btn1           : std_logic;
 
    signal d_bclk            : std_logic;
    signal reset             : std_logic;
    signal d_pbdat           : std_logic;
    signal d_pblrc           : std_logic;
    signal d_recdat          : std_logic;
    signal d_lrc             : std_logic;
    signal d_ech_tst         : std_logic_vector (23 downto 0);   -- pour generer sortie test

    signal d_ech_left_dec    : std_logic_vector(23 downto 0);  -- echantillon canal gauche
    signal d_ech_right_dec   : std_logic_vector(23 downto 0);  -- echantillon canal droite
    signal d_ech_left_out    : std_logic_vector(23 downto 0);  -- echantillon canal gauche
    signal d_ech_right_out   : std_logic_vector(23 downto 0);  -- echantillon canal droite

    signal d_ech_fct         : std_logic_vector(23 downto 0);  --
    signal d_ech_fct_1       : std_logic_vector(23 downto 0);  --
    signal d_ech_fct_2       : std_logic_vector(23 downto 0);  --
    signal d_ech_fct_3       : std_logic_vector(23 downto 0);  --

    signal d_param           : std_logic_vector(7 downto 0);  --
    signal d_param_1         : std_logic_vector(7 downto 0);  --
    signal d_param_2         : std_logic_vector(7 downto 0);  --
    signal d_param_3         : std_logic_vector(7 downto 0);  --

    signal d_puissance       : std_logic_vector(15 downto 0);

    signal d_str_dat_i2s     : std_logic;
   

---------------------------------------------------------------------------------------------
--    Description (sur une carte Zybo)
---------------------------------------------------------------------------------------------
begin
     d_bclk      <= i_bclk;
     reset       <= i_reset;
     d_lrc       <= i_lrc;
     d_sel_fct   <= i_sel_fct;
     d_sel_par   <= i_sel_par;
     d_recdat    <= i_recdat;    -- I²S (Record Data)      provenant du codec
     o_pbdat     <= d_pbdat;     -- I²S (Playback Data)    sortant vers le codec

     o_statut    <= d_sel_fct & d_sel_par;  --  satut des commandes
     o_param     <= d_param  (7 downto 0);  --  sur 8 bit


-- decodeur I2S
inst_decod_i2s: decodeur_i2s_v1b
       Port map
          (
          i_bclk      =>  d_bclk,
          i_reset      => reset,
          i_lrc       =>  d_lrc,
          i_dat       =>  d_recdat,
          o_dat_left  =>  d_ech_left_dec,
          o_dat_right =>  d_ech_right_dec,
          o_str_dat   =>  d_str_dat_i2s
        );

d_ech_fct <= d_ech_right_dec;
d_ech_left_out <= d_ech_left_dec; -- canal gauche non tranformé

-- codeur I2S
  inst_cod_i2s: codeur_i2s_vsb
       Port map
          (
          i_bclk      =>  d_bclk,
          i_reset      => reset,
          i_lrc       =>  d_lrc,
          o_dat       =>  d_pbdat,
          i_dat_left  =>  d_ech_tst,
          i_dat_right =>  d_ech_fct
        );

    inst_fct_dure : fct_dure Port map (
        i_dat24 => d_ech_left_out,
        o_dat24 => d_ech_fct_1
    );
    
    inst_fct_douce : fct_douce port map (
            i_dat24 => d_ech_left_out,
            o_dat24 => d_ech_fct_2
        );
    
    
    d_ech_fct_3 <= not d_ech_left_out;
    
    inst_mux_function : mux_function Port map (
            fct_1 => d_ech_left_out,
            fct_2 => d_ech_fct_1,
            fct_3 => d_ech_fct_2,
            fct_4 => d_ech_fct_3,
            selection => d_sel_fct,
            sortie => d_ech_tst
        );
    
    inst_param_amplitude : param_amplitude Port map ( 
            i_value => d_ech_tst,
            i_dat_str => d_lrc,
            o_value => d_param_1
        );
    
    inst_MEF_frequence : MEF_frequence port map ( 
            i_dat24 => d_ech_tst,
            i_bclk => d_bclk,
            i_reset => reset,
            i_lrc => d_lrc,
            i_cpt_bits => "0000000",
            o_dat8 => d_param_2
    );
    
    inst_param_puissance : param_puissance Port map (
            i_value => d_ech_tst,
            i_dat_str => d_lrc,
            i_puissance => d_puissance,
            o_puissance => d_puissance,
            o_aff => d_param_3
        );
    
    inst_mux_param : mux_param Port map(
            param_1 => x"00",
            param_2 => d_param_1,
            param_3 => d_param_2,
            param_4 => d_param_3,
            selection => d_sel_par,
            sortie => d_param
        );


end Behavioral;