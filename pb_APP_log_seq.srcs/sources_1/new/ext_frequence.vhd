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

LIBRARY ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity MEF_frequence is
   Port ( 
        i_dat24     : in std_logic_vector(23 downto 0);
        i_bclk      : in std_logic;
        i_reset     : in std_logic; 
        i_lrc       : in std_logic;
        i_cpt_bits  : in std_logic_vector(6 downto 0);
        o_dat8     : out std_logic_vector(7 downto 0) 
   
);
end MEF_frequence;

architecture Behavioral of MEF_frequence is
  
-- définition de la MEF de contrôle
    type etats_freq is (
         s0,
         s1,
         s2,
         s3,
         s4,
         s5  
         );
       
    signal EtatCourant, prochainEtat, etatPrecedant : etats_freq := s0;
    signal compteur: STD_LOGIC_VECTOR(7 downto 0) := x"00";
    signal valeur_retenue: STD_LOGIC_VECTOR(7 downto 0) := x"00";
   

begin
    clk_set:process(i_lrc)
        begin
            if (i_reset ='1') then
                 EtatCourant <= s0;
            end if;
            if rising_edge(i_lrc) then
                 EtatCourant <= prochainEtat;
            end if;
    end process;


    -- conditions de transitions
    transitions: process(EtatCourant)
    begin
        case EtatCourant is
            when s0 =>
                if signed(i_dat24) > 0 then
                    prochainEtat <= s1;
                else
                    prochainEtat <= s0;
                end if;
            when s1 =>
                if signed(i_dat24) > 0 then
                    prochainEtat <= s2;
                else
                    prochainEtat <= s0;
                end if;
            when s2 =>
                if signed(i_dat24) > 0 then
                    prochainEtat <= s3;
                else
                    prochainEtat <= s0;
                end if;
            when s3 =>
                if signed(i_dat24) > 0 then
                    prochainEtat <= s3;
                else
                    prochainEtat <= s4;
                end if;
            when s4 =>
                if signed(i_dat24) > 0 then
                    prochainEtat <= s3;
                else
                    prochainEtat <= s5;
                end if;
            when s5 =>
                if signed(i_dat24) > 0 then
                    prochainEtat <= s3;
                else
                    prochainEtat <= s0;
                end if;
        end case;
    end process;

    sortie: process(i_lrc)
    begin
        etatPrecedant <= EtatCourant;
        case EtatCourant is
            when s0 =>
                case etatPrecedant is
                    when s5 =>
                        valeur_retenue    <= compteur;
                        compteur   <= x"00";
                    when s0 =>
                        compteur   <= std_logic_vector(signed(compteur) + 1);
                    when s1 =>
                        compteur   <= std_logic_vector(signed(compteur) + 2);
                    when s2 =>
                        compteur   <= std_logic_vector(signed(compteur) + 3);
                    when others =>
                        compteur   <= compteur;  
                end case;   
            when s3 =>
                case etatPrecedant is
                    when s2 =>
                        compteur   <= std_logic_vector(signed(compteur) + 1);
                    when s3 =>
                        compteur   <= std_logic_vector(signed(compteur) + 1);
                    when s4 =>
                        compteur   <= std_logic_vector(signed(compteur) + 2);
                    when s5 =>
                        compteur   <= std_logic_vector(signed(compteur) + 3);
                    when others =>
                        compteur   <= compteur; 
                end case;
            when others =>
                compteur <= compteur;

        end case;
    end process;
    
    o_dat8 <= valeur_retenue;
  
end Behavioral;