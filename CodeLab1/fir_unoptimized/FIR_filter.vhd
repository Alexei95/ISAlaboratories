LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

library std;
USE work.util.all; 

ENTITY FIR_filter IS 

PORT(	CLK: 	in std_logic; 
		RST_n:	in std_logic; 
		
		VIN: 	in std_logic; 
		VOUT:	out std_logic; 
		
		DIN: 	in signed (Nbit-1 downto 0); 
		DOUT:	out signed (Nbit-1 downto 0); 
		
		b:		in std_logic_vector(N * Nbit - 1 downto 0)); 
		
END ENTITY FIR_filter; 

ARCHITECTURE behavior OF FIR_filter IS 

COMPONENT regn IS
GENERIC (N: INTEGER := 16);  		
PORT (D : IN SIGNED (N-1 DOWNTO 0);  	-- input
	Clock, Resetn, EN : IN STD_LOGIC;  	-- clock, reset, enable
	Q : OUT SIGNED (N-1 DOWNTO 0));  	-- output
END COMPONENT regn;

component dff IS
PORT (D : IN STD_LOGIC;  	-- input
	Clock, Resetn, EN : IN STD_LOGIC;  	-- clock, reset, enable
	Q : OUT STD_LOGIC);  	-- output
END component;

SIGNAL xz: LIST_N;
SIGNAL mult: LIST_mult;
SIGNAL mult_resize: LIST_mult_resize; 
SIGNAL sum: LIST_sum; 

SIGNAL VIN_retard : std_logic; 

TYPE state IS (RESET,IDLE,DATA_CYCLE1,DATA_CYCLE2,LAST_DATA1);
SIGNAL present_state : state;
SIGNAL EN_REG_1,EN_REG_OUT,EN_SHIFT,RST_INT_n,EN_FIRST_REG: STD_LOGIC;

BEGIN 
---- DATAPATH------------------------------------------------

in_reg: regn 	generic map (N => Nbit)
				port map (D => DIN, Clock => CLK, Resetn => RST_INT_n, EN =>EN_FIRST_REG , Q => xz(0));
out_reg: regn	generic map (N => Nbit)
				port map (D => sum(N-2)(Nbit_result downto Nbit_result-Nbit+1), Clock => CLK, Resetn => RST_INT_n, EN => EN_REG_OUT, Q => DOUT);

shift_reg: for i in 0 to N-2 generate	
	reg_i: regn generic map (N => Nbit)
				port map (D => xz(i), Q => xz(i+1), Clock => CLK, Resetn => RST_INT_n, EN => EN_SHIFT);
end generate shift_reg;

multipliers: for i in 0 to N-1 generate	
	mult(i) <= signed(b((i + 1) * Nbit - 1 downto i * Nbit)) * xz(i); 
	mult_resize(i)(Nbit_result downto 0) <= mult(i)(Nbit+Nbit-1 downto Nbit-1);

adders: for i in 0 to N-2 generate 
	i_0: 	if (i=0) generate sum(i)<=mult_resize(i)+mult_resize(i+1); end generate;
	i_etc: 	if (i>0) generate sum(i)<=sum(i-1)+mult_resize(i+1); end generate; 
end generate adders;

--------CONTROL UNIT--------------------------------------------
state_process: PROCESS (CLK, RST_n, VIN)
BEGIN 
IF (RST_n='0') THEN present_state<=RESET; 
ELSIF (CLK'EVENT AND CLK='1') THEN
	CASE (present_state) IS
        -- reset
		WHEN RESET => present_state<= IDLE;
		WHEN IDLE => IF (VIN='1') THEN present_state <= DATA_CYCLE1; 
						ELSE present_state <= IDLE; 
						END IF;
		WHEN DATA_CYCLE1 => IF (VIN='0') THEN present_state <= LAST_DATA1; 
						ELSE present_state<=DATA_CYCLE2;
						END IF; 
		WHEN DATA_CYCLE2 => IF (VIN='0') THEN present_state <= LAST_DATA1; 
						ELSE present_state<=DATA_CYCLE2;
						END IF; 
        WHEN LAST_DATA1 =>  present_state <= IDLE; 
        
       END CASE;
END IF; 
END PROCESS state_process; 

output_process: PROCESS (present_state)
BEGIN 
VOUT<='0';
EN_REG_1<='0';
EN_REG_OUT<='0';
EN_SHIFT<='0';
RST_INT_n<='1';
	CASE (present_state) IS
        -- reset
		WHEN RESET => RST_INT_n<='0';
		WHEN IDLE => EN_REG_1<='1';
		WHEN DATA_CYCLE1 => EN_REG_OUT<='1';
							EN_SHIFT<='1';
		WHEN DATA_CYCLE2 => EN_REG_OUT<='1';
							EN_SHIFT<='1';
							VOUT<='1';
		WHEN LAST_DATA1 =>  VOUT<='1';
       END CASE;
END PROCESS output_process; 

EN_FIRST_REG<=(EN_REG_1 or EN_SHIFT);

END ARCHITECTURE behavior; 