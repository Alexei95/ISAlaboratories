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
		
        -- we have Nbit * P types for Verilog, which does not support custom types
		DIN: 	in std_logic_vector(Nbit * P - 1 downto 0); 
		DOUT:	out std_logic_vector(Nbit * P -1 downto 0); 
		
		b:		in std_logic_vector(N * Nbit - 1 downto 0)); 
		
END ENTITY FIR_filter; 

ARCHITECTURE behavior OF FIR_filter IS 

COMPONENT regn IS
GENERIC (N: INTEGER := 16);  		
PORT (D : IN SIGNED (N-1 DOWNTO 0);  	-- input
	Clock, Resetn, EN : IN STD_LOGIC;  -- clock, reset, enable
	Q : OUT SIGNED (N-1 DOWNTO 0));  	-- output
END COMPONENT regn;

component dff IS
PORT (D : IN STD_LOGIC;  	-- input
	Clock, Resetn, EN : IN STD_LOGIC;  	-- clock, reset, enable
	Q : OUT STD_LOGIC);  	-- output
END component;

-- From util:
-- TYPE LIST_N IS ARRAY (0 to W3) OF SIGNED(Nbit-1 downto 0); 
-- TYPE LIST_mult IS ARRAY (0 to N-1) OF SIGNED(Nbit+Nbit-1 downto 0); 
-- TYPE LIST_mult_resize IS ARRAY (0 to N-1) OF SIGNED(Nbit downto 0); 
-- TYPE OUT_PIPES_TYPE 			IS ARRAY (0 TO P-1) OF LIST_N;
-- TYPE mult_array_TYPE 			IS ARRAY (0 TO P-1) OF LIST_mult;
-- TYPE mult_resize_array_TYPE 	IS ARRAY (0 TO P-1) OF LIST_mult_resize;

SIGNAL xz: OUT_PIPES_TYPE;
SIGNAL mult: mult_array_TYPE;
SIGNAL mult_out_pipe: mult_resize_array_TYPE;

SIGNAL mult_resize: LIST_mult_resize; 
SIGNAL sum_1_in,sum_2_in,sum_3in,sum_1_out,sum_2_out,sum_3out: LIST_sum_1; 
SIGNAL PIPE_REG_MULT_2_8: SIGNED(Nbit+1-1 downto 0);

TYPE sum1_reg_type is array (0 to 4-1) of SIGNED((Nbit+1)-1 downto 0);
TYPE sum1_type is array (0 to P-1) of sum1_reg_type;
SIGNAL sum1_reg_in,sum1_reg_out : sum1_type;

TYPE sum2_reg_type is array (0 to 2-1) of SIGNED((Nbit+2)-1 downto 0);
TYPE sum2_type is array (0 to P-1) of sum2_reg_type;
SIGNAL sum2_reg_in,sum2_reg_out : sum2_type;

TYPE sum3_type is array (0 to P-1) of SIGNED((Nbit+3)-1 downto 0);
SIGNAL sum3_reg_in,sum3_reg_out : sum3_type;
SIGNAL REG8_EXTENDED : SIGNED(Nbit+3-1 DOWNTO 0);

TYPE sum_final_type is array (0 to P-1) of SIGNED((Nbit+4)-1 downto 0);
SIGNAL sum_final : sum_final_type;

TYPE reg_8_reg_type is array (0 to 4-1) of SIGNED((Nbit+1)-1 downto 0);
TYPE reg_8_type is array (0 to P-1) of  reg_8_reg_type;
SIGNAL reg_8_value : reg_8_type;
SIGNAL reg_8_value_not_aggregate: signed(Nbit-1 downto 0);

TYPE pipelined_type is array (0 to 4) of std_logic;
SIGNAL en_shift_p,vout_p : pipelined_type;

SIGNAL VIN_retard : std_logic; 

TYPE state IS (RESET,IDLE,DATA_CYCLE1,DATA_CYCLE2,LAST_DATA1);
SIGNAL present_state : state;
SIGNAL EN_REG_1,EN_REG_OUT,EN_SHIFT,RST_INT_n,EN_FIRST_REG,VOUT1 : STD_LOGIC;

