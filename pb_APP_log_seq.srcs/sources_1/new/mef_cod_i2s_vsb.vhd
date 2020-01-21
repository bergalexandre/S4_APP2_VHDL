---------------------------------------------------------------------------------------------
-- circuit mef_cod_i2s_vsb.vhd.vhd
---------------------------------------------------------------------------------------------
-- Université de Sherbrooke - Département de GEGI
-- Version         : 1.0
-- Nomenclature    : 0.8 GRAMS
-- Date            : 5 mai 2019
-- Auteur(s)       : Daniel Dalle
-- Technologies    : FPGA Zynq (carte ZYBO Z7-10 ZYBO Z7-20)
--
-- Outils          : vivado 2019.1
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
-- Revision  
-- Revision 14 mai 2019 (version ..._vsb) composants dans entités et fichiers distincts
---------------------------------------------------------------------------------------------
-- À faire :
--
--
---------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- pour les additions dans les compteurs

entity mef_cod_i2s_vsb is
   Port ( 
   i_bclk      : in std_logic;
   i_reset     : in    std_logic; 
   i_lrc       : in std_logic;
   i_cpt_bits  : in std_logic_vector(6 downto 0);
 --  
   o_bit_enable     : out std_logic ;  --
   o_load_left      : out std_logic ;  --
   o_load_right     : out std_logic ;  --
  -- o_str_dat        : out std_logic ;  --  
   o_cpt_bit_reset  : out std_logic   -- 
   
);
end mef_cod_i2s_vsb;

architecture Behavioral of mef_cod_i2s_vsb is
  
-- définition de la MEF de contrôle
   type fsm_cI2S_etats is (
         sta_init,
         sta_g0,
         sta_g1,
         sta_g2,
         sta_g3,
         sta_gf,
         sta_d0,
         sta_d1,
         sta_d2,
         sta_d3,
         sta_df
         );
       
   signal fsm_EtatCourant, fsm_prochainEtat : fsm_cI2S_etats;

begin

   -- Assignation du prochain état
    process(i_bclk, i_reset)
    begin
       if (i_reset ='1') then
             fsm_EtatCourant <= sta_init;
       else
       if rising_edge(i_bclk) then
             fsm_EtatCourant <= fsm_prochainEtat;
       end if;
       end if;
    end process;

--
-- conditions de transitions
transitions: process(i_lrc , fsm_EtatCourant, i_cpt_bits)
begin
   case fsm_EtatCourant is
        when sta_init =>
            if(i_lrc = '0') then
                fsm_prochainEtat <= sta_gf;
            else
                fsm_prochainEtat <= sta_df;
            end if;
         when sta_gf =>
            if(i_lrc = '0') then
             fsm_prochainEtat <= sta_gf;
         else
             fsm_prochainEtat <= sta_d0;
         end if;
         when sta_g0 =>
             fsm_prochainEtat <= sta_g1;
         when sta_g1 =>
            if(   i_cpt_bits = "010111"  ) then
                fsm_prochainEtat <= sta_g2;
            else
                fsm_prochainEtat <= sta_g1;
            end if;
         when sta_g2 =>
            fsm_prochainEtat <= sta_g3;
         when sta_g3 =>
            fsm_prochainEtat <= sta_gf;
 --
         when sta_df =>
            if(i_lrc = '0') then
                 fsm_prochainEtat <= sta_g0;
              else
                 fsm_prochainEtat <= sta_df;
            end if;
        when sta_d0 =>
            fsm_prochainEtat <= sta_d1;
        when sta_d1 =>
            if(   i_cpt_bits = "010111"  ) then
                fsm_prochainEtat <= sta_d2;
            else
                fsm_prochainEtat <= sta_d1;
            end if;
        when sta_d2 =>
             fsm_prochainEtat <= sta_d3;
        when sta_d3 =>
             fsm_prochainEtat <= sta_df;
     end case;
  end process;

  -- relations de sorties pour le contrôle du registre et du compteur
  sortie: process(fsm_EtatCourant, i_lrc )
  begin
  
   case fsm_EtatCourant is
        when sta_init =>
            o_cpt_bit_reset    <= '0';
            o_bit_enable     <= '0';
            o_load_left      <= '0';
            o_load_right     <= '0';
       when sta_g0=>
             o_cpt_bit_reset    <= '1';
             o_bit_enable     <= '0';
             o_load_left      <= '0';
             o_load_right     <= '0';
        when sta_g1=>
            o_cpt_bit_reset    <= '0';
            o_bit_enable     <= '1';
            o_load_left      <= '0';
            o_load_right     <= '0';
        when sta_g2=>
            o_cpt_bit_reset    <= '0';
            o_bit_enable     <= '0';
            o_load_left      <= '0';
            o_load_right     <= '0';
        when sta_g3=>
            o_cpt_bit_reset    <= '0';
            o_bit_enable     <= '0';
            o_load_left      <= '0';
            o_load_right     <= '0';
        when sta_gf =>
            o_cpt_bit_reset    <= '0';
            o_bit_enable     <= '0';
            o_load_left      <= '0';
            o_load_right     <= '1';
      --
        when sta_d0=>
            o_cpt_bit_reset    <= '1';
            o_bit_enable     <= '0';
            o_load_left      <= '0';
            o_load_right     <= '0';
         when sta_d1=>
            o_cpt_bit_reset    <= '0';
            o_bit_enable     <= '1';
            o_load_left      <= '0';
            o_load_right     <= '0';
         when sta_d2=>
            o_cpt_bit_reset    <= '0';
            o_bit_enable     <= '0';
            o_load_left      <= '0';
            o_load_right     <= '0';
        when sta_d3=>
            o_cpt_bit_reset    <= '0';
            o_bit_enable     <= '0';
            o_load_left      <= '0';
            o_load_right     <= '0';
         when sta_df=>
            o_cpt_bit_reset    <= '0';
            o_bit_enable     <= '0';
            o_load_left      <= '1';
            o_load_right     <= '0';
     end case;
    
    end process;
  
end Behavioral;