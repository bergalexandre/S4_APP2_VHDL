----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/25/2020 02:33:06 PM
-- Design Name: 
-- Module Name: fct_dure - Behavioral
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
use ieee.numeric_std.all; -- this is the standard package where signed is defined

entity fct_dure is
    Port (
        i_dat24 :   IN STD_LOGIC_VECTOR(23 downto 0);
        o_dat24 :   OUT STD_LOGIC_VECTOR(23 downto 0)
    );
end fct_dure;

architecture Behavioral of fct_dure is
    constant SEUIL : STD_LOGIC_VECTOR(23 downto 0) := x"200000";
    constant SEUIL_C2 : STD_LOGIC_VECTOR(23 downto 0) := x"d00000"; 
begin
    
    distortion_dure : PROCESS(i_dat24)
    begin
        if i_dat24 = x"800000" then
            o_dat24 <= SEUIL_C2;
        elsif abs(signed(i_dat24)) < SIGNED(SEUIL) then
            o_dat24 <= i_dat24;
        else
            if i_dat24(23) = '1' then
                o_dat24 <= SEUIL_C2;
            else
                o_dat24 <=  SEUIL;
            end if;
        end if;
    end PROCESS;
end Behavioral;