SIGNAL DOUT1,DOUT2,DOUT3 :SIGNED(Nbit-1 DOWNTO 0 );

BEGIN 
---- DATAPATH------------------------------------------------
EN_FIRST_REG<=(EN_REG_1 or EN_SHIFT);

-- 3 INPUT REGISTERS
in_reg_3k: regn 	generic map (N => Nbit)
				port map (D => signed(DIN(3 * Nbit - 1 downto 2 * Nbit)), Clock => CLK, Resetn => RST_INT_n, EN => EN_FIRST_REG , Q => xz(0)(0));
in_reg_3k_plus_1: regn 	generic map (N => Nbit)
				port map (D => signed(DIN(2 * Nbit - 1 downto Nbit)), Clock => CLK, Resetn => RST_INT_n, EN => EN_FIRST_REG , Q => xz(1)(0));
in_reg_3k_plus_2: regn 	generic map (N => Nbit)
				port map (D => signed(DIN(Nbit -1 downto 0)), Clock => CLK, Resetn => RST_INT_n, EN => EN_FIRST_REG , Q => xz(2)(0));

-- 3 OUTPUT REGISTERS	
out_reg_1: regn	generic map (N => Nbit)
				port map (D => sum_final(0)((Nbit+1)-1 downto (Nbit+1)-1-Nbit+1), Clock => CLK, Resetn => RST_INT_n, EN => en_shift_p(4), Q => DOUT1(Nbit -1 downto 0));
out_reg_2: regn	generic map (N => Nbit)
				port map (D => sum_final(1)((Nbit+1)-1 downto (Nbit+1)-1-Nbit+1), Clock => CLK, Resetn => RST_INT_n, EN => en_shift_p(4), Q => DOUT2(Nbit - 1 downto 0));
out_reg_3: regn	generic map (N => Nbit)
				port map (D => sum_final(2)((Nbit+1)-1 downto (Nbit+1)-1-Nbit+1), Clock => CLK, Resetn => RST_INT_n, EN => en_shift_p(4), Q => DOUT3(Nbit - 1 downto 0));	
-- 3 output data are aligned in a single vector
DOUT( Nbit - 1  downto 0)		<=std_logic_vector(DOUT3);
DOUT(2 * Nbit-1 downto Nbit)	<=std_logic_vector(DOUT2);
DOUT(3 * Nbit-1 downto 2*Nbit)	<=std_logic_vector(DOUT1);

-- registers for xn[3k]
shift_reg_3k: for i in 0 to W1-1 generate	
	reg_i: regn generic map (N => Nbit)
				port map (D => xz(0)(i), Q => xz(0)(i+1), Clock => CLK, Resetn => RST_INT_n, EN => EN_SHIFT);
end generate shift_reg_3k;

-- registers for xn[3k+1]
shift_reg_3k_plus_1: for i in 0 to W2-1 generate	
	reg_i: regn generic map (N => Nbit)
				port map (D => xz(1)(i), Q => xz(1)(i+1), Clock => CLK, Resetn => RST_INT_n, EN => EN_SHIFT);
end generate shift_reg_3k_plus_1;

-- registers for xn[3k+2]
shift_reg_3k_plus_2: for i in 0 to W3-1 generate	
	reg_i: regn generic map (N => Nbit)
				port map (D => xz(2)(i), Q => xz(2)(i+1), Clock => CLK, Resetn => RST_INT_n, EN => EN_SHIFT);
end generate shift_reg_3k_plus_2;

