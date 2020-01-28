--  module_commande.vhd
--  D. Dalle  30 avril 2019, 16 janv 2020
--  module qui permet de réunir toutes les commandes (problematique circuit sequentiels)
--  recues des boutons, avec conditionnement, et des interrupteurs

LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity module_commande IS
generic (nbtn : integer := 4;  mode_seq_bouton: std_logic := '0'; mode_simulation: std_logic := '0');
    PORT (
          clk          : in  std_logic;
          o_reset      : out  std_logic; 
          i_btn        : in  std_logic_vector (nbtn-1 downto 0); -- signaux directs des boutons
          i_sw         : in  std_logic_vector (3 downto 0);      -- signaux directs des interrupteurs
          o_btn_cd     : out std_logic_vector (nbtn-1 downto 0); -- signaux conditionnés 
          o_selection_fct  :  out std_logic_vector(1 downto 0);
          o_selection_par  :  out std_logic_vector(1 downto 0)
          );
end module_commande;

ARCHITECTURE BEHAVIOR OF module_commande IS


component conditionne_btn_v7 is
generic (nbtn : integer := nbtn;  mode_simul: std_logic := '0');
    port (
         CLK          : in std_logic;         -- devrait etre de l ordre de 50 Mhz
         i_btn        : in    std_logic_vector (nbtn-1 downto 0);
         --
         o_btn_db     : out    std_logic_vector (nbtn-1 downto 0);
         o_strobe_btn : out    std_logic_vector (nbtn-1 downto 0)
         );
end component;


    type fsm_etat_aff IS (S1,S1_off, S2, S2_off, S3, S3_off, S4, S4_off);
    SIGNAL fsm_aff, fsm_aff_suiv : fsm_etat_aff := S1;
    signal d_strobe_btn :    std_logic_vector (nbtn-1 downto 0);
    signal d_btn_cd     :    std_logic_vector (nbtn-1 downto 0); 
    signal d_reset      :    std_logic;
    signal o_btn0       :    std_logic_vector(1 downto 0);
    signal btn0         :    std_logic;
    signal clk_btn0     :    std_logic := '0';
   
BEGIN 
    
                  
 inst_cond_btn:  conditionne_btn_v7
    generic map (nbtn => nbtn, mode_simul => mode_simulation)
    port map(
        clk           => clk,
        i_btn         => i_btn,
        o_btn_db      => d_btn_cd,
        o_strobe_btn  => d_strobe_btn  
         );
 
    clk_btn0 <= not clk_btn0 after 50us;
 
  MEF_btn0: process(clk_btn0)
    begin
        case fsm_aff is
            when S1 =>
                if i_btn(0) = '1' then
                        fsm_aff <= S1_off;
                end if;
            when S1_off =>
                if i_btn(0) = '0' then
                    fsm_aff <= S2;
                end if;
            when S2 =>
                if i_btn(0) = '1' then
                        fsm_aff <= S2_off;
                end if;
            when S2_off =>
                if i_btn(0) = '0' then
                    fsm_aff <= S3;
                end if;
            when S3 =>
                if i_btn(0) = '1' then
                        fsm_aff <= S3_off;
                end if;
            when S3_off =>
                if i_btn(0) = '0' then
                    fsm_aff <= S4;
                end if;
            when S4 =>
                if i_btn(0) = '1' then
                        fsm_aff <= S4_off;
                end if;
            when S4_off =>
                if i_btn(0) = '0' then
                    fsm_aff <= S1;
                end if;
        end case;
    end process;
    
    
    MEF_output: process(fsm_aff)
    begin
        case fsm_aff is
            when S1 =>
                o_btn0 <= "00";
            when S2 =>
                o_btn0 <= "01";
            when S3 =>
                o_btn0 <= "10";
            when S4 =>
                o_btn0 <= "11";
            when others =>
        end case;
    end process;

 
   o_btn_cd        <= d_btn_cd;
   o_selection_par <= o_btn0; -- mode de selection du parametre par sw
   o_selection_fct <= i_sw(3 downto 2); -- mode de selection de la fonction par sw
   d_reset         <= i_btn(3);         -- pas de contionnement particulier sur reset
   o_reset         <= d_reset;          -- pas de contionnement particulier sur reset

END BEHAVIOR;
