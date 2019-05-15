library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity tb_mips_connections is
end tb_mips_connections;

architecture behav of tb_mips_connections is
    component mips_lite_with_mem
        port (clk : in std_logic;
            rstn : in std_logic);
    end component;

    signal clk, rstn : std_logic := '0';
    begin
        mips : mips_lite_with_mem port map (clk => clk, rstn => rstn);
        clk_process : process
        begin
            clk <= (not clk) after 5 ns;
            wait for 5 ns;
        end process;


        process
        begin
            rstn <= '0';

            wait for 50 ns;

            rstn <= '1';

            wait for 100 ns;

            wait;
        end process;
    end behav;
