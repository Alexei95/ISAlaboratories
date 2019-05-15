LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- Flip Flop di tipo D, con parallelismo N e reset asincrono 

ENTITY dff IS
PORT (D : IN STD_LOGIC;  	-- ingresso
	Clock, Resetn, EN : IN STD_LOGIC;  			-- clock, reset, enable
	Q : OUT STD_LOGIC);  	-- uscita
END dff;

ARCHITECTURE Behavior OF dff IS
BEGIN
PROCESS (Clock)
BEGIN
	IF (Clock'EVENT AND Clock = '1') THEN  -- se c'è il fronte
	IF (resetn = '0') then
		q <= '0';   
	elsIF (EN='1') THEN  -- e enable è attivo
		Q <= D;
		END IF;
END IF;
END PROCESS;
END Behavior;
