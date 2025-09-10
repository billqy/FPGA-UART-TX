library IEEE;
use IEEE.std_logic_1164.all;

entity Top_Level is
    Port(
        clk          : in  std_logic;   -- 50 MHz system clock
        reset        : in  std_logic;   -- active-high reset
        input_signal : in  std_logic;   -- sampled input (e.g., button/switch)
        input_high   : out std_logic;
        tx           : out std_logic    -- UART TX line
    );
end Top_Level;

architecture Behavioral of Top_Level is

    component Sampler is
        Port(
            clk         : in  std_logic;
            input_signal: in  std_logic;
            sample_tick : out std_logic;
            out_byte    : out std_logic_vector(7 downto 0)
        );
    end component;

    component UART_TX is
        Port(
            clk      : in  std_logic;
            reset    : in  std_logic;
            tx_start : in  std_logic;
            tx_data  : in  std_logic_vector(7 downto 0);
            tx       : out std_logic;
            busy     : out std_logic
        );
    end component;

    signal sample    : std_logic_vector(7 downto 0);
    signal sample_tick : std_logic;
    signal tx_data   : std_logic_vector(7 downto 0);
    signal tx_start  : std_logic := '0';
    signal busy      : std_logic;

begin

    Sampler_inst : Sampler
        port map(
            clk          => clk,
            input_signal => input_signal,
            sample_tick  => sample_tick,
            out_byte     => sample
        );

    UART_inst : UART_TX
        port map(
            clk      => clk,
            reset    => reset,
            tx_start => tx_start,
            tx_data  => tx_data,
            tx       => tx,
            busy     => busy
        );
    
    input_high <= input_signal;
    
    process(clk, reset)
    begin
        if reset = '1' then
            tx_start <= '0';
            tx_data  <= (others => '1');
        elsif rising_edge(clk) then
            tx_start <= '0';  

            if sample_tick = '1' and busy = '0' then
                tx_data  <= sample;
                tx_start <= '1';
            end if;
        end if;
    end process;

end Behavioral;
