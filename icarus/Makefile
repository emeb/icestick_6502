# Makefile for Icarus Verilog simulation
# 02-11-2019 E. Brombaugh

# sources
SOURCES = 	tb_tst_6502.v ../src/tst_6502.v ../src/acia.v \
			../verilog-6502/ALU.v ../verilog-6502/cpu.v \
			../osdvu/uart.v
        
# preparing the machine code
ASM =	../src/rom_512.asm
OBJ =	rom_512.obj
RPT =	rom_512.rpt
HEX =	rom_512.hex

# top level
TOP = tb_tst_6502
			
# Executables
VLOG = iverilog
WAVE = gtkwave
TECH_LIB = /usr/local/share/yosys/ice40/cells_sim.v
ASM6502 = acme
HEXDUMP = hexdump
HEXDUMP_ARGS = -v -e '1/1 "%02x " "\n"'

# targets
all: $(TOP).vcd

$(OBJ): $(ASM)
	$(ASM6502) -o $(OBJ) -r $(RPT) $<

$(HEX): $(OBJ)
	$(HEXDUMP) $(HEXDUMP_ARGS) $< > $@
	
wave: $(TOP).vcd $(TOP).gtkw
	$(WAVE) $(TOP).gtkw
	
$(TOP).vcd: $(TOP)
	./$(TOP)

$(TOP): $(SOURCES) $(HEX)
	$(VLOG) -D icarus -l $(TECH_LIB) -o $(TOP) $(SOURCES)
	
clean:
	rm -rf a.out *.obj $(HEX) $(RPT) $(TOP) $(TOP).vcd
	
