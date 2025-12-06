library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity optimization_handler is
    generic (
        NUM_FLOORS : integer := 10
    );
    port (
        clk            : in  std_logic;
        rst_n          : in  std_logic;
        floor_requests : in  std_logic_vector(NUM_FLOORS-1 downto 0);
        cancel_requests: in  std_logic_vector(NUM_FLOORS-1 downto 0);
        current_floor  : in unsigned(3 downto 0);
        next_floor     : out unsigned(3 downto 0)
    );
end entity;

architecture rtl of optimization_handler is
    signal next_floor_reg : unsigned(3 downto 0) := (others => '0');
begin
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            next_floor_reg <= (others => '0');

        elsif rising_edge(clk) then
        end if;
    end process;

    next_floor <= next_floor_reg;

end architecture;