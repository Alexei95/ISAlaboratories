library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity dadda_standard_no6LSB is
    port (partial : in partial_array;
          out1, out2 : out signed(2 * Nbit - 1 downto 0));
end dadda_standard_no6LSB;

architecture behav of dadda_standard_no6LSB is
    component fa
        port (cin, a, b : in std_logic;
            cout, s : out std_logic);
    end component;

    component ha
        port (a, b : in std_logic;
            cout, s : out std_logic);
    end component;

    signal partial_temp : internal_partial_array(Nbit / 2 downto 0);
    signal partial_temp_layer1 : internal_partial_array(Nbit / 2 - 2 downto 0);
    signal partial_temp_layer2 : internal_partial_array(Nbit / 2 - 3 downto 0);
    signal partial_temp_layer3 : internal_partial_array(Nbit / 2 - 4 downto 0);

    begin
        partial_association : for i in 0 to Nbit / 2 generate
            partial_temp(i)(2 * Nbit - 1 downto 0) <= partial(i);
            partial_temp(i)(2 * Nbit + 2 downto 2 * Nbit) <= (others => '0');
        end generate;

        -- first stage --> from 6 to 4
        ha1_1 : ha port map (a => partial_temp(0)(6),
                             b => partial_temp(1)(6),
                             cout => partial_temp_layer1(0)(7),
                             s => partial_temp_layer1(0)(6));
        partial_temp_layer1(1)(6) <= partial_temp(2)(6);
        partial_temp_layer1(2)(6) <= partial_temp(3)(6);
        partial_temp_layer1(3)(6) <= partial_temp(5)(6);

        ha1_2 : ha port map (a => partial_temp(0)(7),
                             b => partial_temp(1)(7),
                             cout => partial_temp_layer1(0)(8),
                             s => partial_temp_layer1(1)(7));
        partial_temp_layer1(2)(7) <= partial_temp(2)(7);
        partial_temp_layer1(3)(7) <= partial_temp(3)(7);

        fa1_1 : fa port map (a => partial_temp(0)(8),
                             b => partial_temp(1)(8),
                             cin => partial_temp(2)(8),
                             cout => partial_temp_layer1(0)(9),
                             s => partial_temp_layer1(1)(8));
        ha1_3 : ha port map (a => partial_temp(3)(8),
                             b => partial_temp(4)(8),
                             cout => partial_temp_layer1(1)(9),
                             s => partial_temp_layer1(2)(8));
        partial_temp_layer1(3)(8) <= partial_temp(5)(8);


        fa_ha : for i in 9 to 2 * Nbit - 1 generate
            even_case : if ((i mod 2) = 0) generate
                fa_up : fa port map (a => partial_temp(0)(i),
                                     b => partial_temp(1)(i),
                                     cin => partial_temp(2)(i),
                                     cout => partial_temp_layer1(0)(i + 1),
                                     s => partial_temp_layer1(2)(i));
                fa_down : fa port map (a => partial_temp(3)(i),
                                       b => partial_temp(4)(i),
                                       cin => partial_temp(5)(i),
                                       cout => partial_temp_layer1(1)(i + 1),
                                       s => partial_temp_layer1(3)(i));
            end generate;

            odd_case : if ((i mod 2) = 1) generate
                fa_odd : fa port map (a => partial_temp(0)(i),
                                      b => partial_temp(1)(i),
                                      cin => partial_temp(2)(i),
                                      cout => partial_temp_layer1(0)(i + 1),
                                      s => partial_temp_layer1(2)(i));
                ha_odd : ha port map (a => partial_temp(3)(i),
                                      b => partial_temp(4)(i),
                                      cout => partial_temp_layer1(1)(i + 1),
                                      s => partial_temp_layer1(3)(i));
            end generate;
        end generate;

        -- layer 2
        fa_gen2 : for i in 6 to 2 * Nbit - 1 generate
            fa2 : fa port map (a => partial_temp_layer1(0)(i),
                               b => partial_temp_layer1(1)(i),
                               cin => partial_temp_layer1(2)(i),
                               cout => partial_temp_layer2(0)(i + 1),
                               s => partial_temp_layer2(1)(i));

            partial_temp_layer2(2)(i) <= partial_temp_layer1(3)(i);
        end generate;

        partial_temp_layer2(0)(6) <= '0';

        partial_temp_layer2(1)(2 * Nbit) <= partial_temp_layer1(0)(2 * Nbit);
        partial_temp_layer2(2)(2 * Nbit) <= partial_temp_layer1(1)(2 * Nbit);


        -- layer 3

        fa_gen3 : for i in 6 to 2 * Nbit generate
            fa3 : fa port map (a => partial_temp_layer2(0)(i),
                               b => partial_temp_layer2(1)(i),
                               cin => partial_temp_layer2(2)(i),
                               cout => partial_temp_layer3(0)(i + 1),
                               s => partial_temp_layer3(1)(i));
        end generate;

        partial_temp_layer3(0)(6) <= '0';


        -- cut down version of 23 bits to 20
        out1(5 downto 0) <= (others => '0');
        out2(5 downto 0) <= (others => '0');
        out1(2 * Nbit - 1 downto 6) <= partial_temp_layer3(0)(2 * Nbit - 1 downto 6);
        out2(2 * Nbit - 1 downto 6) <= partial_temp_layer3(1)(2 * Nbit - 1 downto 6);

    end behav;
