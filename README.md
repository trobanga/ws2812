# ws2812
VHDL code to address LED strips with ws2812 chips.


After setting wr_enable to '1', busy is set to '1' and the RGB values are send to the the first LED of the strip.
When busy is '0' again, the next RGB data can be send (by setting wr_enable to '1') to the second LED and so on.
The strip is reset by simply waiting for 50 us. After 50 us reset_done is set to '1'.

The simulation can be run with:
$ vsim -do sim.tcl





