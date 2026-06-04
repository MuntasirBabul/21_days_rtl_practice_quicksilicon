vlib work
vlog -sv dff_top.sv +acc
vsim -assertdebug work.top -voptargs=+acc +UVM_VERBOSITY=UVM_LOW -l run.log
add wave -position insertpoint sim:/top/dut/*
run -all