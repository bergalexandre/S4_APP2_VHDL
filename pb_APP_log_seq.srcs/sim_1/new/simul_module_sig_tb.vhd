---------------------------------------------------------------------------------------------
-- Test-Bench simul_module_sig_tb.vhd
---------------------------------------------------------------------------------------------
-- Université de Sherbrooke - Département de GEGI
-- Version         : 1.0
-- Nomenclature    : 0.8 GRAMS
-- Date            : 10 janvier 2020
-- Auteur(s)       : 
-- Technologies    : FPGA Zynq (carte ZYBO Z7-10 ZYBO Z7-20)
--
-- Outils          : vivado 2019.1
---------------------------------------------------------------------------------------------
-- Description:
-- Developpement d'un test bench pour la problématique de logique séquentielle
-- Test unitaire de module_sig
---------------------------------------------------------------------------------------------
-- À faire :
--
---------------------------------------------------------------------------------------------

LIBRARY ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;  

entity simul_module_sig_tb is
--  Port ( );
end simul_module_sig_tb;

architecture Behavioral of simul_module_sig_tb is

-- le codeur I2S est utlisé pour générer le flot I2S
component codeur_i2s_vsb
  Port ( 
      i_bclk      : in std_logic;
      i_reset      : in std_logic;
      i_lrc       : in std_logic;
      i_dat_left  : in  std_logic_vector(23 downto 0);
      i_dat_right : in  std_logic_vector(23 downto 0);
      o_dat       : out std_logic
  );
end component;

-- pour tests futurs d'un decodeur
--component decodeur_i2s_vsb
--  Port ( 
--      i_bclk      : in std_logic;
--      i_reset      : in std_logic;
--      i_lrc       : in std_logic;
--      i_dat       : in std_logic;
--      o_dat_left  : out  std_logic_vector(23 downto 0);
--      o_dat_right : out  std_logic_vector(23 downto 0);
--      o_str_dat   : out std_logic
--);
--end component;



component module_sig
   Port (
    i_reset     : in    std_logic;    -- reset
    i_bclk      : in    std_logic;    -- bit clock ... I2S digital audio clk  ~  3.1 MHz 
    i_lrc       : in    std_logic;    -- I²S (Playback Channel Clock)         ~ 48.3 KHz (~ 20.8 us)
    i_recdat    : in    std_logic;    -- I²S (Record Data)
    o_pbdat     : out   std_logic;    -- I²S (Playback Data)
    --
    i_sel_fct   : in    std_logic_vector (1 downto 0); -- selecteur de la fonction
    i_sel_par   : in    std_logic_vector (1 downto 0); -- selecteur de l'affichage de parametre
    o_param : out   std_logic_vector (7 downto 0);
    o_statut    : out   std_logic_vector (3 downto 0)
    );
end component;
  
  
--type table_forme is array (integer range 0 to 255) of std_logic_vector(23 downto 0);
type table_forme is array (integer range 0 to 47) of std_logic_vector(23 downto 0);
constant mem_forme_onde_R : table_forme := (   
 -- forme d'un sinus 
 -- chaque cycle a 48 echantillons
 -- la table suivante contient 1 cycle, compléter au besoin 
 x"000000",
 x"0C866D",
 x"18D609",
 x"24B8F4",
 x"2FFB28",
 x"3A6B60",
 x"43DBED",
 x"4C237E",
 x"531DD9",
 x"58AC72",
 x"5CB6F8",
 x"5F2BBC",
 x"5FFFFE",
 x"5F301C",
 x"5CBFA5",
 x"58B946",
 x"532E9C",
 x"4C37E7",
 x"43F3A1",
 x"3A85F9",
 x"301832",
 x"24D7EE",
 x"18F66D",
 x"0CA7AC",
 x"002189",
 x"F39AD4",
 x"E74A5D",
 x"DB660A",
 x"D021E7",
 x"C5AF40",
 x"BC3BD0",
 x"B3F0F4",
 x"ACF2F5",
 x"A7606D",
 x"A351C0",
 x"A0D8B0",
 x"A0000E",
 x"A0CB8F",
 x"A337B9",
 x"A739F1",
 x"ACC0AC",
 x"B3B3BA",
 x"BBF4B2",
 x"C55F75",
 x"CFCACB",
 x"DB091C",
 x"E6E933",
 x"F33716"
--  x"FFBCED"

--others => x"000000" 
);

