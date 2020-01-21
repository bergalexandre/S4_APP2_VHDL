---------------------------------------------------------------------------------------------
-- synchro_zybo_v1.vhd
---------------------------------------------------------------------------------------------
-- Generation d'horloge et de signaux de synchronisation
---------------------------------------------------------------------------------------------
-- Université de Sherbrooke - Département de GEGI
-- 
-- Version          : 1.0
-- Nomenclature     : ref GRAMS
-- Date             : 30 octobre 2018, 7 novembre 2018, 4 janvier 2019, 24 janvier 2019
-- Auteur(s)        : Daniel Dalle
--  Technologie     : ZYNQ 7000 Zybo Z7-10 (xc7z010clg400-1)
--  Outils          : vivado 2018.2 64 bits
-- 
--------------------------------
-- Description
--------------------------------
-- Génération de signaux de synchronisation, incluant des "strobes"
-- (utilise un PLL)
-- Ref:
-- 7 Series Libraries Guide www.xilinx.com 418 UG953 (v2016.3) October 5, 2016
--   (pages 425 PLLE2_BASE)
--
-- revisions
-- mise a jour D Dalle 17 octobre 2019   nomenclature synchro_demo_codec_v4 devient synchro_zybo_v1
-- mise a jour D Dalle 24 janvier 2019   v4 strobe commentaires, élimination entrée reset
-- mise a jour D Dalle 7  janvier 2019   v3 strobe 1000Hz   validation / correction S_1Hz
-- mise a jour D Dalle 4  janvier 2019   v3 strobe 1000Hz   
-- mise a jour D Dalle 27 decembre 2018  v3 tous les strobes sur 50 MHz  
-- mise a jour D Dalle 17 decembre 2018 constantes horloges en Hz (pour coherence avec autres modules)
---------------------------------------------------------------------------------------------
-- À FAIRE:
---------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;     -- requis pour les constantes  etc.
use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- pour les additions dans les compteurs

Library UNISIM;
use UNISIM.vcomponents.all;


entity synchro_zybo_v1 is
generic (const_CLK_syst_Hz: integer := 100_000_000); -- valeur par defaut fréquence de clkm
Port ( 
   sysclk      : in  STD_LOGIC; -- Entrée horloge maitre, typique 100 MHz (10 ns) ou 125 (8 ns)
   o_clk_0     : out STD_LOGIC; -- horloge via bufg 50.    MHz  (20 ns) 
   o_clk_1     : out STD_LOGIC; -- horloge via bufg 12.389 MHz  (80,714 ns)
   o_stb_1000Hz: out STD_LOGIC; -- strobe durée 1/o_clk_0 sync sur 1000Hz
   o_stb_1Hz   : out STD_LOGIC; -- strobe durée 1/o_clk_0 sync sur  1Hz
   o_S_1Hz     : out STD_LOGIC  -- Signal temoin 1 Hz
   );                   
end synchro_zybo_v1;


architecture Behavioral of synchro_zybo_v1 is

   component strb_gen is
         Port ( 
                CLK      : in STD_LOGIC;     -- Entrée  horloge maitre 
                i_don    : in  STD_LOGIC;   -- signal pour generer strobe au front montant          
                o_stb    : out  STD_LOGIC   -- strobe synchrone 
                );                          
     end component;
 
-- parametres pour constantes du PLL                                                          -- sim 125 MHz sysclk
 constant const_CLK_syst_MHz : integer := integer( real (const_CLK_syst_Hz) / 1000000.0);     -- verif 125
 constant c_CLKFBOUT_MULT    : integer := 56; -- Multiply value for all CLKOUT, (2-64)
 constant c_CLKIN1_PERIOD    : real := 1000.0 / real(const_CLK_syst_MHz) ;  -- Input clock period in ns to ps resolution 
                                                                            -- (i.e. 33.333 is 30 MHz).
