# Odd Counter

## 1. Explanation of the Design

This design (`rtl/odd_counter.sv`) is an 8-bit counter that counts through **odd numbers only**: 1, 3, 5, 7, 9, … It demonstrates that a counter does not have to increment by one — the increment step and starting value define the sequence.

| Port    | Direction | Width | Description                                |
|---------|-----------|-------|--------------------------------------------|
| `clk`   | input     | 1     | Clock                                      |
| `reset` | input     | 1     | Synchronous, active-high reset             |
| `cnt_o` | output    | 8     | Current odd count value                    |

## 2. How the Design Works

The whole counter is a single clocked process:

```systemverilog
always_ff @(posedge clk) begin
  if (reset)
    cnt_o <= 8'h1;   // start at the first odd number
  else
    cnt_o <= cnt_o + 8'h2;  // step by 2 to stay odd
end
```

- **Reset** is *synchronous* (checked only at the rising clock edge) and loads the counter with `1` — an odd seed.
- Every subsequent clock edge adds `2`. Since odd + even = odd, the value remains odd forever.
- The 8-bit register naturally wraps: … 251, 253, 255, then overflows back to 1 (255 + 2 = 257 = 9'h101, truncated to 8'h01), so the sequence stays odd even across wrap-around.

The least significant bit is always `1`, which a synthesis tool can exploit — effectively only the upper 7 bits actually count.

## 3. Advantages and Use Cases

**Advantages**
- Shows how choosing the **reset value and increment step** shapes a counting sequence — a key counter design idea.
- Wrap-around behavior preserves the invariant (always odd) with no extra logic.
- Synchronous reset keeps all timing within the clock domain.

**Use cases**
- Generating **odd-only sequences** for addressing (e.g., accessing odd memory banks/indices, interleaved buffers).
- Stride-based address generators in DSP/DMA engines (this is a stride-2 counter).
- Clock-divider and phase-pattern generation schemes that require odd counts.
- A practice vehicle for learning counters, synchronous resets, and overflow behavior in RTL.

## Directory Structure

- `rtl/` — design (`odd_counter.sv`)
- `svtb/` — SystemVerilog testbench (`test_odd_counter.sv`) and Questa run script (`run.do`)
