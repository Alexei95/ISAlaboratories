library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ha is
    port (a, b : in std_logic;
          cout, s : out std_logic);
end ha;

architecture behav of ha is
    begin
        cout <= a and b;
        s <= a xor b;
    end behav;
