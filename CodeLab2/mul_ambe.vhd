library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity mul_ambe is
    port (a, b : in signed(Nbit -1  downto 0);
          product : out signed(2 * Nbit - 1 downto 0));
end mul_ambe;

architecture behav of mul_ambe is
    component  dadda
        port (partial : in partial_array;
            out1, out2 : out signed(2 * Nbit - 1 downto 0));
    end component;

    component ambe
        port (a, b : in signed(Nbit - 1 downto 0);
            partial : out partial_array);
    end component;

    signal partial : partial_array;
    signal out1, out2 : signed(2 * Nbit - 1 downto 0);

    begin
        part_prod_gen : ambe port map (a => a, b => b, partial => partial);
        part_prod_red : dadda port map (partial => partial, out1 => out1, out2 => out2);
        product <= out1 + out2;
    end behav;
