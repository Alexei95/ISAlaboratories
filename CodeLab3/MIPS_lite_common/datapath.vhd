library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity datapath is
    port (opcode : out std_logic_vector(OPCODE_LENGTH - 1 downto 0);
          func : out std_logic_vector(FUNCT_LENGTH - 1 downto 0);
          reg_dest : in std_logic;
          reg_write : in std_logic;
          ALU_src1 : in std_logic;
          ALU_src2 : in std_logic;
          extension : in std_logic;
          branch : in std_logic;
          jump : in std_logic;
          mem_write : in std_logic;
          mem_read : in std_logic;
          mem2reg : in std_logic;
          ALU_operation: in alu_opcode_states;

          inst_mem_rd_en : out std_logic; -- output for inst mem enable

          inst_mem_addr : out std_logic_vector(Nbit_address - 1 downto 0);
          inst_mem_data : in std_logic_vector(Nbit - 1 downto 0); -- output instruction memory data

          address : out std_logic_vector(Nbit_address - 1 downto 0);
          write_data : out std_logic_vector(Nbit - 1 downto 0);
          read_data : in std_logic_vector(Nbit - 1 downto 0);
          enable_write, enable_read : out std_logic;

          inst_mem_rd : in std_logic; -- always to 1
          pc_load : in std_logic; -- always to 1

          if_id_reg_en : in std_logic;
          id_ex_reg_en : in std_logic;
          ex_mem_reg_en : in std_logic;
          mem_wb_reg_en : in std_logic;

          clk : in std_logic;
          rstn : in std_logic
          );
end datapath;

