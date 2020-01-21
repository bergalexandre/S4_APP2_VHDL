
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

  component calcul_param_1
     Port (
     i_bclk    : in   std_logic;   -- bit clock
     i_reset     : in    std_logic;  --
     i_lrc     : in   std_logic;
     i_en        : in   std_logic;
     i_ech     : in   std_logic_vector (23 downto 0);
     o_param   : out  std_logic_vector (7 downto 0)
     );
  end component;

  component calcul_param_2
     Port (
     i_bclk    : in   std_logic;   -- bit clock
     i_reset   : in    std_logic;  --
     i_lrc     : in   std_logic;
     i_en      : in   std_logic;
     i_ech     : in   std_logic_vector (23 downto 0);
     o_param   : out  std_logic_vector (7 downto 0)
     );
 end component;

 component calcul_param_3
     Port (
     i_bclk    : in   std_logic;   -- bit clock
     i_reset   : in    std_logic;  --
     i_lrc     : in   std_logic;
     i_en      : in   std_logic;
     i_ech     : in   std_logic_vector (23 downto 0);
     o_param   : out  std_logic_vector (7 downto 0)
     );
 end component;


 component sig_fct_1 is
      Port (
      i_ech      : in   std_logic_vector (23 downto 0);
      o_ech_fct  : out  std_logic_vector (23 downto 0)
      );
  end component;

 component sig_fct_2 is
        Port (
        i_ech     : in   std_logic_vector (23 downto 0);
        o_ech_fct : out  std_logic_vector (23 downto 0)
        );
    end component;

  component sig_fct_3 is
        Port (
        i_ech     : in   std_logic_vector (23 downto 0);
        o_ech_fct : out  std_logic_vector (23 downto 0)
        );
   end component;

---------------------------------------------------------------------------------
-- Signaux
----------------------------------------------------------------------------------

    signal d_sel_fct    :    std_logic_vector (1 downto 0);
    signal d_sel_par    :    std_logic_vector (1 downto 0);
 
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


  inst_mx_fct: process(d_sel_fct, d_ech_fct_1, d_ech_fct_2, d_ech_fct_3, d_ech_right_dec)
    begin
      case d_sel_fct(1 downto 0) is
        when "00" =>          --
           d_ech_fct      <=  d_ech_right_dec; -- passage direct
        when "01" =>          --
           d_ech_fct      <=  d_ech_fct_1 (23 downto 0);
        when "10" =>          --
           d_ech_fct      <=  d_ech_fct_2 (23 downto 0);
       when others =>          --
           d_ech_fct      <=  d_ech_fct_3 (23 downto 0); -- <=  non spécifiée
      end case;
    end process;

  inst_fct1:  sig_fct_1
         Port map (
         i_ech       => d_ech_right_dec,
         o_ech_fct   => d_ech_fct_1
         );

  inst_fct2:  sig_fct_2
         Port map (
         i_ech       => d_ech_right_dec,
         o_ech_fct  => d_ech_fct_2
         );

   inst_fct3:  sig_fct_3
         Port map (
         i_ech       => d_ech_right_dec,
         o_ech_fct  => d_ech_fct_3
         );


 inst_cal_param1:  calcul_param_1
       Port map(
       i_bclk      => d_bclk,
       i_reset     => reset,
       i_lrc       => d_lrc,
       i_en        => d_str_dat_i2s,
       i_ech       => d_ech_fct,
       o_param     => d_param_1
       );

  inst_cal_param2:  calcul_param_2

      Port map(
      i_bclk      => d_bclk,
      i_reset      => reset,
      i_lrc       => d_lrc,
      i_en          => d_str_dat_i2s,
      i_ech       => d_ech_fct,
      o_param     => d_param_2
      );

   inst_cal_param3:  calcul_param_3
       Port map(
       i_bclk      => d_bclk,
       i_reset     => reset,
       i_lrc       => d_lrc,
       i_en        => d_str_dat_i2s,
       i_ech       => d_ech_fct,
       o_param     => d_param_3
       );

   inst_mx_par: process(d_sel_par, d_param_1, d_param_2, d_param_3)
   begin
       case d_sel_par(1 downto 0) is
             when "00" =>          --
                d_param      <=   x"00";
             when "01" =>          --
                d_param      <=   d_param_1;
             when "10" =>          --
                d_param      <=   d_param_2;
            when others =>          --
                d_param      <=   d_param_3;
       end case;
   end process;


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

d_ech_left_out <= d_ech_left_dec; -- canal gauche non tranformé

-- codeur I2S
  inst_cod_i2s: codeur_i2s_vsb
       Port map
          (
          i_bclk      =>  d_bclk,
          i_reset      => reset,
          i_lrc       =>  d_lrc,
          o_dat       =>  d_pbdat,
          i_dat_left  =>  d_ech_left_out,
          i_dat_right =>  d_ech_fct
        );



end Behavioral;