library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity tb_four_to_two is
end tb_four_to_two;

architecture behav of tb_four_to_two is

    component four_to_two_approx
        port (a, b, c, d : in std_logic;
              cout, s : out std_logic);
    end component;

    signal a, b, c, d, cout, s : std_logic;

    begin
        test : four_to_two_approx port map (a => a, b => b, c => c, d => d,
                                            cout => cout, s => s);

    process
        begin
            for i in 0 to 2 ** 4 - 1 loop
                a <= to_unsigned(i, 4)(3);
                b <= to_unsigned(i, 4)(2);
                c <= to_unsigned(i, 4)(1);
                d <= to_unsigned(i, 4)(0);

                wait for 10 ns;
            end loop;

            wait;
        end process;
    end behav;
