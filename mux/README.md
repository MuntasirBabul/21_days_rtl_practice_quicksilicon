# Parameterized 2-to-1 Multiplexer

## 1. Explanation of the Design

This design implements a **parameterized 2-to-1 multiplexer** (`rtl/mux.sv`). A multiplexer selects one of several data inputs and forwards it to a single output based on a select signal. The data width is set by the `WIDTH` parameter, whose default comes from a shared package (`rtl/mux_pkg.sv`, `param_width = 8`), demonstrating how packages centralize design constants.

| Port  | Direction | Width   | Description              |
|-------|-----------|---------|--------------------------|
| `a`   | input     | `WIDTH` | Data input selected when `sel = 1` |
| `b`   | input     | `WIDTH` | Data input selected when `sel = 0` |
| `sel` | input     | 1       | Select line              |
| `y`   | output    | `WIDTH` | Selected output          |

The design is purely **combinational**.

## 2. How the Design Works

The mux is a single conditional (ternary) assignment:

```systemverilog
assign y = sel ? a : b;
```

- When `sel` is `1`, output `y` follows input `a`.
- When `sel` is `0`, output `y` follows input `b`.
- The operation applies bitwise across the whole `WIDTH`-bit bus, so one statement describes `WIDTH` parallel 2-to-1 muxes sharing a common select.

The module also contains an optional `DUMP_VCD` compile-time guard that dumps a VCD waveform file for debugging when defined. The parameter default is imported from `mux_pkg`, so changing `param_width` in one place re-sizes every instance that uses the default.

## 3. Advantages and Use Cases

**Advantages**
- The multiplexer is one of the most fundamental building blocks in digital logic — any combinational function can be built from muxes.
- Parameterization makes the same RTL reusable for any bus width with no code changes.
- Using a package for the width keeps constants consistent across design and testbench.

**Use cases**
- **Datapath selection:** choosing between ALU results, register sources, immediate vs. register operands in CPUs.
- **Bus arbitration/steering:** routing one of several masters onto a shared bus.
- Implementing **conditional assignments** and if/else logic in hardware.
- Building blocks for larger N-to-1 muxes, crossbars, and barrel shifters.
- Clock/data source selection (e.g., functional vs. test mode).

## Directory Structure

- `rtl/` — design (`mux.sv`) and shared package (`mux_pkg.sv`)
- `svtb/` — SystemVerilog testbench (`test_mux.sv`)
- `cocotb/` — Python/cocotb testbench (`test_mux.py`)
