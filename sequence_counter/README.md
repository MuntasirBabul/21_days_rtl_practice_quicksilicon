# Sequence Detector

## 1. Explanation of the Design

This design (`rtl/sequence_detector.sv`) detects a long, fixed **bit pattern** — `1110_1101_1011` (12 bits) — arriving serially, one bit per clock, on input `x_i`. When the most recent 12 input bits match the target pattern, the output `det_o` asserts.

Rather than building a 12-state FSM, the design uses a **shift-register-and-compare** architecture, which is the practical approach for long sequences. The window length is parameterized via `LENGTH` (default 12).

| Port    | Direction | Description                                  |
|---------|-----------|----------------------------------------------|
| `clk`   | input     | Clock                                        |
| `reset` | input     | Asynchronous, active-low reset               |
| `x_i`   | input     | Serial input bit stream                      |
| `det_o` | output    | High when the last 12 bits equal the pattern |

## 2. How the Design Works

1. **Sliding window:** a shift register `shift_ff` holds the most recent input bits. Each clock cycle the new bit is shifted in:
   ```systemverilog
   assign nxt_shift = {shift_ff[LENGTH-1:0], x_i};
   ```
   so the register always contains the latest window of the input stream, oldest bit at the top.
2. **Compare:** a combinational equality check compares the window against the target pattern:
   ```systemverilog
   assign det_o = (shift_ff == 12'b1110_1101_1011);
   ```
3. **Reset** (active-low, asynchronous) clears the window so stale bits cannot cause a false detection at start-up.

Because the window slides one bit at a time, **overlapping occurrences** of the pattern are detected naturally — no FSM restart logic is needed.

## 3. Advantages and Use Cases

**Advantages**
- Dramatically simpler than a Mealy/Moore FSM for long patterns: a 12-bit sequence would need a 12-state machine, while this is just a shift register plus one comparator.
- Handles **overlapping patterns** for free.
- Easily parameterized — change `LENGTH` and the compare constant to detect any fixed sequence.

**Use cases**
- **Frame/sync-word detection** in serial protocols (start-of-frame markers, preambles, sync patterns in UART/Ethernet/wireless basebands).
- **Pattern matching** in bitstream scanners and protocol analyzers.
- Marker detection in data recovery (e.g., finding sync marks on storage media).
- Trigger generation in logic analyzers — assert when a specific serial pattern is observed.

## Directory Structure

- `rtl/` — design (`sequence_detector.sv`)
- `svtb/` — SystemVerilog testbench (`test_sequence_counter.sv`)
