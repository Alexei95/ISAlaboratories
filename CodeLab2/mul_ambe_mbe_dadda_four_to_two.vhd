library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity mul_ambe_mbe_dadda_four_to_two is
    generic (limit_ambe : integer := 0;
             limit_dadda : integer := 0);
    port (a, b : in signed(Nbit -1  downto 0);
          product : out signed(2 * Nbit - 1 downto 0));
end mul_ambe_mbe_dadda_four_to_two;

architecture behav of mul_ambe_mbe_dadda_four_to_two is
    component  dadda_four_to_two_variable_approx
        generic (limit : integer := 0);
        port (partial : in partial_array;
            out1, out2 : out signed(2 * Nbit - 1 downto 0));
    end component;

    component  dadda_four_to_two_approx_layer2
        port (partial : in partial_array;
            out1, out2 : out signed(2 * Nbit - 1 downto 0));
    end component;

    component ambe_mbe_approx
        generic (limit : integer := 0);
        port (a, b : in signed(Nbit - 1 downto 0);
            partial : out partial_array);
    end component;

    signal partial : partial_array;
    signal out1, out2 : signed(2 * Nbit - 1 downto 0);

    begin
        part_prod_gen : ambe_mbe_approx
                        generic map (limit => limit_ambe)
                        port map (a => a, b => b, partial => partial);
        part_prod_red : dadda_four_to_two_variable_approx
                        generic map (limit => limit_dadda)
                        port map (partial => partial,
                                  out1 => out1, out2 => out2);
        product <= out1 + out2;
    end behav;
