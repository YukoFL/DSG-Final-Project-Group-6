library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity floor_button_handler is
    generic (
        NUM_FLOORS : integer := 10
    );
    port (
        clk           : in  std_logic;
        rst_n         : in  std_logic;
        floor_button  : in  std_logic_vector(NUM_FLOORS-1 downto 0);
        cancel_request: in  std_logic_vector(NUM_FLOORS-1 downto 0);
        floor_request : out std_logic_vector(NUM_FLOORS-1 downto 0)
    );
end entity;

architecture rtl of floor_button_handler is
    signal request_reg : std_logic_vector(NUM_FLOORS-1 downto 0);
begin
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            request_reg <= (others => '0');

        elsif rising_edge(clk) then
            request_reg <= request_reg or floor_button;
            request_reg <= request_reg and not(cancel_request);
        end if;
    end process;

    floor_request <= request_reg;

end architecture;