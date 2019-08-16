----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:36:26 05/15/2019 
-- Design Name: 
-- Module Name:    ProjectCodeFinal - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
use IEEe.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity ProjectCodeFinal is
Generic (N : INTEGER:=50*10**6; -- 50*10^6 Hz Clock
			M : INTEGER := 65536;  --2^16
			P : INTEGER := 32768); --2^15
			--M and P constants are used in order to take mod of the counter module
			
    Port ( MCLK : in  STD_LOGIC;
           Guess : in  STD_LOGIC_VECTOR (7 downto 0);
           rButton : in  STD_LOGIC; --restart button 
           sButton : in  STD_LOGIC; --start button 
			  lower_button : in STD_LOGIC;
			  upper_button : in STD_LOGIC;
           gButton : in  STD_LOGIC; --guess button 
           SevenSegment : out  STD_LOGIC_VECTOR (6 downto 0);
           Leds : out  STD_LOGIC_VECTOR (7 downto 0);
           Anodes : out  STD_LOGIC_VECTOR (7 downto 0));
end ProjectCodeFinal;

architecture Behavioral of ProjectCodeFinal is
------------
-- intermediate signals
signal CLK_DIV : STD_LOGIC;
signal Res : STD_LOGIC_VECTOR(7 downto 0) := "00000000";  -- signal to store the resulting Guess

 --- FSM and 3 states declaration
constant start : STD_LOGIC_VECTOR (2 downto 0) := "001";
constant sLower : STD_LOGIC_VECTOR (2 downto 0) := "010";
constant sUpper : STD_LOGIC_VECTOR (2 downto 0) := "011";
constant init : STD_LOGIC_VECTOR (2 downto 0) := "100";
constant evaluate : STD_LOGIC_VECTOR (2 downto 0) := "101";
constant done : STD_LOGIC_VECTOR (2 downto 0) := "110";

--- the variable storing the state, initialized to start
signal state : STD_LOGIC_VECTOR (2 downto 0) := "001";
signal random_num : STD_LOGIC_VECTOR (7 downto 0) := "00000000";

-- constants
constant lower_bound : STD_LOGIC_VECTOR (7 downto 0) := "00000000"; --- 0
constant upper_bound : STD_LOGIC_VECTOR (7 downto 0) := "11111111"; -- 255

	component rgen
		port (r1 : out  STD_LOGIC_VECTOR (7 downto 0);
           MCLK : in  STD_LOGIC;
           rButton : in  STD_LOGIC; 
			  sButton : in STD_LOGIC); 
	end component;
	
	signal r1 : STD_LOGIC_VECTOR(7 downto 0);
	signal z1 : STD_LOGIC_VECTOR (3 downto 0);
	signal z2 : STD_LOGIC_VECTOR (3 downto 0);
	signal z3 : STD_LOGIC_VECTOR (3 downto 0);
	signal resB : STD_LOGIC_VECTOR (7 downto 0);
	signal resInBcd : STD_LOGIC_VECTOR (11 downto 0);
	
--- function to bcd
-- similar to the to_bcd function we did in lab 

	function to_bcd (bin : std_logic_vector (7 downto 0)) return std_logic_vector is
		variable i : integer:=0;
		variable bcd : std_logic_vector (11 downto 0) := (others => '0');
		variable bint : std_logic_vector (7 downto 0) := bin;
		
		begin
		for i in 0 to 7 loop -- repeat 8 times
			bcd (11 downto 1) := bcd (10 downto 0); -- shifting the bits
			bcd (0) := bint(7);
			bint (7 downto 1) := bint (6 downto 0);
			bint (0) := '0';

			if(i < 7 and bcd(3 downto 0) > "0100") then --add 3 if BCD digit is greater than 4.
			bcd(3 downto 0) := bcd(3 downto 0) + "0011";
			end if;

			if(i < 7 and bcd(7 downto 4) > "0100") then --add 3 if BCD digit is greater than 4.
			bcd(7 downto 4) := bcd(7 downto 4) + "0011";
			end if;

			if(i < 7 and bcd(11 downto 8) > "0100") then  --add 3 if BCD digit is greater than 4.
			bcd(11 downto 8) := bcd(11 downto 8) + "0011";
			end if;


		end loop;
		return bcd;
	end to_bcd;
	

------------
begin

	rg : rgen port map (r1, MCLK, rButton, sButton);
	
	--random_num <= r1; 	
	
	resInBcd <= to_bcd(Res);

	z1 <= resInBcd (11 downto 8);

	z2 <= resInBcd (7 downto 4);

	z3 <= resInBcd (3 downto 0);

