vlib work
vlog -sv test_odd_counter.sv +acc
vsim -assertdebug work.top -voptargs=+acc +UVM_VERBOSITY=UVM_LOW -l run.log
add wave -position insertpoint sim:/odd_counter/dut/*
run -all