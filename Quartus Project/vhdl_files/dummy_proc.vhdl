-- traffic generator that simulates typical transactions that a processor would do
-- proc_type indicates specific implementation
-- this code is only appropriate to the example network
-- if the network is changed then this code needs to be changed (for example address)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dummy_proc is
generic(
		node_ID : std_logic_vector(3 downto 0);
		proc_type : integer

		);
port (
	clk     		: in std_logic;
	nreset			: in std_logic;
	
	dest_addr 		: out std_logic_vector(31 downto 0);	
	
	-- write signals (and dest_addr)
	wr_data			: out std_logic_vector(7 downto 0);
	wr				: out std_logic;
	
	-- read request signals (and dest_addr)
	read_request	: out std_logic;	
	
	-- read return signals
	rd_data 		: in std_logic_vector(7 downto 0);
	read_return			: in std_logic;	
	
	-- NA busy, don't send more requests
	not_ready			: in std_logic;
	
	
	test_leds			: out std_logic_vector(7 downto 0)

);
end dummy_proc;

architecture rtl of dummy_proc is

	signal cnt      : unsigned(31 downto 0);

	signal targetid : std_logic_vector(3 downto 0);
	signal addr		: std_logic_vector(27 downto 0);

	signal read_return_register	: std_logic_vector(7 downto 0);

	signal state : integer := 0;
	signal toggle : std_logic_vector(31 downto 0);

begin

	
	gen_talk_uart : if proc_type = 0 generate
	begin
	--uart test machine	
 	process(clk, nreset)
	begin
		if rising_edge(clk) then
			-- writes and read requests
			if nreset = '0' then
				cnt <= (others => '0');
				wr <= '1';
				read_request <= '0';
				wr_data <= x"01";
			elsif cnt = 10 then
				cnt <= cnt + 1;
				-- read request to leds
				if not_ready = '0' then	
					read_request <= '1';
					wr <= '0';
					targetid <= "0100"; -- read from mem

					addr <= x"0000000";
				end if;
			elsif cnt = 20 then
				cnt <= cnt + 1;
				--write to leds, read_return + 1
				if not_ready = '0' then					
					wr <= '1';
					read_request <= '0';
					targetid <= x"1";
					addr <= x"0000000";
					wr_data <= std_logic_vector(unsigned(read_return_register) + 1);
					--wr_data <= x"61"; --ascii 'a'
				end if;	
				
				
			elsif cnt = 30 then
				cnt <= cnt + 1;
				-- read request to leds
				if not_ready = '0' then	
					read_request <= '1';
					wr <= '0';
					targetid <= "0001"; -- read from uart
					
					addr <= x"0000000";
				end if;	
				
				
			elsif cnt = 41 then	
				cnt <= (others => '0');
				--write to leds, uart read + 1
				if not_ready = '0' then
					wr <= '1';
					read_request <= '0';
					
					targetid <= x"1";
					addr <= x"0000000";
					wr_data <= std_logic_vector(unsigned(read_return_register) + 1);
					--wr_data <= x"41"; --ascii 'A'
				end if;
			else
				cnt <= cnt + 1;
				wr <= '0';
				read_request <= '0';
			end if;
			
			
			-- listen for read returns
--			if read_return = '1' then
--				read_return_register <= rd_data;
--			
--			else
--				read_return_register <= read_return_register;
--		
--			end if;
			
			
			if state = 0 then
				if read_return = '1' then
					read_return_register <= rd_data;
					state <= 1;
					
					--debugging
