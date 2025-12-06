library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity floor_request_manager is
    Port (
        clk            : in  STD_LOGIC;
        reset          : in  STD_LOGIC;

        add_req        : in  STD_LOGIC_VECTOR(7 downto 0); 
        cancel_req     : in  STD_LOGIC_VECTOR(7 downto 0); 
        emergency_stop : in  STD_LOGIC;                    

        active_floors  : out STD_LOGIC_VECTOR(7 downto 0)  
    );
end floor_request_manager;

architecture Behavioral of floor_request_manager is
    signal reg_floors : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
begin

    process(clk, reset)
    begin
        if reset = '1' then
            reg_floors <= (others => '0');

        elsif rising_edge(clk) then
            if emergency_stop = '1' then
                reg_floors <= (others => '0');

            else
                reg_floors <= (reg_floors or add_req) and (not cancel_req);

            end if;
        end if;
    end process;

    active_floors <= reg_floors;

end Behavioral;
