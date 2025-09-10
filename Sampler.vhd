library IEEE;
use IEEE.std_logic_1164.all;

entity Sampler is
    Port(
        clk : in std_logic;
        input_signal : in std_logic;
        sample_tick : out std_logic;
        out_byte : out std_logic_vector(7 downto 0)
    );
end Sampler;

architecture Behavioral of Sampler is

constant CLK_FREQ   : integer := 100_000_000;
constant SAMPLE_RATE : integer := 100;
constant SAMPLE_TICKS : integer := CLK_FREQ / SAMPLE_RATE;

signal sample_cnt : integer range 0 to SAMPLE_TICKS-1 := 0; -- for 1 kHz
signal tick : std_logic := '0';

signal sample : std_logic_vector(7 downto 0) := (others => '1');

begin
out_byte <= sample;
sample_tick <= tick;

process(clk)
begin

  if rising_edge(clk) then
  
    if sample_cnt = SAMPLE_TICKS-1 then
      sample_cnt <= 0;
      tick <= '1';
    else
      sample_cnt <= sample_cnt + 1;
      tick <= '0';
    end if;
    
    if tick = '1' then
        sample <= "0000000" & input_signal;
    end if;
    
  end if;
end process;


end Behavioral;