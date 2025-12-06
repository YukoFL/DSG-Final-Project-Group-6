library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_floor_request_manager is
end tb_floor_request_manager;

architecture sim of tb_floor_request_manager is
    signal clk            : STD_LOGIC := '0';
    signal reset          : STD_LOGIC := '0';
    signal add_req        : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal cancel_req     : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal emergency_stop : STD_LOGIC := '0';
    signal active_floors  : STD_LOGIC_VECTOR(7 downto 0);

begin
    uut: entity work.floor_request_manager
        port map (
            clk => clk,
            reset => reset,
            add_req => add_req,
            cancel_req => cancel_req,
            emergency_stop => emergency_stop,
            active_floors => active_floors
        );

    clk <= not clk after 5 ns;

    process
    begin
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        add_req <= "00001000";
        wait for 10 ns;
        add_req <= (others => '0');

        cancel_req <= "00001000";
        wait for 10 ns;
        cancel_req <= (others => '0');

         emergency_stop <= '1';
        wait for 10 ns;
        emergency_stop <= '0';

        wait;
    end process;

end sim;
