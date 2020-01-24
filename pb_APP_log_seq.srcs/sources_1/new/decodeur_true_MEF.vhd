----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/22/2020 12:38:07 PM
-- Design Name: 
-- Module Name: decodeur_true_MEF - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decodeur_true_MEF is
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
end decodeur_true_MEF;

architecture Behavioral of decodeur_true_MEF is

   type decodeur_etat is (
        decodeur_init,
        decodeur_depart,
        decodeur_Attend,
        decodeur_sauvegarde,
        decodeur_fin
    );
       

    signal      decodeur_etatCourant : decodeur_etat;
    signal      decodeur_etatSuivant : decodeur_etat := decodeur_Attend;
    signal      decodeur_secondeLecture : STD_LOGIC := '0';


begin

   -- pour detecter transitions d_ac_reclrc
   reglrc_I2S: process ( i_bclk)
   begin
       if i_bclk'event and (i_bclk = '1') then
            decodeur_etatCourant <= decodeur_etatSuivant;
       end if;
   end process;
   
   
   
  transition: process(i_bclk)
    begin 
        if i_reset = '1' then
            decodeur_etatSuivant <= decodeur_Attend;
            decodeur_secondeLecture <= '0';
        else
            case decodeur_etatCourant is 
                when decodeur_init => 
                        if i_lrc  = decodeur_secondeLecture then
                            decodeur_secondeLecture <= not decodeur_secondeLecture;
                            decodeur_etatSuivant <= decodeur_depart;
                        end if;
                when decodeur_depart =>
                    if i_cpt_bits  = "0000010" then
                        decodeur_etatSuivant <= decodeur_Attend;
                    end if;
                when decodeur_Attend =>
                    if i_cpt_bits  = "0011001" then
                        decodeur_etatSuivant <= decodeur_sauvegarde;
                    end if;
                when decodeur_sauvegarde =>
                    if decodeur_secondeLecture = '1' then
                        decodeur_etatSuivant <= decodeur_init;
                    else
                        decodeur_etatSuivant <= decodeur_fin;
                    end if;   
                when decodeur_fin =>
                    decodeur_etatSuivant <= decodeur_init;
            end case;
        end if;
    end process;
  
  sortie: process(decodeur_etatCourant)
  begin
  
   case decodeur_etatCourant is
        when decodeur_init =>
            o_cpt_bit_reset    <= '1';
            o_bit_enable     <= '0';
            o_load_left      <= '0';
            o_load_right     <= '0';
            o_str_dat     <= '0';
       when decodeur_depart =>
             o_cpt_bit_reset    <= '0';
             o_bit_enable     <= '0';
             o_load_left      <= '0';
             o_load_right     <= '0';
             o_str_dat     <= '0';
        when decodeur_Attend=>
            o_cpt_bit_reset    <= '0';
            o_bit_enable     <= '1';
            o_load_left      <= '0';
            o_load_right     <= '0';
            o_str_dat     <= '0';
        when decodeur_sauvegarde=>
            o_cpt_bit_reset    <= '1';
            o_bit_enable     <= '0';
            o_load_left      <= not i_lrc;
            o_load_right     <= i_lrc;
            o_str_dat     <= '0';
         when decodeur_fin=>
            o_cpt_bit_reset    <= '0';
            o_bit_enable     <= '0';
            o_load_left      <= '0';
            o_load_right     <= '0';
            o_str_dat     <= '1';
     end case; 
     end process;


end Behavioral;
