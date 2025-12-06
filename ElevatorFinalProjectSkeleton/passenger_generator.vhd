library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity passenger_generator is
    generic (
        NUM_PASSENGERS : integer := 20
    );
    port (
        clk_5s   : in  std_logic;
        rst_n    : in  std_logic;
        sim_time : in unsigned(15 downto 0);

        passenger_enter : out std_logic_vector(NUM_PASSENGERS-1 downto 0);
        passenger_exit  : out std_logic_vector(NUM_PASSENGERS-1 downto 0);
        request_floor   : out std_logic_vector(4*NUM_PASSENGERS-1 downto 0);
        passenger_weight: out std_logic_vector(8*NUM_PASSENGERS-1 downto 0);

        total_energy    : out unsigned(31 downto 0);
        avg_wait_time   : out unsigned(31 downto 0)
    );
end entity;

architecture behavioral of passenger_generator is

    type passenger_state_t is (STATE_IDLE, STATE_WAIT, STATE_TRAVEL, STATE_EXIT, STATE_DONE);

    type passenger_t is record
        state       : passenger_state_t;
        weight      : unsigned(7 downto 0);
        arrival_min : unsigned(15 downto 0);
        dest_fl     : unsigned(3 downto 0);
        wait_accum  : unsigned(15 downto 0);
    end record;

    type passenger_array_t is array (0 to NUM_PASSENGERS-1) of passenger_t;
    signal passengers : passenger_array_t;

    signal enter_sig : std_logic_vector(NUM_PASSENGERS-1 downto 0);
    signal exit_sig  : std_logic_vector(NUM_PASSENGERS-1 downto 0);
    signal floor_sig : std_logic_vector(4*NUM_PASSENGERS-1 downto 0);
    signal weight_sig: std_logic_vector(8*NUM_PASSENGERS-1 downto 0);
    signal energy_accum : unsigned(31 downto 0) := (others => '0');
    signal wait_total   : unsigned(31 downto 0) := (others => '0');
    signal wait_count   : unsigned(15 downto 0) := (others => '0');
    signal lfsr : std_logic_vector(15 downto 0) := x"ACE1";

begin
    process(clk_5s, rst_n)
    begin
        if rst_n = '0' then
            lfsr <= x"ACE1";
        elsif rising_edge(clk_5s) then
            lfsr <= lfsr(14 downto 0) & (lfsr(15) xor lfsr(13) xor lfsr(12) xor lfsr(10));
        end if;
    end process;

    process(clk_5s, rst_n)
        variable rand_val : integer;
    begin
        if rst_n = '0' then
            enter_sig    <= (others => '0');
            exit_sig     <= (others => '0');
            floor_sig    <= (others => '0');
            weight_sig   <= (others => '0');
            energy_accum <= (others => '0');
            wait_total   <= (others => '0');
            wait_count   <= (others => '0');

            for i in 0 to NUM_PASSENGERS-1 loop
                rand_val := to_integer(unsigned(lfsr)) + i*37;

                passengers(i).arrival_min <= to_unsigned(rand_val mod 200, 16); 
                passengers(i).weight      <= to_unsigned(60 + (rand_val mod 41), 8); 
                passengers(i).state       <= STATE_IDLE;
                passengers(i).dest_fl     <= (others => '0');
                passengers(i).wait_accum  <= (others => '0');
            end loop;

        elsif rising_edge(clk_5s) then
            enter_sig <= (others => '0');
            exit_sig  <= (others => '0');

            for i in 0 to NUM_PASSENGERS-1 loop
                rand_val := to_integer(unsigned(lfsr)) + i*11;

                case passengers(i).state is
                    when STATE_IDLE =>
                        if sim_time = passengers(i).arrival_min then
                            passengers(i).dest_fl <= to_unsigned((rand_val mod 10) + 1, 4); 
                            passengers(i).state   <= STATE_WAIT;
                            weight_sig((i*8+7) downto i*8) <= std_logic_vector(passengers(i).weight);
                        end if;

                    when STATE_WAIT =>
                        enter_sig(i) <= '1';
                        passengers(i).wait_accum <= passengers(i).wait_accum + 5;
                        passengers(i).state <= STATE_TRAVEL;

                    when STATE_TRAVEL =>
                        passengers(i).state <= STATE_EXIT;

                    when STATE_EXIT =>
                        exit_sig(i) <= '1';
                        passengers(i).state <= STATE_DONE;

                        wait_total <= wait_total + resize(passengers(i).wait_accum, 32);
                        wait_count <= wait_count + 1;
                        energy_accum <= energy_accum + resize(passengers(i).weight, 32);

                    when STATE_DONE =>
                        weight_sig((i*8+7) downto i*8) <= (others => '0');
                end case;

                floor_sig((i*4+3) downto i*4) <= std_logic_vector(passengers(i).dest_fl);
            end loop;
        end if;
    end process;

    passenger_enter  <= enter_sig;
    passenger_exit   <= exit_sig;
    request_floor    <= floor_sig;
    passenger_weight <= weight_sig;

    total_energy  <= energy_accum;
    avg_wait_time <= (others => '0') when wait_count = 0 else resize(wait_total / wait_count, 32);

end architecture;