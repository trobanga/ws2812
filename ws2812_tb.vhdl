-- Copyright (C) 1991-2016 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, the Altera Quartus Prime License Agreement,
-- the Altera MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Altera and sold by Altera or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "08/25/2016 16:54:23"

-- Vhdl Test Bench template for design  :  ws2812
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

library design_library;
library ieee;
use ieee.std_logic_1164.all;

entity ws2812_vhd_tst is
end ws2812_vhd_tst;
architecture Bench of ws2812_vhd_tst is
-- constants                                                 
-- signals                                                   
  signal b          : std_logic_vector(7 downto 0);
  signal busy       : std_logic;
  signal clk_50     : std_logic := '0';
  signal dout       : std_logic;
  signal g          : std_logic_vector(7 downto 0);
  signal r          : std_logic_vector(7 downto 0);
  signal reset_done : std_logic;
  signal wr_enable  : std_logic;
  component ws2812
    port (
      b          : in  std_logic_vector(7 downto 0);
      busy       : out std_logic;
      clk_50     : in  std_logic;
      dout       : out std_logic;
      g          : in  std_logic_vector(7 downto 0);
      r          : in  std_logic_vector(7 downto 0);
      reset_done : out std_logic;
      wr_enable  : in  std_logic
      );
  end component;
begin

  i1 : ws2812
    port map (
-- list connections between master ports and signals
      b          => b,
      busy       => busy,
      clk_50     => clk_50,
      dout       => dout,
      g          => g,
      r          => r,
      reset_done => reset_done,
      wr_enable  => wr_enable
      );


  clk_50 <= not clk_50 after 10 ns;
 
  stim : process

  begin

    wr_enable <= '0';

    r <= (others => '0');
    g <= (others => '0');
    b <= (others => '0');


    wait until reset_done = '1';
    
    wait for 20 ns;
    r         <= (others => '1');
    wait for 20 ns;
    wr_enable <= '1';
    wait for 60 ns;
    wr_enable <= '0';

    wait until busy = '0';

    wait for 20 ns;
    
    g <= "11001010";

    
    wr_enable <= '1';
    wait for 20 ns;
    wr_enable <= '0';

    wait for 10 us;
    wr_enable <= '1';
    wait for 2 us;
    wr_enable <= '0';
    
    
    
    wait until reset_done = '1';
    wait for 1 us;

    wr_enable <= '1';
    wait for 20 ns;
    wr_enable <= '0';

    
    
    wait;
  end process stim;



end Bench;
