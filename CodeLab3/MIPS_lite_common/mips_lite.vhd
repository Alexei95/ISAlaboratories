library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity mips_lite is
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
end mips_lite;

architecture behav of mips_lite is
    component datapath
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
    end component;

    component control_unit
        port (opcode : in std_logic_vector (OPCODE_LENGTH - 1 downto 0);
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
    end component;

    signal opcode : std_logic_vector(OPCODE_LENGTH - 1 downto 0);
    signal func :  std_logic_vector(FUNCT_LENGTH - 1 downto 0);
    signal reg_dest : std_logic;
    signal reg_write : std_logic;
    signal ALU_src1 : std_logic;
    signal ALU_src2 : std_logic;
    signal extension : std_logic;
    signal branch : std_logic;
    signal jump : std_logic;
    signal mem_write : std_logic;
    signal mem_read : std_logic;
    signal mem2reg : std_logic;
    signal ALU_operation: alu_opcode_states;

    signal inst_mem_rd : std_logic; -- always to 1
    signal pc_load : std_logic; -- always to 1

    signal if_id_reg_en : std_logic;
    signal id_ex_reg_en : std_logic;
    signal ex_mem_reg_en : std_logic;
    signal mem_wb_reg_en : std_logic;

    begin
        datapath_comp : datapath port map
                        (opcode => opcode,
                         func => func,
                         reg_dest => reg_dest,
                         reg_write => reg_write,
                         ALU_src1 => ALU_src1,
                         ALU_src2 => ALU_src2,
                         extension => extension,
                         branch => branch,
                         jump => jump,
                         mem_write => mem_write,
                         mem_read => mem_read,
                         mem2reg => mem2reg,
                         ALU_operation => ALU_operation,
                         inst_mem_rd_en => inst_mem_rd_en,
                         inst_mem_addr => inst_mem_addr,
                         inst_mem_data => inst_mem_data,
                         address => address,
                         write_data => write_data,
                         read_data => read_data,
                         enable_write => enable_write,
                         enable_read => enable_read,
                         inst_mem_rd => inst_mem_rd,
                         pc_load => pc_load,
                         if_id_reg_en => if_id_reg_en,
                         id_ex_reg_en => id_ex_reg_en,
                         ex_mem_reg_en => ex_mem_reg_en,
                         mem_wb_reg_en => mem_wb_reg_en,
                         clk => clk,
                         rstn => rstn);

        control_unit_comp : control_unit port map
                           (opcode => opcode,
                           func => func,
                           reg_dest => reg_dest,
                           reg_write => reg_write,
                           ALU_src1 => ALU_src1,
                           ALU_src2 => ALU_src2,
                           extension => extension,
                           branch => branch,
                           jump => jump,
                           mem_write => mem_write,
                           mem_read => mem_read,
                           mem2reg => mem2reg,
                           ALU_operation => ALU_operation);

        inst_mem_rd <= '1' when rstn = '1' else '0';
        pc_load <= '1' when rstn = '1' else '0';
        if_id_reg_en <= '1' when rstn = '1' else '0';
        id_ex_reg_en <= '1' when rstn = '1' else '0';
        ex_mem_reg_en <= '1' when rstn = '1' else '0';
        mem_wb_reg_en <= '1' when rstn = '1' else '0';

    end behav;
