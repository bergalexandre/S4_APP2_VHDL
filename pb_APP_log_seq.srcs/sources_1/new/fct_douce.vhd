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
    x"000000",
    x"010259",
    x"0202A9",
    x"02FEFD",
    x"03F592",
    x"04E4E1",
    x"05CBAE",
    x"06A909",
    x"077C4F",
    x"08451F",
    x"090357",
    x"09B707",
    x"0A6065",
    x"0AFFC8",
    x"0B9598",
    x"0C2250",
    x"0CA66F",
    x"0D2278",
    x"0D96F0",
    x"0E0455",
    x"0E6B23",
    x"0ECBD1",
    x"0F26CC",
    x"0F7C7E",
    x"0FCD47",
    x"101981",
    x"106180",
    x"10A591",
    x"10E5FC",
    x"112302",
    x"115CDF",
    x"1193CC",
    x"11C7FB",
    x"11F99C",
    x"1228DA",
    x"1255DE",
    x"1280CB",
    x"12A9C5",
    x"12D0EA",
    x"12F658",
    x"131A29",
    x"133C76",
    x"135D56",
    x"137CDE",
    x"139B22",
    x"13B835",
    x"13D427",
    x"13EF08",
    x"1408E7",
    x"1421D2",
    x"1439D5",
    x"1450FD",
    x"146755",
    x"147CE7",
    x"1491BC",
    x"14A5DF",
    x"14B958",
    x"14CC2E",
    x"14DE6A",
    x"14F013",
    x"15012E",
    x"1511C4",
    x"1521D9",
    x"153173",
    x"154098",
    x"154F4C",
    x"155D94",
    x"156B75",
    x"1578F3",
    x"158612",
    x"1592D6",
    x"159F42",
    x"15AB5A",
    x"15B721",
    x"15C29A",
    x"15CDC8",
    x"15D8AE",
    x"15E34E",
    x"15EDAC",
    x"15F7C9",
    x"1601A8",
    x"160B4A",
    x"1614B3",
    x"161DE4",
    x"1626DF",
    x"162FA5",
    x"163839",
    x"16409C",
    x"1648D0",
    x"1650D6",
    x"1658B0",
    x"16605E",
    x"1667E4",
    x"166F41",
    x"167677",
    x"167D88"

    --others => x"000000" 
    );
    
    signal index : signed(6 downto 0) := "0000000";
    signal sim_i_dat24 : signed(23 downto 0) := x"000000";
    
    
    signal sortie : unsigned(23 downto 0) := x"000000";
    signal sortie2 : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    
    
    constant ZERO : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    constant UNITE : STD_LOGIC_VECTOR(7 downto 0) := x"01";
    constant UNITE_24b : unsigned(23 downto 0) := x"000001";
    constant SEUIL : unsigned(23 downto 0) := x"200000";
    constant SEUIL_C2 : unsigned(23 downto 0) := x"d00000"; 
    
    
begin
    
    sim_i_dat24 <= signed(i_dat24);
    index <= abs(signed(sim_i_dat24(22 downto 16)));

    
    simple_function: process(sim_i_dat24, index)
    begin
        if abs(signed(sim_i_dat24)) < signed(SEUIL) then
            sortie <= unsigned(sim_i_dat24);
        elsif to_integer(sim_i_dat24(23 downto 16)) > 96 then
            sortie <= SEUIL_C2 + not (mem_fct_douce(to_integer(unsigned(index)))) + UNITE_24b;
        else
            sortie <=  SEUIL + mem_fct_douce(to_integer(unsigned(index(6 downto 0))));
        end if;
    end PROCESS;
    
    o_dat24 <= STD_LOGIC_VECTOR(sortie);
    
   
end Behavioral;
