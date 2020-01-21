---------------------------------------------------------------------------------------------
--    ctrl_i2c_V4_ssm2603.vhd  
---------------------------------------------------------------------------------------------
--    controle codec SSM2603 par I2C
---------------------------------------------------------------------------------------------
--    Université de Sherbrooke - Département de GEGI
--
--    Version         : 1.0
--    Nomenclature    : inspiree de la nomenclature 0.2 GRAMS
--    Date            : 20 novembre 2018
--    Auteur(s)       : Daniel Dalle
--    Technologie     : ZYNQ 7000 Zybo Z7-10 (xc7z010clg400-1)
--    Outils          : vivado 2018.2 64 bits
--
--------------------------------
--    Description
--------------------------------
-- Contôle du codec SSM2603 sur une carte Zybo
--
--
-- Note; pour le SSM2603, le bus I2C est controlé de manière telle que
-- ref page 8 fiche ssm2603.pdf
--
-- documents en reference
-- reference manual Zybo
-- https://reference.digilentinc.com/reference/programmable-logic/zybo-z7/reference-manual
-- schematic (public)
-- https://reference.digilentinc.com/_media/reference/programmable-logic/zybo-z7/zybo_z7_sch-public.pdf
-- ref Analog Devices SSM2603 Audio Codec
-- https://www.analog.com/media/en/technical-documentation/data-sheets/ssm2603.pdf
-- THE I 2C-BUS SPECIFICATIOn, VERSION 2.1 JANUARY 2000 Philips Semiconductors
--
--- revisions
-- V3: synchronisation, V4 documentation, reset delai
--------------------------------
--  À FAIRE:
-- 
--------------------------------

--
---------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;     -- requis pour les constantes  etc.
use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- pour les additions dans les compteurs

Library UNISIM;
use UNISIM.vcomponents.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- ajoute  par utilisateur...


entity ctrl_i2c_V4_ssm2603 is
-- horloge supposee 50 Mhz
generic ( c_clk_freq_Hz: integer :=  50_000_000; c_bus_i2c_bps: integer := 100_000);

    Port (
           clk_master        : in  STD_LOGIC;                     -- horloge maitre pour le controleur (typique 50 MHz)
           i_reset           : in  STD_LOGIC;
           i_stb_read        : in  STD_LOGIC;                     -- demarre un cycle de lecture
           i_stb_write       : in  STD_LOGIC;                     -- demarre un cycle d ecriture
           i_adr_reg         : in  std_logic_vector(6 downto 0);  -- adresse registres de configuration
           i_dat_wreg        : in  std_logic_vector(8 downto 0);  -- 9 bits  -- data registre a transmettre
           o_dat_rreg        : out std_logic_vector(8 downto 0);  -- 9 bits  -- data registre recue
           io_sda            : inout std_logic ; -- pour developpement
           io_scl            : inout std_logic ; -- pour developpement
           o_read_req        : out std_logic ;   -- pour tests 
           o_write_req       : out std_logic ;   -- pour tests 
           o_busy            : out std_logic;     -- pour tests;
           o_ack_error       :   out   STD_LOGIC;  --  -- pour tests;
           o_ena             :   out   STD_LOGIC;  -- -- pour tests;
           o_rw              :   out   STD_LOGIC  -- -- pour tests;
           );

end ctrl_i2c_V4_ssm2603;

architecture Behavioral of ctrl_i2c_V4_ssm2603 is

constant c_master_clk_freq_Hz : integer := c_clk_freq_Hz;

type fsm_codec_ctrl_type is (
                                 -- read / write sequence SSM2603  *** a developper
           sta_idle,             --  
           sta_write_seq_0,      --
           sta_write_seq_1,      --
           sta_write_seq_fin,    --
           --
           sta_read_seq_0,       --
           sta_read_seq_1,       --
           sta_read_seq_2,       --
           sta_read_seq_3,       --
           sta_read_seq_4,       --      
           sta_read_seq_fin      --  
          );
        
        
constant c_I2C_codec_Addr :  std_logic_vector( 6 downto 0) := "0011010";   -- x"1A"

-- machine etats pour controle i2c_master
signal fsm_i2c_etat_courant, fsm_i2c_etat_prochain   : fsm_codec_ctrl_type := sta_idle;

signal d_read_req   : std_logic;
signal d_write_req  : std_logic;
signal d_reset_req_read_write  : std_logic;


-- signaux pour i2c_master,
signal d_reset_n   : std_logic;
signal d_ena       : std_logic;
signal d_codec_adr : std_logic_vector( 6 downto 0) := c_I2C_codec_Addr;
signal d_rw        : std_logic;
signal d_data_wr   : std_logic_vector(7 downto 0);
signal d_data_rd   : std_logic_vector(7 downto 0);
signal en_d_data1_rd, en_d_data2_rd      : std_logic;

