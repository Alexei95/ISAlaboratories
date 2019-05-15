library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity mul_mbe_dadda_four_to_two is
    port (a, b : in signed(Nbit -1  downto 0);
          product : out signed(2 * Nbit - 1 downto 0));
end mul_mbe_dadda_four_to_two;

architecture behav of mul_mbe_dadda_four_to_two is
    component  dadda_four_to_two_partial_approx
        port (partial : in partial_array;
            out1, out2 : out signed(2 * Nbit - 1 downto 0));
    end component;

    component mbe
        generic (limit : integer := 1);
        port (a, b : in signed(Nbit - 1 downto 0);
            partial : out partial_array);
    end component;

    signal partial : partial_array;
    signal out1, out2 : signed(2 * Nbit - 1 downto 0);

    begin
        part_prod_gen : mbe
                        port map (a => a, b => b, partial => partial);
        part_prod_red : dadda_four_to_two_partial_approx
                        port map (partial => partial,
                                  out1 => out1, out2 => out2);
        product <= out1 + out2;
    end behav;
