TOP     = riscv
SRCS    = rtl/control_unit.sv rtl/shifter.sv rtl/alu.sv rtl/dmem.sv rtl/regfile.sv rtl/imm_ext.sv rtl/imem.sv rtl/PC_unit.sv rtl/riscv.sv sim_main.cpp
TESTDIR ?= /home/chad/a-finished/0004_install_tests/riscv-tests/build

.PHONY: all run test clean

all: obj_dir/V$(TOP)

# --public-flat-rw : keep internal signals and expose them to C++ via rootp
# --trace          : VCD waveform support
obj_dir/V$(TOP): $(SRCS)
	verilator --cc --exe --build --trace --public-flat-rw -Wall --Wno-fatal \
	    --top-module $(TOP) $(SRCS) -o sim

# single run with waveform:  make run HEX=/path/to/add.hex   (HEX optional)
run: all
	./obj_dir/sim +trace $(if $(HEX),+hex=$(HEX))

# run every .hex in TESTDIR:  make test   or   make test TESTDIR=/other/dir
test: all
	./run_tests.sh $(TESTDIR)

clean:
	rm -rf obj_dir wave.vcd

# /mnt/c/Users/cudac/Downloads/surfer_win/surfer.exe "$(wslpath -w wave.vcd)" &