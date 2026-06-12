# Binary to One-Hot Converter

## 1. Explanation of the Design

This design (`rtl/bin_to_onehot.sv`) converts a binary-encoded value into a **one-hot** code — a vector in which exactly one bit is set to `1` and all others are `0`. The position of the set bit equals the binary input value.

The module has two parameters:

- `BIN_W` (default 4) — width of the binary input
- `ONE_HOT_W` (default 16) — width of the one-hot output (normally `2**BIN_W`)

| Port        | Direction | Width       | Description                  |
|-------------|-----------|-------------|------------------------------|
| `bin_i`     | input     | `BIN_W`     | Binary-encoded input         |
| `one_hot_o` | output    | `ONE_HOT_W` | One-hot encoded output       |

It is purely **combinational** — no clock or reset.

## 2. How the Design Works

The entire conversion is a single shift operation:

```systemverilog
assign one_hot_o = 1'b1 << bin_i;
```

A constant `1` is left-shifted by the binary input value, so the bit at index `bin_i` becomes `1` and every other bit is `0`. The synthesizer maps this to a standard binary decoder.

Example (`BIN_W = 4`, `ONE_HOT_W = 16`):

| `bin_i` | `one_hot_o`           |
|---------|------------------------|
| 0000    | 0000_0000_0000_0001    |
| 0011    | 0000_0000_0000_1000    |
| 1111    | 1000_0000_0000_0000    |

## 3. Advantages and Use Cases

**Advantages**
- One-line, easily readable RTL that synthesizes into a clean decoder.
- One-hot signals need **no further decoding** at their destination — each bit can directly drive an enable.
- Comparisons against a one-hot value are a single AND/bit-select rather than a full equality check.

**Use cases**
- **Address decoders** — selecting one of N peripherals/registers from a binary address.
- **One-hot FSM state encoding**, common in FPGA designs for speed (simple next-state logic).
- **Chip/bank select generation** in memory subsystems.
- Driving **multiplexer/demultiplexer select lines** and per-channel enables.
- Priority and arbitration logic where a single active grant line is required.

## Directory Structure

- `rtl/` — synthesizable design (`bin_to_onehot.sv`)
