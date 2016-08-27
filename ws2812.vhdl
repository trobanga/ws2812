-- driver for ws2812

-- High speed mode, clock cycles needed @50MHz
-- +- 150ns
-- T0H 0.35us = 350ns 
-- T0L 0.8us = 800ns 
-- T1H 0.7us = 700ns 
-- T1L 0.6us = 600ns 
-- reset >= 50us = 50000ns 


-- At wr_enable = '1' the rgb input data is copied and sent bitwise to the ws2812.
-- After the data is written  a counter is started and after 50us reset_done is set to
-- '1' indicating that the write cycle starts new.

-- If wr_enable is set again to '1' before the 50us are reached the counter is
-- resset to 0 




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use IEEE.math_real.ceil;
use IEEE.math_real.log2;

entity ws2812 is
  generic (
    g_T0H       : natural := 350;       -- in ns
    g_T0L       : natural := 800;
    g_T1H       : natural := 700;
    g_T1L       : natural := 600;
    g_RESET_LEN : natural := 50100;
    CLOCK_FREQ  : natural := 50         -- clock frequency in MHz
    );
  port (
    clk_50    : in std_logic;           --50 MHz
    wr_enable : in std_logic;
    r         : in std_logic_vector(7 downto 0);
    g         : in std_logic_vector(7 downto 0);
    b         : in std_logic_vector(7 downto 0);

    reset_done : out std_logic := '0';
    busy       : out std_logic;
    dout       : out std_logic          -- Data out to WS2812
    );
end entity ws2812;


architecture rtl of ws2812 is

  -- timing in clock cycles. -1 because initwl/initwh take one clock cycle
  constant T0H       : natural := g_T0H * CLOCK_FREQ / 1000 - 1;
  constant T0L       : natural := g_T0L * CLOCK_FREQ / 1000 - 1;
  constant T1H       : natural := g_T1H * CLOCK_FREQ / 1000 - 1;
  constant T1L       : natural := g_T1L * CLOCK_FREQ / 1000 - 1;
  constant RESET_LEN : natural := g_RESET_LEN * CLOCK_FREQ / 1000;

  type state_t is (idle, initwh, initwl, wh, wl, reset);  -- initwh/wr prepare  bit transfer
                                        -- wh: write high part of bit,
                                        -- wl: write low part of bit
                                        -- reset: bit_reset
  signal state : state_t := idle;
  --type bit_state_t is (none, L0, H0, L1, H1);
  --signal bit_state : bit_state_t := none;

  signal byte_pos           : integer range 23 downto 0                               := 23;  -- position in rgb
  signal rgb                : std_logic_vector(23 downto 0)                           := x"000000";
  signal counter            : unsigned(15 downto 0)                                   := (others => '0');
  signal wr_enable_d        : std_logic_vector(1 downto 0)                            := "00";
  signal last_write_counter : unsigned(integer(ceil(log2(real(RESET_LEN)))) downto 0) := (others => '0');

begin  -- architecture rtl

  -- purpose: write rgb bitwise to WS2812
  -- type   : sequential
  -- inputs : clk_50
  -- outputs: 
  to_ws2812 : process (all) is
  begin  -- process to_ws2812
    if rising_edge(clk_50) then
      wr_enable_d <= wr_enable_d(0) & wr_enable;

      case state is
        when idle =>
          dout <= '0';
          busy <= '0';

          last_write_counter <= last_write_counter + 1;
          if last_write_counter = RESET_LEN then
            reset_done <= '1';
          end if;

          if wr_enable_d(1) = '0' and wr_enable = '1' then
            state              <= initwh;
            rgb                <= g & r & b;
            byte_pos           <= 23;
            busy               <= '1';
            last_write_counter <= (others => '0');
            reset_done         <= '0';
          end if;

        when initwh =>                  -- set counter accoriding to bit
          if rgb(byte_pos) = '1' then
            counter <= to_unsigned(T1H, counter'length);
          else
            counter <= to_unsigned(T0H, counter'length);
          end if;
          state <= wh;
          dout  <= '1';

        when wh =>
          counter <= counter - 1;
          if counter = 0 then
            state <= initwl;
          end if;
          dout <= '1';

        when initwl =>
          if rgb(byte_pos) = '1' then
            counter <= to_unsigned(T1L, counter'length);
          else
            counter <= to_unsigned(T0L, counter'length);
          end if;
          state <= wl;
          dout  <= '0';

        when wl =>
          counter <= counter - 1;
          if counter = 0 then
            if byte_pos > 0 then
              byte_pos <= byte_pos - 1;
              state    <= initwh;
            else
              state <= idle;
            end if;
          end if;
          dout <= '0';
        when others => null;
      end case;
    end if;  -- rising_edge

  end process to_ws2812;

end architecture rtl;
