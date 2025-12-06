library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Elevator_Controller is
    generic (
        NUM_PASSENGERS : integer := 20;
        NUM_FLOORS     : integer := 10
    );
    port (
        clk_5s   : in  std_logic;
        rst_n    : in  std_logic;
        sim_time : in unsigned(15 downto 0);
        floor_button    : in  std_logic_vector(NUM_FLOORS-1 downto 0);
        cancel_request  : in  std_logic_vector(NUM_FLOORS-1 downto 0);
        passenger_weight: in std_logic_vector(8*NUM_PASSENGERS-1 downto 0);
        door_open_btn   : in  std_logic;
        door_close_btn  : in  std_logic;
        emergency_btn   : in  std_logic;
        carrier_floor      : out unsigned(3 downto 0);
        carrier_door_state : out std_logic;
        emergency_active: out std_logic;
        overweight_flag : out std_logic;
        total_energy    : out unsigned(31 downto 0);
        avg_wait_time   : out unsigned(31 downto 0)
    );
end entity Elevator_Controller;

architecture structural of Elevator_Controller is

    signal floor_req_sig   : std_logic_vector(NUM_FLOORS-1 downto 0);
    signal cancel_sig      : std_logic_vector(NUM_FLOORS-1 downto 0);
    signal door_cmd_sig    : std_logic;
    signal emergency_sig   : std_logic;
    signal overweight_sig  : std_logic;
    signal opt_next_floor  : unsigned(3 downto 0);
    signal carrier_floor_sig      : unsigned(3 downto 0);
    signal carrier_door_state_sig : std_logic;
    signal energy_accum : unsigned(31 downto 0) := (others => '0');
    signal wait_total   : unsigned(31 downto 0) := (others => '0');
    signal wait_count   : unsigned(15 downto 0) := (others => '0');

begin
    floor_btn_inst : entity work.floor_button_handler
        port map (
            clk           => clk_5s,
            rst_n         => rst_n,
            floor_button  => floor_button,
            cancel_request=> cancel_request,
            floor_request => floor_req_sig
        );

    door_btn_inst : entity work.door_button_handler
        port map (
            clk           => clk_5s,
            rst_n         => rst_n,
            door_open_btn => door_open_btn,
            door_close_btn=> door_close_btn,
            door_command  => door_cmd_sig
        );

    emergency_inst : entity work.emergency_button_handler
        port map (
            clk             => clk_5s,
            rst_n           => rst_n,
            emergency_btn   => emergency_btn,
            emergency_active=> emergency_sig
        );

    overweight_inst : entity work.overweight_handler
        generic map (NUM_PASSENGERS => NUM_PASSENGERS)
        port map (
            clk              => clk_5s,
            rst_n            => rst_n,
            passenger_weight => passenger_weight,
            carrier_weight_ok=> '1', 
            overweight_flag  => overweight_sig
        );

    opt_inst : entity work.optimization_handler
        port map (
            clk            => clk_5s,
            rst_n          => rst_n,
            floor_requests => floor_req_sig,
            cancel_requests=> cancel_sig,
            current_floor  => carrier_floor_sig,
            next_floor     => opt_next_floor
        );

    motion_inst : entity work.motion_controller
        port map (
            clk             => clk_5s,
            rst_n           => rst_n,
            next_floor      => opt_next_floor,
            door_command    => door_cmd_sig,
            emergency_active=> emergency_sig,
            overweight_flag => overweight_sig,
            carrier_floor      => carrier_floor_sig,
            carrier_door_state => carrier_door_state_sig
        );

    metrics_proc : process(clk_5s, rst_n)
    begin
        if rst_n = '0' then
            energy_accum <= (others => '0');
            wait_total   <= (others => '0');
            wait_count   <= (others => '0');
        elsif rising_edge(clk_5s) then
        end if;
    end process;
    carrier_floor      <= carrier_floor_sig;
    carrier_door_state <= carrier_door_state_sig;
    emergency_active   <= emergency_sig;
    overweight_flag    <= overweight_sig;
    total_energy       <= energy_accum;
    avg_wait_time      <= (others => '0') when wait_count = 0 else resize(wait_total / wait_count, 32);

end architecture structural;