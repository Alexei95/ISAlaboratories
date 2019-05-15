library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package util is

    constant pipe_flag_logic : std_logic := '1';




    constant pipe_flag : boolean := pipe_flag_logic = '1';

    constant Nbit : integer := 32;
    constant bitNreg : integer := 5;

	constant Nbit_address : integer := 9;

    type alu_opcode_states is (NOP, ADDOP, ANDOP, OROP, SHIFTRIGHTOP, XOROP,
                               SETLESSTHAN, SUBOP, SHIFTLEFT16, ABSOP);

    constant alu_opcode_length : integer :=
						alu_opcode_states'pos(alu_opcode_states'right) + 1;

    constant rising : std_logic := '1';
    constant falling : std_logic := '0';

    constant clock_inst_mem : std_logic := rising xor pipe_flag_logic;
    constant clock_PC : std_logic := falling xor pipe_flag_logic;

    constant clock_data_mem : std_logic := falling;

	-- reg_dst
	constant C_i_20_16 : STD_LOGIC := '1';
	constant C_i_15_11 : STD_LOGIC := '0';

	-- reg_write
	constant C_reg_enable : STD_LOGIC := '1';
	constant C_reg_disable : STD_LOGIC := '0';

	-- ALU_src1
	constant C_registers1 : STD_LOGIC := '0';
	constant C_i_10_6 : STD_LOGIC := '1';

	-- ALU src2
	constant C_registers2 : STD_LOGIC := '1';
	constant C_sign_extension : STD_LOGIC := '0';

	-- branch
	constant c_branch_yes : STD_LOGIC := '1';
	constant C_branch_no : STD_LOGIC := '0';

	-- jump
	constant C_jump_yes : STD_LOGIC := '1';
	constant C_jump_no : STD_LOGIC := '0';

	-- mem_write
	constant C_mw_enable : STD_LOGIC := '1';
	constant C_mw_disable : STD_LOGIC := '0';

	-- mem_read
	constant C_mr_enable : STD_LOGIC := '1';
	constant C_mr_disable : STD_LOGIC := '0';

	-- mem2reg
	constant C_memory : STD_LOGIC := '1';
	constant C_result : STD_LOGIC := '0';

	-- extension
	constant C_ext_sign : STD_LOGIC := '1';
	constant C_ext_zero : STD_LOGIC := '0';

	-- positions for instruction/pc
	-- regfile address1
	constant POS_REG1_ADDR_TOP : integer := 25;
	constant POS_REG1_ADDR_BOTTOM : integer := 21;

	-- regfile address2
	constant POS_REG2_ADDR_TOP : integer := 20;
	constant POS_REG2_ADDR_BOTTOM : integer := 16;

	-- destination 1 regfile
	constant POS_REG_DEST_ADDR1_TOP : integer := 20;
	constant POS_REG_DEST_ADDR1_BOTTOM : integer := 16;

	-- destination 2 regfile
	constant POS_REG_DEST_ADDR2_TOP : integer := 15;
	constant POS_REG_DEST_ADDR2_BOTTOM : integer := 11;

	-- operand in instruction
	constant POS_INST_OP_TOP : integer := 10;
	constant POS_INST_OP_BOTTOM : integer := 6;
	constant INST_OP_LENGTH : integer := POS_INST_OP_TOP - POS_INST_OP_BOTTOM + 1;

	-- immediate
	constant POS_IMMEDIATE_TOP : integer := 15;
	constant POS_IMMEDIATE_BOTTOM : integer := 0;
	constant IMMEDIATE_LENGTH : integer := POS_IMMEDIATE_TOP - POS_IMMEDIATE_BOTTOM + 1;

	-- jump address
	constant POS_JUMP_ADDRESS_TOP : integer := 25;
	constant POS_JUMP_ADDRESS_BOTTOM : integer := 0;
	constant POS_JUMP_ADDRESS_LENGTH : integer := POS_JUMP_ADDRESS_TOP - POS_JUMP_ADDRESS_BOTTOM + 1;

	-- pc msb for jump address
	constant POS_PC_MSB_TOP : integer := 31;
	constant POS_PC_MSB_BOTTOM : integer := 28;
	constant POS_PC_MSB_LENGTH : integer := POS_PC_MSB_TOP - POS_PC_MSB_BOTTOM + 1;

	-- opcode
	constant POS_OPCODE_TOP : integer := 31;
	constant POS_OPCODE_BOTTOM : integer := 26;
	constant OPCODE_LENGTH : integer := POS_OPCODE_TOP - POS_OPCODE_BOTTOM + 1;

	-- funct
	constant POS_FUNCT_TOP : integer := 5;
	constant POS_FUNCT_BOTTOM : integer := 0;
	constant FUNCT_LENGTH : integer := POS_FUNCT_TOP - POS_FUNCT_BOTTOM + 1;

	-- ex_right_shift
	constant POS_LEFT_SHIFT_TOP : integer := Nbit - 1 - 2;
	constant POS_LEFT_SHIFT_BOTTOM : integer := 0;
	constant POS_LEFT_SHIFT_LENGTH : integer := POS_LEFT_SHIFT_TOP - POS_LEFT_SHIFT_BOTTOM + 1;

	-- PC offset
	constant PC_N_BIT_OFFSET : integer := 2;
	constant PC_OFFSET : unsigned(Nbit - 1 downto 0) :=  (PC_N_BIT_OFFSET => '1',
														others => '0');
	constant PC_OFFSET_INT : integer := to_integer(PC_OFFSET);

	-- instruction memory
	constant length_memory : integer := 7;
	constant word_length : integer := Nbit / PC_OFFSET_INT;
END util;
