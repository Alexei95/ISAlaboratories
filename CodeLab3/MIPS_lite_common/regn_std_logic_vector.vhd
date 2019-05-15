LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- Flip Flop di tipo D, con parallelismo N e reset asincrono

ENTITY regn_std_logic_vector IS
GENERIC (N: INTEGER := 32);  					-- numero di bit del registro
PORT (D : IN std_logic_vector (N-1 DOWNTO 0);  	-- ingresso
	Clock, Resetn, EN : IN STD_LOGIC;  			-- clock, reset, enable
	Q : OUT std_logic_vector (N-1 DOWNTO 0));  	-- uscita
END regn_std_logic_vector;

ARCHITECTURE Behavior OF regn_std_logic_vector IS
BEGIN
PROCESS (Clock, Resetn)
BEGIN

	IF (Clock'EVENT AND Clock = '1') THEN  -- se c'è il fronte
	IF (resetn = '0') then
		q <= (others => '0');
	elsIF (EN='1') THEN  -- e enable è attivo
		Q <= D;
		END IF;
END IF;
END PROCESS;
END Behavior;
