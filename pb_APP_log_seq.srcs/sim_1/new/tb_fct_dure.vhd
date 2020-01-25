----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/25/2020 02:49:54 PM
-- Design Name: 
-- Module Name: tb_fct_dure - Behavioral
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
use ieee.numeric_std.all; -- this is the standard package where signed is defined

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_fct_dure is
--  Port ( );
end tb_fct_dure;

architecture Behavioral of tb_fct_dure is

    component fct_dure is
        Port(
            i_dat24 :   IN STD_LOGIC_VECTOR(23 downto 0);
            o_dat24 :   OUT STD_LOGIC_VECTOR(23 downto 0)
        );
    end component;

    signal in24 : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    type table_forme is array (integer range 0 to 9) of std_logic_vector(23 downto 0);
    constant test_valeur : table_forme := ( 
     x"000000",
     x"100000",
     x"5fffff",
     x"7fffff",
     x"ffffff",
     x"a00000",
     x"d00000",
     x"800000",
     x"800000",
     x"800000"
     );
     constant delay : time := 100ns;
    signal test : STD_LOGIC_VECTOR(23 downto 0);
    signal test2 : STD_LOGIC_VECTOR(23 downto 0);
    signal test3 : STD_LOGIC_VECTOR(23 downto 0); 
begin

    inst_fct_dure : fct_dure port map(
        i_dat24 => in24,
        o_dat24 => open
    );
    
    testbench : PROCESS
        
    begin
        in24 <= STD_LOGIC_VECTOR(-(signed(test_valeur(3))));
        wait for delay;
        in24 <= test_valeur(0); wait for delay;
        in24 <= test_valeur(1); wait for delay;
        in24 <= test_valeur(2); wait for delay;
        in24 <= test_valeur(3); wait for delay;
        in24 <= test_valeur(4); wait for delay;
        in24 <= test_valeur(5); wait for delay;
        in24 <= test_valeur(6); wait for delay;
        in24 <= test_valeur(7); wait for delay;
        in24 <= test_valeur(8); wait for delay;
        wait;
        
    end PROCESS;
    
end Behavioral;