--					if toggle = '0' then
--						toggle <= '1';
--					else
--						toggle <= '0';
--					end if;

					toggle <= std_logic_vector(unsigned(toggle) + 1);
				else
					read_return_register <= read_return_register;
			
				end if;
			else
				read_return_register <= read_return_register;
				state <= 0;
			end if;
			
		end if;
 	end process;	
	
	
	
	end generate;
	
	gen_talk_memory : if proc_type = 1 generate
	begin
	
	-- memory test
	process(clk, nreset)
	begin
		if rising_edge(clk) then
			-- writes and read requests
			if nreset = '0' then
				cnt <= (others => '0');
				wr <= '1';
				wr_data <= x"00";
				
				
			elsif cnt = 4 then
				cnt <= cnt + 1;
				-- read request to leds
				if not_ready = '0' then	
					read_request <= '1';
					targetid <= "0100";
					--addr <= x"0000000";
					addr(27 downto 25) <= "000"; 
				end if;
			elsif cnt = 8 then
				cnt <= cnt + 1;
				-- write to leds
				if not_ready = '0' then					
					wr <= '1';
					targetid <= "0100";
					addr(27 downto 25) <= "001";
					wr_data <= std_logic_vector(unsigned(read_return_register) + 1);
					--wr_data <= x"61"; --ascii 'a'
				end if;
				
			elsif cnt = 12 then
				cnt <= cnt + 1;
				-- read request to leds
				if not_ready = '0' then	
					read_request <= '1';
					targetid <= "0100";
					--addr <= x"0000000";
					addr(27 downto 25) <= "001"; 
				end if;
			elsif cnt = 16 then
				cnt <= cnt + 1;
				-- write to leds
				if not_ready = '0' then					
					wr <= '1';
					targetid <= "0100";
					addr(27 downto 25) <= "010";
					wr_data <= std_logic_vector(unsigned(read_return_register) + 1);
					--wr_data <= x"61"; --ascii 'a'
				end if;
				
			elsif cnt = 20 then
				cnt <= cnt + 1;
				-- read request to leds
				if not_ready = '0' then	
					read_request <= '1';
					targetid <= "0100";
					--addr <= x"0000000";
					addr(27 downto 25) <= "010"; 
				end if;
			elsif cnt = 24 then
				cnt <= cnt + 1;
				-- write to leds
				if not_ready = '0' then					
					wr <= '1';
					targetid <= "0100";
					addr(27 downto 25) <= "011";
					wr_data <= std_logic_vector(unsigned(read_return_register) + 1);
					--wr_data <= x"61"; --ascii 'a'
				end if;
			
			elsif cnt = 28 then
				cnt <= cnt + 1;
				-- read request to leds
				if not_ready = '0' then	
					read_request <= '1';
					targetid <= "0100";
					--addr <= x"0000000";
					addr(27 downto 25) <= "011"; 
				end if;
			elsif cnt = 32 then
				cnt <= (others => '0');				
				-- write to leds
				if not_ready = '0' then					
					wr <= '1';
					targetid <= "0100";
					addr(27 downto 25) <= "000";
					wr_data <= std_logic_vector(unsigned(read_return_register) + 1);
					--wr_data <= "10001010";
					--wr_data <= x"61"; --ascii 'a'
				end if;
				
			else
				cnt <= cnt + 1;
				wr <= '0';
				read_request <= '0';
			end if;
			
			-- listen for read returns
			if read_return = '1' then
				read_return_register <= rd_data;
			
			else
				read_return_register <= read_return_register;
		
			end if;
			
		end if;
 	end process;
	
	
	end generate;
	
	

	gen_talk_slave2 : if proc_type = 2 generate
	begin
	--uart test machine	
 	process(clk, nreset)
	begin
		if rising_edge(clk) then
			-- writes and read requests
			if nreset = '0' then
				cnt <= (others => '0');
				wr <= '1';
				read_request <= '0';
				wr_data <= x"01";
			--elsif cnt = 10000000 then
			elsif cnt = 11 then
				cnt <= cnt + 1;
				-- read request to leds
				if not_ready = '0' then	
					read_request <= '1';
					wr <= '0';
					--targetid <= x"1";
					
					
					
					
					targetid <= "1111"; -- read from mem
					
					
					addr <= x"0000000";
				end if;
			elsif cnt = 25 then
				cnt <= cnt + 1;
				--write to leds, read_return + 1
				if not_ready = '0' then					
					wr <= '1';
					read_request <= '0';
					
					targetid <= "0011";
					addr <= x"0000000";
					wr_data <= std_logic_vector(unsigned(read_return_register) + 1);
					--wr_data <= x"61"; --ascii 'a'
				end if;	
				
				
			elsif cnt = 37 then
				cnt <= cnt + 1;
				-- read request to leds
				if not_ready = '0' then	
					read_request <= '1';
					wr <= '0';
					--targetid <= x"1";
					
					
					
					
					targetid <= "0011"; -- read from uart
					
					
					
					
					addr <= x"0000000";
				end if;	
				
				
			elsif cnt = 48 then	
				cnt <= (others => '0');
				--write to leds, uart read + 1
				if not_ready = '0' then
					wr <= '1';
					read_request <= '0';
					
					targetid <= "1111";
					addr <= x"0000000";
					wr_data <= std_logic_vector(unsigned(read_return_register) + 1);
					--wr_data <= x"41"; --ascii 'A'
				end if;
			else
				cnt <= cnt + 1;
				wr <= '0';
				read_request <= '0';
			end if;
			
			
			-- listen for read returns
--			if read_return = '1' then
--				read_return_register <= rd_data;
--			
--			else
--				read_return_register <= read_return_register;
--		
--			end if;
			
			
			if state = 0 then
				if read_return = '1' then
					read_return_register <= rd_data;
					state <= 1;
					toggle <= std_logic_vector(unsigned(toggle) + 1);
				else
					read_return_register <= read_return_register;
			
				end if;
			else
				read_return_register <= read_return_register;
				state <= 0;
			end if;
			
		end if;
 	end process;	
	
	
	
	end generate;

	gen_talk_switches : if proc_type = 3 generate
		begin
		--switches
		process(clk, nreset)
		begin
			if rising_edge(clk) then
				-- writes and read requests
				if nreset = '0' then
					cnt <= (others => '0');
					wr <= '1';
					read_request <= '0';
					wr_data <= x"01";
				elsif cnt = 2 then
					cnt <= cnt + 1;
					-- read request to switches
					if not_ready = '0' then	
						
						
						read_request <= '1';
						wr <= '0';
						--targetid <= x"1";
						
						targetid <= "1100"; -- read from switches
						
						
						addr <= x"0000000";
					--else
						--wait
						--don't increment counter
					--	cnt <= cnt;
					end if;
				elsif cnt = 4 then
					
					--write to address given in read return
					if not_ready = '0' then		
						cnt <= (others => '0');
						
						wr <= '1';
						read_request <= '0';
						
						targetid <= read_return_register(3 downto 0);
						addr <= x"0000000";
						wr_data <= x"F0";
					else
						--wait
						--don't increment counter
						cnt <= cnt;
					
					end if;		
		
				else
					cnt <= cnt + 1;
					wr <= '0';
					read_request <= '0';
				end if;
				
				if state = 0 then
					if read_return = '1' then
						read_return_register <= rd_data;
						state <= 1;
						toggle <= std_logic_vector(unsigned(toggle) + 1);
					else
						read_return_register <= read_return_register;
				
					end if;
				else
					read_return_register <= read_return_register;
					state <= 0;
				end if;
			end if;
		end process;	
	end generate;
	
	
	test_leds(3 downto 0) <= read_return_register(3 downto 0); --debugging
	test_leds(7 downto 4) <= toggle(31 downto 28);
	
 	dest_addr(31 downto 28) <= targetid;
 	dest_addr(27 downto 0) <= addr;

end rtl;





