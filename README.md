# icestick_6502
A small 6502 system build on a Lattice Icestick FPGA development board

## prerequisites
To build this you will need the following FPGA tools

* Icestorm - ice40 FPGA tools
* Yosys - Synthesis
* Nextpnr - Place and Route

Info on these can be found at http://www.clifford.at/icestorm/

You will also need the Acme 6502 assembler which can be found at
https://github.com/meonwax/acme

## Building

	git clone https://github.com/emeb/icestick_6502.git
	cd icestick_6502
	git submodule update --init
	cd icestorm
	make

## Running

Make sure you've properly set up udev rules for the icestick, then plug it in.
Start a terminal on the icestick's USB serial port - probably found at
/dev/ttyUSB1 and configure it for 9600 baud. Then load the previously built
bitstream

	make prog

You should see a message printed to the terminal window and the icestick LEDs
should start to flash in sequence. At this point you can type in the terminal
window and see the characters echoed.