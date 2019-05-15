library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity data_memory is
port (clk : in std_logic;
	RSn : in std_logic;
	enable_write, enable_read : in std_logic;
	address : in std_logic_vector (Nbit_address-1 downto 0);
	write_data : in std_logic_vector (Nbit-1 downto 0);
	read_data : out std_logic_vector (Nbit-1 downto 0));
end entity data_memory;

architecture behavior of data_memory is

subtype word is std_logic_vector(word_length - 1 downto 0);
type mem is array(0 to (2 **(Nbit_address+PC_N_BIT_OFFSET)-1)) of word;

signal memory : mem; 
begin

process (clk, RSn)
--	variable memory : mem;
begin
-- 	read_data <= (others=>'0');

	if (RSn='1') then
		if (clk'event and clk=clock_data_mem) then
			if (enable_write='1' and enable_read='0') then
				for i in 0 to (PC_OFFSET_INT - 1) loop
					-- inverted for big endian
					memory(to_integer(unsigned(address)) + PC_OFFSET_INT - 1 - i) <= write_data((i + 1) * word_length - 1 downto i * word_length);
				end loop;
			elsif (enable_write='0' and enable_read='1') then
				for i in 0 to (PC_OFFSET_INT - 1) loop
					read_data((i + 1) * word_length - 1 downto i * word_length) <=  memory(to_integer(unsigned(address)) + PC_OFFSET_INT - 1 - i);
				end loop;
			end if;
		end if;
	else
		memory <= (others => (others => '0'));
		read_data <= (others => '0');
	end if;
end process;

end architecture behavior;
