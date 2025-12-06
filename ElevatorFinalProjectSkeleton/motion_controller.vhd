library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity motion_controller is
    port (
        clk             : in  std_logic;
        rst_n           : in  std_logic;
        next_floor      : in unsigned(3 downto 0);
        door_command    : in std_logic;
        emergency_active: in std_logic;
        overweight_flag : in std_logic;

        carrier_floor      : out unsigned(3 downto 0);
        carrier_door_state : out std_logic
    );
end entity;

architecture rtl of motion_controller is
    signal current_floor_reg : unsigned(3 downto 0) := (others => '0');
    signal door_state_reg    : std_logic := '0';
begin
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            current_floor_reg <= (others => '0');
            door_state_reg    <= '0';

        elsif rising_edge(clk) then
        end if;
    end process;

    carrier_floor      <= current_floor_reg;
    carrier_door_state <= door_state_reg;

end architecture;