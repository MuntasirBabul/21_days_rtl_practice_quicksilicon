import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
import random

@cocotb.test()
async def test_parameterized_mux(dut):
    for i in range(20):
        dut.a.value = random.randint(0, 255)
        dut.b.value = random.randint(0, 255)
        dut.sel.value = random.randint(0,1)
        await Timer(1, units="ns")

        if dut.sel.value == 1:
            assert dut.y.value == dut.a.value, f"Counter not reset properly! Got {dut.count.value}"
        else:
            assert dut.y.value == dut.b.value, f"Counter not reset properly! Got {dut.count.value}"

        dut._log.info(f"Cycle {i+1}: a {dut.a.value}, b {dut.b.value}, sel {dut.sel.value}, out {dut.y.value}")
