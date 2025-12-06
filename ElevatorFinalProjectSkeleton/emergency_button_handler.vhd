library ieee;
use ieee.std_logic_1164.all;

entity emergency_button_handler is
    port (
        clk             : in  std_logic;
        rst_n           : in  std_logic;
        emergency_btn   : in  std_logic;
        emergency_active: out std_logic
    );
end entity;

architecture rtl of emergency_button_handler is
    signal emergency_reg : std_logic := '0';
begin
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            emergency_reg <= '0';

        elsif rising_edge(clk) then
        end if;
    end process;

    emergency_active <= emergency_reg;

end architecture;