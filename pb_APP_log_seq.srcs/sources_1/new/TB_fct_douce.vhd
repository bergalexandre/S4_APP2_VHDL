----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/12/2020 10:41:38 AM
-- Design Name: 
-- Module Name: TB_fct2_3 - Behavioral
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

entity TB_fct_douce is
--  Port ( );
end TB_fct_douce;

architecture Behavioral of TB_fct_douce is

 COMPONENT fct_douce
    Port ( 
        i_dat24: in std_logic_vector(23 downto 0);
        o_dat24: out std_logic_vector(23 downto 0) 
    );
 END COMPONENT;
 
 signal sim_input : std_logic_vector(23 downto 0) := (others => '0');
 signal sim_output : STD_LOGIC_VECTOR(23 downto 0);

 
 CONSTANT PERIOD    : time := 100 ns;
 
BEGIN
 
 -- Instantiate the Unit Under Test (UUT)
 uut: fct_douce PORT MAP (
     i_dat24 => sim_input,
     o_dat24 => sim_output
 );

tb : PROCESS
begin
     wait for PERIOD; sim_input <=x"003411";   
     wait for PERIOD; sim_input <=x"146555";
     wait for PERIOD; sim_input <=x"1FFFFF";
     wait for PERIOD; sim_input <=x"D1FFFF";
     wait for PERIOD; sim_input <=x"EF0005";
     wait for PERIOD; sim_input <=x"F30005";
     wait for PERIOD; sim_input <=x"FFFFFF";
     
     wait for PERIOD; sim_input <=x"200001";
     wait for PERIOD; sim_input <=x"256666";
     wait for PERIOD; sim_input <=x"46AAAA";
     wait for PERIOD; sim_input <=x"5FFFFF";
     wait for PERIOD; sim_input <=x"6FFFFF";
     wait for PERIOD; sim_input <=x"7FFFFF";
     
     wait for PERIOD; sim_input <=x"91EEEE";
     wait for PERIOD; sim_input <=x"A5DDDD";
     wait for PERIOD; sim_input <=x"B33333";
     wait for PERIOD; sim_input <=x"CC7777";
     wait for PERIOD; sim_input <=x"DC7777";
     wait for PERIOD; sim_input <=x"D8C888";
     wait for PERIOD; sim_input <=x"C00000";
     
     wait for PERIOD; sim_input <=x"200000";
     wait for PERIOD; sim_input <=x"800000";
     wait;
     end process;


end Behavioral;