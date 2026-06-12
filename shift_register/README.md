# Shift Register (Serial-In, Parallel-Out)

## 1. Explanation of the Design

This design (`rtl/shift_register.sv`) is a 4-bit **serial-in, parallel-out (SIPO) shift register**. One bit (`x_i`) enters per clock cycle, and the full 4-bit history of the most recent inputs is visible in parallel on `sr_o`.

| Port    | Direction | Width | Description                          |
|---------|-----------|-------|--------------------------------------|
| `clk`   | input     | 1     | Clock                                |
| `reset` | input     | 1     | Asynchronous, active-low reset       |
| `x_i`   | input     | 1     | Serial data input                    |
| `sr_o`  | output    | 4     | Parallel view of the register        |

## 2. How the Design Works

The entire behavior is one clocked concatenation:

```systemverilog
always_ff @(posedge clk or negedge reset) begin
  if (!reset)
    sr_o <= 4'b0;
  else
    sr_o <= {sr_o[2:0], x_i};   // shift left, new bit enters at LSB
end
```

- On reset (active-low, asynchronous) the register clears to `0000`.
- On each rising clock edge, the existing contents move up one position (`sr_o[2:0]` → `sr_o[3:1]`) and the new input bit lands in `sr_o[0]`.
- After 4 clocks, `sr_o` holds the last four serial bits, oldest in `sr_o[3]`, newest in `sr_o[0]` — a sliding 4-bit window over the input stream.

## 3. Advantages and Use Cases

**Advantages**
- One of the simplest yet most versatile sequential structures: a chain of D flip-flops with no extra logic.
- Performs **serial-to-parallel conversion** with zero control overhead — data is always available in parallel.
- Naturally provides a **delayed/pipelined history** of a signal (each bit is the input delayed by k cycles).

**Use cases**
- **Deserializers / serial receivers:** UART, SPI, I2C receive paths collect incoming bits exactly like this.
- **Sequence/pattern detection:** the sliding window feeds a comparator (see the `sequence_counter` design in this repo).
- **Synchronizers and debouncing:** sampling an external signal's recent history to filter glitches.
- **Fixed delay lines** — delaying a signal by N cycles in pipelines.
- Building block for LFSRs, CRC generators, and scan chains in DFT.

## Directory Structure

- `rtl/` — design (`shift_register.sv`)
- `svtb/` — SystemVerilog testbench (`test_shift_register.sv`)