-- constant c_DIVCLK_DIVIDE  : integer := 7;   -- Master division value, (1-56)
 constant c_DIVCLK_DIVIDE    : integer := 5;   -- Master division value, (1-56)
 -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
 constant c_CLKOUT0_DIVIDE : integer := const_CLK_syst_MHz*c_CLKFBOUT_MULT/c_DIVCLK_DIVIDE/50 ; -- pour obtenir 50 MHz
                                                                                                -- verif 28
 constant c_CLKOUT1_DIVIDE : integer := const_CLK_syst_MHz*c_CLKFBOUT_MULT*1000/c_DIVCLK_DIVIDE/12289; -- pour obtenir 12.289 MHz
                                                                                                -- verif 113
 
  constant FRQ_exact_KHz : integer := 1000*const_CLK_syst_MHz*c_CLKFBOUT_MULT/c_DIVCLK_DIVIDE/c_CLKOUT0_DIVIDE ;
   -- calcul des constantes avec CLKOUT1 comme fréquence de base (12,2888 MHz)  **   CLKOUT1 CLKOUT1 CLKOUT1 CLKOUT1
                                                                                       -- verif 50_000
  constant FRQ_niv1_KHz_des :       integer := 200 ; -- KHz (clk intermediaire desiree pour compteurs)
                                                                                       -- verif 200
  constant ctmp1:  integer  :=(FRQ_exact_KHz/(FRQ_niv1_KHz_des)-1);  
                                                                                       -- verif 249 ( = x"0F9")
  constant cdiv1 : std_logic_vector(11  downto 0):= conv_std_logic_vector(ctmp1, 12); 
                                                                                       -- verif x"0F9"
  constant FRQ_niv1_KHz_exact : integer := FRQ_exact_KHz / ctmp1;

  constant FRQ_niv2_Hz_des :       integer := 2000 ; -- Hz (frq toggle intermediaire desiree )       --- **** valeur v3 modifiee
 -- constant ctmp2:  integer  :=(1000*FRQ_niv1_KHz_exact/(2*FRQ_niv2_Hz_des)-1);  -- calcul avec toggle
                                                                                              
  constant ctmp2:  integer  :=(1000*FRQ_niv1_KHz_exact/(FRQ_niv2_Hz_des)-1);  -- 
                                                                                      -- verif 99
  constant cdiv2 : std_logic_vector(11  downto 0):= conv_std_logic_vector(ctmp2, 12); -- 
  constant FRQ_niv2_Hz_exact : integer := 1000*FRQ_niv1_KHz_exact / (ctmp2);
                                                                                      -- verif 2020 
  --  
  constant FRQ_inter_3_Hz_des :       integer := 1 ; -- Hz (clk  desiree )
  constant ctmp3:  integer  :=(FRQ_niv2_Hz_exact/(2*FRQ_inter_3_Hz_des)-1);  
                                                                                      -- verif 1009 (= x"3F1")
  --constant ctmp3:  integer  :=(FRQ_niv2_Hz_exact/(FRQ_inter_3_Hz_des)-1); 
                                                                                             
  constant cdiv3 : std_logic_vector(11  downto 0):= conv_std_logic_vector(ctmp3, 12); 

 signal ValueCounter1      : std_logic_vector(11 downto 0)   := (others => '0');
 signal ValueCounter2      : std_logic_vector(11 downto 0)   := (others => '0');
 signal ValueCounter3      : std_logic_vector(11 downto 0)  := (others => '0');

 signal d_TC_ValueCounter1Hz : std_logic := '0';

 signal clk_0_interne      : std_logic := '0';
 signal clk_1_interne      : std_logic := '0';
 signal d_s1HzInt          : std_logic := '0' ;
 signal q_s1HzInt          : std_logic := '0' ;
 --signal d_200kHzInt   : std_logic := '0' ;
 signal d_s1000HzInt       : std_logic := '0' ;
-- signal q_s100HzInt       : std_logic := '0' ;
-- signal qq_s100HzInt       : std_logic := '0' ;
 signal d_strobe_1000HzInt : std_logic := '0' ;
 signal d_strobe_1HzInt    : std_logic := '0' ;
 
 signal CLKOUT0 : std_logic := '0' ;
 signal CLKOUT1 : std_logic := '0' ; 
 signal CLKOUT2 : std_logic := '0' ; -- non utilisee
 signal CLKOUT3 : std_logic := '0' ; -- non utilisee
 signal CLKOUT4 : std_logic := '0' ; -- non utilisee
 signal CLKOUT5 : std_logic := '0' ; -- non utilisee

 signal CLKFBOUT : std_logic;     -- 1-bit output: Feedback clock
 signal LOCKED   : std_logic;     -- 1-bit output: LOCK
 signal clk_in   : std_logic;     -- 1-bit input: Input clock 


begin

