
---------------------------------------------------------------------------------------------
--    init_codec_v2.vhd  
---------------------------------------------------------------------------------------------
--    configuration conversion A/N  par codec SSM2603 sur la carte ZYBO
---------------------------------------------------------------------------------------------
--    Université de Sherbrooke - Département de GEGI
--
--    Version         : 5.0
--    Nomenclature    : inspiree de la nomenclature 0.2 GRAMS
--    Date            : 13 janvier 2018, révision 21 janvier 2019, 1 février 2019, 20 février (delai ajusté)
--    Auteur(s)       : Daniel Dalle
--    Technologie     : ZYNQ 7000 Zybo Z7-10 (xc7z010clg400-1) 
--    Outils          : vivado 2018.2 64 bits
--
---------------------------------------------------------------------------------------------
--    Description (sur une carte Zybo)
-- initialisation du Codec SSM2603 de la carte Zybo-z7-10 (ou 20)
---------------------------------------------------------------------------------------------
--
---------------------------------------------------------------------------------------------
--
-- ref manual Zybo
-- https://reference.digilentinc.com/reference/programmable-logic/zybo-z7/reference-manual
-- ref schematic (public)
-- https://reference.digilentinc.com/_media/reference/programmable-logic/zybo-z7/zybo_z7_sch-public.pdf
-- ref Analog Devices SSM2603 Audio Codec
-- https://www.analog.com/media/en/technical-documentation/data-sheets/ssm2603.pdf
--
--------------------------------
--    À FAIRE:
-- Espacement de 4 ms entre chaque trame I2C (pour respecter délai power-on et activation) ref. SSM2603.pdf
-- Restructurer pour définir un module d'initialisation du codec qui peut être sous-module
-- dans la hiérarchie et utilisé comme boite noire.
-- verifier R4 Analog audio path (LINE ou MIC)  OK, mais a suivre 11 janvier 2019
-- En particlier, pour la suite, donner une option de configuration MIC ou LINE (actuellement choix fixe)
--------------------------------
--
---------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- pour les additions dans les compteurs
USE ieee.numeric_std.ALL;
--use IEEE.std_logic_arith.all;     -- requis pour les constantes  etc.
--use IEEE.std_logic_arith.all;     -- requi pour les constantes telles que cdviv6 etc.

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
Library UNISIM;
use UNISIM.vcomponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
-- *****************************************************************************--
----------------------------------------------------------------------------------
entity init_codec_v2 is
--generic ( mode_simulation: std_logic := '0');  -- developpement futur si requis
    Port (   
      -- mode de controle necessaire ???   
    i_reset      : in    std_logic;
    o_cfg_done   : out   STD_LOGIC; 
    o_cfg_busy   : out   STD_LOGIC; 
    o_ena        : out   STD_LOGIC;  -- pour tests
    --
    -- Signaux I2C
    i_lrc           :   in   STD_LOGIC;    -- I²S (Record Channel Clock) 
    io_scl          :   inout STD_LOGIC;   -- horloge I2C SPI
    io_sda          :   inout STD_LOGIC;   -- I2C 2-Wire Control Interface Data Input/Output.
    --
    i_strobe_1000Hz : in    std_logic;     -- pour synchro de configuration
    clk_p      : in    std_logic
    );
end init_codec_v2;


----------------------------------------------------------------------------------

architecture Behavioral of init_codec_v2 is
   
   constant nbreboutons:  integer := 4;
   constant freq_sys_Hz:  integer := 125_000_000;  -- Hz

type register_cfg is array (0 to 31) of std_logic_vector (15 downto 0);
 --configuration programmee du codec (dans un ordre determine ref audio.c )
