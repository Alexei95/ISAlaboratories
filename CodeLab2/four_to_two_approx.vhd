library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity four_to_two_approx is
    port (a, b, c, d : in std_logic;
          cout, s : out std_logic);
end four_to_two_approx;

architecture behav of four_to_two_approx is
    begin
        cout <= ((a nor b) nor (c nor d));
        s <= c xnor d;
    end behav;
