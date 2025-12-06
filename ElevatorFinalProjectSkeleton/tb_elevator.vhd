library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_elevator is
end entity;

architecture sim of tb_elevator is

    signal clk_5s   : std_logic := '0';
    signal rst_n    : std_logic := '0';
    signal sim_time : unsigned(15 downto 0) := (others => '0');
    signal passenger_enter_sig : std_logic_vector(19 downto 0);
    signal passenger_exit_sig  : std_logic_vector(19 downto 0);
    signal request_floor_sig   : std_logic_vector(4*20-1 downto 0);
    signal passenger_weight_sig: std_logic_vector(8*20-1 downto 0);
    signal total_energy_sig    : unsigned(31 downto 0);
    signal avg_wait_time_sig   : unsigned(31 downto 0);
    signal floor_button    : std_logic_vector(9 downto 0);
    signal cancel_request  : std_logic_vector(9 downto 0);
    signal door_open_btn   : std_logic := '0';
    signal door_close_btn  : std_logic := '0';
    signal emergency_btn   : std_logic := '0';
    signal carrier_floor      : unsigned(3 downto 0);
    signal carrier_door_state : std_logic;
    signal emergency_active   : std_logic;
    signal overweight_flag    : std_logic;
    signal total_energy       : unsigned(31 downto 0);
    signal avg_wait_time      : unsigned(31 downto 0);

begin
    clk_process : process
    begin
        while true loop
            clk_5s <= '0';
            wait for 2.5 sec;
            clk_5s <= '1';
            wait for 2.5 sec;
        end loop;
    end process;
    sim_time_process : process
    begin
        for t in 0 to 1200 loop 
            sim_time <= to_unsigned(t, sim_time'length);
            wait for 1 min;
        end loop;
        assert false report "Simulation complete after 20 hours" severity failure;
    end process;
    passenger_gen_inst : entity work.passenger_generator
        generic map (
            NUM_PASSENGERS => 20
        )
        port map (
            clk_5s           => clk_5s,
            rst_n            => rst_n,
            sim_time         => sim_time,
            passenger_enter  => passenger_enter_sig,
            passenger_exit   => passenger_exit_sig,
            request_floor    => request_floor_sig,
            passenger_weight => passenger_weight_sig,
            total_energy     => total_energy_sig,
            avg_wait_time    => avg_wait_time_sig
        );

    floor_map : process(passenger_exit_sig, request_floor_sig)
        variable dest_int : integer;
    begin
        floor_button   <= (others => '0');
        cancel_request <= (others => '0');

        for i in 0 to 19 loop
            dest_int := to_integer(unsigned(request_floor_sig((i*4+3) downto i*4)));
            if dest_int >= 1 and dest_int <= 10 then
                floor_button(dest_int-1) <= '1';
            end if;

            if passenger_exit_sig(i) = '1' then
                cancel_request(0) <= '1';
            end if;
        end loop;
    end process;

    dut : entity work.Elevator_Controller
        generic map (
            NUM_PASSENGERS => 20,
            NUM_FLOORS     => 10
        )
        port map (
            clk_5s           => clk_5s,
            rst_n            => rst_n,
            sim_time         => sim_time,
            floor_button     => floor_button,
            cancel_request   => cancel_request,
            passenger_weight => passenger_weight_sig,
            door_open_btn    => door_open_btn,
            door_close_btn   => door_close_btn,
            emergency_btn    => emergency_btn,
            carrier_floor      => carrier_floor,
            carrier_door_state => carrier_door_state,
            emergency_active   => emergency_active,
            overweight_flag    => overweight_flag,
            total_energy       => total_energy,
            avg_wait_time      => avg_wait_time
        );

    stim_proc : process
    begin
        rst_n <= '0';
        wait for 10 sec;
        rst_n <= '1';
        wait;
    end process;

end architecture;