signal cfg_ssm2603 : register_cfg := (
-- adresse reg    contenu             seq registre
-- 15     9        8        0
"0001111"     & "000000000", --    0    R15 Software reset
"0000110"     & "000110000", --    1    R6 Power management
                                     -- R6 D8=0;
                                     -- R6 D7=0; pwroff         : power up;
                                     -- R6 D6=0; clkout power   : power up;
                                     -- R6 D5=1; crystal power  : power down;
                                     -- R6 D4=1; output power   : power down;
                                     -- R6 D3=0; DAC power      : power up;
                                     -- R6 D2=0; ADC power      : power up;
                                     -- R6 D1=0; MIC in power   : power up;
                                     -- R6 D0=0; LINE in power  : power up;
                                      
"0000000"     & "000010111", --    2    R0 Left-channel ADC input volume
                                      --   R0: disable loading left to right;  disable mute; 0 dB
"0000001"     & "000010111", --    3    R1 Right-channel ADC input volume
                                      --    R1: disable loading right to left;  disable mute; 0 dB
                                   
"0000010"     & "001111001", --    4    R2 Left-channel DAC volume  (defaut / datasheet)
                                               --   R2 disable left ch head phone vol data to right; volume 0dB (defaut / datasheet)
"0000011"     & "001111001", --    5    R3 Right-channel DAC volume  (defaut / datasheet)
                                              --    R3 disable right ch head phone vol data to left; volume 0dB (defaut / datasheet)                                   
--"0000010"     & "001101001", --    4    R2 Left-channel DAC volume  (defaut / datasheet)
--                                         --   R2 disable left ch head phone vol data to right; volume -16 dB (conseillé avec écouteurs....)
--"0000011"     & "001101001", --    5    R3 Right-channel DAC volume  (defaut / datasheet)
--                                        --    R3 disable right ch head phone vol data to left; volume -16 dB  (conseillé avec écouteurs....)                                           
                         
--          "0000100"     & "000000100", --    6    R4 Analog audio path    -- audio.c  INSEL = mic
"0000100"     & "000010000", --    6    R4 Analog audio path    --          INSEL = LINE   
                              -- R4 D8=0;                          : 0        (def)
                              -- R4 D7=0; |                        : 0
                              -- R4 D6=0; | mic sidetone gain ctrl : 00 -6dB   (def)
                              -- R4 D5=0; sidetone_en              : 0 disable (def)
                              -- R4 D4=1; DACSEL  (mix DAC output) : 1 select DAC
                              -- R4 D3=0; BypAss                   : 0 = Bypass disabled
                              -- R4 D2=0; INSEL                    : 0 = LINE input select to ADC (def)  ***** 1: MIC
                              -- R4 D1=0; MUTEMIC                  : 0 (disabled)  
                              -- R4 D0=0; MICBOOST                 : 0 = 0 dB (def);          
"0000101"     & "000000000", --    7    R5 Digital audio path
"0000111"     & "000000010", --    8    R7 Digital audio I/F
                           --                   ref data sheet page 25/31
                           --                   24 bits I2S mode, sampling ADC 48 KHz   DAC 48 KHz
"0001000"     & "000000000", --    9    R8 Sampling rate
"0001001"     & "000000001", --   10    R9 Active
"0000110"     & "000100000", --   11    R6 Power management
                               -- R6 D8=0;
                               -- R6 D7=0; pwroff         : power up;
                               -- R6 D6=0; clkout power   : power up;
                               -- R6 D5=1; crystal power  : power down;
                               -- R6 D4=0; output power   : power up;
                               -- R6 D3=0; DAC power      : power up;
                               -- R6 D2=0; ADC power      : power up;
                               -- R6 D1=0; MIC in power   : power up;
others =>
"1111111"     & "000000000"  --   code adresse de registre non reelle signifie extremite table atteinte
);

  
  COMPONENT ctrl_i2c_v4_ssm2603 is
   generic ( c_clk_freq_Hz: integer :=  50_000_000; c_bus_i2c_bps: integer := 100_000);
    Port (
           clk_master        : in  STD_LOGIC;                     -- horloge maitre pour le controleur (typique 50 MHz)
           i_reset           : in  STD_LOGIC;
           i_stb_read        : in  STD_LOGIC;                     -- demarre un cycle de lecture
           i_stb_write       : in  STD_LOGIC;                     -- demarre un cycle d ecriture
           i_adr_reg         : in  std_logic_vector(6 downto 0);  -- adresse registres de configuration
           i_dat_wreg        : in  std_logic_vector(8 downto 0);  -- 9 bits  -- data registre a transmettre
           o_dat_rreg        : out std_logic_vector(8 downto 0);  -- 9 bits  -- data registre recue
           io_sda            : inout std_logic ;
           io_scl            : inout std_logic ;
           o_read_req        : out std_logic ;      -- pour tests
           o_write_req       : out std_logic ;      -- pour tests
           o_busy            : out std_logic;       -- pour tests
           o_ack_error       : out   STD_LOGIC;     -- pour tests;
           o_ena             : out   STD_LOGIC;     -- pour tests;
           o_rw              : out   STD_LOGIC      -- pour tests;
                             
           );

  end COMPONENT;

  component sel_btn_reg
         port ( clk              : in    std_logic; 
                i_str_sel_reg    : in    std_logic; 
                i_reset_sel_reg  : in    std_logic; 
                o_sel_reg        : out   std_logic_vector (6 downto 0)
                );
   end component;

