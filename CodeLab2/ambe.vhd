library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity ambe is
    port (a, b : in signed(Nbit - 1 downto 0);
          partial : out partial_array);
end ambe;

architecture behav of ambe is
    signal q, p_temp : multiple_factoring_array;
    signal extended_b : signed(Nbit downto 0);
    begin
        -- zero right extension for index -1
        extended_b <= b & '0';

        partial_product : for i in 0 to Nbit / 2 - 1 generate
            -- xor 1 bit for MBE
            p_temp_gen : for j in 0 to Nbit - 1 generate
                p_temp(i)(j) <= (a(j) xor extended_b(2 * i + 1)) and (extended_b(2 * i) or extended_b(2 * i + 1));
            end generate;
            -- sign extension
            p_temp(i)(Nbit) <= p_temp(i)(Nbit - 1);
            -- partial product without sign for Roorda
            partial(i)(Nbit + 2 * i - 1 downto 2 * i) <= p_temp(i)(Nbit - 1 downto 0);
            -- Roorda extension
            partial(i)(2 * Nbit - 1 downto Nbit + 2 * i) <= (others => '1');
            -- Zero padding on the right
            if_padding : if i > 0 generate
                partial(i)(2 * i - 1 downto 0) <= (others => '0');
            end generate;
            -- MBE carry
            --p(N / 2)(2 * i) <= b(2 * i + 1);
            -- Roorda carry
            --p(N / 2 + 1)(N + 2 * i) <= p_temp(N);
            -- these last two could be compacted in one, MBE carry should be
            -- max in position N - 1, while Roorda carry starts from position
            -- N
            -- MBE + Roorda carry in same line
            partial(Nbit / 2)(Nbit + 2 * i) <= not p_temp(i)(Nbit);
            partial(Nbit / 2)(2 * i) <= b(2 * i + 1);
            partial(Nbit / 2)(Nbit + 2 * i + 1) <= '0';
            partial(Nbit / 2)(2 * i + 1) <= '0';
        end generate;
    end behav;
