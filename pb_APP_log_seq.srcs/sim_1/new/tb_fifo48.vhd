----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/26/2020 05:17:10 PM
-- Design Name: 
-- Module Name: tb_fifo48 - Behavioral
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

entity tb_fifo48 is
--  Port ( );
end tb_fifo48;

architecture Behavioral of tb_fifo48 is

    component fifo48 is
        Port (
            i_read      : in STD_LOGIC;
            i_write     : in STD_LOGIC;
            i_value     : in STD_LOGIC_VECTOR(23 downto 0);
            o_value     : out STD_LOGIC_VECTOR(23 downto 0)
        );
    end component;
    
    signal clk : STD_LOGIC := '0';
    constant clock : time := 100ns;
    constant zero : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    signal i_read : STD_LOGIC := '0';
    signal i_write : STD_LOGIC := '0';
    signal i_value : STD_LOGIC_VECTOR(23 downto 0) := (others=>'0');
    signal o_value : STD_LOGIC_VECTOR(23 downto 0) := (others=>'0');
    
begin
    
    inst_fifo48 : fifo48 port map (
            i_read  => i_read,
            i_write => i_write,
            i_value => i_value,
            o_value => o_value
    );
    
    clk <= not clk after clock;

    testbench : PROCESS
    begin
        wait for clock;
        i_write <= '1';
        i_value <= x"000001";
        wait for clock;
        i_write <= '0';
        wait for clock;
        
        i_write <= '1';
        i_value <= x"000010";
        wait for clock;
        i_write <= '0';
        wait for clock;
        
        i_write <= '1';
        i_value <= x"000100";
        wait for clock;
        i_write <= '0';
        wait for clock;
        
        i_write <= '1';
        i_value <= x"d00000";
        wait for clock;
        i_write <= '0';
        wait for clock;
        
        i_read <= '1';
        wait for clock;
        i_read <= '0';
        wait for clock;
        
        i_write <= '1';
        i_value <= STD_LOGIC_VECTOR(signed(zero) - signed(i_value));
        wait for clock;
        i_write <= '0';
        wait for clock;
        
        i_read <= '1';
        wait for clock;
        i_read <= '0';
        wait for clock;
        
        i_read <= '1';
        wait for clock;
        i_read <= '0';
        wait for clock;
        
        i_read <= '1';
        wait for clock;
        i_read <= '0';
        wait for clock;
        
        wait;
    end PROCESS;
end Behavioral;