-- Clock divider
process(MCLK)
	variable Counter : INTEGER range 0 to N;
	begin	
			if rising_edge(MCLK) then
				Counter := Counter + 1;
				 -- Clock frequency 1000/2 = 500Hz
				 if (Counter = N/100000-1) then -- as denomitar of N/100000000 gets bigger, the speed increases 
						Counter := 0;
						CLK_DIV <= not CLK_DIV;				
				 end if;
			end if;
	end process;
	

--- state transition
--- states are defined with the help of "when" 
process(CLK_DIV)
	begin	
		if rising_edge(MCLK) then
			case state is
				when start =>
					Res <= "00000000";
					Leds <= Res;
					if (sButton = '1') then
						random_num <= r1; --- "11001100";
					elsif (lower_button = '1') then
						state <= sLower;
					end if;		
					
				when sLower =>
					if (lower_button = '1') then
						Res <= lower_bound;
						Leds <= Res;
					elsif (upper_button = '1') then
						state <= sUpper;
					elsif (rButton = '1') then
						state <= start;
					else
						state <= sLower;
					end if;	
					
				when sUpper =>
					if (upper_button = '1') then
						Res <= upper_bound;
						Leds <= Res;
					end if;
					if (gButton = '1') then
						state <= init;
					elsif (rButton = '1') then
						state <= start;
					else
						state <= sUpper;
					end if;
					
				when init =>
					if (rButton = '1') then
						state <= start;
					elsif (gButton = '1') then
						state <= evaluate;
					else
						state <= init;
					end if;
					
				when evaluate =>
					if (Guess = random_num) then
						Leds <= Guess;
						state <= done;
					elsif (Guess < random_num) then
						Res <= Guess;
						Leds <= Res;
						state <= init;
					elsif (Guess > random_num) then
						Res <= Guess;
						Leds <= Res;
						state <= init;
					end if;
					if (rButton = '1') then
						state <= start;
					end if;
					
				when done =>
					Leds <= Guess;
					if (rButton = '1') then 
						state <= start;
					end if;
				when others =>
					state <= start;
			end case;
		end if;
	end process;


