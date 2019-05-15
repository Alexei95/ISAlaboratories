LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use ieee.math_real.all;

PACKAGE util IS 

CONSTANT Nbit: INTEGER := 10; 
CONSTANT N: INTEGER := 9;
--CONSTANT Nbit_result: INTEGER := Nbit+integer(ceil(log2(real(N)))); 
CONSTANT Nbit_result: INTEGER := Nbit;

CONSTANT FINAL_DELAY : integer := N + 5;

CONSTANT T: time := 20 ns; -- Clock period
CONSTANT start_time: time := 101 ns; -- Start time of simulation 

TYPE LIST_N IS ARRAY (0 to N-1) OF SIGNED(Nbit-1 downto 0); 
TYPE LIST_mult IS ARRAY (0 to N-1) OF SIGNED(Nbit+Nbit-1 downto 0); 
TYPE LIST_mult_resize IS ARRAY (0 to N-1) OF SIGNED(Nbit_result downto 0); 
TYPE LIST_sum IS ARRAY (0 to N-2) OF SIGNED(Nbit_result downto 0);

END util; 