----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/28/2020 11:31:38 AM
-- Design Name: 
-- Module Name: TB_Module_de_cmd - Behavioral
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

entity TB_Module_de_cmd is
--  Port ( );
end TB_Module_de_cmd;



architecture Behavioral of TB_Module_de_cmd is

    

    component module_commande IS
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
    end component;
   
    signal p_clk : STD_LOGIC := '0';
    signal p_reset : STD_LOGIC;
    signal p_btn : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal p_sw : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal p_btn_cd : STD_LOGIC_VECTOR(3 downto 0);
    signal p_sel_fct : STD_LOGIC_VECTOR(1 downto 0);
    signal p_sel_par : STD_LOGIC_VECTOR(1 downto 0);
begin

    inst_mod_cmd : module_commande Port map(
        clk => p_clk,
        o_reset => p_reset,
        i_btn => p_btn,
        i_sw => p_sw,
        o_btn_cd => p_btn_cd,
        o_selection_fct => p_sel_fct,
        o_selection_par => p_sel_par
    );

    p_clk <= not p_clk after 20ns;
    
    test : PROCESS
    
    begin
        p_btn <= "0000"; wait for 20ns;
        
        p_sw <= "0000"; p_btn(0) <= '1'; wait for 5ms;p_btn(0) <= '0'; wait for 5ms;
        p_sw <= "0000"; p_btn(0) <= '1'; wait for 5ms;p_btn(0) <= '0'; wait for 5ms;
        p_sw <= "0000"; p_btn(0) <= '1'; wait for 5ms;p_btn(0) <= '0'; wait for 5ms;
        p_sw <= "0000"; p_btn(0) <= '1'; wait for 5ms;p_btn(0) <= '0'; wait for 5ms;
        
        p_sw <= "0100"; p_btn(0) <= '1'; wait for 5ms;p_btn(0) <= '0'; wait for 5ms;
        p_sw <= "0100"; p_btn(0) <= '1'; wait for 5ms;p_btn(0) <= '0'; wait for 5ms;
        p_sw <= "0100"; p_btn(0) <= '1'; wait for 5ms;p_btn(0) <= '0'; wait for 5ms;
        p_sw <= "0100"; p_btn(0) <= '1'; wait for 5ms;p_btn(0) <= '0'; wait for 5ms;
        
        p_sw <= "1000"; p_btn(0) <= '1'; wait for 5ms;p_btn(0) <= '0'; wait for 5ms;
        p_sw <= "1000"; p_btn(0) <= '1'; wait for 5ms;p_btn(0) <= '0'; wait for 5ms;
        p_sw <= "1000"; p_btn(0) <= '1'; wait for 5ms;p_btn(0) <= '0'; wait for 5ms;
        p_sw <= "1000"; p_btn(0) <= '1'; wait for 5ms;p_btn(0) <= '0'; wait for 5ms;
        
        p_sw <= "1100"; p_btn(0) <= '1'; wait for 5ms;p_btn(0) <= '0'; wait for 5ms;
        p_sw <= "1100"; p_btn(0) <= '1'; wait for 5ms;p_btn(0) <= '0'; wait for 5ms;
        p_sw <= "1100"; p_btn(0) <= '1'; wait for 5ms;p_btn(0) <= '0'; wait for 5ms;
        p_sw <= "1100"; p_btn(0) <= '1'; wait for 5ms;p_btn(0) <= '0'; wait for 5ms;
    end PROCESS;
    
    
end Behavioral;
