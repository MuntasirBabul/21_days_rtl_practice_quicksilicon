# Synchronous FIFO

## 1. Explanation of the Design

This design (`rtl/fifo_sync.sv`) implements a parameterized **synchronous first-in, first-out (FIFO) buffer**. Both the read and write ports share a single clock domain. The data width and depth are set at elaboration time via the `DATA_W` and `DEPTH` parameters.

| Port           | Dir    | Width    | Description                        |
|----------------|--------|----------|------------------------------------|
| `clk`          | input  | 1        | Clock                              |
| `reset`        | input  | 1        | Active-low asynchronous reset      |
| `push_i`       | input  | 1        | Push (write) strobe                |
| `push_data_i`  | input  | `DATA_W` | Data to push                       |
| `pop_i`        | input  | 1        | Pop (read) strobe                  |
| `pop_data_o`   | output | `DATA_W` | Data popped from head              |
| `full_o`       | output | 1        | FIFO is full                       |
| `empty_o`      | output | 1        | FIFO is empty                      |

> **Note — known RTL bug:** `wr_ptr_q <= wr_ptr_q` in the `always_ff` block should be `wr_ptr_q <= nxt_wr_ptr`, and a semicolon is missing after the combinational `fifo_pop_data` assignment before the `case` statement. The FIFO write pointer never advances in the current RTL.

## 2. How the Design Works

The FIFO uses a **circular buffer** backed by a register array (`fifo_mem`):

- Separate read and write pointers (`rd_ptr_q`, `wr_ptr_q`) are `PTR_W + 1` bits wide. The extra MSB acts as a **wrap bit** to distinguish the full and empty conditions when lower bits are equal.
- **Empty:** `rd_ptr == wr_ptr` (all bits equal).
- **Full:** wrap bits differ but lower bits are equal.
- A `case({pop_i, push_i})` block handles four scenarios:
  - `ST_PUSH (01)` — increment write pointer.
  - `ST_POP (10)` — increment read pointer.
  - `ST_BOTH (11)` — increment both (simultaneous push and pop).
  - `00` — no change.

## 3. Advantages and Use Cases

**Advantages**
- Parameterized depth and width make the same RTL reusable across the design.
- The extra-bit pointer technique gives correct full/empty detection without a separate counter.
- Simultaneous push and pop are supported without loss of data or stalling.

**Use cases**
- **Clock-domain boundary buffering** (synchronous FIFO; for CDC use an async FIFO).
- **Rate matching** between a fast producer and a slow consumer (or vice versa).
- Command queues in bus fabrics and DMA controllers.
- Packet buffering in network interfaces.

## Directory Structure

- `rtl/` — design (`fifo_sync.sv`)
- `svtb/` — SystemVerilog testbench (`test_fifo_sync.sv`)
