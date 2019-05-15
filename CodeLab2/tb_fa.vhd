library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity tb_fa is
end tb_fa;

architecture behav of tb_fa is

    component fa
        port (cin, a, b : in std_logic;
              cout, s : out std_logic);
    end component;

    signal a, b, cin, cout, s : std_logic;

    begin
        test : fa port map (a => a, b => b, cin => cin, cout => cout, s => s);

    process
        begin
            a <= '0';
            b <= '0';
            cin <= '0';

            wait for 10 ns;

            a <= '1';
            b <= '0';
            cin <= '0';

            wait for 10 ns;

            a <= '0';
            b <= '1';
            cin <= '0';

            wait for 10 ns;

            a <= '0';
            b <= '0';
            cin <= '1';

            wait for 10 ns;

            a <= '1';
            b <= '1';
            cin <= '1';


            wait for 10 ns;

            a <= '1';
            b <= '1';
            cin <= '0';

            wait for 10 ns;

            a <= '0';
            b <= '1';
            cin <= '1';

            wait for 10 ns;

            a <= '1';
            b <= '0';
            cin <= '1';

            wait for 10 ns;

            wait;
        end process;
    end behav;
