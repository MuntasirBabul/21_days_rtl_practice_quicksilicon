# LFSR — Linear Feedback Shift Register

## 1. Explanation of the Design

This design (`rtl/lfsr.sv`) implements a 4-bit **Linear Feedback Shift Register**. An LFSR is a shift register whose next input bit is a linear function (XOR) of selected bits of its current state, called **taps**. Clocked repeatedly, it walks through a pseudo-random sequence of states.

| Port     | Direction | Width | Description                       |
|----------|-----------|-------|-----------------------------------|
| `clk`    | input     | 1     | Clock                             |
| `reset`  | input     | 1     | Asynchronous, active-low reset    |
| `lfsr_o` | output    | 4     | Current LFSR state                |

## 2. How the Design Works

On every rising clock edge the register shifts, and the feedback bit — the XOR of the tap positions (here bits 1 and 3) — is inserted:

```systemverilog
lfsr_o <= {lfsr_o[0], lfsr_o[1] ^ lfsr_o[3]};
```

- The XOR of the tapped bits forms the new feedback value.
- The register contents shift by one position each cycle.
- Because the feedback is a fixed linear function of the state, the sequence of states is deterministic and repeats with a fixed period. With well-chosen (maximal) taps, an n-bit XOR LFSR cycles through `2^n − 1` states — every value except the all-zeros lock-up state.

Note that since reset clears the register to `0` and XOR feedback cannot escape the all-zeros state, a practical XOR LFSR is normally seeded with a non-zero value (or built with XNOR feedback so that all-zeros is a valid state).

## 3. Advantages and Use Cases

**Advantages**
- Extremely cheap pseudo-random sequence generator: just a shift register plus one XOR gate.
- Very fast — the critical path is a single XOR — so it scales to high clock rates.
- Deterministic and repeatable: the same seed always yields the same sequence, which is ideal for reproducible tests.
- An n-bit LFSR counter is much smaller than a binary counter of the same range (no carry chain).

**Use cases**
- **Pseudo-random number/pattern generation** for test stimulus.
- **Built-In Self-Test (BIST)** — pattern generation and output signature compression (MISR) in silicon test.
- **Scramblers/descramblers and whitening** in serial communication links (PCIe, Ethernet, SATA).
- **CRC computation** — CRC circuits are LFSRs with the polynomial as taps.
- Fast event counters and timeout counters where the count value need not be binary-ordered.
- Spread-spectrum and PN-sequence generation in communications.

## Directory Structure

- `rtl/` — design (`lfsr.sv`)
- `svtb/` — SystemVerilog testbench (`test_lfsr.sv`)
