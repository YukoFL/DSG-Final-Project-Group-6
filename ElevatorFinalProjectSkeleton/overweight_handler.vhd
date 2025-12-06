library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity overweight_handler is
    generic (
        NUM_PASSENGERS : integer := 20;
        MAX_WEIGHT     : integer := 1000 
    );
    port (
        clk              : in  std_logic;
        rst_n            : in  std_logic;
        passenger_weight : in std_logic_vector(8*NUM_PASSENGERS-1 downto 0);
        carrier_weight_ok: in std_logic;
        overweight_flag  : out std_logic
    );
end entity;

architecture rtl of overweight_handler is
    signal total_weight : integer := 0;
    signal overweight_reg : std_logic := '0';
begin
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            total_weight   <= 0;
            overweight_reg <= '0';

        elsif rising_edge(clk) then
        end if;
    end process;

    overweight_flag <= overweight_reg;

end architecture;