import random
import cocotb

from cocotb.clock import Clock
from cocotb.triggers import (
    RisingEdge,
    FallingEdge,
    Edge,
    Timer,
    ReadOnly
)

###############################################################################
# Clock
###############################################################################
async def clock_gen(dut):
    clk = Clock(dut.clk, 10, units="ns")
    await clk.start()

###############################################################################
# Random D driver
###############################################################################
async def data_driver(dut):
    while True:
        await Timer(random.randint(1, 17), units="ns")
        dut.d_i.value = random.randint(0, 1)

###############################################################################
# Reset stimulus
###############################################################################
async def reset_driver(dut):
    while True:
        scenario = random.randint(0, 5)
        #
        # Assert on posedge
        #
        if scenario == 0:
            await RisingEdge(dut.clk)
            dut.reset.value = 1
            await Timer(random.randint(1, 10), units="ns")
            dut.reset.value = 0
        #
        # Assert on negedge
        #
        elif scenario == 1:
            await FallingEdge(dut.clk)
            dut.reset.value = 1
            await Timer(random.randint(1, 10), units="ns")
            dut.reset.value = 0
        #
        # Deassert on posedge
        #
        elif scenario == 2:
            dut.reset.value = 1
            await RisingEdge(dut.clk)
            dut.reset.value = 0
        #
        # Deassert on negedge
        #
        elif scenario == 3:
            dut.reset.value = 1
            await FallingEdge(dut.clk)
            dut.reset.value = 0
        #
        # Random async pulse
        #
        elif scenario == 4:
            await Timer(random.randint(1, 25), units="ns")
            dut.reset.value = 1
            await Timer(random.randint(1, 15), units="ns")
            dut.reset.value = 0
        #
        # Random toggle
        #
        else:
            await Timer(random.randint(1, 20), units="ns")
            dut.reset.value = int(dut.reset.value) ^ 1

###############################################################################
# Reference model
###############################################################################
class DffModel:
    def __init__(self):
        self.q_norst = 0
        self.q1 = 0
        self.q2 = 0
        self.q3 = 0
        self.q4 = 0
        self.q_sync = 0

    def async_update(self, rst):
        #
        # q1 : posedge reset
        #
        if rst == 1:
            self.q1 = 0

        #
        # q2 : negedge reset
        #
        if rst == 0:
            self.q2 = 0

        #
        # q3 : negedge reset
        #
        if rst == 0:
            self.q3 = 0

        #
        # q4 : posedge reset
        #
        if rst == 1:
            self.q4 = 0

    def posedge_clk(self, d, rst):

        #
        # no reset
        #
        self.q_norst = d

        #
        # async active-high reset flop
        #
        if rst == 0:
            self.q1 = d

        #
        # async active-low reset flop
        #
        if rst == 1:
            self.q2 = d

        #
        # sync active-high reset flop
        #
        if rst == 1:
            self.q_sync = 0
        else:
            self.q_sync = d

    def negedge_clk(self, d, rst):

        #
        # async active-low reset flop
        #
        if rst == 1:
            self.q3 = d

        #
        # async active-high reset flop
        #
        if rst == 0:
            self.q4 = d


###############################################################################
# Model update processes
###############################################################################
async def monitor_async_reset(dut, model):
    prev_rst = int(dut.reset.value)
    while True:
        await Edge(dut.reset)
        rst = int(dut.reset.value)
        #
        # posedge reset
        #
        if prev_rst == 0 and rst == 1:
            model.q1 = 0
            model.q4 = 0
        #
        # negedge reset
        #
        if prev_rst == 1 and rst == 0:
            model.q2 = 0
            model.q3 = 0
        prev_rst = rst

async def monitor_posedge(dut, model):
    while True:
        await RisingEdge(dut.clk)
        d = int(dut.d_i.value)
        rst = int(dut.reset.value)
        model.posedge_clk(d, rst)

async def monitor_negedge(dut, model):
    while True:
        await FallingEdge(dut.clk)
        d = int(dut.d_i.value)
        rst = int(dut.reset.value)
        model.negedge_clk(d, rst)

###############################################################################
# Checker
###############################################################################

async def checker(dut, model):
    while True:
        await Timer(1, units="ps")
        await ReadOnly()

        assert int(dut.q_norst_o.value) == model.q_norst, \
            f"q_norst_o mismatch exp={model.q_norst} got={int(dut.q_norst_o.value)}"

        assert int(dut.q_sync_rising_clk_rising_reset_o.value) == model.q1, \
            f"q_sync_rising_clk_rising_reset_o mismatch exp={model.q1} got={int(dut.q_sync_rising_clk_rising_reset_o.value)}"

        assert int(dut.q_sync_rising_clk_falling_reset_o.value) == model.q2, \
            f"q_sync_rising_clk_falling_reset_o mismatch exp={model.q2} got={int(dut.q_sync_rising_clk_falling_reset_o.value)}"

        assert int(dut.q_sync_falling_clk_falling_reset_o.value) == model.q3, \
            f"q_sync_falling_clk_falling_reset_o mismatch exp={model.q3} got={int(dut.q_sync_falling_clk_falling_reset_o.value)}"

        assert int(dut.q_sync_falling_clk_rising_reset_o.value) == model.q4, \
            f"q_sync_falling_clk_rising_reset_o mismatch exp={model.q4} got={int(dut.q_sync_falling_clk_rising_reset_o.value)}"

        assert int(dut.q_asyncrst_o.value) == model.q_sync, \
            f"q_asyncrst_o mismatch exp={model.q_sync} got={int(dut.q_asyncrst_o.value)}"


###############################################################################
# Test
###############################################################################

@cocotb.test()
async def test_dffs(dut):

    random.seed(12345)

    dut.d_i.value = 0
    dut.reset.value = 0

    model = DffModel()

    cocotb.start_soon(clock_gen(dut))
    cocotb.start_soon(data_driver(dut))
    cocotb.start_soon(reset_driver(dut))

    cocotb.start_soon(monitor_async_reset(dut, model))
    cocotb.start_soon(monitor_posedge(dut, model))
    cocotb.start_soon(monitor_negedge(dut, model))

    cocotb.start_soon(checker(dut, model))

    await Timer(20, units="us")
