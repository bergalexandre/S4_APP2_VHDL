----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/27/2020 03:28:38 PM
-- Design Name: 
-- Module Name: param_puissance - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity param_puissance is
    Port (
        i_value : in STD_LOGIC_VECTOR(23 downto 0);
        i_dat_str : in STD_LOGIC;
        i_puissance : in STD_LOGIC_VECTOR(15 downto 0);
        o_puissance : out STD_LOGIC_VECTOR(15 downto 0);
        o_aff : out STD_LOGIC_VECTOR(7 downto 0)
    );
end param_puissance;

architecture Behavioral of param_puissance is
    signal puissance : STD_LOGIC_VECTOR(15 downto 0) := (others=>'0');
begin
   
    
    integral_puissance : PROCESS(i_dat_str)
        variable puissance_oublie : std_logic_vector(31 downto 0) := (others=>'0');
        variable X : std_logic_vector(15 downto 0) := (others=>'0');
    begin
        if rising_edge(i_dat_str) then
            puissance_oublie := std_logic_vector(unsigned(i_puissance)*31);
            puissance_oublie := std_logic_vector(unsigned(puissance_oublie)/32);
            X := x"00" & STD_LOGIC_VECTOR(abs(signed(i_value(23 downto 16))));
            puissance <= std_logic_vector((unsigned(X) + unsigned(puissance_oublie(15 downto 0))));
         end if;
    end PROCESS;
    
    o_puissance <= puissance;
    o_aff <= puissance(11 downto 4);
end Behavioral;
