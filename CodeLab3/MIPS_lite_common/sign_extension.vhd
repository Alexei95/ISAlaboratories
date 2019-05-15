library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sign_extension is
generic (IN_WIDTH : integer := 16;
		OUT_WIDTH : integer := 32);
port (data_in : in std_logic_vector (IN_WIDTH-1 downto 0);
	data_out : out std_logic_vector (OUT_WIDTH-1 downto 0);
	extension: in std_logic);
end entity sign_extension;

architecture behavior of sign_extension is

signal extension_sign, extension_zero : std_logic_vector (OUT_WIDTH-1 downto 0);

begin

	extension_sign(IN_WIDTH-1 downto 0) <= data_in;
	extension_sign(OUT_WIDTH-1 downto IN_WIDTH) <= (others => data_in(IN_WIDTH-1));

	extension_zero(IN_WIDTH-1 downto 0) <= data_in;
	extension_zero(OUT_WIDTH-1 downto IN_WIDTH) <= (others => '0');

	data_out <= extension_zero when extension='0'
			else extension_sign;

end architecture behavior;
