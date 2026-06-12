# Serializer (Parallel-to-Serial Converter)

## 1. Explanation of the Design

This design (`rtl/serializer.sv`) converts a **4-bit parallel word into a serial bit stream**, one bit per clock cycle, with flow-control style status signals: `empty_o` tells the producer when a new word can be accepted, and `valid_o` qualifies the serial output bits.

| Port         | Direction | Width | Description                                    |
|--------------|-----------|-------|------------------------------------------------|
| `clk`        | input     | 1     | Clock                                          |
| `reset`      | input     | 1     | Asynchronous, active-low reset                 |
| `parallel_i` | input     | 4     | Parallel data word to serialize                |
| `serial_o`   | output    | 1     | Serial data output (LSB first)                 |
| `valid_o`    | output    | 1     | High while `serial_o` carries valid data bits  |
| `empty_o`    | output    | 1     | High when the serializer can accept a new word |

## 2. How the Design Works

The core is a 4-bit shift register plus a small cycle counter:

1. **Load:** when `empty_o` is high, the parallel word is captured into the shift register:
   ```systemverilog
   assign next_shift = empty_o ? parallel_i : {'1, shift_ff[3:1]};
   ```
2. **Shift:** on each following clock, the register shifts right by one; `serial_o = shift_ff[0]`, so bits stream out **LSB first**.
3. **Bookkeeping:** a counter (`count_ff`) tracks progress through the word:
   - `empty_o = (count_ff == 0)` — the unit is ready for a new parallel word.
   - `valid_o = |count_ff` — output bits are valid while the counter is non-zero (i.e., during the shifting phase, not on the load cycle).
   - When the counter reaches its terminal value it returns to zero, re-asserting `empty_o` so the next word can be loaded back-to-back.

The result is a repeating load → shift×4 cadence: one cycle to accept data, four cycles streaming it out.

## 3. Advantages and Use Cases

**Advantages**
- Reduces pin/wire count: an N-bit bus is carried over a single data line (plus valid), trading width for time.
- Built-in handshaking (`empty`/`valid`) lets the producer and consumer synchronize without external control logic.
- Simple, low-area structure — a shift register and a tiny counter.

**Use cases**
- **Serial transmitters:** UART, SPI, I2C, and custom serial links all serialize parallel data this way.
- **SerDes front-ends** in high-speed I/O (the "Ser" half of SerDes).
- Off-chip communication where package pins are scarce (LED drivers, display interfaces, daisy-chained peripherals).
- Scan-out / debug interfaces streaming internal registers off-chip over one pin.

## Directory Structure

- `rtl/` — design (`serializer.sv`)
- `svtb/` — SystemVerilog testbench (`test_serializer.sv`)
