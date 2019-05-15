LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use ieee.math_real.all;

PACKAGE util IS 

CONSTANT Nbit: INTEGER := 10; 
CONSTANT N: INTEGER := 9;-- number of coefficients
CONSTANT P: INTEGER := 3; --- unfolding factor
CONSTANT W1: INTEGER := 2; --- MAX NUMBER OF INTERMEDIATE REGISTER FOR DIN(P*K)
CONSTANT W2: INTEGER := 3; --- MAX NUMBER OF INTERMEDIATE REGISTER FOR DIN(P*K+1)
CONSTANT W3: INTEGER := 3; --- MAX NUMBER OF INTERMEDIATE REGISTER FOR DIN(P*K+2)

CONSTANT Nbit_result: INTEGER := Nbit;

CONSTANT FINAL_DELAY : integer := N + 5;

CONSTANT T: time := 20 ns; -- Clock period
CONSTANT start_time: time := 101 ns; --Start time of simulation

TYPE LIST_N IS ARRAY (0 to W3) OF SIGNED(Nbit-1 downto 0); 
TYPE LIST_mult IS ARRAY (0 to N-1) OF SIGNED(Nbit+Nbit-1 downto 0); 
TYPE LIST_mult_resize IS ARRAY (0 to N-1) OF SIGNED(Nbit downto 0); 

TYPE LIST_sum_1 IS ARRAY (0 to (N/2)-1) OF SIGNED((Nbit+1)-1 downto 0);
TYPE LIST_sum_2 IS ARRAY (0 to ((((N*P)/2)-1)/2)+1) OF SIGNED(Nbit downto 0);
----array used in folding structure------------------------------------------
TYPE input_format_type 			IS ARRAY (0 to P-1) OF SIGNED(Nbit-1 downto 0); 
TYPE OUT_PIPES_TYPE 			IS ARRAY (0 TO P-1) OF LIST_N;
TYPE mult_array_TYPE 			IS ARRAY (0 TO P-1) OF LIST_mult;
TYPE mult_resize_array_TYPE 	IS ARRAY (0 TO P-1) OF LIST_mult_resize;

END util; 