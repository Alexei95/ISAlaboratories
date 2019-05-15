library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

library work;
use work.util.all;

entity data_sink is
  port (
    CLK   : in std_logic;
    RST_n : in std_logic;
    VIN   : in std_logic;
    DIN   : in std_logic_vector(P * Nbit - 1 downto 0));
end data_sink;

architecture beh of data_sink is

begin  -- beh

  process (CLK, RST_n)
    file res_fp : text open WRITE_MODE is "./results.txt";
    variable line_out : line;    
  begin  -- process
    if RST_n = '0' then                 -- asynchronous reset (active low)
      null;
    -- it works on falling edges and divides the three outputs
    elsif CLK'event and CLK = '0' then  -- falling clock edge
      if (VIN = '1') then
        write(line_out, conv_integer(signed(DIN(3 * Nbit - 1 downto 2 * Nbit))));
        writeline(res_fp, line_out);
        write(line_out, conv_integer(signed(DIN(2 * Nbit - 1 downto Nbit))));
        writeline(res_fp, line_out);
        write(line_out, conv_integer(signed(DIN(Nbit - 1 downto 0))));
        writeline(res_fp, line_out);
      end if;
    end if;
  end process;

end beh;
