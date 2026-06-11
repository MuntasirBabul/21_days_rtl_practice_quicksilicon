##########################################################################
# Makefile for Cocotb-based Simulation                                   #
# Author: MuntasirBhai                                                   #
# Description: Build and run cocotb simulations with Verilator           #
##########################################################################

TOPLEVEL_LANG     ?= verilog
SIM               ?= verilator

DESIGN            := edge_detector
PROJECT_DIR       := 3_$(DESIGN)
RTL_DIR           := $(PROJECT_DIR)/rtl
VERIF_DIR         := $(PROJECT_DIR)/cocotb

# cocotb v2 versions
#COCOTB_TEST_MODULES = test_mux ; # cocotb python file name
#COCOTB_TOPLEVEL = $(DESIGN)    ; # design top

# cocotb v1 versions
MODULE            := test_$(DESIGN)
TOPLEVEL          := $(DESIGN)

# Provide all the verilog file list
VERILOG_SOURCES   :=  $(shell find $(RTL_DIR) -name '*.vh') \
                      $(shell find $(RTL_DIR) -name '*.svh') \
                      $(shell find $(RTL_DIR) -name '*.v') \
                      $(shell find $(RTL_DIR) -name '*.sv')

# Verilator switch to dump vcd
# Use `ifdef DUMP_VCD in RTL to ignore during synthesis
#EXTRA_ARGS        += +define+DUMP_VCD --trace-vcd --trace --trace-structs
EXTRA_ARGS        += --trace --trace-structs

# cocotb test file path
PYTHONPATH        := $(VERIF_DIR)
export PYTHONPATH

# Include cocotb makefile
include $(shell cocotb-config --makefiles)/Makefile.sim

run_sv:
	@verilator -cc -Wno-NULLPORT -Wno-COMBDLY -Wno-PINMISSING -Wno-MODDUP --exe --build --timing --binary $(VERILOG_SOURCES) -I$(RTL_DIR) --top $(DESIGN)   -j `nproc`

# Run cocotb test
run_sim: clean
	@make SIM=$(SIM) | tee run_sim_$(DESIGN).log

# Check linting
run_lint:
	@verilator --lint-only -Wall $(VERILOG_SOURCES)

# Clean Target
clean::
	@echo "::::::::: Cleaning build and output files :::::::::::"
	@rm -rfv sim_build __pycache__ *.vcd *.xml *.log obj_dir

.PHONY: run clean