------
------------
-- Seven segment disp.
-- P is divided by 8 since there are 8 bits

  process(MCLK)

		variable Counter : INTEGER range 0 to M;
		begin                
			if(rising_edge(MCLK)) then
				Counter :=Counter+1;
				if(state = done )then
					if (Counter mod P =0) then
						Anodes <= "01111111";
						SevenSegment <= "0110001"; -- "C"
					elsif (Counter mod P =1*P/8) then
						Anodes <= "10111111";
						SevenSegment <= "0000001"; -- "O"
					elsif (Counter mod P =2*P/8) then
						Anodes <= "11011111";
						SevenSegment <= "0001001"; -- "N"
					elsif (Counter mod P =3*P/8) then
						Anodes <= "11101111";
						SevenSegment <= "0100000"; -- "G"
					elsif (Counter mod P =4*P/8) then
						Anodes <= "11110111";
						SevenSegment <= "0011001"; -- "R"
					elsif (Counter mod P =5*P/8) then
						Anodes <= "11111011";
						SevenSegment <= "0001000"; -- "A"
					elsif (Counter mod P =6*P/8) then
						Anodes <= "11111101";
						SevenSegment <= "1110000"; -- "t"
					elsif (Counter mod P =7*P/8) then
						Anodes <= "11111110";
						SevenSegment <= "0100100"; -- "s"
					end if;
				elsif (state = evaluate) then
					if (Guess < random_num) then
					
						-- display higher
							if (Counter mod P = 0) then
								Anodes <= "01111111";
								SevenSegment <= "1001000"; --H
							elsif (Counter mod P =1*P/8) then
								Anodes <= "10111111";
								SevenSegment <= "1001111"; -- "I"
							elsif (Counter mod P =2*P/8) then
								Anodes <= "11011111";
								SevenSegment <= "0100000"; -- "G"
							elsif (Counter mod P =3*P/8) then
								Anodes <= "11101111";
								SevenSegment <= "1001000"; -- "H"
							elsif (Counter mod P =4*P/8) then
								Anodes <= "11110111";
								SevenSegment <= "0110000"; -- "E"
							elsif (Counter mod P =5*P/8) then
								Anodes <= "11111011";
								SevenSegment <= "0011001"; -- "R"
							end if;
					elsif (Guess > random_num) then
					
						--display lower;
						if (Counter mod P = 0) then
							Anodes <= "01111111";
							SevenSegment <= "1110001"; --L
						elsif (Counter mod P =1*P/8) then
							Anodes <= "10111111";
							SevenSegment <= "0000001"; -- "O"
						elsif (Counter mod P =2*P/8) then
							Anodes <= "11011111";
							SevenSegment <= "1010100"; -- "W"
						elsif (Counter mod P =3*P/8) then
							Anodes <= "11101111";
							SevenSegment <= "0110000"; -- "E"
						elsif (Counter mod P =4*P/8) then
							Anodes <= "11110111";
							SevenSegment <= "0011001"; -- "R"
						end if;
					end if;
				elsif (Counter mod M =0) then--4 = 1) then
						if(Z3="0000") then
							Anodes <= "11111110";
							SevenSegment <= "0000001"; -- "0"
						elsif (Z3="0001") then
							Anodes <= "11111110";
							SevenSegment <= "1001111"; -- "1"
						elsif (Z3="0010") then
							Anodes <= "11111110";
							SevenSegment <= "0010010"; -- "2"
						elsif (Z3="0011") then
							Anodes <= "11111110";
							SevenSegment <= "0000110"; -- "3"
						elsif (Z3="0100") then
							Anodes <= "11111110";
							SevenSegment <= "1001100"; -- "4"
						elsif (Z3="0101") then
							Anodes <= "11111110";
							SevenSegment <= "0100100"; -- "5"
						elsif (Z3="0110") then
							Anodes <= "11111110";
							SevenSegment <= "0100000"; -- "6"
						elsif (Z3="0111") then
							Anodes <= "11111110";
							SevenSegment <= "0001111"; -- "7"
						elsif (Z3="1000") then
							Anodes <= "11111110";
							SevenSegment <= "0000000"; -- "8"
						elsif (Z3="1001") then
							Anodes <= "11111110";
							SevenSegment <= "0000100"; -- "9"
						end if;
						
						
					elsif (Counter mod M =1*M/8) then--4 = 2) then
						if(Z2="0000") then
							Anodes <= "11111101";
							SevenSegment <= "0000001"; -- "0"
						elsif (Z2="0001") then
							Anodes <= "11111101";
							SevenSegment <= "1001111"; -- "1"
						elsif (Z2="0010") then
							Anodes <= "11111101";
							SevenSegment <= "0010010"; -- "2"
						elsif (Z2="0011") then
							Anodes <= "11111101";
							SevenSegment <= "0000110"; -- "3"
						elsif (Z2="0100") then
							Anodes <= "11111101";
							SevenSegment <= "1001100"; -- "4"
						elsif (Z2="0101") then
							Anodes <= "11111101";
							SevenSegment <= "0100100"; -- "5"
						elsif (Z2="0110") then
							Anodes <= "11111101";
							SevenSegment <= "0100000"; -- "6"
						elsif (Z2="0111") then
							Anodes <= "11111101";
							SevenSegment <= "0001111"; -- "7"
						elsif (Z2="1000") then
							Anodes <= "11111101";
							SevenSegment <= "0000000"; -- "8"
						elsif (Z2="1001") then
							Anodes <= "11111101";
							SevenSegment <= "0000100"; -- "9"
						end if;
					elsif (Counter mod M =2*M/8) then--4 =3) then
						if(Z1="0000") then
							Anodes <= "11111011";
							SevenSegment <= "0000001"; -- "0"
						elsif (Z1="0001") then
							Anodes <= "11111011";
							SevenSegment <= "1001111"; -- "1"
						elsif (Z1="0010") then
							Anodes <= "11111011";
							SevenSegment <= "0010010"; -- "2"
						elsif (Z1="0011") then
							Anodes <= "11111011";
							SevenSegment <= "0000110"; -- "3"
						elsif (Z1="0100") then
							Anodes <= "11111011";
							SevenSegment <= "1001100"; -- "4"
						elsif (Z1="0101") then
							Anodes <= "11111011";
							SevenSegment <= "0100100"; -- "5"
						elsif (Z1="0110") then
							Anodes <= "11111011";
							SevenSegment <= "0100000"; -- "6"
						elsif (Z1="0111") then
							Anodes <= "11111011";
							SevenSegment <= "0001111"; -- "7"
						elsif (Z1="1000") then
							Anodes <= "11111011";
							SevenSegment <= "0000000"; -- "8"
						elsif (Z1="1001") then
							Anodes <= "11111011";
							SevenSegment <= "0000100"; -- "9"
						end if;
				end if;
			end if;
		end process;
end Behavioral;

