----------------------------------------------------------------------------------
-- Author : Mr.Pisith Theplib
-- Computer Engineering
-- Create Date:    21:09:20 05/14/2018 
-- Module Name:    CheckKeypad
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CheckKeypad is
    Port ( CLK20MHz : in  STD_LOGIC;
           Column : in  STD_LOGIC_VECTOR(3 downto 0);
			  isPress : out  STD_LOGIC;
           Output : out  STD_LOGIC_VECTOR (3 downto 0);
			  Buzzer	: out	 STD_LOGIC;
           Row : out  STD_LOGIC_VECTOR (3 downto 0));
end CheckKeypad;

architecture Behavioral of CheckKeypad is

-----------------------------------------------------------
--------------- Signal for Clock Divider ------------------
-----------------------------------------------------------
	signal	sCountDivider		:	STD_LOGIC_VECTOR(19 downto 0);
	signal	sPulse				:	STD_LOGIC;
	signal	sCLK250Hz			:	STD_LOGIC;
	
-----------------------------------------------------------
---------------- Signal for Scan Column -------------------
-----------------------------------------------------------
	signal	sScanRow				:	STD_LOGIC_VECTOR(3 downto 0);
	signal	sScanCounter		:	STD_LOGIC_VECTOR(1 downto 0);
	
-----------------------------------------------------------
---------------- Signal for Output Press ------------------
-----------------------------------------------------------
	signal	sIsPress				:	STD_LOGIC;
	signal	sOutput				:	STD_LOGIC_VECTOR(3 downto 0);
	
-----------------------------------------------------------
------------------ State Declaration ----------------------
-----------------------------------------------------------
	TYPE		State_type 	is (CheckRow1, CheckRow2, CheckRow3, CheckRow4);
	signal	State			:	State_type;

begin

--------------------------------------------- Clock Divider to 250 Hz ---------------------------------------------

-----------------------------------------------------------
------------------------ Counter --------------------------
-----------------------------------------------------------
	Counter	:	Process(CLK20MHz)
	begin
		if(rising_edge(CLK20MHz)) then
			if(sCountDivider = x"C34FF") then -- HIGH for 2ms and LOW for 2ms
				sCountDivider(19 downto 0)		<=		(others => '0');	-- Reset Counter
			else
				sCountDivider(19 downto 0)		<=		sCountDivider(19 downto 0) + 1;
			end if;
		end if;
	end process Counter;

-----------------------------------------------------------
-------------------- Create a pulse -----------------------
-----------------------------------------------------------
	sPulse		<=		'1' when sCountDivider = x"C34FF" else '0';
	
-----------------------------------------------------------
---------------------- T Flip-Flop ------------------------
-----------------------------------------------------------
	TFlipFlop	:	Process(sPulse)
	begin
		if(rising_edge(sPulse)) then -- sPulse = '1'
			sCLK250Hz		<=		not sCLK250Hz;
		end if;
	end process TFlipFlop;

--------------------------------------------- Start Process State Machine ---------------------------------------------

	StateMachine	:	process(sCLK250Hz)
	begin
		if(rising_edge(sCLK250Hz)) then
			case (State) is
				----------------- State CheckRow1 -----------------
				when CheckRow1	=>
					--if(rising_edge(CLK20MHz)) then
						if(Column = "0000") then
							State		<=		CheckRow2;
						else
							State		<=		CheckRow1;
						end if;
					--end if;
				---------------------------------------------------
				----------------- State CheckRow2 -----------------
				when CheckRow2	=>
					--if(rising_edge(CLK20MHz)) then
						if(Column = "0000") then
							State		<=		CheckRow3;
						else
							State		<=		CheckRow2;
						end if;
					--end if;
				---------------------------------------------------
				----------------- State CheckRow3 -----------------
				when CheckRow3	=>
					--if(rising_edge(CLK20MHz)) then
						if(Column = "0000") then
							State		<=		CheckRow4;
						else
							State		<=		CheckRow3;
						end if;
					--end if;
				---------------------------------------------------
				----------------- State CheckRow4 -----------------
				when CheckRow4	=>
					--if(rising_edge(CLK20MHz)) then
						if(Column = "0000") then
							State		<=		CheckRow1;
						else
							State		<=		CheckRow4;
						end if;
					--end if;
				------------------ State Others -------------------
				--when others	=>
					--State		<=		CheckRow1;
			end case;
		end if;
	end process;
	
------------------------------------------- End Process State Machine -----------------------------------------

----------------------------------------------- Start Scan Row ------------------------------------------------

	sScanRow			<=				"1000"	when	State = CheckRow1 else
										"0100"	when	State = CheckRow2 else
										"0010"	when	State = CheckRow3 else
										"0001";
										
------------------------------------------------ End Scan Row -------------------------------------------------

------------------------------------------- Start Process CheckPress ------------------------------------------
	
	CheckPress	:	Process(Column, State)
	begin
		------------- Check Row if = "0000" is not Press -------------
		if(Column = "0000") then 
			sIsPress <= '0';
			sOutput	<=	"0000";
		--------------------------------------------------------------
		--------------- Check Row if /= "0000" is Press --------------
		else
			sIsPress	<=	'1';
			-------------- In State CheckRow1 --------------
			if(State = CheckRow1) then
				if(Column = "1000") then sOutput <=	"0000";		-- Press Number 1
				elsif(Column = "0100") then sOutput	<=	"0001";	-- Press Number 2
				elsif(Column = "0010") then sOutput	<=	"0010";	-- Press Number 3
				elsif(Column = "0001") then sOutput <= "0011";	-- Press Character A
				else sOutput <= "0000";
				end if;					
			------------------------------------------------
			-------------- In State CheckRow2 --------------
			elsif(State = CheckRow2) then
				if(Column = "1000") then sOutput	<=	"0100";		-- Press Number 4
				elsif(Column = "0100") then sOutput	<=	"0101";	-- Press Number 5
				elsif(Column = "0010") then sOutput	<=	"0110";	--	Press Number 6
				elsif(Column = "0001") then sOutput <= "0111";	-- Press Character B
				else sOutput <= "0000";
				end if;					
			------------------------------------------------
			-------------- In State CheckRow3 --------------
			elsif(State = CheckRow3) then
				if(Column = "1000") then sOutput	<=	"1000";		-- Press Number 7
				elsif(Column = "0100") then sOutput	<=	"1001";	-- Press Number 8
				elsif(Column = "0010") then sOutput	<=	"1010";	-- Press Number 9
				elsif(Column = "0001") then sOutput <= "1011";	-- Press Character C
				else sOutput <= "0000";
				end if;					
			------------------------------------------------
			-------------- In State CheckRow4 --------------
			elsif(State = CheckRow4) then
				if(Column = "1000") then sOutput	<=	"1100";		-- Press Character *
				elsif(Column = "0100") then sOutput	<=	"1101";	-- Press Number 0
				elsif(Column = "0010") then sOutput	<=	"1110";	-- Press Character #
				elsif(Column = "0001") then sOutput <= "1111";	-- Press Character D
				else sOutput <= "0000";
				end if;						
			------------------------------------------------
			end if;
		end if;
	end process;
		
-------------------------------------------- End Process CheckPress -------------------------------------------

---------------------------------------------- Output Assignment ----------------------------------------------
	isPress		<=			sIsPress;
	Output		<=			sOutput;
	Row			<=			sScanRow;
	Buzzer		<=			sIsPress;

end Behavioral;