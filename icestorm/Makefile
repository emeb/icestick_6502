# Makefile for icestorm tools + yosys + nextpnr
# Modified from examples in icestorm distribution
# 03-03-19 E. Brombaugh
# this version builds the CPU code from C

# src directory
VPATH = ../src/ ../verilog-6502/ ../osvdu/

SRC =	icestick_6502_top.v ../src/tst_6502.v ../src/acia.v \
		../verilog-6502/cpu.v ../verilog-6502/ALU.v \
		../src/acia_rx.v ../src/acia_tx.v

# preparing the machine code
FAKE_HEX =	rom.hex
REAL_HEX =  code.hex

# project stuff
PROJ = icestick_6502_top
PIN_DEF = icestick_6502_top.pcf
SDC = icestick_6502_top.sdc
DEVICE = hx1k

YOSYS = yosys
NEXTPNR = nextpnr-ice40
#NEXTPNR_ARGS = --pre-pack $(SDC) --ignore-loops
NEXTPNR_ARGS = --pre-pack $(SDC)
ICEPACK = icepack
ICETIME = icetime
ICEPROG = iceprog
ICEBRAM = icebram
CDCPROG = cdc_prog
VERILATOR = verilator
TECH_LIB = /usr/local/share/yosys/ice40/cells_sim.v
ASM6502 = acme
HEXDUMP = hexdump
HEXDUMP_ARGS = -v -e '1/1 "%02x " "\n"'

all: $(PROJ).bin

$(FAKE_HEX):
	$(ICEBRAM) -g 8 4096 > $(FAKE_HEX)

%.json: $(SRC) $(FAKE_HEX)
	$(YOSYS) -p 'synth_ice40 -top $(PROJ) -json $@' $(SRC)

%.asc: %.json $(PIN_DEF) 
	$(NEXTPNR) $(NEXTPNR_ARGS) --$(DEVICE) --json $< --pcf $(PIN_DEF) --asc $@

$(REAL_HEX):
	$(MAKE) -C ../cc65/
	cp ../cc65/$(FAKE_HEX) ./$(REAL_HEX)
	
assembly:
	$(MAKE) -C ../assembly/
	cp ../assembly/$(REAL_HEX) .
	
%.bin: %.asc $(REAL_HEX)
	$(ICEBRAM) $(FAKE_HEX) $(REAL_HEX) < $< > temp.asc
	$(ICEPACK) temp.asc $@

%.rpt: %.asc
	$(ICETIME) -d $(DEVICE) -mtr $@ $<

prog: $(PROJ).bin
	$(ICEPROG) $<
    
#prog: $(PROJ).bin
#	$(CDCPROG) -p /dev/ttyACM0 $<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo $(ICEPROG) -S -IB $<
	
recode:
	rm -f $(REAL_HEX) $(PROJ).bin
	$(MAKE) prog
    
lint: $(SRC)
	$(VERILATOR) --lint-only -Wall --top-module $(PROJ) $(TECH_LIB) $(SRC)

clean:
	rm -f *.json *.asc *.rpt *.bin *.hex
	$(MAKE) clean -C ../cc65/

.SECONDARY:
.PHONY: all prog clean
