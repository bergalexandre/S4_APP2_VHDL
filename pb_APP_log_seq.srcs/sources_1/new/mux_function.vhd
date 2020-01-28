----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/27/2020 09:57:34 PM
-- Design Name: 
-- Module Name: mux_function - Behavioral
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

entity mux_function is
    Port (
        fct_1  : in STD_LOGIC_VECTOR(23 downto 0);
        fct_2  : in STD_LOGIC_VECTOR(23 downto 0);
        fct_3  : in STD_LOGIC_VECTOR(23 downto 0);
        fct_4  : in STD_LOGIC_VECTOR(23 downto 0);
        selection : in STD_LOGIC_VECTOR(1 downto 0);
        sortie : out STD_LOGIC_VECTOR(23 downto 0)
    );
end mux_function;

architecture Behavioral of mux_function is

begin

    selection_function : PROCESS(selection, fct_1, fct_2, fct_3, fct_4)
    
    begin
        case selection is 
            when "00" =>
                sortie <= fct_1;
            when "01" =>
                sortie <= fct_2;
            when "10" =>
                sortie <= fct_3;
            when "11" =>
                sortie <= fct_4;
            when others =>
                sortie <= fct_1;
        end case;
    end PROCESS;

end Behavioral;