-- All the nine multiplications are performed in parallel in the three 
-- replicas of the original datapath
mult(0)(0)<= signed(b((0 + 1) * Nbit - 1 downto 0 * Nbit)) * xz(0)(0); 
mult(0)(1)<= signed(b((1 + 1) * Nbit - 1 downto 1 * Nbit)) * xz(2)(1);
mult(0)(2)<= signed(b((2 + 1) * Nbit - 1 downto 2 * Nbit)) * xz(1)(1);
mult(0)(3)<= signed(b((3 + 1) * Nbit - 1 downto 3 * Nbit)) * xz(0)(1);
mult(0)(4)<= signed(b((4 + 1) * Nbit - 1 downto 4 * Nbit)) * xz(2)(2);
mult(0)(5)<= signed(b((5 + 1) * Nbit - 1 downto 5 * Nbit)) * xz(1)(2);
mult(0)(6)<= signed(b((6 + 1) * Nbit - 1 downto 6 * Nbit)) * xz(0)(2);
mult(0)(7)<= signed(b((7 + 1) * Nbit - 1 downto 7 * Nbit)) * xz(2)(3);
mult(0)(8)<= signed(b((8 + 1) * Nbit - 1 downto 8 * Nbit)) * xz(1)(3);

mult(1)(0)<= signed(b((0 + 1) * Nbit - 1 downto 0 * Nbit)) * xz(1)(0);
mult(1)(1)<= signed(b((1 + 1) * Nbit - 1 downto 1 * Nbit)) * xz(0)(0);
mult(1)(2)<= signed(b((2 + 1) * Nbit - 1 downto 2 * Nbit)) * xz(2)(1);
mult(1)(3)<= signed(b((3 + 1) * Nbit - 1 downto 3 * Nbit)) * xz(1)(1);
mult(1)(4)<= signed(b((4 + 1) * Nbit - 1 downto 4 * Nbit)) * xz(0)(1);
mult(1)(5)<= signed(b((5 + 1) * Nbit - 1 downto 5 * Nbit)) * xz(2)(2);
mult(1)(6)<= signed(b((6 + 1) * Nbit - 1 downto 6 * Nbit)) * xz(1)(2);
mult(1)(7)<= signed(b((7 + 1) * Nbit - 1 downto 7 * Nbit)) * xz(0)(2);
mult(1)(8)<= signed(b((8 + 1) * Nbit - 1 downto 8 * Nbit)) * xz(2)(3);

mult(2)(0)<= signed(b((0 + 1) * Nbit - 1 downto 0 * Nbit)) * xz(2)(0);
mult(2)(1)<= signed(b((1 + 1) * Nbit - 1 downto 1 * Nbit)) * xz(1)(0);
mult(2)(2)<= signed(b((2 + 1) * Nbit - 1 downto 2 * Nbit)) * xz(0)(0);
mult(2)(3)<= signed(b((3 + 1) * Nbit - 1 downto 3 * Nbit)) * xz(2)(1);
mult(2)(4)<= signed(b((4 + 1) * Nbit - 1 downto 4 * Nbit)) * xz(1)(1);
mult(2)(5)<= signed(b((5 + 1) * Nbit - 1 downto 5 * Nbit)) * xz(0)(1);
mult(2)(6)<= signed(b((6 + 1) * Nbit - 1 downto 6 * Nbit)) * xz(2)(2);
mult(2)(7)<= signed(b((7 + 1) * Nbit - 1 downto 7 * Nbit)) * xz(1)(2);
mult(2)(8)<= signed(b((8 + 1) * Nbit - 1 downto 8 * Nbit)) * xz(0)(2);

-- registers at the output of multipliers
mult_reg: for i in 0 to P-1 generate	
			sec:for k in 0 to N-1 generate
				mult_reg_i: regn generic map (N => Nbit+1)
									port map (D => mult(i)(k)(Nbit+Nbit-1 downto Nbit-1) , Q => mult_out_pipe(i)(k), Clock => CLK, Resetn => RST_INT_n, EN => en_shift_p(0));
			end generate;
		 end generate mult_reg;

---- first layer of adders ---------------------------------------------------------
adders_1_1: process(mult_out_pipe)
			variable temp1,temp2,temp3: integer;
			begin
				for i in 0 to P-1 loop
					for k in 0 to 3 loop
						temp1:=to_integer(mult_out_pipe(i)(2*k+1));
						temp2:=to_integer(mult_out_pipe(i)(2*k));
						temp3:=temp1+temp2;
						sum1_reg_in(i)(k)<=to_signed(temp3,Nbit+1);
					end loop;
				end loop;
			end process;

