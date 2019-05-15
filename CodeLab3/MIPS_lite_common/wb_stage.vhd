library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity wb_stage is
    port (clk : in std_logic;
          rstn : in std_logic;

          rd_mem_data_wb : in std_logic_vector(Nbit - 1 downto 0);
          alu_res_wb : in std_logic_vector(Nbit - 1 downto 0);
          mem2reg_wb : in std_logic;

          rf_wr_data_wb : out std_logic_vector(Nbit - 1 downto 0);

          reg_dest_data_wb : in std_logic_vector(bitNreg - 1 downto 0);
          reg_dest_data_fb : out std_logic_vector(bitNreg - 1 downto 0)

          );
end wb_stage;

architecture behav of wb_stage is
    begin
        rf_wr_data_wb <= rd_mem_data_wb when mem2reg_wb = C_memory else
                         alu_res_wb;

        reg_dest_data_fb <= reg_dest_data_wb;

    end behav;
