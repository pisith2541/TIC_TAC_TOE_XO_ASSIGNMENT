library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity Tic_Tac_Toe_XO_Main is
	port ( clk20MHz      : in  std_logic; -- Clock 20 MHz
          resetBtn      : in  std_logic; -- Reset Button
          startBtn      : in  std_logic; -- Start Button
          xGiveupBtn    : in  std_logic; -- X Giveup Button
          oGiveupBtn    : in  std_logic; -- O Giveup Button 
			 columnKeypad  : in  std_logic_vector(3  downto 0);  -- Input from Keypad
			 rowKeypad     : out std_logic_vector(3  downto 0);  -- Output to Keypad
			 rgbLed        : out std_logic_vector(2  downto 0);  -- R,G,B for All LED
			 gndLed        : out std_logic_vector(17 downto 0); -- GND for All LED (18 LEDS)
			 Buzzer			: out std_logic);
end Tic_Tac_Toe_XO_Main;

architecture Behavioral of Tic_Tac_Toe_XO_Main is
	-- Clock Signal ----------------------------------------
	signal clk25Hz 		: std_logic; -- Clock for scan Keypad // Clock 25 Hz (40 ms) 20 MHz x 40 ms = (800,000 - 1) = 799,999 [C34FF]
	signal clk1000Hz		: std_logic; -- Clock for scan LED // Clock 1000 Hz (1 ms) 20 MHz x 1 ms = (20,000 - 1) = 19,999 [4E1F]
	signal clk500ms		: std_logic; -- Clock for Win LED
	-- Clock for scan LED
	signal sCounterScanLED	:	std_logic_vector(15 downto 0); -- Counter Clock Divider to 1000 Hz
	signal sPulse			: std_logic;
	signal sCounterMUX	: std_logic_vector(4 downto 0);
	--------------------------------------------------------
	-- Board LED Signal ------------------------------------
	-- 	  RC		 RC		 RC	   RC   ------------------
	-- | led00 | led01 | led 02 | led03 | ------------------
	-- | led10 | led11 | led 12 | led13 | ------------------
	-- | led20 | led21 | led 22 | led23 | ------------------
	-- | led30 | led31 | led 32 | led33 | ------------------
	--------------------------------------------------------
	-- LED Signal ------------------------------------------
	signal sLedX   : std_logic_vector(2 downto 0);
	signal sLedO   : std_logic_vector(2 downto 0);
	-- Row 0 -----------------------------------------------
	signal sLed00,sLed01,sLed02,sLed03 : std_logic_vector(2 downto 0);
	signal sBLed00,sBLed01,sBLed02,sBLed03 : std_logic_vector(2 downto 0);
	-- Row 1 -----------------------------------------------
	signal sLed10,sLed11,sLed12,sLed13 : std_logic_vector(2 downto 0);
	signal sBLed10,sBLed11,sBLed12,sBLed13 : std_logic_vector(2 downto 0);
	-- Row 2 -----------------------------------------------
	signal sLed20,sLed21,sLed22,sLed23 : std_logic_vector(2 downto 0);
	signal sBLed20,sBLed21,sBLed22,sBLed23 : std_logic_vector(2 downto 0);
	-- Row 3 -----------------------------------------------
	signal sLed30,sLed31,sLed32,sLed33 : std_logic_vector(2 downto 0);
	signal sBLed30,sBLed31,sBLed32,sBLed33 : std_logic_vector(2 downto 0);
	-- Common ----------------------------------------------
	signal sRGBLed : std_logic_vector(2  downto 0);
	signal sGndLed : std_logic_vector(17 downto 0);
	--------------------------------------------------------
	-- Keypad Set ------------------------------------------
	-- Key press => isKeyPress (0)[No press] , (1)[Press]
	-- 1  : 0000 , 2  : 0001 , 3  : 0010 , A  : 0011
	-- 4  : 0100 , 5  : 0101 , 6  : 0110 , B  : 0111
	-- 7  : 1000 , 8  : 1001 , 9  : 1010 , C  : 1011
	-- *  : 1100 , 0  : 1101 , #  : 1110 , D  : 1111
	--------------------------------------------------------
	-- Keypad Signal ---------------------------------------
	signal sKeypadIsPress  : std_logic; -- For Check now press or not press
	signal sKeypadBtnPress : std_logic_vector(3 downto 0); -- What button now press?
	signal sBuzzerKeypad	  : std_logic; -- Buzzer if Press Keypad
	signal sBuzzerWin		  : std_logic; -- Buzzer if Win
	signal sBuzzer			  : std_logic;
	--------------------------------------------------------
	-- Button Signal ---------------------------------------
	signal sResetBtn			:	std_logic;
	signal sStartBtn			:	std_logic;
	signal sXGiveupBtn		:	std_logic;
	signal sOGiveupBtn		:	std_logic;
	-- st Signal -------------------------------------------
	signal sXStatusEn : std_logic; -- Enable/Disable LED X Status
	signal sOStatusEn : std_logic; -- Enable/Disable LED O Status
	signal sDrawStatusEn : std_logic; -- Enable/Disable LED X Status & LED O Status
	signal sRoundCount : std_logic_vector(4 downto 0); -- Round count
	signal sRoundCountEn : std_logic;
	signal sLEDSuccessEn : std_logic;
	signal sSuccessOK : std_logic;
	--------------------------------------------------------
	signal sKeypad         : std_logic_vector(3 downto 0); -- Store last key press
	signal sKeypadEn       : std_logic; -- Enable/Disable to store last key press
	signal sLedOffEn		  : std_logic; -- Enable/Disable to off LED
	signal sVerifyKeypad   : std_logic_vector(3 downto 0);
	signal sVerifyKeypadEn : std_logic; 
	-- signal sSetLEDEn       : std_logic; -- Enable/Disable to set LED on board
	-- signal sVerifyOK       : std_logic; -- Enable/Disable to know already ok?
	-- signal sNewKeyOK       : std_logic; -- Enable/Disable to know already ok?
	-- signal sVerifySelect   : std_logic_vector(1 downto 0); -- Select state to go
	signal sCompareKeyEn   : std_logic; -- Enable/Disable to compare?
	-- signal sCompareKey     : std_logic; -- Compare lastKey = verifyKeypad ? => 0 : not equal , 1 : equal 
	signal sLedBlueOnEn    : std_logic;
	signal sLedBlueOffEn   : std_logic;
	signal sNewKeyEn	     : std_logic;
	--------------------------------------------------------
	signal sIsWin   : std_logic;
	signal sWhoWin  : std_logic;
	signal sWinType : std_logic_vector(3 downto 0);
	signal sWinBlueEn : std_logic;
	--------------------------------------------------------
	signal sRowKeypad : std_logic_vector(3 downto 0);
	--------------------------------------------------------
	-- State Name ------------------------------------------
	type StateType is ( stIdle,
							  stXStatus,
							  stOStatus,
							  stPlay,
							  stBlueOn,  --
							  stVerifyKey,
							  stCompare,
							  stSuccess,							  
							  stNewKey,
							  stBlueOff, --
							  stRoundUp,
							  stCheck,
							  stXWin,
							  stOWin,
							  stWin,
							  stDraw);
	signal State : StateType;
	--------------------------------------------------------
	-- Component Clock divider to 500ms --------------------
	component ClockDividerTo500ms is
    Port ( CLK20MHz : in  STD_LOGIC;
           Output : out  STD_LOGIC);
	end component ClockDividerTo500ms;
	-- Component checkWin ----------------------------------
	component checkWin is																	-- 1, 0
    Port ( LED00, LED01, LED02, LED03 : in  STD_LOGIC_VECTOR (1 downto 0); -- R, G
           LED10, LED11, LED12, LED13 : in  STD_LOGIC_VECTOR (1 downto 0);
           LED20, LED21, LED22, LED23 : in  STD_LOGIC_VECTOR (1 downto 0);
           LED30, LED31, LED32, LED33 : in  STD_LOGIC_VECTOR (1 downto 0);
           winType : out  STD_LOGIC_VECTOR (3 downto 0);
           whoWin : out  STD_LOGIC;
           isWin : out  STD_LOGIC);
	end component;
	--------------------------------------------------------
	-- Component checkKeypad -------------------------------
	component CheckKeypad is
    Port ( CLK20MHz : in  STD_LOGIC;
           Column : in  STD_LOGIC_VECTOR(3 downto 0);
			  isPress : out  STD_LOGIC;
           Output : out  STD_LOGIC_VECTOR (3 downto 0);
			  Buzzer	: out  STD_LOGIC;
           Row : out  STD_LOGIC_VECTOR (3 downto 0));
	end component;
	--------------------------------------------------------
	-- Component Debounce Switch ---------------------------
	component SwitchDebounce is
    Port ( Input : in  STD_LOGIC;
           CLK20MHz : in  STD_LOGIC;
           Output : out  STD_LOGIC);
	end component SwitchDebounce;
