----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:09:35 05/10/2019 
-- Design Name: 
-- Module Name:    rgen - Behavioral 
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
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rgen is
    Port ( r1 : out STD_LOGIC_VECTOR (7 downto 0);
           MCLK : in  STD_LOGIC;
           rButton : in  STD_LOGIC; --restart button
			  sButton : in STD_LOGIC); --start button 
			  
			  
end rgen;

architecture Behavioral of rgen is

	signal count :std_logic_vector (15 downto 0); 
	signal c_out :std_logic_vector (15 downto 0);
	signal linear_feedback :std_logic;
	signal r1signal :std_logic_vector (7 downto 0); 


	begin
	linear_feedback <= not(count(15) xor count(11));
	
	process (MCLK, rButton) 
	begin
		if (rButton = '1') then
			count <= (others=>'0');
		elsif (rising_edge(MCLK)) then
			if (sButton = '1') then
			count <= ( count(14) & count(13) & count(12)&count(11) & count(10) & count(9) & count(8) & count(7)&count(6) & count(5) & count(4) & count(3) & count(2) & count(1) & count(0) & linear_feedback);
			end if;
		end if;
	end process;
	c_out <= count;
 
 
 r1signal(0)<=c_out(0) xor c_out(15);
 r1signal(1)<=c_out(1) xor c_out(14);
 r1signal(2)<=c_out(2) xor c_out(13);
 r1signal(3)<=c_out(3) xor c_out(12);
 r1signal(4)<=c_out(4) xor c_out(11);
 r1signal(5)<=c_out(5) xor c_out(10);
 r1signal(6)<=c_out(6) xor c_out(9);
 r1signal(7)<=c_out(7) xor c_out(8);
 
 
-- process (r1signal)
 r1(0) <= r1signal(0);
 r1(1) <= r1signal(1);
 r1(2) <= r1signal(2);
 r1(3) <= r1signal(3);
 r1(4) <= r1signal(4);
 r1(5) <= r1signal(5);
 r1(6) <= r1signal(6);
 r1(7) <= r1signal(7);
 
end Behavioral;

