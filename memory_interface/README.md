# Memory Interface with Random Latency

## 1. Explanation of the Design

This design (`rtl/mem_inft.sv`) implements a **16-entry × 32-bit synchronous memory** with a variable-latency ready signal. The latency on every new request is randomized using an internal 4-bit LFSR, mimicking the non-deterministic response times of real SRAM or DRAM controllers.

| Port           | Dir    | Width | Description                                     |
|----------------|--------|-------|-------------------------------------------------|
| `clk`          | input  | 1     | Clock                                           |
| `reset`        | input  | 1     | Asynchronous active-high reset                  |
| `req_i`        | input  | 1     | Request strobe (hold high until `req_ready_o`)  |
| `req_rnw_i`    | input  | 1     | `1` = read, `0` = write                         |
| `req_addr_i`   | input  | 4     | Word address (16 locations)                     |
| `req_wdata_i`  | input  | 32    | Write data                                      |
| `req_ready_o`  | output | 1     | Handshake: transaction accepted this cycle      |
| `req_rdata_o`  | output | 32    | Read data (valid when `req_ready_o` is high)    |

The module includes `lfsr.sv` and `edge_detector.sv` from sibling directories.

## 2. How the Design Works

1. **Edge detection** — An `edge_detector` instance watches `req_i`. On the rising edge (start of a new request), it samples the current LFSR value to determine the latency count.

2. **Countdown counter** — A 4-bit counter is loaded with the LFSR value on every new request rising edge and counts up each cycle until it overflows to zero.

3. **Ready signal** — `req_ready_o = ~|count` — the memory signals ready only when the counter reaches all-zeros, producing a random delay of 1–15 cycles (depending on the LFSR output).

4. **Write path** — Data is written to `mem[req_addr_i]` only when `req_i`, `~req_rnw_i`, and `~|count` are all true simultaneously.

5. **Read path** — `req_rdata_o` is driven directly (combinationally) from `mem[req_addr_i]` whenever `req_i && req_rnw_i`.

The LFSR uses the polynomial x⁴ + x³ + 1 (taps on bits 3 and 1), initialized to `4'hE`, and cycles through 15 non-zero values.

## 3. Advantages and Use Cases

**Advantages**
- The LFSR-based random latency is a realistic model of memories that insert wait states.
- The ready/valid handshake is simple to integrate: hold the request, wait for the ready pulse.
- Parameterized for formal verification (`FORMAL` guard switches to unpacked array syntax).

**Use cases**
- **Memory controller modelling** in simulation to stress-test designs that must tolerate variable latency.
- A sub-component of the APB slave in this repo (`../apb/`).
- Teaching proper handshake protocols: the requester must hold signals stable and only sample data when `ready` is asserted.
- Integration with an APB, AXI-lite, or custom bus as a backing store.

## Directory Structure

- `rtl/` — design (`mem_inft.sv`)
- `svtb/` — SystemVerilog testbench (`test_memory_interface.sv`)
