library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity dadda_four_to_two_variable_approx is
    generic (limit : integer := 0);
    port (partial : in partial_array;
          out1, out2 : out signed(2 * Nbit - 1 downto 0));
end dadda_four_to_two_variable_approx;

architecture behav of dadda_four_to_two_variable_approx is
    component fa
        port (cin, a, b : in std_logic;
            cout, s : out std_logic);
    end component;

    component ha
        port (a, b : in std_logic;
            cout, s : out std_logic);
    end component;

    component four_to_two_approx
        port (a, b, c, d : in std_logic;
              cout, s : out std_logic);
    end component;

    signal partial_temp : internal_partial_array(Nbit / 2 downto 0);
    signal partial_temp_layer1 : internal_partial_array(Nbit / 2 - 2 downto 0);
    signal partial_temp_layer2 : internal_partial_array(Nbit / 2 - 3 downto 0);
    signal partial_temp_layer3 : internal_partial_array(Nbit / 2 - 4 downto 0);
    signal temp_partial_2 : signed(22 downto 0);

    begin
        partial_association : for i in 0 to Nbit / 2 generate
            partial_temp(i)(2 * Nbit - 1 downto 0) <= partial(i);
            partial_temp(i)(2 * Nbit + 2 downto 2 * Nbit) <= (others => '0');
        end generate;

        -- first stage --> from 6 to 4
        -- HA --> carry in 0 and sum in 1
        ha1_1 : ha port map (a => partial_temp(0)(6),
                             b => partial_temp(1)(6),
                             cout => partial_temp_layer1(0)(7),
                             s => partial_temp_layer1(1)(6));
        ha1_2 : ha port map (a => partial_temp(0)(7),
                             b => partial_temp(1)(7),
                             cout => partial_temp_layer1(0)(8),
                             s => partial_temp_layer1(1)(7));
        ha1_3 : ha port map (a => partial_temp(3)(8),
                             b => partial_temp(4)(8),
                             cout => partial_temp_layer1(0)(9),
                             s => partial_temp_layer1(1)(8));
        ha1_4 : ha port map (a => partial_temp(3)(9),
                             b => partial_temp(4)(9),
                             cout => partial_temp_layer1(0)(10),
                             s => partial_temp_layer1(1)(9));
        ha1_5 : ha port map (a => partial_temp(3)(11),
                             b => partial_temp(4)(11),
                             cout => partial_temp_layer1(0)(12),
                             s => partial_temp_layer1(1)(11));
        ha1_6 : ha port map (a => partial_temp(3)(15),
                             b => partial_temp(4)(15),
                             cout => partial_temp_layer1(0)(16),
                             s => partial_temp_layer1(1)(15));
        ha1_7 : ha port map (a => partial_temp(3)(13),
                             b => partial_temp(4)(13),
                             cout => partial_temp_layer1(0)(14),
                             s => partial_temp_layer1(1)(13));
        -- FA --> carry in 2/0 and sum in 3/1
        fa1_1 : fa port map (a => partial_temp(0)(8),
                             b => partial_temp(1)(8),
                             cin => partial_temp(2)(8),
                             cout => partial_temp_layer1(2)(9),
                             s => partial_temp_layer1(3)(8));
        fa1_2 : fa port map (a => partial_temp(0)(9),
                             b => partial_temp(1)(9),
                             cin => partial_temp(2)(9),
                             cout => partial_temp_layer1(2)(10),
                             s => partial_temp_layer1(3)(9));
        fa1_3 : fa port map (a => partial_temp(0)(10),
                             b => partial_temp(1)(10),
                             cin => partial_temp(2)(10),
                             cout => partial_temp_layer1(2)(11),
                             s => partial_temp_layer1(3)(10));
        fa1_4 : fa port map (a => partial_temp(0)(11),
                             b => partial_temp(1)(11),
                             cin => partial_temp(2)(11),
                             cout => partial_temp_layer1(2)(12),
                             s => partial_temp_layer1(3)(11));
        fa1_5 : fa port map (a => partial_temp(3)(10),
                             b => partial_temp(4)(10),
                             cin => partial_temp(5)(10),
                             cout => partial_temp_layer1(0)(11),
                             s => partial_temp_layer1(1)(10)); -- row 3 already taken by FA, free for HA
        fa1_6 : fa port map (a => partial_temp(3)(12),
                             b => partial_temp(4)(12),
                             cin => partial_temp(5)(12),
                             cout => partial_temp_layer1(2)(13),
                             s => partial_temp_layer1(3)(12));
        fa1_7 : fa port map (a => partial_temp(3)(14),
                             b => partial_temp(4)(14),
                             cin => partial_temp(5)(14),
                             cout => partial_temp_layer1(2)(15),
                             s => partial_temp_layer1(3)(14));
        fa1_8 : fa port map (a => partial_temp(3)(16),
                             b => partial_temp(4)(16),
                             cin => partial_temp(5)(16),
                             cout => partial_temp_layer1(2)(17),
                             s => partial_temp_layer1(3)(16));
        -- propagations
        partial_temp_layer1(0)(5 downto 0) <= partial_temp(0)(5 downto 0);
        partial_temp_layer1(0)(5 downto 0) <= partial_temp(0)(5 downto 0);
        partial_temp_layer1(1)(5 downto 2) <= partial_temp(1)(5 downto 2);
        partial_temp_layer1(2)(7) <= partial_temp(2)(7);
        --partial_temp_layer1(2)(6) <= partial_temp(2)(6);
        partial_temp_layer1(2)(5) <= partial_temp(2)(5);
        partial_temp_layer1(2)(4) <= partial_temp(2)(4);
        partial_temp_layer1(3)(7) <= partial_temp(3)(7);
        partial_temp_layer1(2)(6) <= partial_temp(3)(6); -- because 3 will be used for Roorda and MBE carries
        partial_temp_layer1(0)(6) <= partial_temp(2)(6);
        partial_temp_layer1(3)(6) <= partial_temp(5)(6);
        partial_temp_layer1(2)(8) <= partial_temp(5)(8); -- used by FA
        roorda_mbe_carries : for i in 0 to 3 generate
            partial_temp_layer1(3)(2 * i) <= partial_temp(5)(2 * i);
        end generate;
        -- custom connections
        -- positioned in HA sum 1
        -- three ones
        partial_temp_layer1(1)(14) <= '1';
        partial_temp_layer1(1)(16) <= '1';
        partial_temp_layer1(1)(19) <= '1';
        -- two ones
        partial_temp_layer1(1)(18) <= partial_temp(5)(18);
        --partial_temp_layer1(1)(12) <= partial_temp(3)(12);
        -- one one
        partial_temp_layer1(1)(17) <= not partial_temp(4)(17);
        -- position in HA carry 0
        -- three ones
        partial_temp_layer1(0)(15) <= '1';
        partial_temp_layer1(0)(17) <= '1';
        -- two ones
        partial_temp_layer1(0)(19) <= '1';
        partial_temp_layer1(0)(13) <= '1';
        partial_temp_layer1(0)(20) <= '1';
        -- one one
        partial_temp_layer1(0)(18) <= partial_temp(4)(17);
        -- positioned in FA sum 3
        -- three ones
        partial_temp_layer1(3)(15) <= '1';
        partial_temp_layer1(3)(17) <= '1';
        partial_temp_layer1(3)(18) <= '1';
        -- two ones
        partial_temp_layer1(1)(12) <= partial_temp(2)(12); -- taken by FA
        partial_temp_layer1(3)(13) <= partial_temp(2)(13);
        -- positioned in FA carry 2
        -- three ones
        partial_temp_layer1(2)(16) <= '1';
        partial_temp_layer1(2)(18) <= '1';
        partial_temp_layer1(2)(19) <= '1';
        -- two ones
        partial_temp_layer1(2)(14) <= partial_temp(2)(14);
        partial_temp_layer1(2)(20) <= '1';







        -- layer 2
        -- HA --> sum 0 carry 1
        ha2_1 : ha port map (a => partial_temp_layer1(0)(4),
                             b => partial_temp_layer1(3)(4),
                             cout => partial_temp_layer2(1)(5),
                             s => partial_temp_layer2(0)(4));
        ha2_2 : ha port map (a => partial_temp_layer1(0)(5),
                             b => partial_temp_layer1(1)(5),
                             cout => partial_temp_layer2(1)(6),
                             s => partial_temp_layer2(0)(5));
        -- ha2_4 : ha port map (a => partial_temp_layer1(0)(16),
        --                      b => partial_temp_layer1(1)(16),
        --                      cout => partial_temp_layer2(1)(17),
        --                      s => partial_temp_layer2(0)(16));
        -- FA --> sum 0 carry 1

        fa2_8 : fa port map (a => partial_temp_layer1(0)(14),
                             b => partial_temp_layer1(2)(14),
                             cin => partial_temp_layer1(3)(14),
                             cout => partial_temp_layer2(1)(15),
                             s => partial_temp_layer2(0)(14));
        fa2_9 : fa port map (a => partial_temp_layer1(2)(13),
                             b => partial_temp_layer1(3)(13),
                             cin => partial_temp_layer1(1)(13),
                             cout => partial_temp_layer2(1)(14),
                             s => partial_temp_layer2(0)(13));

        -- propagation
        partial_temp_layer2(0)(3 downto 0) <= partial_temp_layer1(0)(3 downto 0);
        partial_temp_layer2(1)(0) <= partial_temp_layer1(3)(0);
        partial_temp_layer2(1)(4 downto 2) <= partial_temp_layer1(1)(4 downto 2);
        partial_temp_layer2(2)(2) <= partial_temp_layer1(3)(2);
        temp_partial_2(12 downto 4) <= partial_temp_layer1(3)(12 downto 8) &
                                       partial_temp_layer1(2)(7 downto 4);
        partial_temp_layer2(2)(5 downto 4) <= temp_partial_2(5 downto 4);
        partial_temp_layer2(2)(14 downto 13) <= (others => '1');
        partial_temp_layer2(2)(15) <= partial_temp_layer1(2)(15);
        --partial_temp_layer2(0)(16) <= partial_temp_layer1(1)(16);
        partial_temp_layer2(0)(16) <= partial_temp_layer1(0)(16);
        partial_temp_layer2(2)(16) <= partial_temp_layer1(3)(16);
        --partial_temp_layer2(1)(17) <= partial_temp_layer1(1)(17);
        partial_temp_layer2(2)(17) <= partial_temp_layer1(2)(17);
        partial_temp_layer2(2)(18) <= partial_temp_layer1(1)(18);
        partial_temp_layer2(2)(19) <= partial_temp_layer1(2)(19);
        partial_temp_layer2(0)(20) <= partial_temp_layer1(0)(20);
        partial_temp_layer2(2)(20) <= partial_temp_layer1(2)(20);


        -- custom connection
        partial_temp_layer2(0)(15) <= partial_temp_layer1(1)(15);
        partial_temp_layer2(1)(16) <= '1';

        partial_temp_layer2(0)(17) <= partial_temp_layer1(1)(17);
        partial_temp_layer2(1)(17) <= '1';
        partial_temp_layer2(1)(18) <= '1';

        partial_temp_layer2(0)(18) <= partial_temp_layer1(0)(18);
        partial_temp_layer2(1)(19) <= '1';

        partial_temp_layer2(0)(19) <= '0';
        partial_temp_layer2(1)(20) <= '1';





        -- layer 3
        -- HA
        ha3_1 : ha port map (a => partial_temp_layer2(0)(2),
                             b => partial_temp_layer2(1)(2),
                             cout => partial_temp_layer3(1)(3),
                             s => partial_temp_layer3(0)(2));
        ha3_2 : ha port map (a => partial_temp_layer2(0)(3),
                             b => partial_temp_layer2(1)(3),
                             cout => partial_temp_layer3(1)(4),
                             s => partial_temp_layer3(0)(3));



        -- FA
        fa3_1 : fa port map (a => partial_temp_layer2(0)(4),
                             b => partial_temp_layer2(1)(4),
                             cin => partial_temp_layer2(2)(4),
                             cout => partial_temp_layer3(1)(5),
                             s => partial_temp_layer3(0)(4));

        fa3_2 : fa port map (a => partial_temp_layer2(0)(5),
                             b => partial_temp_layer2(1)(5),
                             cin => partial_temp_layer2(2)(5),
                             cout => partial_temp_layer3(1)(6),
                             s => partial_temp_layer3(0)(5));



        fa3_10 : fa port map (a => partial_temp_layer2(0)(13),
                              b => partial_temp_layer2(1)(13),
                              cin => partial_temp_layer2(2)(13),
                              cout => partial_temp_layer3(1)(14),
                              s => partial_temp_layer3(0)(13));

        fa3_11 : fa port map (a => partial_temp_layer2(0)(14),
                              b => partial_temp_layer2(1)(14),
                              cin => partial_temp_layer2(2)(14),
                              cout => partial_temp_layer3(1)(15),
                              s => partial_temp_layer3(0)(14));

        fa3_12 : fa port map (a => partial_temp_layer2(0)(15),
                              b => partial_temp_layer2(1)(15),
                              cin => partial_temp_layer2(2)(15),
                              cout => partial_temp_layer3(1)(16),
                              s => partial_temp_layer3(0)(15));

        fa3_13 : fa port map (a => partial_temp_layer2(0)(17),
                              b => partial_temp_layer2(1)(17),
                              cin => partial_temp_layer2(2)(17),
                              cout => partial_temp_layer3(1)(18),
                              s => partial_temp_layer3(0)(17));

        fa3_14 : fa port map (a => partial_temp_layer2(0)(18),
                              b => partial_temp_layer2(1)(18),
                              cin => partial_temp_layer2(2)(18),
                              cout => partial_temp_layer3(1)(19),
                              s => partial_temp_layer3(0)(18));

        fa3_15 : fa port map (a => partial_temp_layer2(0)(16),
                              b => partial_temp_layer2(1)(16),
                              cin => partial_temp_layer2(2)(16),
                              cout => partial_temp_layer3(1)(17),
                              s => partial_temp_layer3(0)(16));



        -- propagation
        partial_temp_layer3(0)(0) <= partial_temp_layer2(0)(0);
        partial_temp_layer3(1)(0) <= partial_temp_layer2(1)(0);

        partial_temp_layer3(0)(1) <= partial_temp_layer2(0)(1);

        -- partial_temp_layer3(1)(1) <= partial_temp_layer2(2)(1);
        partial_temp_layer3(1)(1) <= '0'; -- to avoid U
        partial_temp_layer3(1)(2) <= partial_temp_layer2(2)(2);


        partial_temp_layer3(0)(20) <= partial_temp_layer2(0)(20);

        -- custom connections
        -- partial_temp_layer3(0)(16) <= partial_temp_layer2(2)(16);
        -- partial_temp_layer3(1)(17) <= '1';

        partial_temp_layer3(0)(19) <= '0';
        partial_temp_layer3(1)(20) <= '1';

        partial_temp_layer3(1)(21) <= '1';

        -- cut down version of 23 bits to 20
        out1 <= partial_temp_layer3(0)(2 * Nbit - 1 downto 0);
        out2 <= partial_temp_layer3(1)(2 * Nbit - 1 downto 0);











        mix_gen : if limit > 0 and limit < 6 generate
            four_to_two_gen : for i in 6 to 6 + limit - 1 generate
                four_to_two_comp : four_to_two_approx
                            port map (a => partial_temp_layer1(0)(i),
                                    b => partial_temp_layer1(1)(i),
                                    c => partial_temp_layer1(2)(i),
                                    d => partial_temp_layer1(3)(i),
                                    cout => partial_temp_layer2(1)(i + 1),
                                    s => partial_temp_layer2(0)(i));
            end generate;
            fa_gen_layer2 : for i in 6 + limit to 12 generate
            fa_comp : fa port map (a => partial_temp_layer1(0)(i),
                                b => partial_temp_layer1(1)(i),
                                cin => partial_temp_layer1(2)(i),
                                cout => partial_temp_layer2(1)(i + 1),
                                s => partial_temp_layer2(0)(i));
            end generate;

            fa_gen_layer3 : for i in 6 + limit to 12 generate
                fa_comp_layer3 : fa port map (a => partial_temp_layer2(0)(i),
                                        b => partial_temp_layer2(1)(i),
                                        cin => partial_temp_layer2(2)(i),
                                        cout => partial_temp_layer3(1)(i + 1),
                                        s => partial_temp_layer3(0)(i));
            end generate;

            ha_gen : for i in 6 to 6 + limit - 1 generate
                ha_comp : ha port map (a => partial_temp_layer2(0)(i),
                                       b => partial_temp_layer2(1)(i),
                                       cout => partial_temp_layer3(1)(i + 1),
                                       s => partial_temp_layer3(0)(i));
            end generate;

            partial_temp_layer2(2)(12 downto 6 + limit) <=
                                        temp_partial_2(12 downto 6 + limit);
        end generate;

        no_approx_gen : if limit <= 0 generate
            fa_gen_6_7 : for i in 6 to 7 generate
                fa_comp : fa port map (a => partial_temp_layer1(0)(i),
                                    b => partial_temp_layer1(1)(i),
                                    cin => partial_temp_layer1(3)(i),
                                    cout => partial_temp_layer2(1)(i + 1),
                                    s => partial_temp_layer2(0)(i));
            end generate;

            fa_gen_others : for i in 8 to 12 generate
                fa_comp : fa port map (a => partial_temp_layer1(0)(i),
                                    b => partial_temp_layer1(1)(i),
                                    cin => partial_temp_layer1(2)(i),
                                    cout => partial_temp_layer2(1)(i + 1),
                                    s => partial_temp_layer2(0)(i));
            end generate;

            fa_gen_layer3 : for i in 6 to 12 generate
                fa_comp_layer3 : fa port map (a => partial_temp_layer2(0)(i),
                                        b => partial_temp_layer2(1)(i),
                                        cin => partial_temp_layer2(2)(i),
                                        cout => partial_temp_layer3(1)(i + 1),
                                        s => partial_temp_layer3(0)(i));
            end generate;

            partial_temp_layer2(2)(12 downto 6) <=
                                        temp_partial_2(12 downto 6);
        end generate;

        full_approx_gen : if limit >= 6 generate
            four_to_two_gen : for i in 6 to 12 generate
                four_to_two_comp : four_to_two_approx
                            port map (a => partial_temp_layer1(0)(i),
                                    b => partial_temp_layer1(1)(i),
                                    c => partial_temp_layer1(2)(i),
                                    d => partial_temp_layer1(3)(i),
                                    cout => partial_temp_layer2(1)(i + 1),
                                    s => partial_temp_layer2(0)(i));
            end generate;

            ha_gen : for i in 6 to 12 generate
                ha_comp : ha port map (a => partial_temp_layer2(0)(i),
                                       b => partial_temp_layer2(1)(i),
                                       cout => partial_temp_layer3(1)(i + 1),
                                       s => partial_temp_layer3(0)(i));
            end generate;
        end generate;


    end behav;
