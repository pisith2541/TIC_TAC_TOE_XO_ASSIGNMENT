----------------------------------------------------------------------------------
-- University : King Mongkut's Institute of Technology Ladkrabang
-- Major	:	Computer Engineering
-- Author : Pisith Theplib
-- Create Date:    17:51:58 04/02/2018 
-- Project Name: BCD to 7 segment
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ClockDividerTo500ms is
    Port ( CLK20MHz : in  STD_LOGIC;
           Output : out  STD_LOGIC);
end ClockDividerTo500ms;

architecture Behavioral of ClockDividerTo500ms is

	signal sCount		:		STD_LOGIC_VECTOR(23 downto 0);
	signal sPulse		:		STD_LOGIC;
	signal sOutput		:		STD_LOGIC;

begin

-----------------------------------------------------------
------------------------ Counter --------------------------
-----------------------------------------------------------
	Counter	:	Process(CLK20MHz)
	begin
		if(rising_edge(CLK20MHz)) then
			if(sCount = x"5F5E0F") then -- HIGH for 250ms and LOW for 250ms
				sCount(23 downto 0)		<=		(others => '0');	-- Reset Counter
			else
				sCount(23 downto 0)		<=		sCount(23 downto 0) + 1;
			end if;
		end if;
	end process Counter;

-----------------------------------------------------------
-------------------- Create a pulse -----------------------
-----------------------------------------------------------
	sPulse		<=		'1' when sCount = x"5F5E0F" else '0';
	
-----------------------------------------------------------
---------------------- T Flip-Flop ------------------------
-----------------------------------------------------------
	TFlipFlop	:	Process(sPulse)
	begin
		if(rising_edge(sPulse)) then -- sPulse = '1'
			sOutput		<=		not sOutput;
		end if;
	end process TFlipFlop;
	
-----------------------------------------------------------
------------------ Output Assignment ----------------------
-----------------------------------------------------------
	Output		<=			sOutput;

end Behavioral;

