# Edge Detector

## 1. Explanation of the Design

This design (`rtl/edge_detector.sv`) detects **rising and falling edges** of an input signal `a_i` relative to the clock. It produces a single-cycle pulse on `rising_edge_o` when the input transitions from `0` to `1`, and on `falling_edge_o` when it transitions from `1` to `0`.

| Port             | Direction | Description                                  |
|------------------|-----------|----------------------------------------------|
| `clk`            | input     | Clock                                        |
| `reset`          | input     | Asynchronous, active-high reset              |
| `a_i`            | input     | Signal to monitor                            |
| `rising_edge_o`  | output    | High for one cycle on a 0→1 transition       |
| `falling_edge_o` | output    | High for one cycle on a 1→0 transition       |

## 2. How the Design Works

The circuit keeps a **one-cycle-delayed copy** of the input in a flip-flop:

```systemverilog
always_ff @(posedge clk or posedge reset)
  if (reset) sig_dly <= 1'b0;
  else       sig_dly <= a_i;
```

It then compares the current value with the delayed value:

- **Rising edge:** `rising_edge_o = a_i & ~sig_dly` — the input is `1` now but was `0` last cycle.
- **Falling edge:** `falling_edge_o = ~a_i & sig_dly` — the input is `0` now but was `1` last cycle.

Each output is therefore asserted for exactly one clock period per transition, regardless of how long the input stays at its new level.

## 3. Advantages and Use Cases

**Advantages**
- Minimal hardware: one flip-flop and two gates.
- Converts a level (which may stay high for many cycles) into a clean **single-cycle pulse**, which is what most synchronous logic actually needs.
- Detects both edge polarities simultaneously and independently.

**Use cases**
- **Button/key-press detection** — act once per press instead of every cycle the button is held.
- **Handshake and strobe generation** — turning a level-based request into a pulse.
- **Event counting** — counting transitions of an external signal.
- Triggering one-shot actions (starting a timer, latching data, raising an interrupt) on a signal change.
- Front-end of synchronizer chains when a slow external signal must produce one event in the fast clock domain.

## Directory Structure

- `rtl/` — design (`edge_detector.sv`)
- `svtb/` — SystemVerilog testbench (`test_edge_detect.sv`)
- `cocotb/` — Python/cocotb testbench (`test_edge_detector.py`)
