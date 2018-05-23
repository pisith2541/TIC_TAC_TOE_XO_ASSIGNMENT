----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:42:11 05/19/2018 
-- Design Name: 
-- Module Name:    SwitchDebounce - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SwitchDebounce is
    Port ( Input : in  STD_LOGIC;
           CLK20MHz : in  STD_LOGIC;
           Output : out  STD_LOGIC);
end SwitchDebounce;

architecture Behavioral of SwitchDebounce is

	signal	sCounter	:	STD_LOGIC_VECTOR(7 downto 0);
	signal	sOutput	:	STD_LOGIC;

begin

---------------------------------------------------------
---------------------- Counter --------------------------
---------------------------------------------------------
	Debounce	:	process(CLK20MHz)
	begin
		if(rising_edge(CLK20MHz)) then
			if(Input = '1') then
				if(sCounter = x"FF") then
					sCounter(7 downto 0)		<=		sCounter(7 downto 0);
				else
					sCounter(7 downto 0)		<=		sCounter(7 downto 0) + 1;
				end if;
			else
				sCounter(7 downto 0)		<=		(others => '0');
			end if;
		end if;
	end process Debounce;
	
---------------------------------------------------------
---------------------- Debounce -------------------------
---------------------------------------------------------
	sOutput		<=		'1' when sCounter = x"FF" else '0';
	
---------------------------------------------------------
------------------ Output Assignment --------------------
---------------------------------------------------------
	Output		<=		sOutput;


end Behavioral;