-- Signaux
----------------------------------------------------------------------------------
  
    signal clk_12_288MHz   : std_logic;
    signal d_strobe_1000Hz : std_logic;
    signal d_strobe_trame_I2C : std_logic;
 
    signal d_stb_read   : std_logic;
    signal d_stb_write  : std_logic;
    signal d_read_req   : std_logic;  -- pour test
    signal d_write_req  : std_logic;  -- pour test
   
    signal d_dat_wreg   : std_logic_vector(8 downto 0);
    signal d_dat_rreg   : std_logic_vector(8 downto 0);
    signal d_sclk       : std_logic;
    signal d_busy       : std_logic;
    signal d_ack_error  : std_logic;
    signal d_ena        : std_logic;
    signal d_rw         : std_logic;
    
    signal d_adr_reg    : std_logic_vector(6 downto 0) ;  -- adresse I2c du registre codec
    signal d_sel_reg    : std_logic_vector(6 downto 0) ;  -- selection registre (directe)
    signal d_sel_cfg_reg: std_logic_vector(6 downto 0) ;  -- selection registre indirecte par cfg_ssm2603
    signal q_sel_cfg_reg: std_logic_vector(6 downto 0) ;  -- selection registre indirecte par cfg_ssm2603
 
    signal d_reset_sel_reg : std_logic;
    signal d_cfg_done      : std_logic;
    signal d_cfg_busy      : std_logic;
    
    signal d_delai_trame_I2C       :  unsigned(7 downto 0); -- delai en nombre de bclk pour configuration
    constant c_delai_trame_I2C_max :  unsigned(7 downto 0) := "00000110";   --  pour delai 7 ms entre trames I2C
    signal d_delai_trame_I2C_atteint      : std_logic;

---------------------------------------------------------------------------------------------
--    init_codec
---------------------------------------------------------------------------------------------
begin

 inst_ctrl_i2c: ctrl_i2c_v4_ssm2603
  generic map (c_clk_freq_Hz => 50_000_000, c_bus_i2c_bps => 100_000 )
   PORT MAP(
    clk_master     => clk_p,
    i_reset        => i_reset,
    i_stb_read     => d_stb_read,
    i_stb_write    => d_stb_write,
    i_adr_reg      => d_adr_reg,
    i_dat_wreg     => d_dat_wreg,
    o_dat_rreg     => d_dat_rreg,
    io_scl         => io_scl ,
    io_sda         => io_sda,
    o_ack_error    => d_ack_error,
    o_ena          =>  d_ena,       -- pour tests
    o_rw           =>  d_rw,        -- pour tests
    o_read_req     =>  d_read_req,  -- pour tests
    o_write_req    =>  d_write_req, -- pour tests
    o_busy        => d_busy         --
   );
   
   --
   -- Generation d'un signal de delai entre trames I2C
   --  version 1
    compteur_delai_cfg : process (clk_p, i_reset)
      begin
         if ( i_reset = '1') then
             d_delai_trame_I2C <= (others =>'0');
             d_delai_trame_I2C_atteint <= '0';
         else
         if (rising_edge(clk_p) and d_strobe_1000Hz ='1') then
             d_delai_trame_I2C <= d_delai_trame_I2C + 1;
             if (d_delai_trame_I2C = c_delai_trame_I2C_max)  then 
                 d_delai_trame_I2C_atteint <= '1';
                 d_delai_trame_I2C <= (others =>'0');
               else
                d_delai_trame_I2C_atteint <= '0';
               end if;
         end if;
         end if;
      end process;
       
