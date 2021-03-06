----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/27/2020 10:04:44 PM
-- Design Name: 
-- Module Name: mux_param - Behavioral
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

entity mux_param is
Port (
        param_1 : in STD_LOGIC_VECTOR(7 downto 0);
        param_2 : in STD_LOGIC_VECTOR(7 downto 0);
        param_3 : in STD_LOGIC_VECTOR(7 downto 0);
        param_4 : in STD_LOGIC_VECTOR(7 downto 0);
        selection : in STD_LOGIC_VECTOR(1 downto 0);
        sortie : out STD_LOGIC_VECTOR(7 downto 0)
    );
end mux_param;

architecture Behavioral of mux_param is

begin
    selection_function : PROCESS(selection, param_1, param_2, param_3, param_4)
    
    begin
        case selection is 
            when "00" =>
                sortie <= param_1;
            when "01" =>
                sortie <= param_2;
            when "10" =>
                sortie <= param_3;
            when "11" =>
                sortie <= param_4;
            when others =>
                sortie <= param_1;
        end case;
    end PROCESS;

end Behavioral;
    