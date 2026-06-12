import cocotb
import random

from cocotb.clock import Clock
from cocotb.triggers import (RisingEdge, FallingEdge, Timer, Edge, ReadOnly)

class reference_model:
  def __init__(self):
    self.a_i        = 0
    self.b_i        = 0
    self.op_i       = 0
    self.exp_alu_o  = 0

  def simple_alu_reference(self, a_i, b_i, op_i):
    # ADD
    if self.op_i == 0:
      self.exp_alu_o = self.a_i + self.b_i
    # SUB
    if self.op_i == 1:
      if (self.a_i > self.b_i):
        self.exp_alu_o = self.a_i - self.b_i
      else:
        self.exp_alu_o = 256 - (self.b_i - self.a_i)
    # Vector a should left shift using bits 2:0 of vector b
    if self.op_i == 2:
      self.exp_alu_o = (self.a_i << (self.b_i & 0x7)) & ((1 << 8) - 1)
    # Vector a should right shift using bits 2:0 of vector b
    if self.op_i == 3:
      self.exp_alu_o = (self.a_i >> (self.b_i & 0x7)) & ((1 << 8) - 1)
    # AND
    if self.op_i == 4:
      self.exp_alu_o = self.a_i & self.b_i    
    # OR
    if self.op_i == 5:
      self.exp_alu_o = self.a_i | self.b_i    
    # XOR
    if self.op_i == 6:
      self.exp_alu_o = self.a_i ^ self.b_i    
    # EQL
    if self.op_i == 7:
      if (self.a_i == self.b_i):
        self.exp_alu_o = 1
      else:
        self.exp_alu_o = 0
    return self.exp_alu_o


@cocotb.test()
async def test_simple_alu(dut):
  model = reference_model()
  for i in range(3):
    for j in range(7):
      
      a = random.randint(0,127)
      b = random.randint(0,127)
      dut.a_i.value = a
      dut.b_i.value = b
      dut.op_i.value = j
      await Timer(1, units="ns")
      model.a_i = a
      model.b_i = b
      model.op_i = j
      expected = model.simple_alu_reference(a,b,j)
      print("Input a_i = ",a,", b_i = ",b," opcode = ",{j}," Expected = ",{expected},", Actual = ",{int(dut.alu_o.value)})
      assert int(dut.alu_o.value) == expected, f"\n \
        ----------------------------------- \
        Mismatch Outputs! \n\
        Input a_i = {a}, b_i = {b} opcode = {j} \n\
        Expected = {expected}, Actual = {int(dut.alu_o.value)}\n\
        ----------------------------------- "
      await Timer(10, units="ns")
      



