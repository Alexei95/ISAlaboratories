library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity instruction_memory is
port (clk : in std_logic;
	  RSn : in std_logic;
	  rd_enable : in std_logic;
	  rd_address : in std_logic_vector (Nbit_address-1 downto 0);
	  read_data : out std_logic_vector (Nbit-1 downto 0);
	  wr_address : in std_logic_vector(Nbit_address - 1 downto 0);
	  write_data : in std_logic_vector(Nbit - 1 downto 0);
	  wr_enable : in std_logic);
end entity instruction_memory;

architecture behavior of instruction_memory is

subtype word is std_logic_vector(word_length - 1 downto 0);
type memory is array (0 to 2**(length_memory+PC_N_BIT_OFFSET)-1) of word;

begin

process (clk, RSn)
	variable mem0 : memory;
begin
--read_data <= (others=>'0');

	if (RSn='1') then
		if (clk'event and clk=clock_inst_mem) then
			if (rd_enable='1' and wr_enable = '0') then
				-- inverted for big endian
				for i in 0 to (PC_OFFSET_INT - 1) loop
					read_data((i + 1) * word_length - 1 downto i * word_length) <= mem0(to_integer(unsigned(rd_address)) + PC_OFFSET_INT - 1 - i);
                end loop;
            elsif (rd_enable='0' and wr_enable = '1') then
				-- inverted for big endian
				for i in 0 to (PC_OFFSET_INT - 1) loop
					mem0(to_integer(unsigned(wr_address)) + PC_OFFSET_INT - 1 - i) := write_data((i + 1) * word_length - 1 downto i * word_length);
				end loop;
			end if;
		end if;
	else
		mem0 := (others => (others => '0'));
		read_data <= (others => '0');
	end if;
end process;

end architecture behavior;
