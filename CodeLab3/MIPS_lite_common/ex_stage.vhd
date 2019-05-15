library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity ex_stage is
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
end ex_stage;

architecture behav of ex_stage is
    component alu
        generic (Nbit : integer := 32);
        port (operand1, operand2 : in std_logic_vector(Nbit - 1 downto 0);
            result : out std_logic_vector(Nbit - 1 downto 0);
            zero : out std_logic;
            alu_opcode : in alu_opcode_states);
    end component;

    signal alu_op1, alu_op2 : std_logic_vector(Nbit - 1 downto 0);
    signal zero_flag_ex : std_logic;
    signal branch_imm_offset : std_logic_vector(Nbit - 1 downto 0);
    signal fin_branch_flag_ex : std_logic;
    signal fin_seq_branch_addr : std_logic_vector(Nbit - 1 downto 0);
    signal fin_branch_addr : std_logic_vector(Nbit - 1 downto 0);

    begin
        alu_comp : alu generic map (Nbit => Nbit)
                       port map (operand1 => alu_op1,
                                 operand2 => alu_op2,
                                 result => alu_res_ex,
                                 alu_opcode => alu_operation_ex,
                                 zero => zero_flag_ex);

        alu_op2 <= rf_data2_ex when alu_src2_ex = C_registers2 else
                   sgn_ext_imm_ex;
        process(rf_data1_ex, alu_src1_ex, inst_op_ex)
        begin
            if (alu_src1_ex = C_registers1) then
                alu_op1 <= rf_data1_ex;
            else
                alu_op1(INST_OP_LENGTH - 1 downto 0) <= inst_op_ex;
                alu_op1(Nbit - 1 downto INST_OP_LENGTH) <= (others => '0');
            end if;
        end process;

        branch_imm_offset(Nbit - 1 downto Nbit - POS_LEFT_SHIFT_LENGTH) <= sgn_ext_imm_ex(POS_LEFT_SHIFT_TOP downto POS_LEFT_SHIFT_BOTTOM);
        branch_imm_offset(Nbit - POS_LEFT_SHIFT_LENGTH - 1 downto 0) <= (others => '0');

        -- signed sum for offset
        fin_branch_addr <= std_logic_vector(signed(branch_imm_offset) + signed(pc_next_seq_ex));

        fin_branch_flag_ex <= branch_ex and zero_flag_ex;

        pc_jump_branch_ex <= fin_branch_addr
                             when fin_branch_flag_ex = C_branch_yes else
                             fin_jump_addr_ex;

        jump_branch_ex <= fin_branch_flag_ex or jump_ex;

        reg_dest_data_ex_mem <= reg_dest_data_ex;
        rf_data2_ex_mem <= rf_data2_ex;

    end behav;
