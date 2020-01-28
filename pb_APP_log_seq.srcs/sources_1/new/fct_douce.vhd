----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/25/2020 02:35:24 PM
-- Design Name: 
-- Module Name: fct_douce - Behavioral
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


LIBRARY ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fct_douce is
    Port (
        i_dat24: in std_logic_vector(23 downto 0);
        o_dat24: out std_logic_vector(23 downto 0)      
    );
end fct_douce;

architecture Behavioral of fct_douce is

    type table_fct_douce is array (integer range 0 to 95) of unsigned(23 downto 0);
    constant mem_fct_douce : table_fct_douce := (   
		x"200000",
		x"21025A",
		x"2202A9",
		x"22FEFD",
		x"23F592",
		x"24E4E1",
		x"25CBAE",
		x"26A909",
		x"277C4F",
		x"28451F",
		x"290357",
		x"29B707",
		x"2A6065",
		x"2AFFC8",
		x"2B9598",
		x"2C2250",
		x"2CA66F",
		x"2D2279",
		x"2D96F0",
		x"2E0455",
		x"2E6B24",
		x"2ECBD1",
		x"2F26CD",
		x"2F7C7E",
		x"2FCD47",
		x"301981",
		x"306180",
		x"30A591",
		x"30E5FC",
		x"312302",
		x"315CDF",
		x"3193CC",
		x"31C7FB",
		x"31F99C",
		x"3228DB",
		x"3255DE",
		x"3280CC",
		x"32A9C5",
		x"32D0EA",
		x"32F658",
		x"331A29",
		x"333C76",
		x"335D56",
		x"337CDE",
		x"339B22",
		x"33B835",
		x"33D427",
		x"33EF08",
		x"3408E7",
		x"3421D2",
		x"3439D5",
		x"3450FD",
		x"346755",
		x"347CE7",
		x"3491BC",
		x"34A5DF",
		x"34B958",
		x"34CC2E",
		x"34DE6A",
		x"34F013",
		x"35012F",
		x"3511C4",
		x"3521D9",
		x"353173",
		x"354098",
		x"354F4C",
		x"355D94",
		x"356B75",
		x"3578F3",
		x"358612",
		x"3592D6",
		x"359F42",
		x"35AB5A",
		x"35B721",
		x"35C29A",
		x"35CDC8",
		x"35D8AE",
		x"35E34F",
		x"35EDAC",
		x"35F7C9",
		x"3601A8",
		x"360B4B",
		x"3614B3",
		x"361DE4",
		x"3626DF",
		x"362FA5",
		x"363839",
		x"36409C",
		x"3648D0",
		x"3650D6",
		x"3658B0",
		x"36605F",
		x"3667E4",
		x"366F41",
		x"367677",
		x"367D88"


    --others => x"000000" 
    );
    
    signal index : signed(7 downto 0) := "00000000";
    signal index_neg : signed(7 downto 0) := "00000000";
    
    signal sim_i_dat24_base : signed(23 downto 0) := x"000000";
    signal sim_i_dat24_second : signed(23 downto 0) := x"000000";
    signal sim_abs : signed(23 downto 0) := x"000000";

    
    
    signal sortie : unsigned(23 downto 0) := x"000000";
    signal sortie_neg : STD_LOGIC_VECTOR(27 downto 0) := "0000000000000000000000000000";
    
    constant seuil_test : STD_LOGIC_VECTOR(7 downto 0) := "00100000";
    
    constant ZERO : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    constant UNITE : STD_LOGIC_VECTOR(7 downto 0) := x"01";
    constant UNITE_24b : unsigned(23 downto 0) := x"000001";
    constant SEUIL : unsigned(23 downto 0) := x"200000";
    constant SEUIL_C2 : unsigned(23 downto 0) := x"E00000"; 
    
    
begin
    sim_i_dat24_base <= signed(i_dat24);
    sim_i_dat24_second <= signed(i_dat24) - signed(SEUIL);
    sim_abs <= abs(sim_i_dat24_second);
    index <= signed(sim_abs(23 downto 16));
   -- index_neg <=
    
    
    
--and to_integer(unsigned(sim_i_dat24_base(23 downto 16))) < 96
    
    simple_function: process(sim_i_dat24_second, sim_i_dat24_base, index)
    begin
        if abs(signed(i_dat24)) < signed(SEUIL) then
            sortie <= unsigned(sim_i_dat24_base);
        elsif to_integer(unsigned(sim_i_dat24_second(23 downto 16))) < 96 then
            sortie <=  mem_fct_douce(to_integer(unsigned(sim_i_dat24_second(22 downto 16))));
        else
            --sortie <= x"200000";
            
            sortie <= not (mem_fct_douce(to_integer(unsigned(160 - index)))) + UNITE_24b;

        end if;
    end PROCESS;
    

    
    o_dat24 <= STD_LOGIC_VECTOR(sortie);
    
   
end Behavioral;
