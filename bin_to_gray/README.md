# Binary to Gray Code Converter

## 1. Explanation of the Design

This design (`rtl/binary_2_gray.sv`) converts a binary number into its equivalent **Gray code** representation. Gray code (also called reflected binary code) is an ordering of binary numbers in which two successive values differ in **exactly one bit**.

The module is parameterized by `VEC_W` (default 4), so it can convert a binary vector of any width. It is a purely **combinational** design — there is no clock or reset.

| Port     | Direction | Width   | Description          |
|----------|-----------|---------|----------------------|
| `bin_i`  | input     | `VEC_W` | Binary input value   |
| `gray_o` | output    | `VEC_W` | Gray code output     |

## 2. How the Design Works

The classic binary-to-Gray conversion rule is:

- The **MSB** of the Gray code is the same as the MSB of the binary input:
  `gray_o[VEC_W-1] = bin_i[VEC_W-1]`
- Every other Gray bit is the **XOR of two adjacent binary bits**:
  `gray_o[i] = bin_i[i+1] ^ bin_i[i]`

The RTL implements this with a `generate` for-loop (`genvar i`) that instantiates one XOR per bit, making the design scale automatically with `VEC_W`. Equivalently, the whole conversion is `gray = bin ^ (bin >> 1)`.

Example (4-bit):

| Binary | Gray |
|--------|------|
| 0000   | 0000 |
| 0001   | 0001 |
| 0010   | 0011 |
| 0011   | 0010 |
| 0100   | 0110 |

Notice each step changes only a single bit.

## 3. Advantages and Use Cases

**Advantages**
- Only one bit changes between consecutive values, which eliminates intermediate invalid codes during a transition.
- Extremely cheap hardware: just `VEC_W-1` XOR gates, with no sequential logic.
- Fully parameterizable for any bus width.

**Use cases**
- **Clock Domain Crossing (CDC):** Gray-coded counters are the standard way to pass multi-bit counter values (e.g., FIFO read/write pointers) safely between asynchronous clock domains, since at most one bit is in transition at any time.
- **Asynchronous FIFO pointers** for full/empty flag generation.
- **Rotary/shaft encoders**, where mechanical position changes must never produce glitch codes.
- Reducing switching activity (dynamic power) on buses.

## Directory Structure

- `rtl/` — synthesizable design (`binary_2_gray.sv`)
- `svtb/` — SystemVerilog testbench (`test_binary_2_gray.sv`)
