library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity mul_dadda_standard_no6LSB is
    port (a, b : in signed(Nbit -1  downto 0);
          product : out signed(2 * Nbit - 1 downto 0));
end mul_dadda_standard_no6LSB;

architecture behav of mul_dadda_standard_no6LSB is
    component  dadda_standard_no6LSB
        port (partial : in partial_array;
            out1, out2 : out signed(2 * Nbit - 1 downto 0));
    end component;

    component mbe
        port (a, b : in signed(Nbit - 1 downto 0);
            partial : out partial_array);
    end component;

    signal partial : partial_array;
    signal out1, out2 : signed(2 * Nbit - 1 downto 0);

    begin
        part_prod_gen : mbe port map (a => a, b => b, partial => partial);
        part_prod_red : dadda_standard_no6LSB port map (partial => partial, out1 => out1, out2 => out2);
        product <= out1 + out2;
    end behav;