----second layer of adders ---------------------------------------------------------
adders_2: process(sum1_reg_out)
			variable temp1,temp2,temp3: integer;
			begin
				for i in 0 to P-1 loop
					for k in 0 to 1 loop
						temp1:=to_integer(sum1_reg_out(i)(2*k+1));
						temp2:=to_integer(sum1_reg_out(i)(2*k));
						temp3:=temp1+temp2;
						sum2_reg_in(i)(k)<=to_signed(temp3,Nbit+2);
					end loop;
				end loop;
			end process;

--- third layer of adders-------------------------------------------------------------
adders_3: process(sum2_reg_out)
			variable temp1,temp2,temp3: integer;
			begin
				for i in 0 to P-1 loop
					temp1:=to_integer(sum2_reg_out(i)(0));
					temp2:=to_integer(sum2_reg_out(i)(1));
				temp3:=temp1+temp2;
				sum3_reg_in(i)<=to_signed(temp3,Nbit+3);
				
				end loop;
			end process;			
	 
---fourth layer of adders-------------------------------------------------------------

adders_4:process(reg_8_value,sum3_reg_out)
			variable temp1,temp2,temp3: integer;
			begin
				for i in 0 to P-1 loop
					temp1:=to_integer(reg_8_value(i)(3));
					temp2:=to_integer(sum3_reg_out(i));
				temp3:=temp1+temp2;
				sum_final(i)<=to_signed(temp3,Nbit+4);
				
				end loop;
			end process;



-------------reg_8 shift register------------------
shift_reg8: for i in 0 to P-1 generate	
				reg_8_value(i)(0)<=mult_out_pipe(i)(8);
			sec:for k in 0 to 2 generate
				shift_reg_8: regn generic map (N => Nbit+1)
				port map (D => reg_8_value(i)(k), Q => reg_8_value(i)(k+1), Clock => CLK, Resetn => RST_INT_n, EN => en_shift_p(k+1));
			end generate;
		 end generate shift_reg8;	

-------registers between adders -------------------
registri_vari: for i in 0 to P-1 generate	
			sum1_cycle:for k in 0 to 3 generate
				sum1_reg: regn generic map (N => Nbit+1)
				port map (D => sum1_reg_in(i)(k), Q => sum1_reg_out(i)(k), Clock => CLK, Resetn => RST_INT_n, EN => en_shift_p(1));
			end generate;
			sum2_cycle:for k in 0 to 1 generate
				sum2_reg: regn generic map (N => Nbit+2)
				port map (D => sum2_reg_in(i)(k), Q => sum2_reg_out(i)(k), Clock => CLK, Resetn => RST_INT_n, EN => en_shift_p(2));
			end generate;
			
			sum3_reg: regn generic map (N => Nbit+3)
				port map (D => sum3_reg_in(i), Q => sum3_reg_out(i), Clock => CLK, Resetn => RST_INT_n, EN => en_shift_p(3));
			
		 end generate registri_vari;	
		 
-----PIPE OF CONTROL SIGNALS------------------------------------
-- registers to shift enable signal 
pipe_registers_en_shift: for i in 0 to 3 generate	
	reg_i: dff 	port map (D => en_shift_p(i), Q => en_shift_p(i+1), Clock => CLK, Resetn => RST_INT_n, EN => '1');
end generate pipe_registers_en_shift;

 -- registers to shift vout signal 
pipe_registers_vout: for i in 0 to 3 generate	
	reg_i: dff port map (D => vout_p(i), Q => vout_p(i+1), Clock => CLK, Resetn => RST_INT_n, EN => '1');
end generate pipe_registers_vout;

en_shift_p(0)<=EN_SHIFT;
vout_p(0)<=VOUT1;
VOUT<=vout_p(4);


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
VOUT1<='0';
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
							VOUT1<='1';
		WHEN LAST_DATA1 =>  VOUT1<='1';
       END CASE;
END PROCESS output_process; 

END ARCHITECTURE behavior; 