begin
	
	-- Portmap DebounceSwitch ------------------------------
	ResetButtonDB		:	SwitchDebounce port map(Input => resetBtn, CLK20MHz => clk20MHz, Output => sResetBtn);
	StartButtonDB		:	SwitchDebounce port map(Input => startBtn, CLK20MHz => clk20MHz, Output => sStartBtn);
	XGiveUpButtonDB	:	SwitchDebounce port map(Input => xGiveupBtn, CLK20MHz => clk20MHz, Output => sXGiveupBtn);
	OGiveUpButtonDB	:	SwitchDebounce port map(Input => oGiveupBtn, CLK20MHz => clk20MHz, Output => sOGiveupBtn);
	ClockDevider500ms	:	ClockDividerTo500ms port map(CLK20MHz => clk20MHz, Output => clk500ms);
	
	-- Portmap checkWin ------------------------------------
		check_Win : checkWin
		port map ( LED00 => sLed00(2 downto 1), LED01 => sLed01(2 downto 1), LED02 => sLed02(2 downto 1), LED03 => sLed03(2 downto 1),			  
					  LED10 => sLed10(2 downto 1), LED11 => sLed11(2 downto 1), LED12 => sLed12(2 downto 1), LED13 => sLed13(2 downto 1),			  
					  LED20 => sLed20(2 downto 1), LED21 => sLed21(2 downto 1), LED22 => sLed22(2 downto 1), LED23 => sLed23(2 downto 1),  
					  LED30 => sLed30(2 downto 1), LED31 => sLed31(2 downto 1), LED32 => sLed32(2 downto 1), LED33 => sLed33(2 downto 1),
					  winType => sWinType,
					  whoWin  => sWhoWin,
					  isWin   => sIsWin);
	--------------------------------------------------------
	
	-- Portmap checkKeypad ---------------------------------
	 Check_Keypad : CheckKeypad 
    port map ( CLK20MHz => clk20MHz,
				   Column   => columnKeypad,
				   isPress  => sKeypadIsPress,
				   Output   => sKeypadBtnPress,
					Buzzer	=> sBuzzerKeypad,
				   Row      => sRowKeypad);
	--------------------------------------------------------
	
	-- Process of State ------------------------------------
	Process (clk20MHz,sResetBtn,sXGiveupBtn,sOGiveupBtn)
	Begin
		
			if ( sResetBtn = '1' ) then
				State <= stIdle;
			else
				if ( rising_edge(clk20MHz) ) then
					case ( State ) is
						-- stIdle ----------------------------------------------
						when stIdle =>
							if ( sXStatusEn = '1' ) then
								State <= stXStatus; -- Change to state stXStatus
							else
								if ( sStartBtn = '1' ) then -- Press Start Button
									sXStatusEn <= '1'; -- Enable to set LED X & Change State
								else -- Not press Start Button
									-- Reset all signal
									sXStatusEn <= '0'; -- Disable to set LED X & Change State
									sLed00 <= "000"; sLed01 <= "000"; sLed02 <= "000"; sLed03 <= "000";
									sLed10 <= "000"; sLed11 <= "000"; sLed12 <= "000"; sLed13 <= "000";
									sLed20 <= "000"; sLed21 <= "000"; sLed22 <= "000"; sLed23 <= "000";
									sLed30 <= "000"; sLed31 <= "000"; sLed32 <= "000"; sLed33 <= "000";
									sLedX <= "000";
									sLedO <= "000";
									sRoundCount <= "00000";
								end if;
							end if;
						--------------------------------------------------------
						-- stXStatus -------------------------------------------
						when stXStatus =>
							if ( sXStatusEn = '0' ) then
								State <= stPlay;
							else
								if ( sXStatusEn = '1' ) then
									sLedX <= "001";      -- Set LED X To Blue 
									sLedO <= "000";      -- Set LED O To None
									sKeypadEn    <= '1'; -- Set Keypad Enable
									sXStatusEn   <= '0'; -- Disable to set LED X & Change State 
								end if;
							end if;
						--------------------------------------------------------
						-- stOStatus -------------------------------------------
						when stOStatus =>
							if ( sOStatusEn = '0' ) then
								State <= stPlay;
							else
								if ( sOStatusEn = '1' ) then
									sLedX <= "000";      -- Set LED X To None 
									sLedO <= "001";      -- Set LED O To Blue
									sKeypadEn    <= '1'; -- Set Keypad Enable
									sOStatusEn   <= '0'; -- Disable to set LED X & Change State 
								end if;
							end if;
						--------------------------------------------------------
						-- stPlay ----------------------------------------------
						when stPlay =>
							if ( sKeypadEn = '0' ) then -- After Press on keypad
								State <= stBlueOn;
							else
								if ( sXGiveupBtn = '1' and sOGiveupBtn = '0' ) then
									State <= stOWin;
									sOStatusEn <= '1';
								elsif ( sXGiveupBtn = '0' and sOGiveupBtn = '1' ) then
									State <= stXWin;
									sXStatusEn <= '1';
								elsif ( sXGiveupBtn = '1' and sOGiveupBtn = '1' ) then
									State <= stDraw;
									sDrawStatusEn <= '1';
								else
									if ( sKeypadEn = '1' ) then
										if ( sKeypadIsPress = '1' ) then -- if press on keypad
											sKeypad         <= sKeypadBtnPress; -- Store keypad press
											sLedBlueOnEn	 <= '1';
											sKeypadEn		 <= '0';
										end if;
									end if;
								
								end if;
							end if;
						--------------------------------------------------------
						-- stBlueOn --------------------------------------------
						when stBlueOn =>
							if ( sLedBlueOnEn = '0' and sKeypadEn = '0') then
								State <= stVerifyKey;
							else
								-- Set on key to blue
								      if ( sKeypad = "0000" ) then if ( sLed00 = "000" ) then sLed00 <= "001"; sVerifyKeypadEn <= '1'; sLedBlueOnEn <= '0'; else sKeypadEn <= '1'; State <= stPlay; end if;
									elsif ( sKeypad = "0001" ) then if ( sLed01 = "000" ) then sLed01 <= "001"; sVerifyKeypadEn <= '1'; sLedBlueOnEn <= '0'; else sKeypadEn <= '1'; State <= stPlay; end if;
									elsif ( sKeypad = "0010" ) then if ( sLed02 = "000" ) then sLed02 <= "001"; sVerifyKeypadEn <= '1'; sLedBlueOnEn <= '0'; else sKeypadEn <= '1'; State <= stPlay; end if;
									elsif ( sKeypad = "0011" ) then if ( sLed03 = "000" ) then sLed03 <= "001"; sVerifyKeypadEn <= '1'; sLedBlueOnEn <= '0'; else sKeypadEn <= '1'; State <= stPlay; end if;
									elsif ( sKeypad = "0100" ) then if ( sLed10 = "000" ) then sLed10 <= "001"; sVerifyKeypadEn <= '1'; sLedBlueOnEn <= '0'; else sKeypadEn <= '1'; State <= stPlay; end if;
									elsif ( sKeypad = "0101" ) then if ( sLed11 = "000" ) then sLed11 <= "001"; sVerifyKeypadEn <= '1'; sLedBlueOnEn <= '0'; else sKeypadEn <= '1'; State <= stPlay; end if;
									elsif ( sKeypad = "0110" ) then if ( sLed12 = "000" ) then sLed12 <= "001"; sVerifyKeypadEn <= '1'; sLedBlueOnEn <= '0'; else sKeypadEn <= '1'; State <= stPlay; end if;
									elsif ( sKeypad = "0111" ) then if ( sLed13 = "000" ) then sLed13 <= "001"; sVerifyKeypadEn <= '1'; sLedBlueOnEn <= '0'; else sKeypadEn <= '1'; State <= stPlay; end if;
									
									elsif ( sKeypad = "1000" ) then if ( sLed20 = "000" ) then sLed20 <= "001"; sVerifyKeypadEn <= '1'; sLedBlueOnEn <= '0'; else sKeypadEn <= '1'; State <= stPlay; end if;
									elsif ( sKeypad = "1001" ) then if ( sLed21 = "000" ) then sLed21 <= "001"; sVerifyKeypadEn <= '1'; sLedBlueOnEn <= '0'; else sKeypadEn <= '1'; State <= stPlay; end if;
									elsif ( sKeypad = "1010" ) then if ( sLed22 = "000" ) then sLed22 <= "001"; sVerifyKeypadEn <= '1'; sLedBlueOnEn <= '0'; else sKeypadEn <= '1'; State <= stPlay; end if;
									elsif ( sKeypad = "1011" ) then if ( sLed23 = "000" ) then sLed23 <= "001"; sVerifyKeypadEn <= '1'; sLedBlueOnEn <= '0'; else sKeypadEn <= '1'; State <= stPlay; end if;
									
									elsif ( sKeypad = "1100" ) then if ( sLed30 = "000" ) then sLed30 <= "001"; sVerifyKeypadEn <= '1'; sLedBlueOnEn <= '0'; else sKeypadEn <= '1'; State <= stPlay; end if;
									elsif ( sKeypad = "1101" ) then if ( sLed31 = "000" ) then sLed31 <= "001"; sVerifyKeypadEn <= '1'; sLedBlueOnEn <= '0'; else sKeypadEn <= '1'; State <= stPlay; end if;
									elsif ( sKeypad = "1110" ) then if ( sLed32 = "000" ) then sLed32 <= "001"; sVerifyKeypadEn <= '1'; sLedBlueOnEn <= '0'; else sKeypadEn <= '1'; State <= stPlay; end if;
									elsif ( sKeypad = "1111" ) then if ( sLed33 = "000" ) then sLed33 <= "001"; sVerifyKeypadEn <= '1'; sLedBlueOnEn <= '0'; else sKeypadEn <= '1'; State <= stPlay; end if;
									end if;
							end if;
						--------------------------------------------------------
						-- stVerifyKey -----------------------------------------
						when stVerifyKey =>
								if ( sVerifyKeypadEn = '0' ) then
									State <= stCompare;
								else
									-- Get New keypad to confirm
									
									
									if ( sKeypadIsPress = '1' ) then -- if press on keypad 
										sVerifyKeypad   <= sKeypadBtnPress; -- Store new keypad press
										sCompareKeyEn   <= '1'; -- Enable to compare key
										sVerifyKeypadEn <= '0'; -- Disable to get new keypad
									end if;
								end if;
						--------------------------------------------------------	
						-- stCompare -------------------------------------------
						when stCompare =>
								if ( sCompareKeyEn = '1' and sVerifyKeypad = sKeypad) then
									sCompareKeyEn <= '0';
									sLEDSuccessEn <= '1';
									State <= stSuccess;
								else
									sCompareKeyEn <= '0';
									sLedBlueOffEn <= '1';
									State <= stBlueOff;
								end if;
						--------------------------------------------------------
						-- stBlueOff -------------------------------------------
						when stBlueOff =>
							if ( sLedBlueOffEn = '0' ) then
								sNewKeyEn <= '1';
								State <= stNewKey;
							else
										if ( sKeypad = "0000" ) then sLed00 <= "000"; sLedBlueOffEn <= '0'; 
									elsif ( sKeypad = "0001" ) then sLed01 <= "000"; sLedBlueOffEn <= '0';
									elsif ( sKeypad = "0010" ) then sLed02 <= "000"; sLedBlueOffEn <= '0';
									elsif ( sKeypad = "0011" ) then sLed03 <= "000"; sLedBlueOffEn <= '0';
									
									elsif ( sKeypad = "0100" ) then sLed10 <= "000"; sLedBlueOffEn <= '0';
									elsif ( sKeypad = "0101" ) then sLed11 <= "000"; sLedBlueOffEn <= '0';
									elsif ( sKeypad = "0110" ) then sLed12 <= "000"; sLedBlueOffEn <= '0';
									elsif ( sKeypad = "0111" ) then sLed13 <= "000"; sLedBlueOffEn <= '0';
									
									elsif ( sKeypad = "1000" ) then sLed20 <= "000"; sLedBlueOffEn <= '0';
									elsif ( sKeypad = "1001" ) then sLed21 <= "000"; sLedBlueOffEn <= '0';
									elsif ( sKeypad = "1010" ) then sLed22 <= "000"; sLedBlueOffEn <= '0';
									elsif ( sKeypad = "1011" ) then sLed23 <= "000"; sLedBlueOffEn <= '0';
									
									elsif ( sKeypad = "1100" ) then sLed30 <= "000"; sLedBlueOffEn <= '0';
									elsif ( sKeypad = "1101" ) then sLed31 <= "000"; sLedBlueOffEn <= '0';
									elsif ( sKeypad = "1110" ) then sLed32 <= "000"; sLedBlueOffEn <= '0';
									elsif ( sKeypad = "1111" ) then sLed33 <= "000"; sLedBlueOffEn <= '0';
									end if;
							end if;
						-- stNewKey --------------------------------------------
						when stNewKey =>
							if ( sNewKeyEn = '0' ) then -- After Press on keypad
								sLedBlueOnEn <= '1';
								State <= stBlueOn;
							else
								if ( sKeypadIsPress = '1' ) then -- if press on keypad
									sKeypad   <= sKeypadBtnPress; -- Store new keypad
									sNewKeyEn    <= '0';
								end if;
							end if;
						--------------------------------------------------------
						-- stSuccess -------------------------------------------
						when stSuccess =>
							if ( sLEDSuccessEn = '0' ) then -- After Press on keypad
								sRoundCountEn <= '1';
								State <= stRoundUp;
							else
									-- change to color x or o
									if ( sKeypad = "0000" )    then if ( sRoundCount(0) = '0' ) then sLed00 <= "100"; else sLed00 <= "010"; end if; 
									elsif ( sKeypad = "0001" ) then if ( sRoundCount(0) = '0' ) then sLed01 <= "100"; else sLed01 <= "010"; end if; 
									elsif ( sKeypad = "0010" ) then if ( sRoundCount(0) = '0' ) then sLed02 <= "100"; else sLed02 <= "010"; end if; 
									elsif ( sKeypad = "0011" ) then if ( sRoundCount(0) = '0' ) then sLed03 <= "100"; else sLed03 <= "010"; end if; 
									
									elsif ( sKeypad = "0100" ) then if ( sRoundCount(0) = '0' ) then sLed10 <= "100"; else sLed10 <= "010"; end if; 
									elsif ( sKeypad = "0101" ) then if ( sRoundCount(0) = '0' ) then sLed11 <= "100"; else sLed11 <= "010"; end if;
									elsif ( sKeypad = "0110" ) then if ( sRoundCount(0) = '0' ) then sLed12 <= "100"; else sLed12 <= "010"; end if;
									elsif ( sKeypad = "0111" ) then if ( sRoundCount(0) = '0' ) then sLed13 <= "100"; else sLed13 <= "010"; end if;
									
									elsif ( sKeypad = "1000" ) then if ( sRoundCount(0) = '0' ) then sLed20 <= "100"; else sLed20 <= "010"; end if;
									elsif ( sKeypad = "1001" ) then if ( sRoundCount(0) = '0' ) then sLed21 <= "100"; else sLed21 <= "010"; end if;
									elsif ( sKeypad = "1010" ) then if ( sRoundCount(0) = '0' ) then sLed22 <= "100"; else sLed22 <= "010"; end if;
									elsif ( sKeypad = "1011" ) then if ( sRoundCount(0) = '0' ) then sLed23 <= "100"; else sLed23 <= "010"; end if;
									
									elsif ( sKeypad = "1100" ) then if ( sRoundCount(0) = '0' ) then sLed30 <= "100"; else sLed30 <= "010"; end if;
									elsif ( sKeypad = "1101" ) then if ( sRoundCount(0) = '0' ) then sLed31 <= "100"; else sLed31 <= "010"; end if;
									elsif ( sKeypad = "1110" ) then if ( sRoundCount(0) = '0' ) then sLed32 <= "100"; else sLed32 <= "010"; end if;
									elsif ( sKeypad = "1111" ) then if ( sRoundCount(0) = '0' ) then sLed33 <= "100"; else sLed33 <= "010"; end if;
									end if;
									sLEDSuccessEn <= '0';
							end if;
						--------------------------------------------------------
						-- stRoundUp ---------------------------------------------
						when stRoundUp =>		
								if ( sRoundCountEn = '0' ) then -- After Press on keypad
									State <= stCheck;
								else
									sRoundCount   <= sRoundCount + 1;
									sRoundCountEn <= '0';
								end if;
						--------------------------------------------------------
						-- stCheck ---------------------------------------------
						when stCheck =>
							if ( sIsWin = '0' and sRoundCount(0) = '0' and sRoundCount /= "10000" ) then -- After Press on keypad
								sXStatusEn <= '1';
								State <= stXStatus;
							elsif ( sIsWin = '0' and sRoundCount(0) = '1' and sRoundCount /= "10000" ) then
								sOStatusEn <= '1';
								State <= stOStatus;
							elsif ( sIsWin = '0' and sRoundCount = "10000" ) then
								State <= stDraw;
								sDrawStatusEn <= '1';
							elsif ( sIsWin = '1' and sWhoWin = '0' ) then
								State <= stXWin;
								sXStatusEn <= '1';
							elsif ( sIsWin = '1' and sWhoWin = '1' ) then
								State <= stOWin;
								sOStatusEn <= '1';
							else
								State <= stCheck;
							end if;
						---------------------------------------------------------
						-- stXWin -----------------------------------------------
						when stXWin => 
							if ( sXStatusEn = '0') then
								State <= stWin;
							else
								sLedX <= "010";      -- Set LED X To Green 
								sLedO <= "100";      -- Set LED O To Red
								sWinBlueEn <= '1';
								sXStatusEn <= '0';
							end if;
						---------------------------------------------------------
						-- stOWin -----------------------------------------------
						when stOWin => 
							if ( sOStatusEn = '0') then
								State <= stWin;
							else
								sLedX <= "100";      -- Set LED X To Red 
								sLedO <= "010";      -- Set LED O To Green
								sWinBlueEn <= '1';
								sOStatusEn <= '0';
							end if;
						---------------------------------------------------------
						-- stWin ------------------------------------------------
						when stWin => 
							if ( sWinBlueEn <= '0' and sResetBtn = '1') then
								State <= stIdle;
							else
								-- Check Pattern
									sBuzzerWin	<=		clk500ms;
								   if ( sWinType = "0001" ) then
									-- row 00 01 02 03
									sLed00(2 downto 1) <= "00"; sLed01(2 downto 1) <= "00"; sLed02(2 downto 1) <= "00"; sLed03(2 downto 1) <= "00";
									sLed00(0) <= clk500ms; sLed01(0) <= clk500ms; sLed02(0) <= clk500ms; sLed03(0) <= clk500ms; 
								elsif ( sWinType = "0010" ) then
									-- row 10 11 12 13
									sLed10(2 downto 1) <= "00"; sLed11(2 downto 1) <= "00"; sLed12(2 downto 1) <= "00"; sLed13(2 downto 1) <= "00";
									sLed10(0) <= clk500ms; sLed11(0) <= clk500ms; sLed12(0) <= clk500ms; sLed13(0) <= clk500ms; 
								elsif ( sWinType = "0011" ) then
									-- row 20 21 22 23
									sLed20(2 downto 1) <= "00"; sLed21(2 downto 1) <= "00"; sLed22(2 downto 1) <= "00"; sLed23(2 downto 1) <= "00";
									sLed20(0) <= clk500ms; sLed21(0) <= clk500ms; sLed22(0) <= clk500ms; sLed23(0) <= clk500ms; 
								elsif ( sWinType = "0100" ) then
									-- row 30 31 32 33
									sLed30(2 downto 1) <= "00"; sLed31(2 downto 1) <= "00"; sLed32(2 downto 1) <= "00"; sLed33(2 downto 1) <= "00";
									sLed30(0) <= clk500ms; sLed31(0) <= clk500ms; sLed32(0) <= clk500ms; sLed33(0) <= clk500ms; 
								elsif ( sWinType = "0101" ) then
									-- col 00 10 20 30
									sLed00(2 downto 1) <= "00"; sLed10(2 downto 1) <= "00"; sLed20(2 downto 1) <= "00"; sLed30(2 downto 1) <= "00";
									sLed00(0) <= clk500ms; sLed10(0) <= clk500ms; sLed20(0) <= clk500ms; sLed30(0) <= clk500ms; 
								elsif ( sWinType = "0110" ) then
									-- col 01 11 21 31
									sLed01(2 downto 1) <= "00"; sLed11(2 downto 1) <= "00"; sLed21(2 downto 1) <= "00"; sLed31(2 downto 1) <= "00";
									sLed01(0) <= clk500ms; sLed11(0) <= clk500ms; sLed21(0) <= clk500ms; sLed31(0) <= clk500ms; 
								elsif ( sWinType = "0111" ) then
									-- col 02 12 22 32
									sLed02(2 downto 1) <= "00"; sLed12(2 downto 1) <= "00"; sLed22(2 downto 1) <= "00"; sLed32(2 downto 1) <= "00";
									sLed02(0) <= clk500ms; sLed12(0) <= clk500ms; sLed22(0) <= clk500ms; sLed32(0) <= clk500ms; 
								elsif ( sWinType = "1000" ) then
									-- col 03 13 23 33
									sLed03(2 downto 1) <= "00"; sLed13(2 downto 1) <= "00"; sLed23(2 downto 1) <= "00"; sLed33(2 downto 1) <= "00";
									sLed03(0) <= clk500ms; sLed13(0) <= clk500ms; sLed23(0) <= clk500ms; sLed33(0) <= clk500ms; 
								elsif ( sWinType = "1001" ) then
									-- 00 11 22 33 
									sLed00(2 downto 1) <= "00"; sLed11(2 downto 1) <= "00"; sLed22(2 downto 1) <= "00"; sLed33(2 downto 1) <= "00";
									sLed00(0) <= clk500ms; sLed11(0) <= clk500ms; sLed22(0) <= clk500ms; sLed33(0) <= clk500ms; 
								elsif ( sWinType = "1010" ) then
									-- 03 12 21 30
									sLed03(2 downto 1) <= "00"; sLed12(2 downto 1) <= "00"; sLed21(2 downto 1) <= "00"; sLed30(2 downto 1) <= "00";
									sLed03(0) <= clk500ms; sLed12(0) <= clk500ms; sLed21(0) <= clk500ms; sLed30(0) <= clk500ms; 
								elsif ( sWinType = "1011" ) then
									-- 01 12 23
									sLed01(2 downto 1) <= "00"; sLed12(2 downto 1) <= "00"; sLed23(2 downto 1) <= "00";
									sLed01(0) <= clk500ms; sLed12(0) <= clk500ms; sLed23(0) <= clk500ms;
								elsif ( sWinType = "1100" ) then
									-- 10 21 32
									sLed10(2 downto 1) <= "00"; sLed21(2 downto 1) <= "00"; sLed32(2 downto 1) <= "00";
									sLed10(0) <= clk500ms; sLed21(0) <= clk500ms; sLed32(0) <= clk500ms;
								elsif ( sWinType = "1101" ) then
									-- 20 11 02
									sLed20(2 downto 1) <= "00"; sLed11(2 downto 1) <= "00"; sLed02(2 downto 1) <= "00";
									sLed20(0) <= clk500ms; sLed11(0) <= clk500ms; sLed02(0) <= clk500ms;
								elsif ( sWinType = "1110" ) then
									-- 31 22 13
									sLed31(2 downto 1) <= "00"; sLed22(2 downto 1) <= "00"; sLed13(2 downto 1) <= "00";
									sLed31(0) <= clk500ms; sLed22(0) <= clk500ms; sLed13(0) <= clk500ms;
								end if;
								
								sWinBlueEn <= '0';
							end if;
						---------------------------------------------------------
						-- stDraw -----------------------------------------------
						when stDraw => 
							if ( sDrawStatusEn = '0' and sResetBtn = '1') then
								State <= stIdle;
							else
								sLedX <= "001";      -- Set LED X To Blue 
								sLedO <= "001";      -- Set LED O To Blue
								sDrawStatusEn <= '0';
							end if;
						---------------------------------------------------------
						when others =>
							State <= stIdle;
					end case;
			end if;
		end if;
	End Process;
	--------------------------------------------------------
	-- Counter for Clock Divider to 1000 Hz ----------------
