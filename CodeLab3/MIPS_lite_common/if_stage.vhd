library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity if_stage is
    port (inst_mem_addr : out std_logic_vector(Nbit_address - 1 downto 0);
          inst_mem_data : in std_logic_vector(Nbit - 1 downto 0); -- output instruction memory data
          inst_if : out std_logic_vector(Nbit - 1 downto 0);
          pc_next_seq_if : out std_logic_vector(Nbit - 1 downto 0);
          pc_jump_branch_if : in std_logic_vector(Nbit - 1 downto 0);

          inst_mem_rd_if : in std_logic; -- always to 1
          inst_mem_rd_en : out std_logic; -- output for inst mem enable
          pc_load_if : in std_logic; -- load signal for PC, always to 1
          jump_branch_if : in std_logic;

          clk : in std_logic;
          rstn : in std_logic
          );
end if_stage;

architecture behav of if_stage is
    component regn_std_logic_vector
        generic (N : integer := 32);
        port (D : in std_logic_vector(N - 1 downto 0);
              clock, resetN, en : in std_logic;
              Q : out std_logic_vector(N - 1 downto 0));
    end component;

    component instruction_memory
        port (clk : in std_logic;
            RSn : in std_logic;
            enable : in std_logic;
            address : in std_logic_vector (Nbit_address-1 downto 0);
            read_data : out std_logic_vector (Nbit-1 downto 0));
    end component;

    signal pc_out : std_logic_vector(Nbit - 1 downto 0);
    signal pc_src : std_logic_vector(Nbit - 1 downto 0);
    signal clkN : std_logic;
    signal pc_next_seq_internal : std_logic_vector(Nbit - 1 downto 0);

    begin
        clkN <= clk xnor clock_PC;
        pc_reg : regn_std_logic_vector
                    generic map (N => Nbit)
                    port map (D => pc_src,
                            clock => clkN,
                            resetN => rstn,
                            en => pc_load_if,
                            Q => pc_out);

        -- unsigned sum for sequential address
        pc_next_seq_internal <= std_logic_vector(unsigned(pc_out) + PC_OFFSET);
        pc_next_seq_if <= pc_next_seq_internal;

        pc_src <= pc_jump_branch_if when jump_branch_if = '1' else pc_next_seq_internal;

        -- for instruction memory
        inst_if <= inst_mem_data;
        inst_mem_rd_en <= inst_mem_rd_if;
        inst_mem_addr <= pc_out(Nbit_address - 1 downto 0);

    end behav;