constant mem_forme_onde_L : table_forme := ( 
 -- forme d'une onde carrée
 -- chaque cycle a 48 echantillons
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"5FFFFF",
x"A00001",
x"A00001",
x"A00001",
x"A00001",
x"A00001",
x"A00001",
x"A00001",
x"A00001",
x"A00001",
x"A00001",
x"A00001",
x"A00001",
x"A00001",
x"A00001",
x"A00001",
x"A00001",
x"A00001",
x"A00001",
x"A00001",
x"A00001",
x"A00001",
x"A00001",
x"A00001",
x"A00001"
--x"5FFFFF",
--others => x"000000"  --
);


    signal   d_ac_bclk     : std_logic := '0';   -- bit clock ... horloge I2S digital audio
    signal   d_ac_mclk     : std_logic := '0';   -- Master Clock horloge 12.288 MHz
    signal   d_cpt_mclk    : std_logic_vector (7 downto 0) := "00000000";
    
    signal   d_ac_pbdat    : std_logic := '0';   -- I²S (Playback Data)
    signal   d_sig_pbdat   : std_logic := '0';   -- I²S (Playback Data) 
  
    signal   d_ac_pblrc    : std_logic := '0';  -- I²S (Playback Channel Clock) DAC Sampling Rate Clock,
    signal   d_ac_recdat   : std_logic := '0';  -- I²S (Record Data) 
    signal   d_ac_reclrc   : std_logic := '0';  -- I²S (Record Channel Clock)   ADC Sampling Rate Clock,
    
 -- source I2S simulee
    signal  d_val_ech_L    : std_logic_vector(23 downto 0) := (others =>'0') ;  -- ech source simulee canal gauche
    signal  d_val_ech_R    : std_logic_vector(23 downto 0) := (others =>'0') ;  -- ech source simulee canal droite  
    signal  d_val_ech_R_u  : std_logic_vector(23 downto 0) := (others =>'0');   -- ech source simulee transforme pour affichage 
    signal  d_ech_reg_left : std_logic_vector(23 downto 0) := (others =>'0');    -- echantillon canal gauche
    signal  d_ech_reg_right: std_logic_vector(23 downto 0) := (others =>'0');    -- echantillon canal droite

    --signal s_ech_gen : std_logic_vector(23 downto 0) := (others =>'0'); 
    signal s_reset   : std_logic;
    signal compt_gen_R, compt_gen_L  : unsigned(7 downto 0) := x"00";
                      
    signal d_sel_fct    : std_logic_vector(1 downto 0):= (others =>'0'); 
    signal d_sel_par    : std_logic_vector(1 downto 0):= (others =>'0'); 
    signal d_param  : std_logic_vector(7 downto 0):= (others =>'0'); 
    signal d_led        : std_logic_vector(3 downto 0):= (others =>'0'); 
    
-- notes  
    -- frequences      ***********************
    -- d_ac_reclrc  ~ 48.    KHz    (~ 20.8    us)
    -- d_ac_mclk,   ~ 12.288 MHz    (~ 80,715  ns)
    -- d_ac_bclk    ~ 3,10   MHz    (~ 322,857 ns) freq mclk/4 
    -- La durée d'une période reclrc est de 64,5 périodes de bclk ... ARRONDI a 64 pour simul
    --
    
    constant c_mclk_Period       : time :=  80.715 ns;  -- 12.288 MHz
    constant c_clk_p_Period      : time :=  8 ns;  -- 125 MHz
 

begin
   ----------------------------------------------------------------------------
   -- unites objets du test  
   ----------------------------------------------------------------------------
     
 UUT_codeur: codeur_i2s_vsb
 Port map
    ( 
      i_bclk      =>  d_ac_bclk,
      i_reset     =>  s_reset,
      i_lrc       =>  d_ac_pblrc,
      i_dat_left  =>  d_val_ech_L,
      i_dat_right =>  d_val_ech_R,
      o_dat       =>  d_ac_recdat
  );

  
  UUT_mod_sig: module_sig
   Port map
      ( 
        i_reset     =>  s_reset,
        i_bclk      =>  d_ac_bclk,
        i_lrc       =>  d_ac_pblrc,
        i_recdat    =>  d_ac_recdat,
        o_pbdat     =>  d_sig_pbdat,
        i_sel_fct   =>  d_sel_fct,
        i_sel_par   =>  d_sel_par,
        o_param     =>  d_param,
        o_statut    =>  d_led
    );
  
--    prevu pour test d'un decodeur
--    UUT_decodeur: decodeur_i2s_vsb
--     Port map
--        ( 
--          i_bclk      =>  d_ac_bclk,
--          i_reset     =>  s_reset,
--          i_lrc       =>  d_ac_pblrc,
--          i_dat       =>  d_sig_pbdat,
--          o_dat_left  =>  d_ech_reg_left,
--          o_dat_right =>  d_ech_reg_right,
--          o_str_dat   =>  open
--      );
    
  
  
   ----------------------------------------------------------------------------
   -- generation horloge  
   ----------------------------------------------------------------------------
   
  sim_mclk:  process
      begin
         d_ac_mclk <= '1';  -- init
         loop
            wait for c_mclk_Period / 2;
            d_ac_mclk <= not d_ac_mclk; 
         end loop;
      end process;   
   
   
  sim_cpt_bclk: process (d_ac_mclk)
     begin
         if rising_edge(d_ac_mclk) then
               d_cpt_mclk<= d_cpt_mclk + 1;
         end if;
     end process sim_cpt_bclk;

