LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY sound IS
	PORT (
		CLOCK_50, CLOCK2_50, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT : IN STD_LOGIC;
		KEY : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		SW : IN STD_LOGIC_VECTOR(17 DOWNTO 0); 
		I2C_SDAT : INOUT STD_LOGIC;
		I2C_SCLK, AUD_DACDAT, AUD_XCK : OUT STD_LOGIC;
		LEDR : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
END sound;

ARCHITECTURE Behavior OF sound IS

 
	-- CODEC Cores. These will be included in your design as is
 
	COMPONENT clock_generator
		PORT (
			CLOCK2_50 : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			AUD_XCK : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT audio_and_video_config
		PORT (
			CLOCK_50, reset : IN STD_LOGIC;
			I2C_SDAT : INOUT STD_LOGIC;
			I2C_SCLK : OUT STD_LOGIC
		);
	END COMPONENT;
 
	COMPONENT audio_codec
		PORT (
			CLOCK_50, reset, read_s, write_s : IN STD_LOGIC;
			writedata_left, writedata_right : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
			AUD_ADCDAT, AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK : IN STD_LOGIC;
			read_ready, write_ready : OUT STD_LOGIC;
			readdata_left, readdata_right : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
			AUD_DACDAT : OUT STD_LOGIC
		);
	END COMPONENT;
	-- local signals and constants. You will want to add some stuff here
	--type song_arr is array of std_logic_vector(3 downto 0);
	SIGNAL reset : std_logic;
	SIGNAL slowclk: std_logic_vector(23 downto 0);
	SIGNAL read_s : std_logic;
	SIGNAL write_s : std_logic;
	SIGNAL writedata_left : std_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL writedata_right : std_LOGIC_VECTOR(23 DOWNTO 0);
 
	SIGNAL writedata_leftC4 : std_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL writedata_rightC4 : std_LOGIC_VECTOR(23 DOWNTO 0);
 
	SIGNAL writedata_leftD4 : std_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL writedata_rightD4 : std_LOGIC_VECTOR(23 DOWNTO 0);
 
	SIGNAL writedata_leftE4 : std_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL writedata_rightE4 : std_LOGIC_VECTOR(23 DOWNTO 0);
 
	SIGNAL writedata_leftF4 : std_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL writedata_rightF4 : std_LOGIC_VECTOR(23 DOWNTO 0);

	SIGNAL writedata_leftG4 : std_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL writedata_rightG4 : std_LOGIC_VECTOR(23 DOWNTO 0);
 
	SIGNAL writedata_leftA4 : std_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL writedata_rightA4 : std_LOGIC_VECTOR(23 DOWNTO 0);

	SIGNAL writedata_leftB4 : std_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL writedata_rightB4 : std_LOGIC_VECTOR(23 DOWNTO 0);
 
	SIGNAL writedata_leftC5 : std_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL writedata_rightC5 : std_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL notes : std_LOGIC_VECTOR(17 DOWNTO 0);
 
	SIGNAL readdata_left : std_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL readdata_right : std_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL read_ready : std_logic;
	SIGNAL write_ready : std_logic;
	SIGNAL state : std_logic;
	SIGNAL stateD4 : std_logic;
	SIGNAL stateE4 : std_logic;
	SIGNAL stateF4 : std_logic;
	SIGNAL stateG4 : std_logic;
	SIGNAL stateA4 : std_logic;
	SIGNAL stateB4 : std_logic;
	SIGNAL stateC5 : std_logic;
	--SIGNAL notes : song_arr := ("0001","0010","0100","0001","0010","0100","0100","0100","0100","0100","0010","0010","0010","0010", "0001","0010","0100")
	
	SIGNAL counters : std_logic_vector(4 downto 0):= "00000"; 
	--signal AUD_ADCDAT,AUD_BCLK,AUD_ADCLRCK,AUD_DACLRCK: std_LOGIC;
	--constant UPPER_PEAK : signed;
	--constant LOWER_PEAK : std_LOGIC_VECTOR(23 downto 0):= "000000000000000000000000";
	--Signal slwClkCtr: std_logic_vector(2 downto 0);

 
BEGIN
	-- The audio core requires an active high reset signal

	reset <= NOT(KEY(3));
	LEDR(0) <= write_ready;
 
 
	-- we will never read from the microphone in this lab, so we might as well set read_s to 0.

	read_s <= '0';

	-- instantiate the parts of the audio core.
 
	my_clock_gen : clock_generator
	PORT MAP(CLOCK2_50, reset, AUD_XCK);
	cfg : audio_and_video_config
	PORT MAP(CLOCK_50, reset, I2C_SDAT, I2C_SCLK);
	codec : audio_codec
	PORT MAP(CLOCK_50, reset, read_s, write_s, writedata_left, writedata_right, AUD_ADCDAT, AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK, read_ready, write_ready, readdata_left, readdata_right, AUD_DACDAT);
--slwClkCtr <= slwClkCtr + '1' when rising_edge(CLOCK_50);
 
-- the rest of your code goes here
PROCESS (CLOCK_50)

VARIABLE counterC4 : INTEGER := 0;
VARIABLE counterD4 : INTEGER := 0;
VARIABLE counterE4 : INTEGER := 0;
VARIABLE counterF4 : INTEGER := 0;
VARIABLE counterG4 : INTEGER := 0;
VARIABLE counterA4 : INTEGER := 0;
VARIABLE counterB4 : INTEGER := 0;
VARIABLE counterC5 : INTEGER := 0;

VARIABLE PEAK : SIGNED(23 DOWNTO 0) := "000001000000000000000000";
--variable state : std_LOGIC := '0';

BEGIN
	
		--IF reset = '1' THEN
			--counterC4 := 0;
			--counterD4 := 0;
			--counterE4 := 0;
			--counterF4 := 0;
			--counterG4 := 0;
			--counterA4 := 0;
			--counterB4 := 0;
			--counterC5 := 0;
			------------------------------------THE RIGHT NOTE
		IF rising_edge(CLOCK_50) THEN
			if(write_ready = '0' AND write_s = '1') then
				if(notes(7) = '1') then
					IF (counterC4 < 168 AND counterC4 >= 0) THEN
						writedata_leftC4 <= STD_LOGIC_VECTOR(PEAK);
						writedata_rightC4 <= STD_LOGIC_VECTOR(PEAK);
						counterC4 := counterC4 + 1;
					ELSIF (counterC4 >= 168) AND (counterC4 < 336) THEN
						writedata_leftC4 <= STD_LOGIC_VECTOR( - peak);
						writedata_rightC4 <= STD_LOGIC_VECTOR( - peak);
						counterC4 := counterC4 + 1;
					ELSE
						counterC4 := 0;
					END IF;
				end if;
			--end if;
		
			------------------------------------------D4------------------------------
 
 		--IF rising_edge(CLOCK_50) THEN
			--if(write_ready = '0' AND write_s = '1') then
				if(notes(6) = '1') then
					IF (counterD4 < 150 AND counterD4 >= 0) THEN
						writedata_leftD4 <= STD_LOGIC_VECTOR(PEAK);
						writedata_rightD4 <= STD_LOGIC_VECTOR(PEAK);
						counterD4 := counterD4 + 1;
					ELSIF (counterD4 >= 150) AND (counterD4 < 300) THEN
						writedata_leftD4 <= STD_LOGIC_VECTOR( - peak);
						writedata_rightD4 <= STD_LOGIC_VECTOR( - peak);
						counterD4 := counterD4 + 1;
					ELSE
						counterD4 := 0;
					--END IF;
				end if;
			end if;
		
		

 
 
			------------------------------------------E4------------------------------
 
  		--IF rising_edge(CLOCK_50) THEN
		--	if(write_ready = '0' AND write_s = '1') then
				if(notes(5) = '1') then 
					IF (counterE4 < 134 AND counterE4 >= 0) THEN
						writedata_leftE4 <= STD_LOGIC_VECTOR(PEAK);
						writedata_rightE4 <= STD_LOGIC_VECTOR(PEAK);
						counterE4 := counterE4 + 1;
					ELSIF (counterE4 >= 134) AND (counterE4 < 267) THEN
						writedata_leftE4 <= STD_LOGIC_VECTOR( - peak);
						writedata_rightE4 <= STD_LOGIC_VECTOR( - peak);
						counterE4 := counterE4 + 1;
					ELSE
						counterE4 := 0;
				--	END IF;
				end if;
			end if;
		
		
 
	

 
			------------------------------------------F4------------------------------
 
 

					
		--IF rising_edge(CLOCK_50) THEN
		--	if(write_ready = '0' AND write_s = '1') then
				if(notes(4) = '1') then
					IF (counterF4 < 126 AND counterF4 >= 0) THEN
						writedata_leftF4 <= STD_LOGIC_VECTOR(PEAK);
						writedata_rightF4 <= STD_LOGIC_VECTOR(PEAK);
						counterF4 := counterF4 + 1;
					ELSIF (counterF4 >= 126) AND (counterF4 < 252) THEN
						writedata_leftF4 <= STD_LOGIC_VECTOR( - peak);
						writedata_rightF4 <= STD_LOGIC_VECTOR( - peak);
						counterF4 := counterF4 + 1;
					ELSE
						counterF4 := 0;
				--	END IF;
				end if;
			end if;
		

 
			------------------------------------------G4------------------------------
 

					
		--IF rising_edge(CLOCK_50) THEN
			--if(write_ready = '0' AND write_s = '1') then
				if(notes(3) = '1' OR SW(3) = '1') then
					IF (counterG4 < 113 AND counterG4 >= 0) THEN
						writedata_leftG4 <= STD_LOGIC_VECTOR(PEAK);
						writedata_rightG4 <= STD_LOGIC_VECTOR(PEAK);
						counterG4 := counterG4 + 1;
					ELSIF (counterG4 >= 113) AND (counterG4 < 225) THEN
						writedata_leftG4 <= STD_LOGIC_VECTOR( - peak);
						writedata_rightG4 <= STD_LOGIC_VECTOR( - peak);
						counterG4 := counterG4 + 1;
					ELSE
						counterG4 := 0;
					--END IF;
				end if;
			end if;
	


 
			------------------------------------------A4------------------------------
 
 

					
		--IF rising_edge(CLOCK_50) THEN
			--if(write_ready = '0' AND write_s = '1') then
				if(notes(2) = '1') then
					IF (counterA4 < 101 AND counterA4 >= 0) THEN
						writedata_leftA4 <= STD_LOGIC_VECTOR(PEAK);
						writedata_rightA4 <= STD_LOGIC_VECTOR(PEAK);
						counterA4 := counterA4 + 1;
					ELSIF (counterA4 >= 101) AND (counterA4 < 201) THEN
						writedata_leftA4 <= STD_LOGIC_VECTOR( - peak);
						writedata_rightA4 <= STD_LOGIC_VECTOR( - peak);
						counterA4 := counterA4 + 1;
					ELSE
						counterA4 := 0;
					--END IF;
				end if;
			end if;
	

			------------------------------------------B4------------------------------
 
 

		--IF rising_edge(CLOCK_50) THEN
			--if(write_ready = '0' AND write_s = '1') then
				if(notes(1) = '1') then
					IF (counterB4 < 90 AND counterB4 >= 0) THEN
						writedata_leftB4 <= STD_LOGIC_VECTOR(PEAK);
						writedata_rightB4 <= STD_LOGIC_VECTOR(PEAK);
						counterB4 := counterB4 + 1;
					ELSIF (counterB4 >= 90) AND (counterB4 < 179) THEN
						writedata_leftB4 <= STD_LOGIC_VECTOR( - peak);
						writedata_rightB4 <= STD_LOGIC_VECTOR( - peak);
						counterB4 := counterB4 + 1;
					ELSE
						counterB4 := 0;
					--END IF;
				end if;
			end if;
	


			------------------------------------------C5------------------------------
 

		--IF rising_edge(CLOCK_50) THEN
			--if(write_ready = '0' AND write_s = '1') then
				if(notes(0) = '1') then
					IF (counterC5 < 85 AND counterC5 >= 0) THEN
						writedata_leftC5 <= STD_LOGIC_VECTOR(PEAK);
						writedata_rightC5 <= STD_LOGIC_VECTOR(PEAK);
						counterC5 := counterC5 + 1;
					ELSIF (counterC5 >= 85) AND (counterC5 < 169) THEN
						writedata_leftC5 <= STD_LOGIC_VECTOR( - peak);
						writedata_rightC5 <= STD_LOGIC_VECTOR( - peak);
						counterC5 := counterC5 + 1;
					ELSE
						counterC5 := 0;
					END IF;
				end if;
			end if;
		writedata_left <= writedata_leftC4 + writedata_leftD4 + writedata_leftE4 + writedata_leftF4 + writedata_leftG4 + writedata_leftA4 + writedata_leftB4 + writedata_leftC5;
		writedata_right <= writedata_rightC4 + writedata_rightD4 + writedata_rightE4 + writedata_rightF4 + writedata_rightG4 + writedata_rightA4 + writedata_rightB4 + writedata_rightC5;

		
		
		
			
	
		
	end if;
-- EDEDEBDCA



END PROCESS; 



PROCESS (CLOCK_50)
BEGIN
	IF rising_edge(CLOCK_50) then
		write_s <= write_ready;
		slowclk <= slowclk + '1';
	end if;
	
--	write_ready = '1' THEN
-- 
--		write_s <= '1';
--	ELSE
--		write_s <= '0';
-- 
-- 
--	END IF;

END PROCESS; 
process(slowclk(23))
BEGIN
	if rising_edge(slowclk(23)) THEN
		counters <= counters + '1';
	end if;
	if(counters = 0) THEN
		notes(7) <= '1';
	end if;
	if(counters = 1) THEN
		notes(7) <= '0';
		notes(6) <= '1';
	end if;
	if(counters = 2) THEN
		notes(6) <= '0';
		notes(5) <= '1';
	end if;
	if(counters = 3) THEN
		notes(5) <= '0';
		notes(7) <= '1';
	end if;
	if(counters = 4) THEN
		notes(7) <= '0';
		notes(6) <= '1';
	end if;
	if(counters = 5) THEN
		notes(6) <= '0';
		notes(5) <= '1';
	end if;
	if(counters = 6) THEN
		notes(5) <= '1';
	end if;
	if(counters = 7) THEN
		notes(5) <= '0';
		notes(6) <= '1';
	end if;
	if(counters = 8) THEN
		notes(6) <= '0';
		notes(7) <= '1';
	end if;
	if(counters = 9) THEN
		notes(7) <= '0';
		notes(6) <= '1';
	end if;
	if(counters = 10) THEN
		notes(6) <= '0';
		notes(5) <= '1';
		counters <= "00000";
	end if;
end process;
	
		
		
		

 
 
 
END;
