library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity id_stage is
    port (clk : in std_logic;
          rstn : in std_logic;

          cu_opcode_id : out std_logic_vector(OPCODE_LENGTH - 1 downto 0);
          cu_funct_id : out std_logic_vector(FUNCT_LENGTH - 1 downto 0);

          pc_next_seq_id : in std_logic_vector(Nbit - 1 downto 0);
          inst_id : in std_logic_vector(Nbit - 1 downto 0);

        --   reg_addr_rd1 : out std_logic_vector(bitNreg - 1 downto 0);
        --   reg_addr_rd2 : out std_logic_vector(bitNreg - 1 downto 0);
        --   reg_data_wr : out std_logic_vector(Nbit - 1 downto 0);
        --   reg_addr_wr : out std_logic_vector(bitNreg - 1 downto 0);
        --   rf_wr_en_id : out std_logic;
        --   reg_data_rd1 : in std_logic_vector(Nbit - 1 downto 0);
        --   reg_data_rd2 : in std_logic_vector(Nbit - 1 downto 0);
          reg_write_id : in std_logic;
          reg_data_wr_id : in std_logic_vector(Nbit - 1 downto 0);
          reg_addr_wr_id : in std_logic_vector(bitNreg - 1 downto 0);

          reg_dest_id : in std_logic;
          reg_dest_data_id : out std_logic_vector(bitNreg - 1 downto 0);

          rf_data1_id : out std_logic_vector(Nbit - 1 downto 0);
          rf_data2_id : out std_logic_vector(Nbit - 1 downto 0);

          inst_op_id : out std_logic_vector(INST_OP_LENGTH - 1 downto 0);

          extension_id : in std_logic;
          sgn_ext_imm_id : out std_logic_vector(Nbit - 1 downto 0);

          fin_jump_addr_id : out std_logic_vector(Nbit - 1 downto 0);
          pc_next_seq_id_ex : out std_logic_vector(Nbit -1  downto 0)
          );
end id_stage;

architecture behav of id_stage is
    component regfile
        generic (bitNregaddr : integer := 5; -- 2 ** bitNregaddr is total number of regs
             Nbitdata : integer := 32);
        port (addr_rd_reg1 : in std_logic_vector(bitNregaddr - 1 downto 0);
            addr_rd_reg2 : in std_logic_vector(bitNregaddr - 1 downto 0);
            addr_wr_reg : in std_logic_vector(bitNregaddr - 1 downto 0);
            data_wr_reg : in std_logic_vector(Nbitdata - 1 downto 0);
            data_rd_reg1 : out std_logic_vector(Nbitdata - 1 downto 0);
            data_rd_reg2 : out std_logic_vector(Nbitdata - 1 downto 0);
            write_en : in std_logic;
            clk : in std_logic;
            rstn : in std_logic);
    end component;

    component sign_extension
        generic (IN_WIDTH : integer := 16;
                OUT_WIDTH : integer := 32);
        port (data_in : in std_logic_vector (IN_WIDTH-1 downto 0);
            data_out : out std_logic_vector (OUT_WIDTH-1 downto 0);
            extension: in std_logic);
    end component;

    begin
        rf : regfile generic map (bitNregaddr => bitNreg, Nbitdata => Nbit)
                     port map (addr_rd_reg1 => inst_id(POS_REG1_ADDR_TOP downto POS_REG1_ADDR_BOTTOM),
                               addr_rd_reg2 => inst_id(POS_REG2_ADDR_TOP downto POS_REG2_ADDR_BOTTOM),
                               addr_wr_reg => reg_addr_wr_id,
                               data_wr_reg => reg_data_wr_id,
                               data_rd_reg1 => rf_data1_id,
                               data_rd_reg2 => rf_data2_id,
                               write_en => reg_write_id,
                               clk => clk,
                               rstn => rstn);

        se : sign_extension generic map (IN_WIDTH => IMMEDIATE_LENGTH,
                                         OUT_WIDTH => Nbit)
                            port map (data_in => inst_id(POS_IMMEDIATE_TOP downto POS_IMMEDIATE_BOTTOM),
                                      data_out => sgn_ext_imm_id,
                                      extension => extension_id);


        reg_dest_data_id <= inst_id(POS_REG_DEST_ADDR1_TOP downto POS_REG_DEST_ADDR1_BOTTOM)
                            when reg_dest_id = C_i_20_16 else
                            inst_id(POS_REG_DEST_ADDR2_TOP downto POS_REG_DEST_ADDR2_BOTTOM);

        inst_op_id <= inst_id(POS_INST_OP_TOP downto POS_INST_OP_BOTTOM);

        fin_jump_addr_id(Nbit - 1 downto Nbit - POS_PC_MSB_LENGTH - POS_JUMP_ADDRESS_LENGTH) <= pc_next_seq_id(POS_PC_MSB_TOP downto POS_PC_MSB_BOTTOM) & inst_id(POS_JUMP_ADDRESS_TOP downto POS_JUMP_ADDRESS_BOTTOM);
        fin_jump_addr_id(Nbit - POS_PC_MSB_LENGTH - POS_JUMP_ADDRESS_LENGTH - 1 downto 0) <= (others => '0');

        cu_opcode_id <= inst_id(POS_OPCODE_TOP downto POS_OPCODE_BOTTOM);
        cu_funct_id <= inst_id(POS_FUNCT_TOP downto POS_FUNCT_BOTTOM);

        pc_next_seq_id_ex <= pc_next_seq_id;
    end behav;