-----------------------------------------------------------
------------------------ Counter --------------------------
-----------------------------------------------------------
	CounterScanLED	:	Process(CLK20MHz)
	begin
		if(rising_edge(CLK20MHz)) then
			if(sCounterScanLED = x"270F") then -- HIGH for 2ms and LOW for 2ms
				sCounterScanLED(15 downto 0)		<=		(others => '0');	-- Reset Counter
			else
				sCounterScanLED(15 downto 0)		<=		sCounterScanLED(15 downto 0) + 1;
			end if;
		end if;
	end process CounterScanLED;

-----------------------------------------------------------
-------------------- Create a pulse -----------------------
-----------------------------------------------------------
	sPulse		<=		'1' when sCounterScanLED = x"270F" else '0';
	
-----------------------------------------------------------
---------------------- T Flip-Flop ------------------------
-----------------------------------------------------------
	TFlipFlop	:	Process(sPulse)
	begin
		if(rising_edge(sPulse)) then -- sPulse = '1'
			clk1000Hz		<=		not clk1000Hz;
		end if;
	end process TFlipFlop;
	
	-- Counter for MUX ----------------
	CounterMUX : process(clk1000Hz)
	begin
		if(rising_edge(clk1000Hz)) then
			if(sCounterMUX = "10001") then
				sCounterMUX(4 downto 0)		<=		(others => '0');
			else
				sCounterMUX			<=		sCounterMUX + 1;
			end if;
		end if;
	end process CounterMUX;
	
	-- MUX ----------------
	sRGBLed		<=		sLed00 when sCounterMUX = "00000" else
							sLed01 when sCounterMUX = "00001" else
							sLed02 when sCounterMUX = "00010" else
							sLed03 when sCounterMUX = "00011" else
							sLed10 when sCounterMUX = "00100" else
							sLed11 when sCounterMUX = "00101" else
							sLed12 when sCounterMUX = "00110" else
							sLed13 when sCounterMUX = "00111" else
							sLed20 when sCounterMUX = "01000" else
							sLed21 when sCounterMUX = "01001" else
							sLed22 when sCounterMUX = "01010" else
							sLed23 when sCounterMUX = "01011" else
							sLed30 when sCounterMUX = "01100" else
							sLed31 when sCounterMUX = "01101" else
							sLed32 when sCounterMUX = "01110" else
							sLed33 when sCounterMUX = "01111" else
							sLedX	 when sCounterMUX = "10000" else
							sLedO;
							
	-- Decoder 5:18 ----------------
	sGndLed		<=		"011111111111111111" when sCounterMUX = "00000" else
							"101111111111111111" when sCounterMUX = "00001" else
							"110111111111111111" when sCounterMUX = "00010" else
							"111011111111111111" when sCounterMUX = "00011" else
							"111101111111111111" when sCounterMUX = "00100" else
							"111110111111111111" when sCounterMUX = "00101" else
							"111111011111111111" when sCounterMUX = "00110" else
							"111111101111111111" when sCounterMUX = "00111" else
							"111111110111111111" when sCounterMUX = "01000" else
							"111111111011111111" when sCounterMUX = "01001" else
							"111111111101111111" when sCounterMUX = "01010" else
							"111111111110111111" when sCounterMUX = "01011" else
							"111111111111011111" when sCounterMUX = "01100" else
							"111111111111101111" when sCounterMUX = "01101" else
							"111111111111110111" when sCounterMUX = "01110" else
							"111111111111111011" when sCounterMUX = "01111" else
							"111111111111111101" when sCounterMUX = "10000" else
							"111111111111111110";
							
	sBuzzer	<=		sBuzzerWin or sBuzzerKeypad;
							
	-- Output Assignment -----------------------------------
	rgbLed    <= sRGBLed;  -- R,G,B for All LED
	gndLed    <= sGndLed; -- GND for All LED (18 LEDS)
	rowKeypad <= sRowKeypad;
	Buzzer	 <= sBuzzer;
	--------------------------------------------------------

end Behavioral;

