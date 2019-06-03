library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity states is
	port( price        : in std_logic_vector(7 downto 0);
			count_sw		 : in std_logic_vector(2 downto 0); --Contador do numero de SW
			dinheiro  	 : in std_logic_vector(7 downto 0); -- Acumulador do dinheiro
			troco        : in std_logic_vector(7 downto 0);
			clk       	 : in std_logic;
			reset			 : in std_logic;
			resetAcumulador : out std_logic;
			hexEn     	 : out std_logic;
			ledr0         : out std_logic;
			ledr1         : out std_logic;
			ledr2         : out std_logic;
			ledr3         : out std_logic;
			hexPiscar	 : out std_logic;
			centimos     : out std_logic_vector(7 downto 0);
			euros     	 : out std_logic_vector(7 downto 0));
end states;

architecture Behav of states is
	type state is (I, SB, S, F); 		--	I: Inicial;		SB: Stand By;
	signal PS, NS  : state :=I;					-- S: Start;		F: Final;
	signal s_hex_En, s_hex_piscar : std_logic := '0'; --sinal do HEX Enable e do Piscar
	signal s_centimos, s_euros : unsigned(7 downto 0);
	signal s_reset_a: std_logic;

	
begin
	sync_proc: process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				PS <= I;
			else
				PS <= NS;
			end if;
		end if;
	end process;
	
	
	comb_proc : process(PS, dinheiro, price, troco, count_sw)
	begin
		s_euros    <= "00000000";
		case PS is
		when I =>
			s_hex_En  <= '0'; -- desligar hexs se ligados;
			s_hex_piscar <= '0'; --desligar piscar
			s_reset_a <= '1'; -- reset no acumulador das moedas;
			s_euros <= to_unsigned(0,8);
			s_centimos <= to_unsigned(0,8);
							
			if(count_sw = "001") then
				NS <= SB;
			else
				NS <= I;
			end if;
			
		when SB =>
		
			s_hex_En <= '1'; --ligar HEXs;
			s_centimos <= unsigned(price);
			s_reset_a <= '0';
			s_hex_piscar <= '0';		
			
			--Verificar que se encontra um SW para cima:
			if(count_sw = "001") then
				if(dinheiro > "0000000") then --passar para S se key tocada
					NS <= S;
				else
					NS <= SB;
				end if;
			else
				NS <= I; --regressar ao estado inicial caso count !=1
			end if;
			
			
		when S =>
		
			s_hex_En <= '1'; --ligar HEXs;
			s_centimos <= unsigned(price);
			s_reset_a <= '0';
			s_hex_piscar <= '0';	
			
			if (unsigned(dinheiro) >= unsigned(price)) then 
				s_centimos <= unsigned(troco);
				s_hex_piscar <= '1';	
				NS <= F;
			else
				s_centimos <= unsigned(price);
				s_hex_piscar <= '0';	
				NS <= S;
			end if;
			
			
		when F =>		
			if(count_sw = "000") then
				s_hex_En <= '0'; --ligar HEXs;
				s_centimos <= unsigned(price);
				s_reset_a <= '1';
				s_hex_piscar <= '0';	
				NS <= I;
			else
				s_hex_En <= '1'; --ligar HEXs;
				s_centimos <= unsigned(troco);
				s_reset_a <= '0';
				s_hex_piscar <= '1';	
				NS <= F;
			end if;
		end case;
	centimos <= std_logic_vector(s_centimos);
	euros <= std_logic_vector(s_euros);
	hexEn <= std_logic(s_hex_En);
	hexPiscar <= std_logic(s_hex_piscar);
	resetAcumulador <= std_logic(s_reset_a);
	
	ledr0<='0';
	ledr1<='0';
	ledr2<='0';
	ledr3<='0';
	if(PS=I) then
		ledr0<='1';
	elsif(PS=SB) then
		ledr1<='1';
	elsif(PS=S) then
		ledr2<='1';
	elsif(PS=F) then
		ledr3<= '1';
	else
		ledr0<='1';
		ledr1<='1';
		ledr2<='1';
		ledr3<='1';
	end if;
		
	end process;

end Behav;