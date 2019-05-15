LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE STD.Textio.all;

library std;
USE work.util.all; 

ENTITY signal_generator IS 
	PORT(	VIN: 	out std_logic; 
			DIN:	out std_logic_vector(P*Nbit-1 downto 0);
            RST_n : in std_logic;
            CLK : in std_logic;
            END_SIM : out std_logic;
			b: 		out std_logic_vector(Nbit * N - 1 downto 0));
END ENTITY signal_generator; 

ARCHITECTURE behavior OF signal_generator is

SUBTYPE word IS STD_LOGIC_VECTOR (Nbit-1 DOWNTO 0);
-- Array in cui salvare tutti i dati del file DATI_AB
TYPE word_array IS ARRAY (1 TO 1000) OF word;
SIGNAL input_data: word_array;

signal global_line_count : integer := 0;

BEGIN 

data_reading_process: PROCESS
	FILE in_file: TEXT open READ_MODE is "./samples_bin.txt";
	VARIABLE buf: LINE;
	VARIABLE d_v: CHARACTER;
    variable line_count : integer := 1;
	--VARIABLE i: INTEGER:=1;
	BEGIN 
    -- we first read all the file containing all the samples
	while not endfile(in_file) loop
		readline(in_file,buf);
		for h in Nbit-1 downto 0 loop
		 read(buf,d_v);
         -- we convert each line bit by bit
		 IF d_v='1' THEN
			input_data(line_count)(h)<='1';
		 ELSE 
			input_data(line_count)(h)<='0';
		 END IF;
		end loop;
        -- we increase the count of the lines
		line_count := line_count + 1;
	END LOOP;
	file_close(in_file);
    -- to communicate the total line count to the other process
    global_line_count <= line_count;
	wait;
END PROCESS data_reading_process; 

data_generation_process: PROCESS(CLK, RST_n)
    variable j : integer := 3;
    variable delay : integer := 0;
    variable end_int : boolean := false;
    variable w : boolean := false;
    variable wait_reset : boolean := false;
BEGIN
-- we avoid working during reset
if (RST_n = '0') then
    DIN<=(OTHERS => '0');
    VIN<='0';
    END_SIM <= '0';
else
    -- we work on falling edges to avoid simulation errors
    if (falling_edge(CLK)) then
        -- we wait 1 cycle after issuing the reset to ensure the correct
        -- resetting of the whole machine
        if (wait_reset = true) then
            -- standard cycle, 3 by 3
            if (j < global_line_count and end_int = false) then
                -- this if is needed to stop the execution for some time
                -- to check the correct behaviour while VIN = 0
                if (w = false and (j < 100 and j > 90)) then
                    VIN <= '0';
                    j := j + 1;
                    if (j = 99) then
                        w := true;
                        j := 93;
                    end if;
                else
                    -- input data at each cycle
                    VIN<='1';
                    DIN<=input_data(j-2) & input_data(j-1) & input_data(j);
                    END_SIM <= '0';
                    j := j + 3;
                end if;
            -- check for the end of the simulation after passing all inputs
            elsif (end_int = false) then
                end_int := true;
                VIN <= '0';
            -- we wait for some time before stopping the simulation
            elsif (end_int = true and delay < FINAL_DELAY) then
                delay := delay + 1;
            -- stop the simulation
            elsif (end_int = true and delay >= FINAL_DELAY) then
                END_SIM <= '1';
            end if;
        else
            wait_reset := true;
        end if;
    end if;
end if;
END PROCESS data_generation_process;

b <= "1111111100" & "1111111001" & "0000011010" & "0010001000" & "0011001111" & "0010001000" & "0000011010" & "1111111001" & "1111111100";

END ARCHITECTURE behavior; 
