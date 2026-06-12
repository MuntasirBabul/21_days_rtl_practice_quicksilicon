# D Flip-Flop Variants (dff_examples)

## 1. Explanation of the Design

This design (`rtl/dff.sv`) is a teaching module that implements **six D flip-flop variants** side by side, all sampling the same data input `d_i`. It demonstrates every common combination of clock edge, reset type (asynchronous vs. synchronous), and reset polarity (active-high vs. active-low).

| Output                                | Sensitivity List               | Reset Type   | Active Level | Clock Edge |
|---------------------------------------|--------------------------------|--------------|--------------|------------|
| `q_norst_o`                           | `posedge clk`                  | No reset     | N/A          | Rising     |
| `q_async_rising_clk_rising_reset_o`   | `posedge clk or posedge reset` | Asynchronous | High         | Rising     |
| `q_async_rising_clk_falling_reset_o`  | `posedge clk or negedge reset` | Asynchronous | Low          | Rising     |
| `q_async_falling_clk_falling_reset_o` | `negedge clk or negedge reset` | Asynchronous | Low          | Falling    |
| `q_async_falling_clk_rising_reset_o`  | `negedge clk or posedge reset` | Asynchronous | High         | Falling    |
| `q_sync_reset_o`                      | `posedge clk`                  | Synchronous  | High         | Rising     |

## 2. How the Design Works

A D flip-flop captures the value on its `D` input at the active clock edge and holds it on `Q` until the next active edge. Each variant here is written as its own `always_ff` block:

- **No reset:** `always_ff @(posedge clk)` simply registers `d_i` every rising edge; the power-up value is undefined.
- **Asynchronous reset:** the reset signal appears **in the sensitivity list** (`or posedge reset` / `or negedge reset`), so the flop is cleared the moment reset asserts, independent of the clock. The polarity of the edge in the sensitivity list and the level checked in the `if` determine active-high vs. active-low.
- **Synchronous reset:** reset is **not** in the sensitivity list; it is just an `if (reset)` inside the clocked block, so the flop only clears on the next active clock edge.
- The falling-edge variants use `negedge clk`, capturing data on the falling edge instead of the rising edge.

## 3. Advantages and Use Cases

**Advantages**
- The D flip-flop is the fundamental storage element of all synchronous digital design.
- Async reset brings the design to a known state even without a running clock; sync reset keeps reset fully within the timing-analyzed clock domain and avoids reset-recovery hazards.
- Seeing all styles together makes the coding-style differences (sensitivity list vs. in-block condition) explicit.

**Use cases**
- Registers, pipeline stages, counters, FSM state storage — essentially every sequential circuit.
- **Async-reset flops:** power-on reset paths, safety-critical defaults before clocks are stable.
- **Sync-reset flops:** datapath registers where glitch-free, timing-clean reset release matters.
- **Negedge flops:** DDR-style interfaces and clocking schemes that use both clock edges.

## Directory Structure

- `rtl/` — design (`dff.sv`)
- `svtb/` — plain SystemVerilog testbench (`test_dff.sv`)
- `cocotb/` — Python/cocotb testbench (`test_dff.py`)
- `uvmtb/` — full UVM testbench (driver, monitor, agent, scoreboard, env, test, `run.do`)
