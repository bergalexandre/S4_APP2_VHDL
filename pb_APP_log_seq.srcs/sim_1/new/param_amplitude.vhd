----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/27/2020 11:59:16 AM
-- Design Name: 
-- Module Name: param_amplitude - Behavioral
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

entity param_amplitude is
    Port ( 
        i_value     : in STD_LOGIC_VECTOR(23 downto 0);
        i_dat_str   : in STD_LOGIC;
        o_value     : out STD_LOGIC_VECTOR(7 downto 0)
    );
end param_amplitude;

architecture Behavioral of param_amplitude is

    component fifo48 is
        Port (
            i_read      : in STD_LOGIC;
            i_write     : in STD_LOGIC;
            i_value     : in STD_LOGIC_VECTOR(23 downto 0);
            o_value     : out STD_LOGIC_VECTOR(23 downto 0);
            o_plein     : out STD_LOGIC;
            o_vide      : out STD_LOGIC
        );
    end component;

    signal clk_5Mhz : STD_LOGIC := '0';
    constant PERIOD_5MHZ : time := 200ns;
    signal vide : STD_LOGIC;
    signal plein : STD_LOGIC;
    
    type CLK_STATE is (
        CLK_START,
        CLK_STOP
    );
    signal state_clock : CLK_STATE := CLK_STOP;
    signal fifo_output : STD_LOGIC_VECTOR(23 downto 0) := (others=>'0');
    signal amplitude   : STD_LOGIC_VECTOR(23 downto 0) := (others=>'0');
    signal reset       : STD_LOGIC := '0';
    signal Aff_8Segment : STD_LOGIC_VECTOR(7 downto 0) := (others=>'0');
begin

    inst_fifo48 : fifo48 port map (
        i_read  => clk_5Mhz,
        i_write => i_dat_str,
        i_value => i_value,
        o_value => fifo_output,
        o_plein => plein,
        o_vide => vide
    );
    
    process_state_clk : PROCESS(plein, vide)
    begin
        if plein = '1' then
            state_clock <= CLK_START;
        elsif vide = '1' then
            state_clock <= CLK_STOP;
        end if;
    end PROCESS;
    
    clk_5Mhz <= not clk_5Mhz after PERIOD_5MHZ when state_clock = CLK_START
                else '0' when state_clock = CLK_STOP;

    comparateur : PROCESS(fifo_output, vide, plein)        
    begin
        if(signed(fifo_output) > signed(amplitude)) and (not rising_edge(plein)) then
            amplitude <= fifo_output;
        elsif(rising_edge(plein)) then
            amplitude <= x"000000";
        end if;
    end PROCESS;
    
    Aff_8Segment <= amplitude(23 downto 16) when rising_edge(vide);
    o_value <= Aff_8Segment;
    
end Behavioral;