--    --
--    -- Generation d'un signal de delai entre trames I2C
--    --
--     compteur_delai_cfg : process (clk_p, i_reset)
--       begin
--          if ( i_reset = '1') then
--              d_delai_trame_I2C <= (others =>'0');
--          else
--          if (rising_edge(clk_p) and d_strobe_1000Hz ='1') then
--              d_delai_trame_I2C <= d_delai_trame_I2C + 1;
--              if (d_delai_trame_I2C = c_delai_trame_I2C_max)  then 
--                  d_delai_trame_I2C <= (others =>'0');
--              end if;
--          end if;
--          end if;
--       end process;
       
--     test_delai_cfg : process (clk_p, i_reset)
--           begin
--              if ( i_reset = '1') then
--                  d_delai_trame_I2C_atteint <= '0';
--              else
--              if (rising_edge(clk_p) and d_strobe_1000Hz ='1') then
--                  if (d_delai_trame_I2C = c_delai_trame_I2C_max)  then 
--                       d_delai_trame_I2C_atteint <= '1';
--                    else
--                       d_delai_trame_I2C_atteint <= '0';
--                    end if;
--              end if;
--              end if;
--           end process;     
       
       
       

  d_strobe_trame_I2C <= d_strobe_1000Hz and d_delai_trame_I2C_atteint;

  inst_idx_cfg_reg : process (clk_p, i_reset)
     begin    
       if   (i_reset = '1') then           
               d_sel_cfg_reg <= (others =>'0');
               q_sel_cfg_reg <= (others =>'0');  -- non requis
               d_cfg_done <= '0';
         else
           if rising_edge(clk_p) and (d_strobe_trame_I2C = '1') and (d_cfg_busy  = '1')then
               if  (d_sel_cfg_reg = "0001011") then     -- limite index = 11 
             --if  (d_sel_cfg_reg = "0000010") then  -- limite index = 2  -- pour certains test simulation
                   d_cfg_done <= '1';                   
                end if;  
                q_sel_cfg_reg <= d_sel_cfg_reg;     -- valeur courante     
                d_sel_cfg_reg <= d_sel_cfg_reg + 1; -- prochaine valeur;    
           end if;
        end if;
     end process;
  
--inst_busy_cfg_reg 
inst_busy_cfg_reg : process (clk_p, d_cfg_done )
    begin
       if ( d_cfg_done = '1') then
                d_cfg_busy  <= '0';
       else
       if rising_edge(clk_p)  then
          d_cfg_busy  <= '1';
        end if;
        end if;
    end process;

    d_reset_sel_reg  <= i_reset;
    o_cfg_done       <= d_cfg_done;
    o_cfg_busy       <= d_cfg_busy;
    o_ena            <= d_ena;
    d_strobe_1000Hz  <= i_strobe_1000Hz;
    d_stb_read       <= '0';   
    d_stb_write      <= d_cfg_busy and d_strobe_trame_I2C;
    d_dat_wreg       <= cfg_ssm2603( to_integer (unsigned(  q_sel_cfg_reg(4 downto 0)  ))) (8 downto 0);
    d_adr_reg        <= cfg_ssm2603( to_integer (unsigned(  q_sel_cfg_reg(4 downto 0)  ))) (15 downto 9);                                  
                       
end Behavioral;
