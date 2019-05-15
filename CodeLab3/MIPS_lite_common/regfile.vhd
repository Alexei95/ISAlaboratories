library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile is
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
end regfile;

architecture behav of regfile is
    component regn_std_logic_vector
        generic (N : integer := 32);
        port (D : in std_logic_vector(N - 1 downto 0);
              clock, resetN, en : in std_logic;
              Q : out std_logic_vector(N - 1 downto 0));
    end component;

    type reg_sig_buf is array(2 ** bitNregaddr - 1 downto 0) of
                        std_logic_vector(Nbitdata - 1 downto 0);
    signal data_out : reg_sig_buf;
    signal wr_en_reg : std_logic_vector(2 ** bitNregaddr - 1 downto 0);

    begin
        reg_gen : for i in 0 to 2 ** bitNregaddr - 1 generate
            reg_comp : regn_std_logic_vector
                            generic map (N => Nbitdata)
                            port map (D => data_wr_reg,
                                      clock => clk,
                                      resetN => rstn,
                                      en => wr_en_reg(i),
                                      Q => data_out(i));
        end generate;

        write_enable : process(addr_wr_reg, write_en)
            variable temp_wr_en_reg :
                            std_logic_vector(2 ** bitNregaddr - 1 downto 0);
        begin
            temp_wr_en_reg := (others => '0');
            temp_wr_en_reg(to_integer(unsigned(addr_wr_reg))) := '1';
            if (write_en = '1') then
                wr_en_reg <= temp_wr_en_reg;
            else
                wr_en_reg <= (others => '0');
            end if;
        end process;

        output_selection1 : process(addr_rd_reg1, data_out)
        begin
            data_rd_reg1 <= data_out(to_integer(unsigned(addr_rd_reg1)));
        end process;

        output_selection2 : process(addr_rd_reg2, data_out)
        begin
            data_rd_reg2 <= data_out(to_integer(unsigned(addr_rd_reg2)));
        end process;
    end behav;
