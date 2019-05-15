library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

library work;
use work.util.all;

entity testbench is
    generic (t_clk : time := 20 ns);
end entity testbench;

architecture behavior of testbench is

    component mips_lite_with_mem is
        port (clk : in std_logic;
            rstn : in std_logic;
            inst_mem_rstn : in std_logic;
            inst_mem_wr_en : in std_logic;
            inst_mem_wr_addr : in std_logic_vector(Nbit_address - 1 downto 0);
            inst_mem_wr_data : in std_logic_vector(Nbit - 1 downto 0));
    end component mips_lite_with_mem;

    signal clk, rstn, inst_mem_rstn, inst_mem_wr_en: std_logic := '0';
    signal inst_mem_wr_addr : std_logic_vector(Nbit_address - 1 downto 0) := (others => '0');
    signal inst_mem_wr_data : std_logic_vector(Nbit - 1 downto 0) := (others => '0');

begin
    dut : mips_lite_with_mem port map (clk => clk,
                                       rstn => rstn,
                                       inst_mem_rstn => inst_mem_rstn,
                                       inst_mem_wr_en => inst_mem_wr_en,
                                       inst_mem_wr_addr => inst_mem_wr_addr,
                                       inst_mem_wr_data => inst_mem_wr_data);

    clk <= (not clk) after t_clk / 2;

    process
        file in_file: text;
        variable buf: line;
        variable temp_int : integer;
        variable inst_mem_wr_addr_var : integer := 0;
        variable temp_data : std_logic_vector(Nbit - 1 downto 0);
    begin
        rstn <= '0';
        inst_mem_rstn <= '0';
        wait for t_clk;
        inst_mem_rstn <= '1';

        wait for t_clk * 1 / 4;
        file_open(in_file, "./opcode.txt", read_mode);
        while not endfile(in_file) loop
            readline(in_file, buf);
            read(buf, temp_data);
            -- temp_data := conv_std_logic_vector(temp_int, 16);
            inst_mem_wr_addr <= std_logic_vector(to_unsigned(inst_mem_wr_addr_var, Nbit_address));
            inst_mem_wr_data <= temp_data;
            wait for t_clk / 8;
            inst_mem_wr_en <= '1';
            inst_mem_wr_addr_var := inst_mem_wr_addr_var + PC_OFFSET_INT;
            deallocate(buf);
            wait for t_clk;
        end loop;
        file_close(in_file);
        deallocate(buf);
        inst_mem_wr_en <= '0';
        wait for 5 * t_clk / 8;
        rstn <= '1';

        wait;


    end process;
end architecture behavior;
