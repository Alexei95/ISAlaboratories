library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity control_unit is
port (	opcode : in std_logic_vector (OPCODE_LENGTH - 1 downto 0);
		func : in std_logic_vector (FUNCT_LENGTH - 1 downto 0);
		reg_dest : out std_logic;
		reg_write : out std_logic;
		ALU_src1 : out std_logic;
		ALU_src2 : out std_logic;
		extension : out std_logic;
		branch : out std_logic;
		jump : out std_logic;
		mem_write : out std_logic;
		mem_read : out std_logic;
		mem2reg : out std_logic;
		ALU_operation: out alu_opcode_states);
end entity control_unit;

architecture behavior of control_unit is

signal opcode_long, func_long : std_logic_vector (OPCODE_LENGTH + 2 - 1 downto 0);

begin

opcode_long <= "00" & opcode;
func_long <= "00" & func;

cu_process : process (opcode_long, func_long)
begin
	case opcode_long is
		when x"00" =>
					case func_long is
						-- nop
						when x"00" => 	reg_dest <= C_i_15_11;
										reg_write <= C_reg_disable;
										ALU_src1 <= C_registers1;
										ALU_src2 <= C_registers2;
										extension <= C_ext_zero;
										branch <= C_branch_no;
										jump <= C_jump_no;
										mem_write <= C_mw_disable;
										mem_read <= C_mr_disable;
										mem2reg <= C_result;
										ALU_operation <= NOP;
						-- add
						when x"20" => 	reg_dest <= C_i_15_11;
										reg_write <= C_reg_enable;
										ALU_src1 <= C_registers1;
										ALU_src2 <= C_registers2;
										extension <= C_ext_zero;
										branch <= C_branch_no;
										jump <= C_jump_no;
										mem_write <= C_mw_disable;
										mem_read <= C_mr_disable;
										mem2reg <= C_result;
										ALU_operation <= ADDOP;
						-- slt
						when x"2a" => 	reg_dest <= C_i_15_11;
										reg_write <= C_reg_enable;
										ALU_src1 <= C_registers1;
										ALU_src2 <= C_registers2;
										extension <= C_ext_zero;
										branch <= C_branch_no;
										jump <= C_jump_no;
										mem_write <= C_mw_disable;
										mem_read <= C_mr_disable;
										mem2reg <= C_result;
										ALU_operation <= SETLESSTHAN;
						-- xor
						when x"26" =>	reg_dest <= C_i_15_11;
										reg_write <= C_reg_enable;
										ALU_src1 <= C_registers1;
										ALU_src2 <= C_registers2;
										extension <= C_ext_zero;
										branch <= C_branch_no;
										jump <= C_jump_no;
										mem_write <= C_mw_disable;
										mem_read <= C_mr_disable;
										mem2reg <= C_result;
										ALU_operation <= XOROP;
						-- sra
						when x"03" =>	reg_dest <= C_i_15_11;
										reg_write <= C_reg_enable;
										ALU_src1 <= C_i_10_6;
										ALU_src2 <= C_registers2;
										extension <= C_ext_zero;
										branch <= C_branch_no;
										jump <= C_jump_no;
										mem_write <= C_mw_disable;
										mem_read <= C_mr_disable;
										mem2reg <= C_result;
										ALU_operation <= SHIFTRIGHTOP;

						when others => 	reg_dest <= C_i_15_11;
										reg_write <= C_reg_disable;
										ALU_src1 <= C_registers1;
										ALU_src2 <= C_registers2;
										extension <= C_ext_zero;
										branch <= C_branch_no;
										jump <= C_jump_no;
										mem_write <= C_mw_disable;
										mem_read <= C_mr_disable;
										mem2reg <= C_result;
										ALU_operation <= NOP;
					end case;
		-- addi
		when x"08" => 	reg_dest <= C_i_20_16;
						reg_write <= C_reg_enable;
						ALU_src1 <= C_registers1;
						ALU_src2 <= C_sign_extension;
						extension <= C_ext_sign;
						branch <= C_branch_no;
						jump <= C_jump_no;
						mem_write <= C_mw_disable;
						mem_read <= C_mr_disable;
						mem2reg <= C_result;
						ALU_operation <= ADDOP;
		-- andi
		when x"0c" => 	reg_dest <= C_i_20_16;
						reg_write <= C_reg_enable;
						ALU_src1 <= C_registers1;
						ALU_src2 <= C_sign_extension;
						extension <= C_ext_zero;
						branch <= C_branch_no;
						jump <= C_jump_no;
						mem_write <= C_mw_disable;
						mem_read <= C_mr_disable;
						mem2reg <= C_result;
						ALU_operation <= ANDOP;
		-- beq
		when x"04" => 	reg_dest <= C_i_15_11;
						reg_write <= C_reg_disable;
						ALU_src1 <= C_registers1;
						ALU_src2 <= C_registers2;
						extension <= C_ext_sign;
						branch <= C_branch_yes;
						jump <= C_jump_no;
						mem_write <= C_mw_disable;
						mem_read <= C_mr_disable;
						mem2reg <= C_result;
						ALU_operation <= SUBOP;
		-- j
		when x"02" =>	reg_dest <= C_i_15_11;
						reg_write <= C_reg_disable;
						ALU_src1 <= C_registers1;
						ALU_src2 <= C_registers2;
						extension <= C_ext_zero;
						branch <= C_branch_no;
						jump <= C_jump_yes;
						mem_write <= C_mw_disable;
						mem_read <= C_mr_disable;
						mem2reg <= C_result;
						ALU_operation <= NOP;
		-- lui
		when x"0f" => 	reg_dest <= C_i_20_16;
						reg_write <= C_reg_enable;
						ALU_src1 <= C_registers1;
						ALU_src2 <= C_sign_extension;
						extension <= C_ext_zero;
						branch <= C_branch_no;
						jump <= C_jump_no;
						mem_write <= C_mw_disable;
						mem_read <= C_mr_disable;
						mem2reg <= C_result;
						ALU_operation <= SHIFTLEFT16;
		-- lw
		when x"23" => 	reg_dest <= C_i_20_16;
						reg_write <= C_reg_enable;
						ALU_src1 <= C_registers1;
						ALU_src2 <= C_sign_extension;
						extension <= C_ext_sign;
						branch <= C_branch_no;
						jump <= C_jump_no;
						mem_write <= C_mw_disable;
						mem_read <= C_mr_enable;
						mem2reg <= C_memory;
						ALU_operation <= ADDOP;
		-- ori
		when x"0d" => 	reg_dest <= C_i_20_16;
						reg_write <= C_reg_enable;
						ALU_src1 <= C_registers1;
						ALU_src2 <= C_sign_extension;
						extension <= C_ext_zero;
						branch <= C_branch_no;
						jump <= C_jump_no;
						mem_write <= C_mw_disable;
						mem_read <= C_mr_disable;
						mem2reg <= C_result;
						ALU_operation <= OROP;
		-- sw
		when x"2b" => 	reg_dest <= C_i_20_16;
						reg_write <= C_reg_disable;
						ALU_src1 <= C_registers1;
						ALU_src2 <= C_sign_extension;
						extension <= C_ext_sign;
						branch <= C_branch_no;
						jump <= C_jump_no;
						mem_write <= C_mw_enable;
						mem_read <= C_mr_disable;
						mem2reg <= C_result;
						ALU_operation <= ADDOP;


		when others =>	reg_dest <= C_i_15_11;
						reg_write <= C_reg_disable;
						ALU_src1 <= C_registers1;
						ALU_src2 <= C_registers2;
						extension <= C_ext_zero;
						branch <= C_branch_no;
						jump <= C_jump_no;
						mem_write <= C_mw_disable;
						mem_read <= C_mr_disable;
						mem2reg <= C_result;
						ALU_operation <= NOP;
	end case;
end process cu_process;

end architecture behavior;
