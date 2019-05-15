library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

library work;
use work.util.all;

entity testbench_dadda is
end testbench_dadda;

architecture behav of testbench_dadda is

    component mul_dadda_standard_no6LSB
        port (a, b : in signed(Nbit -1  downto 0);
            product : out signed(2 * Nbit - 1 downto 0));
    end component;

    signal a, b : signed(9 downto 0) := "0000000000";
    signal a_int, b_int, product_int, correct_int, dist : integer;
    signal product, correct_bin : signed(19 downto 0);
    signal correct : std_logic;

    begin
        test : mul_dadda_standard_no6LSB port map (a => a, b => b, product => product);

        a <= to_signed(a_int, 10);
        b <= to_signed(b_int, 10);
        product_int <= to_integer(product);
        correct_bin <= to_signed(correct_int, 20);
        dist <= correct_int - product_int;


    process
        variable line_out : line;
        file output : text open WRITE_MODE is "./Matlab/PDFs/results_dadda_standard_no6LSB.txt";
        begin
            a_int <= 0;
            b_int <= 0;

            wait for 10 ns;

            for i in -2 ** 9 to 2 ** 9 - 1 loop
                for j in -2**9 to 2 ** 9 - 1 loop
                    a_int <= i;
                    b_int <= j;
                    wait for 1 ps;
                    correct_int <= i * j;
                    if (i * j - product_int) = 0 then
                        correct <= '1';
                    else
                        correct <= '0';
                    end if;
                    wait for 2499 ps;
                    --write(line_out, string'("a bin: "));
                    --write(line_out, a, right, 10);
                    --write(line_out, string'(" ; a int: "));
                    --write(line_out, string'("a int: "));
                    write(line_out, a_int);
                    --write(line_out, string'(" ; b bin: "));
                    --write(line_out, b, right, 10);
                    --write(line_out, string'(" ; b int: "));
                    write(line_out, string'(";"));
                    write(line_out, b_int);
                    --write(line_out, string'(" ; product bin: "));
                    --write(line_out, product, right, 20);
                    --write(line_out, string'(" ; product int: "));
                    write(line_out, string'(";"));
                    write(line_out, product_int);
                    --write(line_out, string'(" ; correct bin: "));
                    --write(line_out, correct_bin, right, 20);
                    --write(line_out, string'(" ; correct int: "));
                    write(line_out, string'(";"));
                    write(line_out, correct_int);
                    --write(line_out, string'(" ; correct bool: "));
                    write(line_out, string'(";"));
                    write(line_out, correct);
                    --write(line_out, string'(" ; distance: "));
                    write(line_out, string'(";"));
                    write(line_out, dist);
                    writeline(output, line_out);
                    deallocate(line_out);
                    wait for 2500 ps;
                end loop;
            end loop;

            -- a <= "0000000001";
            -- b <= "0000000001";

            -- wait for 10 ns;

            -- a <= "1111111111";
            -- b <= "1111111111";

            -- wait for 10 ns;

            -- a <= "1111111110";
            -- b <= "0000000001";

            -- wait for 10 ns;

            -- a <= "1010010100";
            -- b <= "1010111001";

            -- wait for 10 ns;


            wait;
        end process;
    end behav;
