library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity mips_lite_with_mem is
    port (clk : in std_logic;
          rstn : in std_logic;
          inst_mem_rstn : in std_logic;
          inst_mem_wr_en : in std_logic;
          inst_mem_wr_addr : in std_logic_vector(Nbit_address - 1 downto 0);
          inst_mem_wr_data : in std_logic_vector(Nbit - 1 downto 0));
end mips_lite_with_mem;

architecture behav of mips_lite_with_mem is
    component data_memory
        port (clk : in std_logic;
              RSn : in std_logic;
              enable_write, enable_read : in std_logic;
              address : in std_logic_vector (Nbit_address-1 downto 0);
              write_data : in std_logic_vector (Nbit-1 downto 0);
              read_data : out std_logic_vector (Nbit-1 downto 0));
    end component;

    component instruction_memory
        port (clk : in std_logic;
              RSn : in std_logic;
              rd_enable : in std_logic;
              rd_address : in std_logic_vector (Nbit_address-1 downto 0);
              read_data : out std_logic_vector (Nbit-1 downto 0);
              wr_address : in std_logic_vector(Nbit_address - 1 downto 0);
              write_data : in std_logic_vector(Nbit - 1 downto 0);
              wr_enable : in std_logic);
    end component;

    component mips_lite
        port (inst_mem_rd_en : out std_logic; -- output for inst mem enable
              inst_mem_addr : out std_logic_vector(Nbit_address - 1 downto 0);
              inst_mem_data : in std_logic_vector(Nbit - 1 downto 0); -- output instruction memory data

              address : out std_logic_vector(Nbit_address - 1 downto 0);
              write_data : out std_logic_vector(Nbit - 1 downto 0);
              read_data : in std_logic_vector(Nbit - 1 downto 0);
              enable_write, enable_read : out std_logic;

              clk : in std_logic;
              rstn : in std_logic
              );
    end component;

    signal inst_mem_rd_en : std_logic;
    signal inst_mem_addr : std_logic_vector(Nbit_address - 1 downto 0);
    signal inst_mem_data : std_logic_vector(Nbit - 1 downto 0);

    signal address : std_logic_vector(Nbit_address - 1 downto 0);
    signal write_data : std_logic_vector(Nbit - 1 downto 0);
    signal read_data : std_logic_vector(Nbit - 1 downto 0);
    signal enable_write : std_logic;
    signal enable_read : std_logic;

    begin
        inst_mem : instruction_memory port map
                   (clk => clk,
                    RSn => inst_mem_rstn,
                    rd_enable => inst_mem_rd_en,
                    rd_address => inst_mem_addr,
                    read_data => inst_mem_data,
                    wr_address => inst_mem_wr_addr,
                    wr_enable => inst_mem_wr_en,
                    write_data => inst_mem_wr_data);

        data_mem : data_memory port map
                   (clk => clk,
                    RSn => inst_mem_rstn,
                    enable_write => enable_write,
                    enable_read => enable_read,
                    address => address,
                    write_data => write_data,
                    read_data => read_data);

        mips_comp : mips_lite port map
                    (inst_mem_rd_en => inst_mem_rd_en,
                    inst_mem_addr => inst_mem_addr,
                    inst_mem_data  => inst_mem_data,

                    address => address,
                    write_data => write_data,
                    read_data => read_data,
                    enable_write => enable_write,
                    enable_read => enable_read,

                    clk => clk,
                    rstn => rstn);


    end behav;
