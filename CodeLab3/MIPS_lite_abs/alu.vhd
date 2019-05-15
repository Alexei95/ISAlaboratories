library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.util.all;

entity alu is
    generic (Nbit : integer := 32);
    port (operand1, operand2 : in std_logic_vector(Nbit - 1 downto 0);
          result : out std_logic_vector(Nbit - 1 downto 0);
          zero : out std_logic;
          alu_opcode : in alu_opcode_states);
end alu;

architecture behav of alu is

    begin
        process(operand1, operand2, alu_opcode)
            variable temp, zeros : signed(Nbit - 1 downto 0);
            variable optemp1, optemp2 : signed(Nbit - 1 downto 0);
        begin
            zeros := (others => '0');
            optemp1 := signed(operand1);
            optemp2 := signed(operand2);

            if (alu_opcode = ADDOP) then
                temp := optemp1 + optemp2;
            elsif (alu_opcode = ANDOP) then
                for i in 0 to Nbit - 1 loop
                    temp(i) := optemp1(i) and optemp2(i);
                end loop;
            elsif (alu_opcode = OROP) then
                for i in 0 to Nbit - 1 loop
                    temp(i) := optemp1(i) or optemp2(i);
                end loop;
            elsif (alu_opcode = SHIFTRIGHTOP) then
                temp := shift_right(optemp2, to_integer(optemp1));
            elsif (alu_opcode = XOROP) then
                for i in 0 to Nbit - 1 loop
                    temp(i) := optemp1(i) xor optemp2(i);
                end loop;
            elsif (alu_opcode = SETLESSTHAN) then
                if (optemp1 < optemp2) then
                    temp(0) := '1';
                else
                    temp(0) := '0';
                end if;
                temp(Nbit - 1 downto 1) := (others => '0');
			elsif (alu_opcode = SUBOP) then
				temp := optemp1 - optemp2;
			elsif (alu_opcode = SHIFTLEFT16) then
                temp := shift_left(optemp2, 16);
            elsif (alu_opcode = ABSOP) then
                if (optemp1 < 0) then
                    temp := -optemp1;
                else
                    temp := optemp1;
                end if;
            else
                temp := (others => '0');
            end if;

            result <= std_logic_vector(temp);
            if (temp = zeros) then
                zero <= '1';
            else
                zero <= '0';
            end if;
        end process;
    end behav;
