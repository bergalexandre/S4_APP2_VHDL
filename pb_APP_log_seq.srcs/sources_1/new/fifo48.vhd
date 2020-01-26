----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/26/2020 04:30:43 PM
-- Design Name: 
-- Module Name: fifo48 - Behavioral
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

entity fifo48 is
    Port (
        i_clk_codec : in STD_LOGIC;
        i_read      : in STD_LOGIC;
        i_write     : in STD_LOGIC;
        i_value     : in STD_LOGIC_VECTOR(23 downto 0);
        o_value     : out STD_LOGIC_VECTOR(23 downto 0)
    );
end fifo48;

architecture Behavioral of fifo48 is
    type fifoEchantillion is array (integer range 0 to 47) of std_logic_vector(23 downto 0);
    signal fifo : fifoEchantillion := (others=>(others=>'0'));
    constant FIFO_MAX: STD_LOGIC_VECTOR(5 downto 0) := "110000";
    
    signal head_position    : STD_LOGIC_VECTOR(5 downto 0) := (others=>'0');
    signal queue_position   : STD_LOGIC_VECTOR(5 downto 0) := (others=>'0');
    signal number_of_item   : STD_LOGIC_VECTOR(5 downto 0) := (others=>'0');
    
    type fifo_etat_type is (
        fifo_wait,
        fifo_read,
        fifo_write
    );
    signal fifo_etat : fifo_etat_type := fifo_wait;
    signal fifo_etat_suivant : fifo_etat_type := fifo_wait;
        
begin
    
    manage_state : PROCESS(i_write, i_read)
    begin
        if rising_edge(i_write) then
            fifo_etat <= fifo_write;
        elsif rising_edge(i_read) then
            fifo_etat <= fifo_read;
        else
            fifo_etat <= fifo_wait;
        end if;
    end PROCESS;
    
    managerBuffer : PROCESS(fifo_etat)
    begin
        case fifo_etat is
            when fifo_wait =>
                o_value <= (others=>'0');
            when fifo_read =>
                if number_of_item = "000000" then
                    o_value <= (others=>'0'); 
                else
                    o_value <= fifo(to_integer(unsigned(queue_position)));
                    number_of_item <= STD_LOGIC_VECTOR(unsigned(number_of_item) - 1);
                    queue_position <= STD_LOGIC_VECTOR((unsigned(queue_position) + 1) mod unsigned(FIFO_MAX));
                end if;
            when fifo_write =>
                if number_of_item /= FIFO_MAX then
                    fifo(to_integer(unsigned(head_position))) <= i_value;
                    number_of_item <= STD_LOGIC_VECTOR(unsigned(number_of_item) + 1);
                    head_position <= STD_LOGIC_VECTOR((unsigned(head_position) + 1) mod unsigned(FIFO_MAX));
                end if;
        end case;
    end PROCESS;

end Behavioral;
