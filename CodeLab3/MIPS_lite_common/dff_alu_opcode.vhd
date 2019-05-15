LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- Flip Flop di tipo D, con parallelismo N e reset asincrono

library work;
use work.util.all;

ENTITY dff_alu_opcode IS
PORT (D : IN alu_opcode_states;  	-- ingresso
	Clock, Resetn, EN : IN STD_LOGIC;  			-- clock, reset, enable
	Q : OUT alu_opcode_states);  	-- uscita
END dff_alu_opcode;

ARCHITECTURE Behavior OF dff_alu_opcode IS
BEGIN
PROCESS (Clock)
BEGIN

	IF (Clock'EVENT AND Clock = '1') THEN  -- se c'è il fronte
	IF (resetn = '0') then
		q <= NOP;
	elsIF (EN='1') THEN  -- e enable è attivo
		Q <= D;
		END IF;
END IF;
END PROCESS;
END Behavior;
