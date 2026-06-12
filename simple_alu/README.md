# Simple ALU (Arithmetic Logic Unit)

## 1. Explanation of the Design

This design implements a simple 8-bit **ALU** (`rtl/simple_alu.sv`) that performs one of eight operations on two operands, selected by a 3-bit opcode. The opcodes and the data width are defined in a shared package (`rtl/simple_alu_pkg.sv`) as a SystemVerilog `enum`, giving the operations readable names instead of magic numbers.

| Port    | Direction | Width        | Description            |
|---------|-----------|--------------|------------------------|
| `a_i`   | input     | `DATA_WIDTH` | Operand A              |
| `b_i`   | input     | `DATA_WIDTH` | Operand B              |
| `op_i`  | input     | 3 (enum)     | Operation select       |
| `alu_o` | output    | `DATA_WIDTH` | Result                 |

Supported operations (from `alu_pkg`):

| Opcode | Encoding | Operation                                |
|--------|----------|------------------------------------------|
| `ADD`  | 3'b000   | `a + b`                                  |
| `SUB`  | 3'b001   | `a - b`                                  |
| `SLL`  | 3'b010   | Logical shift left: `a << b[2:0]`        |
| `LSR`  | 3'b011   | Logical shift right: `a >> b[2:0]`       |
| `AND`  | 3'b100   | Bitwise AND                              |
| `OR`   | 3'b101   | Bitwise OR                               |
| `XOR`  | 3'b110   | Bitwise XOR                              |
| `EQL`  | 3'b111   | Equality: result is 1 if `a == b`, else 0 |

## 2. How the Design Works

The ALU is purely **combinational**: a single `always_comb` block with a `case` statement on the opcode.

- The `case (op_i)` selects which arithmetic/logic expression drives `alu_o`; in hardware this synthesizes to the eight operation datapaths feeding an 8-to-1 result multiplexer controlled by `op_i`.
- Shift amounts use only `b_i[2:0]`, since shifting an 8-bit value by more than 7 is meaningless.
- A `default` arm drives `0`, ensuring `alu_o` is always assigned and no latches are inferred.
- The opcode is typed as the package `enum`, so tools can warn on illegal values and waveforms display operation names.
- `DATA_WIDTH` (default 8, from the package) parameterizes the operand width.

There is no clock — results appear after combinational delay; registering the output is left to the surrounding pipeline.

## 3. Advantages and Use Cases

**Advantages**
- Clean separation of **types/constants (package)** from **logic (module)** — a scalable SystemVerilog coding practice.
- Enumerated opcodes make the RTL self-documenting and simulation traces readable.
- Fully combinational, so it slots into any pipeline stage; parameterized width makes it reusable.
- The case/mux structure is easy to extend with new operations.

**Use cases**
- The **execute stage of a CPU/microcontroller** — every processor datapath contains an ALU of this shape (the opcode set here resembles a subset of RISC-V ALU ops).
- Datapaths of DSPs, GPUs, and custom accelerators.
- Address calculation units and comparators in control logic.
- A standard teaching/interview design for combinational design, `case` statements, packages, and enums.

## Directory Structure

- `rtl/` — design (`simple_alu.sv`) and package (`simple_alu_pkg.sv`)
- `svtb/` — SystemVerilog testbench (`test_simple_alu.sv`)
- `cocotb/` — Python/cocotb testbench (`test_simple_alu.py`)
