library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fa is
    port (cin, a, b : in std_logic;
          cout, s : out std_logic);
end fa;

architecture behav of fa is
    begin
        cout <= (cin and a) or (cin and b) or (a and b);
        s <= cin xor a xor b;
    end behav;
