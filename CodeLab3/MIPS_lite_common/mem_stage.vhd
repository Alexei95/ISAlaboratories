library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity mem_stage is
    port (clk : in std_logic;
          rstn : in std_logic;

          mem_write_mem : in std_logic;
          mem_read_mem : in std_logic;
          alu_res_mem : in std_logic_vector(Nbit - 1 downto 0);
          read_data : in std_logic_vector(Nbit - 1 downto 0);
          rf_data2_mem : in std_logic_vector(Nbit - 1 downto 0);

          rd_mem_data_mem : out std_logic_vector(Nbit - 1 downto 0);
          address : out std_logic_vector(Nbit_address - 1 downto 0);
          write_data : out std_logic_vector(Nbit - 1 downto 0);
          enable_write, enable_read : out std_logic;

          alu_res_mem_wb : out std_logic_vector(Nbit - 1 downto 0);
          reg_dest_data_mem_wb : out std_logic_vector(bitNreg - 1 downto 0);
          reg_dest_data_mem : in std_logic_vector(bitNreg - 1 downto 0);
          pc_jump_branch_mem : in std_logic_vector(Nbit - 1 downto 0);
          pc_jump_branch_mem_wb : out std_logic_vector(Nbit - 1 downto 0);
          jump_branch_mem : in std_logic;
          jump_branch_mem_wb : out std_logic
          );
end mem_stage;

architecture behav of mem_stage is
    component data_memory
        port (clk : in std_logic;
            RSn : in std_logic;
            enable_write, enable_read : in std_logic;
            address : in std_logic_vector (Nbit_address-1 downto 0);
            write_data : in std_logic_vector (Nbit-1 downto 0);
            read_data : out std_logic_vector (Nbit-1 downto 0));
    end component;
    begin
        enable_write <= mem_write_mem;
        enable_read <= mem_read_mem;

        address <= alu_res_mem(Nbit_address - 1 downto 0);
        rd_mem_data_mem <= read_data;

        write_data <= rf_data2_mem;

        alu_res_mem_wb <= alu_res_mem;
        reg_dest_data_mem_wb <= reg_dest_data_mem;
        pc_jump_branch_mem_wb <= pc_jump_branch_mem;
        jump_branch_mem_wb <= jump_branch_mem;

    end behav;
