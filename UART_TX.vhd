library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_TX is
    Port(
        clk      : in  std_logic;
        reset    : in  std_logic;
        tx_start : in  std_logic;                     
        tx_data  : in  std_logic_vector(7 downto 0);
        tx       : out std_logic;
        busy     : out std_logic
    );
end UART_TX;

architecture Behavioral of UART_TX is
    constant CLK_FREQ   : integer := 100_000_000; -- 100 MHz
    constant BAUD_RATE  : integer := 115_200;
    constant BAUD_TICKS : integer := CLK_FREQ / BAUD_RATE;

    signal baud_cnt   : integer range 0 to BAUD_TICKS-1 := 0;
    signal baud_tick  : std_logic := '0';

    signal shift_reg  : std_logic_vector(9 downto 0) := (others => '1'); -- 10 bits (stop, b7..b0, start)
    signal bits_rem   : integer range 0 to 10 := 0;  -- how many bits remain to shift out 

    signal tx_reg     : std_logic := '1';
    signal busy_reg   : std_logic := '0';

begin
    tx   <= tx_reg;
    busy <= busy_reg;

    -- Baud tick generator
    process(clk, reset)
    begin
        if reset = '1' then
            baud_cnt  <= 0;
            baud_tick <= '0';
        elsif rising_edge(clk) then
            if baud_cnt = BAUD_TICKS - 1 then
                baud_cnt  <= 0;
                baud_tick <= '1';
            else
                baud_cnt  <= baud_cnt + 1;
                baud_tick <= '0';
            end if;
        end if;
    end process;

    -- Shift-register transmitter (driven on baud_tick)
    -- shift_reg(0) = start bit
    process(clk, reset)
    begin
        if reset = '1' then
            shift_reg <= (others => '1');
            bits_rem  <= 0;
            tx_reg    <= '1';
            busy_reg  <= '0';
        elsif rising_edge(clk) then
            if (tx_start = '1') and (bits_rem = 0) then
                shift_reg <= '1' & tx_data & '0';
                bits_rem  <= 10;   
                busy_reg  <= '1';
            end if;

            -- On each baud tick shift out one bit 
            if baud_tick = '1' then
                if bits_rem > 0 then
                    tx_reg   <= shift_reg(0);                               -- output LSB of shift_reg
                    shift_reg <= '1' & shift_reg(9 downto 1);              -- shift right, fill MSB with '1' (idle high)
                    bits_rem <= bits_rem - 1;

                    if bits_rem = 1 then
                        -- this was the last bit being sent
                        busy_reg <= '0';
                    else
                        busy_reg <= '1';
                    end if;
                else
                    -- idle state: TX line remains high
                    tx_reg <= '1';
                    busy_reg <= '0';
                end if;
            end if;
        end if;
    end process;

end Behavioral;
