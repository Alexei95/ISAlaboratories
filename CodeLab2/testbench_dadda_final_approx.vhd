library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

library work;
use work.util.all;

entity testbench_dadda_final_approx is
    generic (max_limit_ambe : integer := 5;
             max_limit_dadda : integer := 6);
end testbench_dadda_final_approx;

architecture behav of testbench_dadda_final_approx is

    component mul_ambe_mbe_dadda_four_to_two_with_enable
        generic (limit_ambe : integer := 0;
                 limit_dadda : integer := 0);
        port (a, b : in signed(Nbit -1  downto 0);
            product : out signed(2 * Nbit - 1 downto 0);
            en : in std_logic);
    end component;

    signal a, b : signed(9 downto 0) := "0000000000";
    signal a_int, b_int, correct_int : integer;
    signal correct_bin : signed(19 downto 0);
    --type subfile_array is array(max_limit_dadda downto 0) of file;
    --type file_array is array(max_limit_ambe downto 0) of subfile_array;
    type subproduct_array is
            array(max_limit_dadda downto 0) of signed(2 * Nbit - 1 downto 0);
    type product_array is
        array(max_limit_ambe downto 0) of subproduct_array;
    type subproduct_int_array is array(max_limit_dadda downto 0) of integer;
    type product_int_array is
         array(max_limit_ambe downto 0) of subproduct_int_array;
    type substring_array is array(max_limit_dadda downto 0) of string(40 downto 1);
    type string_array is array(max_limit_ambe downto 0) of substring_array;
    type correct_array is array(max_limit_ambe downto 0) of
                              std_logic_vector(max_limit_dadda downto 0);

    signal product : product_array;
    signal product_int, dist : product_int_array;
    --signal files : file_array;
    signal filenames : string_array;
    signal basedir : string(24 downto 1) := "Comparisons_final_approx";
    signal correct, en_array : correct_array;

    begin
        if_gen : if max_limit_ambe >= 0 and max_limit_ambe <= 5 and
                    max_limit_dadda >= 0 and max_limit_dadda <= 6 generate
            ambe_gen : for i in 0 to max_limit_ambe generate
                dadda_gen : for j in 0 to max_limit_dadda generate
                    test : mul_ambe_mbe_dadda_four_to_two_with_enable
                        generic map (limit_ambe => i, limit_dadda => j)
                        port map (a => a, b => b, product => product(i)(j),
                                  en => en_array(i)(j));
                    product_int(i)(j) <= to_integer(product(i)(j));
                    dist(i)(j) <= correct_int - product_int(i)(j);
                    filenames(i)(j) <= basedir & "/ambe" & integer'image(i) &
                                       "dadda" & integer'image(j) & ".txt";
                end generate;
            end generate;
        end generate;

        a <= to_signed(a_int, 10);
        b <= to_signed(b_int, 10);
        correct_bin <= to_signed(correct_int, 20);


    process
        variable line_out : line;
        file output : text;
        begin
            a_int <= 0;
            b_int <= 0;
            en_array <= (others => (others => '0'));

            wait for 10 ns;

            if max_limit_ambe >= 0 and max_limit_ambe <= 5 and
                            max_limit_dadda >= 0 and max_limit_dadda <= 6 then
                for k in 0 to max_limit_ambe loop
                    for l in 0 to max_limit_dadda loop
                        file_open(output, filenames(k)(l), write_mode);
                        en_array(k)(l) <= '1';
                        for i in -2 ** 9 to 2 ** 9 - 1 loop
                            for j in -2**9 to 2 ** 9 - 1 loop
                                a_int <= i;
                                b_int <= j;
                                wait for 1 ps;
                                correct_int <= i * j;
                                if (i * j - product_int(k)(l)) = 0 then
                                    correct(k)(l) <= '1';
                                else
                                    correct(k)(l) <= '0';
                                end if;
                                wait for 2500 ps;
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
                                write(line_out, product_int(k)(l));
                                --write(line_out, string'(" ; correct bin: "));
                                --write(line_out, correct_bin, right, 20);
                                --write(line_out, string'(" ; correct int: "));
                                write(line_out, string'(";"));
                                write(line_out, correct_int);
                                --write(line_out, string'(" ; correct bool: "));
                                write(line_out, string'(";"));
                                write(line_out, correct(k)(l));
                                --write(line_out, string'(" ; distance: "));
                                write(line_out, string'(";"));
                                write(line_out, dist(k)(l));
                                writeline(output, line_out);
                                wait for 2499 ps;
                            end loop;
                        end loop;
                        wait for 0.5 us;
                        file_close(output);
                        en_array(k)(l) <= '0';
                        wait for 0.5 us;
                    end loop;
                end loop;
            end if;

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
