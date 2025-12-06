library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity floor_request_manager is
    Port(
        clk: in STD_LOGIC;
        reset: in STD_LOGIC;
        add_req: in STD_LOGIC_VECTOR(7 downto 0);
        cancel_req: in STD_LOGIC_VECTOR(7 downto 0);
        emergency_stop: in STD_LOGIC;
        current_weight: in INTEGER;
        call_button: in STD_LOGIC;
        call_mode: out STD_LOGIC;
        overweight: out STD_LOGIC;
        alarm: out STD_LOGIC;
        led_out: out STD_LOGIC;
        active_floors: out STD_LOGIC_VECTOR(7 downto 0)
    );
end floor_request_manager;

architecture Behavioral of floor_request_manager is
    signal reg_floors: STD_LOGIC_VECTOR(7 downto 0):=(others=>'0');
    signal overweight_flag: STD_LOGIC:='0';
    signal call_flag: STD_LOGIC:='0';
    signal blink_counter: INTEGER:=0;
    signal led_state: STD_LOGIC:='0';
begin

process(clk,reset)
begin
    if reset='1' then
        reg_floors<=(others=>'0');
        overweight_flag<='0';
        call_flag<='0';
        led_state<='0';
        blink_counter<=0;
    elsif rising_edge(clk) then

        if call_button='1' then
            call_flag<='1';
        end if;

        if current_weight<=2000 then
            call_flag<='0';
        end if;

        if current_weight>2000 then
            overweight_flag<='1';
            reg_floors<=reg_floors;
        else
            overweight_flag<='0';
            if call_flag='1' then
                reg_floors<=reg_floors;
            else
                if emergency_stop='1' then
                    reg_floors<=(others=>'0');
                else
                    reg_floors<=(reg_floors or add_req) and (not cancel_req);
                end if;
            end if;
        end if;

        if overweight_flag='1' then
            blink_counter<=blink_counter+1;
            if blink_counter=5000000 then
                led_state<=not led_state;
                blink_counter<=0;
            end if;
        else
            led_state<='0';
            blink_counter<=0;
        end if;

    end if;
end process;

overweight<=overweight_flag;
alarm<=overweight_flag;
led_out<=led_state;
call_mode<=call_flag;
active_floors<=reg_floors;

end Behavioral;
