----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:02:47 05/18/2018 
-- Design Name: 
-- Module Name:    checkWin - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity checkWin is																			-- 1, 0
    Port ( LED00, LED01, LED02, LED03 : in  STD_LOGIC_VECTOR (1 downto 0); -- R, G
           LED10, LED11, LED12, LED13 : in  STD_LOGIC_VECTOR (1 downto 0);
           LED20, LED21, LED22, LED23 : in  STD_LOGIC_VECTOR (1 downto 0);
           LED30, LED31, LED32, LED33 : in  STD_LOGIC_VECTOR (1 downto 0);
           winType : out  STD_LOGIC_VECTOR (3 downto 0);
           whoWin : out  STD_LOGIC;
           isWin : out  STD_LOGIC);
end checkWin;

architecture Behavioral of checkWin is

	signal logicTypeG01 : STD_LOGIC;
	signal logicTypeG02 : STD_LOGIC;
	signal logicTypeG03 : STD_LOGIC;
	signal logicTypeG04 : STD_LOGIC;
	signal logicTypeG05 : STD_LOGIC;
	signal logicTypeG06 : STD_LOGIC;
	signal logicTypeG07 : STD_LOGIC;
	signal logicTypeG08 : STD_LOGIC;
	signal logicTypeG09 : STD_LOGIC;
	signal logicTypeG10 : STD_LOGIC;
	signal logicTypeG11 : STD_LOGIC;
	signal logicTypeG12 : STD_LOGIC;
	signal logicTypeG13 : STD_LOGIC;
	signal logicTypeG14 : STD_LOGIC;
	
	signal logicTypeR01 : STD_LOGIC;
	signal logicTypeR02 : STD_LOGIC;
	signal logicTypeR03 : STD_LOGIC;
	signal logicTypeR04 : STD_LOGIC;
	signal logicTypeR05 : STD_LOGIC;
	signal logicTypeR06 : STD_LOGIC;
	signal logicTypeR07 : STD_LOGIC;
	signal logicTypeR08 : STD_LOGIC;
	signal logicTypeR09 : STD_LOGIC;
	signal logicTypeR10 : STD_LOGIC;
	signal logicTypeR11 : STD_LOGIC;
	signal logicTypeR12 : STD_LOGIC;
	signal logicTypeR13 : STD_LOGIC;
	signal logicTypeR14 : STD_LOGIC;
	
	signal GreenWin : STD_LOGIC;
	signal RedWin : STD_LOGIC;
	
	signal winCase01 : STD_LOGIC;
	signal winCase02 : STD_LOGIC;
	signal winCase03 : STD_LOGIC;
	signal winCase04 : STD_LOGIC;
	signal winCase05 : STD_LOGIC;
	signal winCase06 : STD_LOGIC;
	signal winCase07 : STD_LOGIC;
	signal winCase08 : STD_LOGIC;
	signal winCase09 : STD_LOGIC;
	signal winCase10 : STD_LOGIC;
	signal winCase11 : STD_LOGIC;
	signal winCase12 : STD_LOGIC;
	signal winCase13 : STD_LOGIC;
	signal winCase14 : STD_LOGIC;
	
	
begin
----------------------------------------------------------------------
--                           Output Logic                           --
----------------------------------------------------------------------

	GreenWin <= logicTypeG01 or logicTypeG02 or logicTypeG03 or logicTypeG04 or
					logicTypeG05 or logicTypeG06 or logicTypeG07 or logicTypeG08 or
					logicTypeG09 or logicTypeG10 or logicTypeG11 or logicTypeG12 or
					logicTypeG13 or logicTypeG14;
					
	RedWin 	<= logicTypeR01 or logicTypeR02 or logicTypeR03 or logicTypeR04 or
					logicTypeR05 or logicTypeR06 or logicTypeR07 or logicTypeR08 or
					logicTypeR09 or logicTypeR10 or logicTypeR11 or logicTypeR12 or
					logicTypeR13 or logicTypeR14;
									  
	isWin <= RedWin or GreenWin;
	
	whoWin <= '1' when GreenWin = '1' else '0';
				 
	winType <= 	  "0001" when winCase01 = '1' else
				  "0010" when winCase02 = '1' else
				  "0011" when winCase03 = '1' else
				  "0100" when winCase04 = '1' else
				  "0101" when winCase05 = '1' else
				  "0110" when winCase06 = '1' else
				  "0111" when winCase07 = '1' else
				  "1000" when winCase08 = '1' else
				  "1001" when winCase09 = '1' else
				  "1010" when winCase10 = '1' else
				  "1011" when winCase11 = '1' else
				  "1100" when winCase12 = '1' else
				  "1101" when winCase13 = '1' else
				  "1110" when winCase14 = '1' else
				  "0000";
	
	winCase01 <= logicTypeG01 or logicTypeR01;
	winCase02 <= logicTypeG02 or logicTypeR02;
	winCase03 <= logicTypeG03 or logicTypeR03;
	winCase04 <= logicTypeG04 or logicTypeR04;
	winCase05 <= logicTypeG05 or logicTypeR05;
	winCase06 <= logicTypeG06 or logicTypeR06;
	winCase07 <= logicTypeG07 or logicTypeR07;
	winCase08 <= logicTypeG08 or logicTypeR08;
	winCase09 <= logicTypeG09 or logicTypeR09;
	winCase10 <= logicTypeG10 or logicTypeR10;
	winCase11 <= logicTypeG11 or logicTypeR11;
	winCase12 <= logicTypeG12 or logicTypeR12;
	winCase13 <= logicTypeG13 or logicTypeR13;
	winCase14 <= logicTypeG14 or logicTypeR14;