PLLE2_BASE_inst : PLLE2_BASE
 generic map (
 BANDWIDTH => "OPTIMIZED",  -- OPTIMIZED, HIGH, LOW
 CLKFBOUT_MULT  => c_CLKFBOUT_MULT,       -- Multiply value for all CLKOUT, (2-64)
 CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB, (-360.000-360.000).
 CLKIN1_PERIOD  => c_CLKIN1_PERIOD,     -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
 -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
 CLKOUT0_DIVIDE => c_CLKOUT0_DIVIDE,
 CLKOUT1_DIVIDE => c_CLKOUT1_DIVIDE,
 CLKOUT2_DIVIDE => 1,
 CLKOUT3_DIVIDE => 1,
 CLKOUT4_DIVIDE => 1,
 CLKOUT5_DIVIDE => 1,
 -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
 CLKOUT0_DUTY_CYCLE => 0.5,
 CLKOUT1_DUTY_CYCLE => 0.5,
 CLKOUT2_DUTY_CYCLE => 0.5,
 CLKOUT3_DUTY_CYCLE => 0.5,
 CLKOUT4_DUTY_CYCLE => 0.5,
 CLKOUT5_DUTY_CYCLE => 0.5,
 -- CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
 CLKOUT0_PHASE => 0.0,
 CLKOUT1_PHASE => 0.0,
 CLKOUT2_PHASE => 0.0,
 CLKOUT3_PHASE => 0.0,
 CLKOUT4_PHASE => 0.0,
 CLKOUT5_PHASE => 0.0,
 DIVCLK_DIVIDE => c_DIVCLK_DIVIDE, -- Master division value, (1-56)
 REF_JITTER1   => 0.01, -- Reference input jitter in UI, (0.000-0.999).
 STARTUP_WAIT  => "FALSE" -- Delay DONE until PLL Locks, ("TRUE"/"FALSE")
 )
 port map (
-- Clock Outputs: 1-bit (each) output: User configurable clock outputs
CLKOUT0 => CLKOUT0, -- 1-bit output: CLKOUT0
CLKOUT1 => CLKOUT1, -- 1-bit output: CLKOUT1
CLKOUT2 => CLKOUT2, -- 1-bit output: CLKOUT2
CLKOUT3 => CLKOUT3, -- 1-bit output: CLKOUT3
CLKOUT4 => CLKOUT4, -- 1-bit output: CLKOUT4
CLKOUT5 => CLKOUT5, -- 1-bit output: CLKOUT5
-- Feedback Clocks: 1-bit (each) output: Clock feedback ports
CLKFBOUT => CLKFBOUT,     -- 1-bit output: Feedback clock
LOCKED => LOCKED,         -- 1-bit output: LOCK
CLKIN1 => sysclk,         -- 1-bit input: Input clock
-- Control Ports: 1-bit (each) input: PLL control ports
PWRDWN => '0',       -- 1-bit input: Power-down
--RST => i_rst, -- 1-bit input: Reset
RST =>'0', -- 1-bit input: Reset
-- Feedback Clocks: 1-bit (each) input: Clock feedback ports
CLKFBIN => CLKFBOUT      -- 1-bit input: Feedback clock
 );
 
--  buffer horloge 
ClockBuf0: bufg
port map(
   I  => CLKOUT0,
   O  => clk_0_interne
   ); 
o_clk_0  <= clk_0_interne ; -- 
                          
ClockBufer1: bufg
    port map(
        I    => CLKOUT1,
        O    => clk_1_interne
        );

o_clk_1      <= clk_1_interne ; --     
o_S_1Hz      <= d_s1HzInt;
o_stb_1000Hz <= d_strobe_1000HzInt;
o_stb_1Hz    <= d_strobe_1HzInt;

-- gestion des compteurs  (estimes de durees calcules pour sysclk = 125 MHz) --V3
process(clk_0_interne)           -- avec 50 MHz
--
begin                                                     -- Estimation avec clk1 = 12,288 
                                                          --     (12,389 selon calcul avec sysclk =125 MHz)
                                                          --
   if(clk_0_interne'event and clk_0_interne = '1') then   -- evenement se produit aux 81 ns approx
       ValueCounter1 <= ValueCounter1 + 1;
       if (ValueCounter1 = cdiv1) then                    -- evenement se produit aux 5 us approx
            ValueCounter1 <= "000000000000"; 
            ValueCounter2 <= ValueCounter2 + 1;
            if (ValueCounter2 = cdiv2) then
               d_s1000HzInt <= Not d_s1000HzInt;           -- evenement se produit aux 500 us approx (2 KHz)
               ValueCounter2 <= "000000000000";            -- la periode de d_s1000HzInt est alors ~ 1 ms
               ValueCounter3 <= ValueCounter3 + 1;
               if (ValueCounter3 = cdiv3) then             -- evenement se produit aux 500 ms approx (2 Hz)
                   ValueCounter3 <= "000000000000";
                     d_s1HzInt <= Not d_s1HzInt;           -- ici on fait un toggle donc 2*500 ms  
                                                           --     -> 1 sec.  pour frequence de d_s1HzInt;
               end if;
            end if;                 
      end if;
   end if;
end process;



inst_strb_1000Hz : strb_gen 
     -- les strobes sont synchronisés sur l'horloge clk_1_interne
         Port map ( 
                CLK     =>  clk_0_interne,
                i_don   =>  d_s1000HzInt,     
                o_stb   =>  d_strobe_1000HzInt
                ); 
 
inst_strb_1Hz : strb_gen 
     -- les strobes sont synchronisés sur l'horloge clk_1_interne
         Port map ( 
                CLK     =>  clk_0_interne,
                i_don   =>  d_s1HzInt,     
                o_stb   =>  d_strobe_1HzInt
                );                          
                 

--process(CLKOUT1, q_s100HzInt)   -- bascule synchro de l entree
--begin
-- if(CLKOUT1'event and CLKOUT1 = '1') then
--     qq_s100HzInt <= q_s100HzInt;
-- end if;
--end process;

--process(q_s100HzInt, qq_s100HzInt)   -- sortie impulsion synchrone
--begin
--    d_strobe_100HzInt <= q_s100HzInt and not(qq_s100HzInt);
--end process;


end Behavioral;