signal d_dat_readreg  : std_logic_vector(8 downto 0);  -- 9 bits
signal d_busy, q_busy_prec, q_busy      : std_logic;

signal d_delai         :  std_logic_vector(7 downto 0); -- delai en nombre de mclk pour changement etats
constant c_delai_max   :  std_logic_vector(7 downto 0) := "00101000";   -- 
signal  d_delai_synch  : std_logic;

signal d_ack_error : std_logic;


 
component i2c_master
GENERIC(
    input_clk : INTEGER := 50_000_000; --input clock speed from user logic in Hz
    bus_clk   : INTEGER := 400_000);   --speed the i2c bus (scl) will run at in Hz
  PORT(
    clk       : IN     STD_LOGIC;                    --system clock
    reset_n   : IN     STD_LOGIC;                    --active low reset
    ena       : IN     STD_LOGIC;                    --latch in command
    addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
    rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
    data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
    busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
    data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
    ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : INOUT  STD_LOGIC); 
end component;

BEGIN

inst_i2c_master:  i2c_master 
 generic map ( input_clk => c_clk_freq_Hz, bus_clk => c_bus_i2c_bps )  
   port map( 
      clk        => clk_master,
      reset_n    => d_reset_n,
      ena        => d_ena,
      addr       => d_codec_adr,
      rw         => d_rw,
      data_wr    => d_data_wr,
      busy       => d_busy,
      data_rd    => d_data_rd,
      ack_error  => d_ack_error,
      sda        => io_sda,
      scl        => io_scl
   );



 
 -- latch de la requete read ou write 
  process(clk_master, d_reset_req_read_write, i_reset)
  begin
     if (d_reset_req_read_write = '1') or (i_reset = '1') then 
         d_read_req   <= '0';  -- test
         d_write_req  <= '0';  -- test
     else
     if (clk_master'event and clk_master = '1' and (i_stb_read = '1') )  then
        d_read_req   <= '1';  -- test
        end if;     
     if (clk_master'event and clk_master = '1' and (i_stb_write= '1')  )  then
        d_write_req  <= '1';  -- test
     end if; 
     end if;
  end process;
  
 -- synchro du signal d_busy  au front d'horloge
  process(clk_master)
  begin
     if (clk_master'event and clk_master = '1' )  then
           q_busy <= d_busy;  
     end if;
  end process; 
  
  
  --
  -- Generation d'un signal d_delai_synch pour assurer duree minimale entre transition...
  -- NON nécessaire ... utile pour avoir le temps de voir
  -- des transitions rapides sur l'analyseur logique en periode de mise au point..
  --
   compteur_delai : process (clk_master, i_reset)
     begin
        if ( i_reset = '1') then
            d_delai <= (others =>'0');
            d_delai_synch <= '0';
        else
        if (rising_edge(clk_master)) then
            d_delai <= d_delai + 1;
            if (d_delai = c_delai_max)  then 
              d_delai_synch <= '1';
              d_delai <= (others =>'0');
              else
               d_delai_synch <= '0';
              end if;
        end if;
        end if;
     end process;
   

-- Assignation du prochain état au front d'horloge
process(clk_master, i_reset)
begin
   if (i_reset= '1') then 
        fsm_i2c_etat_courant <= sta_idle;
   else
    if (clk_master'event and clk_master = '1' and d_delai_synch = '1' )  then
    --if (clk_master'event and clk_master = '1' )  then
         fsm_i2c_etat_courant <= fsm_i2c_etat_prochain;
         q_busy_prec <= q_busy;       
   end if;
   end if;
end process;


-- Calcul des transitions du prochain état
-- nextstate: process(fsm_i2c_etat_courant, d_read_req, d_write_req, q_busy_prec, d_busy)
nextstate: process(fsm_i2c_etat_courant, d_read_req, d_write_req, q_busy_prec, q_busy)
begin
   case fsm_i2c_etat_courant is
        when sta_idle =>
             if (d_read_req = '1') and (q_busy = '0')  then
                   fsm_i2c_etat_prochain   <= sta_read_seq_0;     -- demarrage d'une transaction de lecture
               --     d_ack_debug  <= not d_ack_debug;    -- debug temporaire...
             else
               if (d_write_req = '1') and (q_busy = '0')  then
                   fsm_i2c_etat_prochain   <= sta_write_seq_0;     -- demarrage d'une transaction d'écriture
               --    d_ack_debug  <= not d_ack_debug;    -- debug temporaire...
                else
                fsm_i2c_etat_prochain  <= sta_idle; 
                end if;        
         end if;
         --
         -- Sequence lecture
         when sta_read_seq_0    => 
             if (q_busy_prec = '0') and (q_busy = '1') then
                fsm_i2c_etat_prochain  <= sta_read_seq_1;
              --  d_ack_debug  <= not d_ack_debug;    -- debug temporaire...
                else
                fsm_i2c_etat_prochain  <= sta_read_seq_0;
             end if;
         when sta_read_seq_1    =>
             if (q_busy_prec = '0') and (q_busy = '1')then
               fsm_i2c_etat_prochain  <= sta_read_seq_2;
              -- d_ack_debug  <= not d_ack_debug;    -- debug temporaire...
               else
               fsm_i2c_etat_prochain  <= sta_read_seq_1;
             end if;                  
         when sta_read_seq_2    => 
             if (q_busy = '0') then
               fsm_i2c_etat_prochain  <= sta_read_seq_fin;
              -- d_ack_debug  <= not d_ack_debug;    -- debug temporaire...
               else
               fsm_i2c_etat_prochain  <= sta_read_seq_2;
             end if;
         when sta_read_seq_fin  =>
              fsm_i2c_etat_prochain  <= sta_idle;
               -- d_ack_debug  <= not d_ack_debug;    -- debug temporaire...
         --
         -- Sequence ecriture
         when sta_write_seq_0    => 
              if (q_busy_prec = '0') and (q_busy = '1') then
                fsm_i2c_etat_prochain  <= sta_write_seq_1;
              -- d_ack_debug  <= not d_ack_debug;    -- debug temporaire...
              else
                fsm_i2c_etat_prochain  <= sta_write_seq_0;
              end if;
         when sta_write_seq_1    => 
               if (q_busy_prec = '0') and (q_busy = '1') then
                 fsm_i2c_etat_prochain  <= sta_write_seq_fin; 
               --d_ack_debug  <= not d_ack_debug;    -- debug temporaire...
               else
                 fsm_i2c_etat_prochain  <= sta_write_seq_1;              
              end if;     

         when sta_write_seq_fin    => 
              fsm_i2c_etat_prochain  <= sta_idle;
              --d_ack_debug  <= not d_ack_debug;    -- debug temporaire...
              
         when others =>
             fsm_i2c_etat_prochain <= sta_idle;
   end case;
end process;

-- calcul des sorties de la MEF de controle
sorties: process(fsm_i2c_etat_courant, i_adr_reg, i_dat_wreg, d_data_rd)
-- Calcul des sorties
begin
--
-- documentation ****************************************************
--   Sequence non déterminée
--        sta idle
--                   sorties:
--                        q_busy est 0
--                        pas d'opération
--                   transitions
--                        strobe i_stb_read détecté, prochain etat est sta_read_seq_0  sans autre condition
--                        strobe i_stb_write détecté, prochain etat est sta_write_seq_0  sans autre condition
--                        d_rw  <= '1' ; --  commande prochaine requise est lecture (premiere partie contenu registre)
--                   transitions prochaine
--                        q_busy  passe de 0 a 1 : la commande a ete saisie par codec, prochain etat sta_read_seq2
--        sta_read_seq2
--                        d_rw  <= '1' ; --  commande requise est lecture (seconde partie contenu registre)
--                   transitions prochaine
--                        quand q_busy = '0' la lecture premiere partie est disponible
--                        q_busy  passe de 0 a 1 : la commande a ete saisie par codec, prochain etat sta_read_seq_fin
---
--        sta_read_seq_fin
--                        le resultat de lecture est disponible  (seconde partie contenu registre)
--                   transitions
--                        prochain etat sta_idle sans condition
--
--   Sequence ecriture
--        sta_read_seq_fin
--                    d_ena <= '0';   -- pas de prochaine commande
--                        le resultat de lecture est disponible  (seconde partie contenu registre)
--                   transitions
--                        prochain etat sta_idle sans condition
--
--   Sequence ecriture
--        sta_write_seq0
--                        d_ena <= '1';  -- initialiser transaction  (inferred latch)
--                        d_rw  <= '0' ; -- commande requise est ecriture
--                        donnée a écrire sur d_data_wr (numero registre codec)  + 1 bit du contenu du registre
--                        adresse I2C déja en place sur addr
--                   transitions
--                        q_busy  passe de 0 a 1 : la commande est saisie par codec, prochain etat sta_write_seq0
--        sta_write_se1
--                        d_rw  <= '0' ; --  commande requise est ecriture (seconde partie contenu registre 8 bits )
--                                       --  donnée a écrire sur d_data_wr (seconde partie contenu registre 8 bits )
--                   transitions
--                        q_busy  passe de 0 a 1 : la commande a ete saisie par codec, prochain etat sta_write_seq_fin
--        sta_write_seq_fin
--                        le resultat de lecture est disponible  (seconde partie contenu registre)
--                   transitions
--                        prochain etat sta_idle sans condition
--

   case fsm_i2c_etat_courant is
       when sta_idle           =>
           d_ena       <= '0';
           --
           d_reset_req_read_write <='0'; 
           d_rw  <= '1';  -- par defaut
           d_data_wr(7 downto 0 ) <= (others => '0');
           en_d_data1_rd  <= '0';  
           en_d_data2_rd  <= '0';         
       -- Sequence lecture 
       when sta_read_seq_0   =>   -- on arrive ici avec q_busy = '0'
        -- l'adresse I2C est deja fixee tours la meme dans ce contexte d_codec_adr
          d_ena <= '1'; 
          d_rw  <= '0';        -- commande ecriture (pour adresse registre codec)
          d_data_wr(7 downto 0 ) <= i_adr_reg (6 downto 0) & '0';  --   data tx : adresse registre codec  & '0'          
          d_reset_req_read_write <='0';
          --
          d_reset_req_read_write <='0'; 
          en_d_data1_rd  <= '0';  
          en_d_data2_rd  <= '0';
          
       when sta_read_seq_1   =>  -- le codec a repondu en levant q_busy = '1'
          d_ena <= '1';  
          d_rw  <= '1';        --  (pour lire premiere partie contenu registre)
          d_reset_req_read_write <='1';
          --
          d_data_wr(7 downto 0 ) <= (others => '0');
          en_d_data1_rd  <= '0';  
          en_d_data2_rd  <= '0';
                       
       when sta_read_seq_2   =>   -- enregiste les 8 bits lu et enchaine une nouvelle commande immediatement  lire 1 bits (parmi 8)
                                  -- q_busy passse a zero -> transition vers le suivant
          d_ena <= '1'; 
          d_rw  <= '1';           --  (pour lire seconde partie contenu registre)
          en_d_data1_rd  <= '1';  -- 
          d_reset_req_read_write <='0';
          --
          d_data_wr(7 downto 0 ) <= (others => '0'); 
          en_d_data2_rd  <= '0';        
          
        when sta_read_seq_fin   => 
          d_ena <= '0';
          en_d_data2_rd  <= '1';   --
          d_reset_req_read_write <='0'; 
          d_rw  <= '1';
          d_data_wr(7 downto 0 ) <= (others => '0');
          en_d_data1_rd  <= '0';  
          --  
          --
          --
          --
       when sta_write_seq_0    => 
           -- l'adresse I2C est deja fixee tours la meme dans ce contexte d_codec_adr
           d_ena <= '1';         --
           d_rw  <= '0';         --
           d_data_wr(7 downto 0 ) <= i_adr_reg (6 downto 0) & i_dat_wreg(8);  --  data tx : adresse registre codec & 1 bit data
           --
           d_reset_req_read_write <='0'; 
           en_d_data1_rd  <= '0';  
           en_d_data2_rd  <= '0';              
      -- 
       when sta_write_seq_1    => 
           d_ena <= '1';  
           d_rw  <= '0'; 
           d_data_wr(7 downto 0 ) <= i_dat_wreg (7 downto 0);                 --  data tx :  8 bits data    
           d_reset_req_read_write <='1';
           --
           en_d_data1_rd  <= '0';  
           en_d_data2_rd  <= '0';    
       --    
       when sta_write_seq_fin    => 
           d_ena <= '0';   
           d_reset_req_read_write <='0';           
           --
           d_rw  <= '1';
           d_data_wr(7 downto 0 ) <= (others => '0');
           en_d_data1_rd  <= '0';  
           en_d_data2_rd  <= '0';        
       --when others         => NULL;
       when others    => 
            d_ena       <= '0';
            d_reset_req_read_write <='0'; 
            d_rw  <= '1';
            d_data_wr(7 downto 0 ) <= (others => '0');
            en_d_data1_rd  <= '0';  
            en_d_data2_rd  <= '0'; 
 end case;

 end process;
 
 
inst_dat_read:  process(clk_master, i_reset)
 begin
    if (i_reset= '1') then 
         d_dat_readreg(8 downto 0) <= (others => '0');
    else
        if (clk_master'event and clk_master = '1') then
            if   (en_d_data1_rd = '1')  then
               d_dat_readreg(7 downto 0)  <= d_data_rd ; 
               else if (en_d_data2_rd = '1') then 
                d_dat_readreg(8)  <= d_data_rd(0);  
               end if;
            end if;    
        end if;
     end if;
 end process;


 --
  d_reset_n <= not i_reset;
  o_busy <=  q_busy;
  o_ack_error   <=  d_ack_error;
  o_ena         <=  d_ena;
  o_rw          <=  d_rw;
              
  o_read_req    <= d_read_req;
  o_write_req   <= d_write_req;
  o_dat_rreg    <= d_dat_readreg;

end Behavioral;