architecture behav of datapath is
    component dff
        port (D : in std_logic;
            clock, resetN, en : in std_logic;
            Q : out std_logic);
    end component;

    component dff_alu_opcode
        port (D : in alu_opcode_states;
              clock, resetN, en : in std_logic;
              Q : out alu_opcode_states);
    end component;

    component regn
        generic (N : integer := 32);
        port (D : in signed(N - 1 downto 0);
              clock, resetN, en : in std_logic;
              Q : out signed(N - 1 downto 0));
    end component;

    component regn_std_logic_vector
        generic (N : integer := 32);
        port (D : in std_logic_vector(N - 1 downto 0);
              clock, resetN, en : in std_logic;
              Q : out std_logic_vector(N - 1 downto 0));
    end component;

    component if_stage
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
    end component;

    component id_stage
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
    end component;

    component ex_stage
        port (clk : in std_logic;
            rstn : in std_logic;

            sgn_ext_imm_ex : in std_logic_vector(Nbit - 1 downto 0);
            rf_data1_ex : in std_logic_vector(Nbit - 1 downto 0);
            rf_data2_ex : in std_logic_vector(Nbit - 1 downto 0);
            pc_next_seq_ex : in std_logic_vector(Nbit - 1 downto 0);
            fin_jump_addr_ex : in std_logic_vector(Nbit - 1 downto 0);
            inst_op_ex : in std_logic_vector(INST_OP_LENGTH - 1 downto 0);

            alu_operation_ex : in alu_opcode_states;
            alu_src1_ex : in std_logic;
            alu_src2_ex : in std_logic;

            pc_jump_branch_ex : out std_logic_vector(Nbit - 1 downto 0);
            alu_res_ex : out std_logic_vector(Nbit - 1 downto 0);

            branch_ex : in std_logic;
            jump_ex : in std_logic;

            jump_branch_ex : out std_logic;

            reg_dest_data_ex_mem : out std_logic_vector(bitNreg - 1 downto 0);
            reg_dest_data_ex : in std_logic_vector(bitNreg - 1 downto 0);
            rf_data2_ex_mem : out std_logic_vector(Nbit - 1 downto 0)
            );
    end component;

    component mem_stage
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
    end component;

    component wb_stage
        port (clk : in std_logic;
            rstn : in std_logic;

            rd_mem_data_wb : in std_logic_vector(Nbit - 1 downto 0);
            alu_res_wb : in std_logic_vector(Nbit - 1 downto 0);
            mem2reg_wb : in std_logic;

            rf_wr_data_wb : out std_logic_vector(Nbit - 1 downto 0);

            reg_dest_data_wb : in std_logic_vector(bitNreg - 1 downto 0);
            reg_dest_data_fb : out std_logic_vector(bitNreg - 1 downto 0)
            );
    end component;

    signal pipe_if_out : std_logic_vector(2 * Nbit - 1 downto 0);
    signal pipe_id_in : std_logic_vector(2 * Nbit - 1 downto 0);
    signal pipe_id_out : std_logic_vector(INST_OP_LENGTH + bitNreg + 5 * Nbit + 7 downto 0);
    signal pipe_ex_in : std_logic_vector(INST_OP_LENGTH + bitNreg + 5 * Nbit + 7 downto 0);
    signal pipe_ex_out : std_logic_vector(3 * Nbit + bitNreg + 4 downto 0);
    signal pipe_mem_in : std_logic_vector(3 * Nbit + bitNreg + 4 downto 0);
    signal pipe_mem_out : std_logic_vector(3 * Nbit + bitNreg + 2 downto 0);
    signal pipe_wb_in : std_logic_vector(2 * Nbit + bitNreg + 1 downto 0);
    signal pipe_wb_out : std_logic_vector(bitNreg + Nbit downto 0);

    signal pipe_id_alu_op_out : alu_opcode_states;
    signal pipe_ex_alu_op_in : alu_opcode_states;

	-- ********* 
	signal jmp_brch : std_logic; 

    begin
        if_comp : if_stage port map
                  (inst_mem_addr => inst_mem_addr,
                   inst_mem_data => inst_mem_data,
                   inst_if => pipe_if_out(Nbit - 1 downto 0),
                   pc_next_seq_if  => pipe_if_out(2 * Nbit - 1 downto Nbit),

                   inst_mem_rd_if => inst_mem_rd,
                   inst_mem_rd_en => inst_mem_rd_en,
                   pc_load_if => pc_load,
                   pc_jump_branch_if => pipe_mem_out(3 * Nbit + bitNreg - 1 + 2 downto 2 * Nbit + bitNreg + 2),
                   jump_branch_if => pipe_mem_out(3 * Nbit + bitNreg - 1 + 3),

                   clk => clk,
                   rstn => rstn);

        id_comp : id_stage port map
                  (clk => clk,
                  rstn => rstn,

                  cu_opcode_id => opcode,
                  cu_funct_id  => func,

                  pc_next_seq_id => pipe_id_in(2 * Nbit - 1 downto Nbit),
                  inst_id => pipe_id_in(Nbit - 1 downto 0),

                  reg_write_id => pipe_wb_out(bitNreg + Nbit),
                  reg_data_wr_id => pipe_wb_out(Nbit - 1 downto 0),
                  reg_addr_wr_id => pipe_wb_out(bitNreg - 1 + Nbit downto Nbit),

                  reg_dest_id => reg_dest,
                  reg_dest_data_id => pipe_id_out(bitNreg - 1 + 5 * Nbit downto 5 * Nbit),

                  rf_data1_id => pipe_id_out(Nbit - 1 downto 0),
                  rf_data2_id => pipe_id_out(2 * Nbit - 1 downto Nbit),

                  inst_op_id => pipe_id_out(INST_OP_LENGTH - 1 + bitNreg + 5 * Nbit downto 5 * Nbit + bitNreg),

                  extension_id => extension,
                  sgn_ext_imm_id => pipe_id_out(3 * Nbit - 1 downto 2 * Nbit),

                  fin_jump_addr_id => pipe_id_out(4 * Nbit - 1 downto 3 * Nbit),
                  pc_next_seq_id_ex => pipe_id_out(5 * Nbit - 1 downto 4 * Nbit)
            );

        pipe_id_out(INST_OP_LENGTH + bitNreg + 5 * Nbit) <= mem2reg;
        pipe_id_out(INST_OP_LENGTH + bitNreg + 5 * Nbit + 1) <= reg_write;
        pipe_id_out(INST_OP_LENGTH + bitNreg + 5 * Nbit + 2) <= ALU_src1;
        pipe_id_out(INST_OP_LENGTH + bitNreg + 5 * Nbit + 3) <= ALU_src2;
        pipe_id_out(INST_OP_LENGTH + bitNreg + 5 * Nbit + 4) <= branch;
        pipe_id_out(INST_OP_LENGTH + bitNreg + 5 * Nbit + 5) <= jump;
        pipe_id_out(INST_OP_LENGTH + bitNreg + 5 * Nbit + 6) <= mem_write;
        pipe_id_out(INST_OP_LENGTH + bitNreg + 5 * Nbit + 7) <= mem_read;
        pipe_id_alu_op_out <= ALU_operation;

        ex_comp : ex_stage port map
                 (clk => clk,
                  rstn => rstn,

                  sgn_ext_imm_ex => pipe_ex_in(3 * Nbit - 1 downto 2 * Nbit),
                  rf_data1_ex => pipe_ex_in(Nbit - 1 downto 0),
                  rf_data2_ex => pipe_ex_in(2 * Nbit - 1 downto Nbit),

                  pc_next_seq_ex => pipe_ex_in(5 * Nbit - 1 downto 4 * Nbit),
                  fin_jump_addr_ex => pipe_ex_in(4 * Nbit - 1 downto 3 * Nbit),
                  inst_op_ex => pipe_ex_in(INST_OP_LENGTH - 1 + bitNreg + 5 * Nbit downto 5 * Nbit + bitNreg),

                  alu_operation_ex => pipe_ex_alu_op_in,
                  alu_src1_ex => pipe_ex_in(INST_OP_LENGTH + bitNreg + 5 * Nbit + 2),
                  alu_src2_ex => pipe_ex_in(INST_OP_LENGTH + bitNreg + 5 * Nbit + 3),

                  pc_jump_branch_ex => pipe_ex_out(Nbit - 1 downto 0),
                  alu_res_ex => pipe_ex_out(2 * Nbit - 1 downto Nbit),

                  branch_ex => pipe_ex_in(INST_OP_LENGTH + bitNreg + 5 * Nbit + 4),
                  jump_ex => pipe_ex_in(INST_OP_LENGTH + bitNreg + 5 * Nbit + 5),

                  jump_branch_ex => pipe_ex_out(3 * Nbit + bitNreg + 4),

                  reg_dest_data_ex_mem => pipe_ex_out(3 * Nbit + bitNreg - 1 downto 3 * Nbit),
                  reg_dest_data_ex => pipe_ex_in(bitNreg - 1 + 5 * Nbit downto 5 * Nbit),
                  rf_data2_ex_mem => pipe_ex_out(3 * Nbit - 1 downto 2 * Nbit)
            );
        pipe_ex_out(3 * Nbit + bitNreg) <= pipe_ex_in(INST_OP_LENGTH + bitNreg + 5 * Nbit); -- mem2reg
        pipe_ex_out(3 * Nbit + bitNreg + 1) <= pipe_ex_in(INST_OP_LENGTH + bitNreg + 5 * Nbit + 1); -- reg write
        pipe_ex_out(3 * Nbit + bitNreg + 2) <= pipe_ex_in(INST_OP_LENGTH + bitNreg + 5 * Nbit + 6); -- mem write
        pipe_ex_out(3 * Nbit + bitNreg + 3) <= pipe_ex_in(INST_OP_LENGTH + bitNreg + 5 * Nbit + 7); -- mem read

        mem_comp : mem_stage port map
                  (clk => clk,
                   rstn => rstn,

                   mem_write_mem => pipe_mem_in(3 * Nbit + bitNreg + 2),
                   mem_read_mem => pipe_mem_in(3 * Nbit + bitNreg + 3),
                   alu_res_mem => pipe_mem_in(2 * Nbit - 1 downto Nbit),
                   read_data => read_data,
                   rf_data2_mem => pipe_mem_in(3 * Nbit - 1 downto 2 * Nbit),

                   rd_mem_data_mem => pipe_mem_out(Nbit - 1 downto 0),
                   address => address,
                   write_data => write_data,
                   enable_write => enable_write,
                   enable_read => enable_read,

                   alu_res_mem_wb => pipe_mem_out(2 * Nbit - 1 downto Nbit),
                   reg_dest_data_mem_wb => pipe_mem_out(bitNreg - 1 + 2 * Nbit  downto 2 * Nbit),
                   reg_dest_data_mem => pipe_mem_in(3 * Nbit + bitNreg - 1 downto 3 * Nbit),
                   pc_jump_branch_mem => pipe_mem_in(Nbit - 1 downto 0),
                   pc_jump_branch_mem_wb => pipe_mem_out(3 * Nbit + bitNreg - 1 + 2 downto 2 * Nbit + bitNreg + 2), -- not in pipe
                   jump_branch_mem => pipe_mem_in(3 * Nbit + bitNreg + 4),
                   jump_branch_mem_wb => pipe_mem_out(3 * Nbit + bitNreg - 1 + 3) -- not in pipe
            );

        pipe_mem_out(2 * Nbit + bitNreg) <= pipe_mem_in(3 * Nbit + bitNreg); -- mem2reg
        pipe_mem_out(2 * Nbit + bitNreg + 1) <= pipe_mem_in(3 * Nbit + bitNreg + 1); -- reg write

        wb_comp : wb_stage port map
                  (clk => clk,
                   rstn => rstn,

                   rd_mem_data_wb => pipe_wb_in(Nbit - 1 downto 0),
                   alu_res_wb => pipe_wb_in(2 * Nbit - 1 downto Nbit),
                   mem2reg_wb => pipe_wb_in(2 * Nbit + bitNreg),

                   rf_wr_data_wb => pipe_wb_out(Nbit - 1 downto 0),

                   reg_dest_data_wb => pipe_wb_in(bitNreg - 1 + 2 * Nbit  downto 2 * Nbit),
                   reg_dest_data_fb => pipe_wb_out(bitNreg - 1 + Nbit downto Nbit)
            );

        pipe_wb_out(bitNreg + Nbit) <= pipe_wb_in(2 * Nbit + bitNreg + 1); -- reg write

        pipe_gen : if pipe_flag = true generate
            pipe_if_id_reg : regn_std_logic_vector
                                generic map (N => pipe_if_out'length)
                                port map (clock => clk,
                                            resetN => rstn,
                                            en => if_id_reg_en,
                                            Q => pipe_id_in,
                                            D => pipe_if_out);
            pipe_id_ex_reg : regn_std_logic_vector
                                generic map (N => pipe_id_out'length)
                                port map (clock => clk,
                                            resetN => rstn,
                                            en => id_ex_reg_en,
                                            Q => pipe_ex_in,
                                            D => pipe_id_out);
            pipe_id_ex_dff_alu_op : dff_alu_opcode port map (
                                    D => pipe_id_alu_op_out,
                                    clock => clk,
                                    resetN => rstn,
                                    en => id_ex_reg_en,
                                    Q => pipe_ex_alu_op_in);
            pipe_ex_mem_reg : regn_std_logic_vector
                                generic map (N => pipe_ex_out'length)
                                port map (clock => clk,
                                            resetN => rstn,
                                            en => ex_mem_reg_en,
                                            Q => pipe_mem_in,
                                            D => pipe_ex_out);
            pipe_mem_wb_reg : regn_std_logic_vector
                                generic map (N => pipe_wb_in'length)
                                port map (clock => clk,
                                            resetN => rstn,
                                            en => mem_wb_reg_en,
                                            Q => pipe_wb_in,
                                            D => pipe_mem_out(2 * Nbit + bitNreg + 1 downto 0));
        end generate;
        no_pipe_gen : if pipe_flag = false generate
            pipe_id_in <= pipe_if_out;
            pipe_ex_in <= pipe_id_out;
            pipe_ex_alu_op_in <= pipe_id_alu_op_out;
            pipe_mem_in <= pipe_ex_out;
            pipe_wb_in <= pipe_mem_out(2 * Nbit + bitNreg + 1 downto 0);
        end generate;
    end behav;
