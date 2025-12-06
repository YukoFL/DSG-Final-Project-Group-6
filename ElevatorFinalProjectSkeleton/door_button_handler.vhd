library ieee;
use ieee.std_logic_1164.all;

entity door_button_handler is
    port (
        clk           : in  std_logic;
        rst_n         : in  std_logic;
        door_open_btn : in  std_logic;
        door_close_btn: in  std_logic;
        door_command  : out std_logic 
    );
end entity;

architecture rtl of door_button_handler is
    signal door_cmd_reg : std_logic := '0';
begin
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            door_cmd_reg <= '0';

        elsif rising_edge(clk) then
        end if;
    end process;

    door_command <= door_cmd_reg;

end architecture;