----------------------------------------------------------------------------
-- generation signal s_ech_gen par lecture de la table de valeurs
----------------------------------------------------------------------------
sim_entree_D : process (s_reset, d_ac_pblrc) 
begin
   if(s_reset = '1') then  -- Init/reset
      compt_gen_R <= x"00";
      d_val_ech_R <= X"000000";
   else
      if(d_ac_pblrc'event and d_ac_pblrc = '1') then   
         d_val_ech_R <= mem_forme_onde_R(to_integer(compt_gen_R)); 
         if (compt_gen_R = mem_forme_onde_R'length-1) then
           compt_gen_R <= x"00";
         else
           compt_gen_R <= compt_gen_R + 1;
         end if;           
      end if;        
   end if;
end process;

sim_entree_G : process (s_reset, d_ac_pblrc) 
begin
   if(s_reset = '1') then  -- Init/reset
      compt_gen_L <= x"00";
      d_val_ech_L <= X"000000";
   else
      if(d_ac_pblrc'event and d_ac_pblrc = '0') then
         d_val_ech_L <= mem_forme_onde_L(to_integer(compt_gen_L));
         if (compt_gen_L = mem_forme_onde_L'length-1) then
           compt_gen_L <= x"00";
         else
           compt_gen_L <= compt_gen_L + 1;
         end if;           
      end if;        
   end if;
end process;

 d_ac_bclk   <= d_cpt_mclk(1);
 d_ac_pblrc <=  d_ac_reclrc;                 -- identique a reclrc 
 d_val_ech_R_u <=  d_val_ech_R + x"800000";  -- pour afficher dans un format analogique

-- synchro sur front descendant bclk
 lrc_proc: process(d_ac_bclk)    
   begin
     if falling_edge(d_ac_bclk) then
            d_ac_reclrc <= d_cpt_mclk(7);  
         end if;
     end process lrc_proc;

  -- Le processus suivant cree une copie au front mclk (4 fois plus rapide que bclk)
  -- ou le d_ac_recdat genere par le codeur I2S simulé est redirigé vers d_ac_pbdat 
  -- (peut être utile pour un test unitaire de décodeur)
  -- Noter que le module module_sig est connecté èa d_sig_pbdat
  --
  inst_sortie_pb_dat : process(d_ac_mclk)
     begin
         if rising_edge(d_ac_mclk) then
             d_ac_pbdat  <=  d_ac_recdat;         -- 
         end if;
     end process;     
     
              
  --  stimuli du testbench, adapter aux besoins...
  tb : PROCESS
     BEGIN
        -- 
        s_reset   <= '0';
        d_sel_par <= "00";
        d_sel_fct <= "00";
        wait for c_mclk_Period;
        s_reset   <= '1';
        wait for c_mclk_Period;
        s_reset   <= '0';
        d_sel_fct <= "00";  d_sel_par <= "00";  wait for 40 us;
        d_sel_fct <= "00";  d_sel_par <= "01";  wait for 40 us;
        d_sel_fct <= "00";  d_sel_par <= "10";  wait for 40 us;                  
        d_sel_fct <= "00";  d_sel_par <= "11";  wait for 40 us; 
        d_sel_fct <= "01";  d_sel_par <= "00";  wait for 40 us;
        --
        d_sel_fct <= "01";  d_sel_par <= "00";  wait for 40 us;
        d_sel_fct <= "01";  d_sel_par <= "01";  wait for 40 us;
        d_sel_fct <= "01";  d_sel_par <= "10";  wait for 40 us;                  
        d_sel_fct <= "01";  d_sel_par <= "11";  wait for 40 us;  
        --
        d_sel_fct <= "10";  d_sel_par <= "00";  wait for 40 us;
        d_sel_fct <= "10";  d_sel_par <= "01";  wait for 40 us;
        d_sel_fct <= "10";  d_sel_par <= "10";  wait for 40 us;                  
        d_sel_fct <= "10";  d_sel_par <= "11";  wait for 40 us;              
        --
        d_sel_fct <= "11";  d_sel_par <= "00";  wait for 40 us;
        d_sel_fct <= "11";  d_sel_par <= "01";  wait for 40 us;
        d_sel_fct <= "11";  d_sel_par <= "10";  wait for 40 us;                  
        d_sel_fct <= "11";  d_sel_par <= "11";  wait for 40 us;  
        --          
        d_sel_fct <= "00";
        d_sel_par <= "00"; 
        wait for 40 us;   
                 
        WAIT; -- will wait forever
     END PROCESS;

end Behavioral;
