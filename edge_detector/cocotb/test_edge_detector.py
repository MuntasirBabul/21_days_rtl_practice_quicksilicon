import random
import cocotb

from cocotb.clock import Clock
from cocotb.triggers import (RisingEdge, FallingEdge, Edge, Timer, ReadOnly)

###############################################################################
# Clock
###############################################################################
async def clock_gen(dut):
    clk = Clock(dut.clk, 10, units = "ns")
    await clk.start()

###############################################################################
# reset apply
###############################################################################
async def apply_reset(dut):
    await RisingEdge(dut.clk)
    dut.reset.value = 0
    await RisingEdge(dut.clk)
    dut.reset.value = 1
    await RisingEdge(dut.clk)
    dut.reset.value = 0

@cocotb.test()
async def test_edge_detector(dut):
    cocotb.start_soon(clock_gen(dut))
    cocotb.start_soon(apply_reset(dut))

    dut.a_i.value = 0
    await Timer(10, units="ns")
    for i in range (32):
        dut.a_i.value =  random.randint(0,1)
        await Timer(10, units="ns")
        