----------------------------------------------------------------------
--                            Green Logic                           --
----------------------------------------------------------------------

----------------------------- Row Checker ----------------------------

	logicTypeG01 <= LED00(0) and LED01(0) and LED02(0) and LED03(0);
	logicTypeG02 <= LED10(0) and LED11(0) and LED12(0) and LED13(0);
	logicTypeG03 <= LED20(0) and LED21(0) and LED22(0) and LED23(0);
	logicTypeG04 <= LED30(0) and LED31(0) and LED32(0) and LED33(0);
	
----------------------------- Col Checker ----------------------------

	logicTypeG05 <= LED00(0) and LED10(0) and LED20(0) and LED30(0);
	logicTypeG06 <= LED01(0) and LED11(0) and LED21(0) and LED31(0);
	logicTypeG07 <= LED02(0) and LED12(0) and LED22(0) and LED32(0);
	logicTypeG08 <= LED03(0) and LED13(0) and LED23(0) and LED33(0);
	
------------------------------ X Checker -----------------------------

	logicTypeG09 <= LED00(0) and LED11(0) and LED22(0) and LED33(0);  --- \ Check
	logicTypeG10 <= LED03(0) and LED12(0) and LED21(0) and LED30(0);  --- / Check

------------------------------ \ Checker -----------------------------

	logicTypeG11 <= LED01(0) and LED12(0) and LED23(0);  --- \ Top Check
	logicTypeG12 <= LED10(0) and LED21(0) and LED32(0);  --- \ Down Check
	
------------------------------ / Checker -----------------------------

	logicTypeG13 <= LED02(0) and LED11(0) and LED20(0);  --- / Top Check
	logicTypeG14 <= LED13(0) and LED22(0) and LED31(0);  --- / Down Check
	
----------------------------------------------------------------------
--                             Red Logic                            --
----------------------------------------------------------------------

----------------------------- Row Checker ----------------------------

	logicTypeR01 <= LED00(1) and LED01(1) and LED02(1) and LED03(1);
	logicTypeR02 <= LED10(1) and LED11(1) and LED12(1) and LED13(1);
	logicTypeR03 <= LED20(1) and LED21(1) and LED22(1) and LED23(1);
	logicTypeR04 <= LED30(1) and LED31(1) and LED32(1) and LED33(1);
	
----------------------------- Col Checker ----------------------------

	logicTypeR05 <= LED00(1) and LED10(1) and LED20(1) and LED30(1);
	logicTypeR06 <= LED01(1) and LED11(1) and LED21(1) and LED31(1);
	logicTypeR07 <= LED02(1) and LED12(1) and LED22(1) and LED32(1);
	logicTypeR08 <= LED03(1) and LED13(1) and LED23(1) and LED33(1);
	
------------------------------ X Checker -----------------------------

	logicTypeR09 <= LED00(1) and LED11(1) and LED22(1) and LED33(1);  --- \ Check
	logicTypeR10 <= LED03(1) and LED12(1) and LED21(1) and LED30(1);  --- / Check

------------------------------ \ Checker -----------------------------

	logicTypeR11 <= LED01(1) and LED12(1) and LED23(1);  --- \ Top Check
	logicTypeR12 <= LED10(1) and LED21(1) and LED32(1);  --- \ Down Check
	
------------------------------ / Checker -----------------------------

	logicTypeR13 <= LED02(1) and LED11(1) and LED20(1);  --- / Top Check
	logicTypeR14 <= LED13(1) and LED22(1) and LED31(1);  --- / Down Check
	
	
	
end Behavioral;

