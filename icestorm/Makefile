# Makefile for icestorm tools + yosys + nextpnr
# Modified from examples in icestorm distribution
# 03-03-19 E. Brombaugh

# src directory
VPATH = ../src/ ../verilog-6502/ ../osvdu/

SRC =	icestick_6502_top.v ../src/tst_6502.v ../src/acia.v \
		../verilog-6502/cpu.v ../verilog-6502/ALU.v \
		../osdvu/uart.v

# preparing the machine code
ASM =	../src/rom.asm
OBJ =	rom.obj
RPT =	rom.rpt
HEX =	rom.hex

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
CDCPROG = cdc_prog
VERILATOR = verilator
TECH_LIB = /usr/local/share/yosys/ice40/cells_sim.v
ASM6502 = acme
HEXDUMP = hexdump
HEXDUMP_ARGS = -v -e '1/1 "%02x " "\n"'

all: $(PROJ).bin

$(OBJ): $(ASM)
	$(ASM6502) -o $(OBJ) -r $(RPT) $<

$(HEX): $(OBJ)
	$(HEXDUMP) $(HEXDUMP_ARGS) $< > $@
	
%.json: $(SRC) $(HEX)
	$(YOSYS) -p 'synth_ice40 -top $(PROJ) -json $@' $(SRC)

%.asc: %.json $(PIN_DEF) 
	$(NEXTPNR) $(NEXTPNR_ARGS) --$(DEVICE) --json $< --pcf $(PIN_DEF) --asc $@

%.bin: %.asc
	$(ICEPACK) $< $@

%.rpt: %.asc
	$(ICETIME) -d $(DEVICE) -mtr $@ $<

prog: $(PROJ).bin
	$(ICEPROG) $<
    
#prog: $(PROJ).bin
#	$(CDCPROG) -p /dev/ttyACM0 $<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo $(ICEPROG) -S -IB $<
	
lint: $(SRC)
	$(VERILATOR) --lint-only -Wall --top-module $(PROJ) $(TECH_LIB) $(SRC)

clean:
	rm -f $(PROJ).json $(PROJ).asc $(PROJ).rpt $(PROJ).bin *.obj $(HEX) $(RPT)

.SECONDARY:
.PHONY: all prog clean
