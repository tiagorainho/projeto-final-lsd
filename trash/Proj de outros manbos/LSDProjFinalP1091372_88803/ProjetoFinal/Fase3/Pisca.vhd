library IEEE;
use IEEE.std_logic_1164.all;

entity Pisca is
	port( Entrada	: in std_logic_vector(3 downto 0);
			clk		: in std_logic;
			Saida		: out std_logic);
end Pisca;

architecture Behavioral of Pisca is
	begin
	process(Entrada, clk)
		begin
		if(Entrada = "0000") then
			Saida <= clk;
		else	
			Saida <= '1';
		end if;
	end process;	
end Behavioral;