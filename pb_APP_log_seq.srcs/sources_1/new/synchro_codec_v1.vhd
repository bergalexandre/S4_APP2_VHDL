---------------------------------------------------------------------------------------------
--  synchro_codec_v1.vhd          EN DEVELOPPPEMENT .......!!!!!!!!!!!!!!!!!!!!!!!!!!!!
---------------------------------------------------------------------------------------------
--  Generation d'horloge et de signaux de synchronisation
---------------------------------------------------------------------------------------------
--  Université de Sherbrooke - Département de GEGI
--
--  Version         : 1.0
--  Nomenclature    : ref GRAMS
--  Date            : 30 octobre 2018, 7 novembre 2018, 4 janvier 2019, 24 janvier 2019, 10 décembre 2019
--  Auteur(s)       : Daniel Dalle
--  Technologie     : ZYNQ 7000 Zybo Z7-10 (xc7z010clg400-1)
--  Outils          : vivado 2018.2 64 bits
--
--------------------------------
--  Description
--------------------------------
-- Génération de signaux de synchronisation, incluant des "strobes"
-- (utilise un PLL)
-- Ref:
-- 7 Series Libraries Guide www.xilinx.com 418 UG953 (v2016.3) October 5, 2016
--   (pages 425 PLLE2_BASE)
--
-- revisions
-- mise a jour D Dalle 10 decembre 2019  v1 synchro_zybo_v1 nomenclature synchro_demo_codec_v4 devient synchro_zybo_v1
-- mise a jour D Dalle 24 janvier 2019   v4 strobe commentaires, élimination entrée reset
-- mise a jour D Dalle 7  janvier 2019   v3 strobe 1000Hz   validation / correction S_1Hz
-- mise a jour D Dalle 4  janvier 2019   v3 strobe 1000Hz
-- mise a jour D Dalle 27 decembre 2018  v3 tous les strobes sur 50 MHz
-- mise a jour D Dalle 17 decembre 2018 constantes horloges en Hz (pour coherence avec autres modules)
---------------------------------------------------------------------------------------------
--  À FAIRE:
---------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;     -- requis pour les constantes  etc.
use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- pour les additions dans les compteurs

Library UNISIM;
use UNISIM.vcomponents.all;

entity synchro_codec_v1 is
generic (cst_CLK_syst_Hz: integer := 100_000_000); -- valeur par defaut fréquence de clkm
    Port (
    sysclk       : in STD_LOGIC;    -- Entrée  horloge système  
                                    -- (typique 125 MHz (1/8 ns) ou 100  ( 1/10 ns))
    o_clk_0      : out  STD_LOGIC;  -- horloge via bufg 50 MHz  (20 ns)  
                                    ---  (sera pour clk_p, horloge)
    o_mclk       : out  STD_LOGIC;  -- horloge via bufg 12.389 MHz 
                                    -- (80,714 ns) (pour codec)
    o_stb_1000Hz : out  STD_LOGIC;  -- strobe durée 1/o_clk_0 sync sur 1000Hz
    o_stb_1Hz    : out  STD_LOGIC;  -- strobe durée 1/o_clk_0 sync sur  1Hz
    o_S_1Hz      : out  STD_LOGIC;  -- Signal temoin 1 Hz
    o_bclk       : out  STD_LOGIC;  -- horloge bit clk 
                                    -- (~ 12.289 MHz/4 soit 3,07225 MHz (325.49 ns) )
    o_reclrc     : out  STD_LOGIC   -- horloge record, play back, 
                                    -- sampling rate clock, left right channel 
                                    -- (~ 48 KHz (20,83 us))
    );
end synchro_codec_v1;




architecture Behavioral of synchro_codec_v1 is

  component synchro_zybo_v1 is
   generic (const_CLK_syst_Hz: integer := 100_000_000);  -- valeur par defaut de fréquence de clkm
       Port (
              sysclk         : in STD_LOGIC;    -- Entrée  horloge maitre  (typique 125 MHz (1/8 ns) ou 100  ( 1/10 ns))
              o_clk_0      : out  STD_LOGIC;  -- horloge via bufg 50.    MHz  (20 ns)
              o_clk_1      : out  STD_LOGIC;  -- horloge via bufg 12.389 MHz  (80,714 ns)
              o_stb_1000Hz : out  STD_LOGIC;  -- strobe durée 1/o_clk_0 sync sur 1000Hz
              o_stb_1Hz    : out  STD_LOGIC;  -- strobe durée 1/o_clk_0 sync sur  1Hz
              o_S_1Hz      : out  STD_LOGIC   -- Signal temoin 1 Hz
              );
   end component;

   component gen_clk_codec
      port  (
              i_rst     : in STD_LOGIC;     -- entree reset
              m_clk     : in STD_LOGIC;     -- Entrée  horloge maitre codec  (defaut 12.289 MHz  (81.374 ns) )
              o_bclk    : out  STD_LOGIC;   -- horloge bit clk (defaut 12.289 MHz / 4 soit 3,07225 MHz  (325.49 ns) )
              o_reclrc  : out  STD_LOGIC    -- horloge record, play back, sampling rate clock, left right channel (defaut 48 KHz (20,83 us))
             );
    end component;

--   component strb_gen is
--         Port (
--                CLK      : in STD_LOGIC;     -- Entrée  horloge maitre
--                i_don    : in  STD_LOGIC;   -- signal pour generer strobe au front montant
--                o_stb    : out  STD_LOGIC   -- strobe synchrone
--                );
--     end component;

   signal sysclk_int : std_logic;
   signal clk_0_int   : std_logic;
   signal clk_1_int   : std_logic;

   signal d_strobe_1000Hz_int : std_logic;
   signal d_strobe_1Hz_int    : std_logic;
   signal d_S1Hz_int    : std_logic;
   signal d_bclk_int : std_logic;
   signal d_lrc_int    : std_logic;
   signal d_T1Hz          : std_logic;
   -- signal reset           : std_logic;

begin

 inst_synchro : synchro_zybo_v1
  generic map (const_CLK_syst_Hz => cst_CLK_syst_Hz)
     port map (
      sysclk            => sysclk_int,
      o_clk_0           => clk_0_int,      -- 50 MHz
      o_clk_1           => clk_1_int,      -- master clk pour SSM2603
      o_stb_1000Hz      => d_strobe_1000Hz_int,
      o_stb_1Hz         => d_strobe_1Hz_int,
      o_S_1Hz           => d_S1Hz_int
      );

  -- generateur horloge echantillonnage (ADC sampling Rate) et transfert binaire
  inst_gen_clk_codec : gen_clk_codec
     Port map (
          i_rst     => '0',
          m_clk     => clk_1_int,
          o_bclk    => d_bclk_int,
          o_reclrc  => d_lrc_int
       );


----  buffer horloge 
--ClockBuf0: bufg
--port map(
--  I   => CLKOUT0,
--  O   => clk_0_interne
--  );
--o_clk_0  <= clk_0_interne ; --

--ClockBufer1: bufg
--    port map(
--        I    => CLKOUT1,
--        O    => clk_1_interne
--        );

sysclk_int   <= sysclk ; --
o_clk_0      <= clk_0_int ; --
o_mclk       <= clk_1_int ; --
o_S_1Hz      <= d_S1Hz_int;
o_stb_1000Hz <= d_strobe_1000Hz_int;
o_stb_1Hz    <= d_strobe_1Hz_int;

o_bclk    <= d_bclk_int;
o_reclrc    <= d_lrc_int;


end Behavioral;

