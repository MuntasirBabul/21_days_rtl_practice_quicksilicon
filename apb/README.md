# APB Master / Slave System

## 1. Explanation of the Design

This directory contains a complete **APB (Advanced Peripheral Bus) system** consisting of three files:

| File              | Module        | Description                                  |
|-------------------|---------------|----------------------------------------------|
| `rtl/apb_master.sv` | `apb_master` | AMBA APB master with a 3-state FSM           |
| `rtl/apb_slave.sv`  | `apb_slave`  | APB slave wrapping a `memory_interface`      |
| `rtl/apb_system.sv` | `day20`      | Top-level system connecting master and slave through a FIFO and a fixed-priority arbiter |

The design follows the **AMBA APB protocol**, which uses three phases per transaction:
- **IDLE** — no transfer in progress.
- **SETUP** — `PSEL` is asserted; slave prepares.
- **ACCESS** — `PSEL` and `PENABLE` are both asserted; transaction completes when `PREADY` goes high.

### APB Master Port Table

| Port        | Dir    | Width | Description                                             |
|-------------|--------|-------|---------------------------------------------------------|
| `clk`       | input  | 1     | Clock                                                   |
| `reset`     | input  | 1     | Asynchronous active-high reset                          |
| `cmd_i`     | input  | 2     | `2'b00`=NOP, `2'b01`=Read, `2'b10`=Write               |
| `psel_o`    | output | 1     | APB select                                              |
| `penable_o` | output | 1     | APB enable                                              |
| `paddr_o`   | output | 32    | Target address (fixed at `0xDEAD_CAFE`)                 |
| `pwrite_o`  | output | 1     | `1` = write, `0` = read                                 |
| `pwdata_o`  | output | 32    | Write data (last read value + 1)                        |
| `pready_i`  | input  | 1     | Slave ready handshake                                   |
| `prdata_i`  | input  | 32    | Read data from slave                                    |

## 2. How the Design Works

### APB Master FSM

```
IDLE ──(cmd_i != 0)──► SETUP ──► ACCESS ──(pready_i)──► IDLE
```

1. The master waits in **IDLE** until a non-zero `cmd_i` is received.
2. It moves to **SETUP**, asserting `PSEL`.
3. On the next clock it enters **ACCESS**, asserting both `PSEL` and `PENABLE`.
4. It stays in ACCESS until the slave asserts `PREADY`, then returns to IDLE.

For a **write** transaction, the master sends `rdata_q + 1` as the write data, where `rdata_q` latches the last read data. This implements a simple read-modify-write pattern.

### APB Slave

The slave wraps the `memory_interface` module (from `../memory_interface/`), translating APB signals into the memory's `req_*` interface. The memory introduces random latency through an internal LFSR counter, which is reflected back as delayed `PREADY`.

### APB System (`day20`)

The system integrates:
- A **fixed-priority arbiter** to choose between read and write requests.
- A **synchronous FIFO** (depth 16) to buffer pending commands.
- The APB master and slave connected together.

## 3. Advantages and Use Cases

**Advantages**
- APB is a low-complexity, low-power bus — minimal signal count compared to AHB or AXI.
- The three-phase protocol makes it easy to add variable-latency slaves via `PREADY`.
- The separation of master, slave, and system files makes each block independently verifiable.

**Use cases**
- Configuration and control register access in SoCs (GPIOs, timers, UARTs, interrupt controllers).
- Low-bandwidth peripheral busses where throughput is less important than simplicity.
- A teaching vehicle for the AMBA APB protocol handshake and FSM-based bus masters.

## Directory Structure

- `rtl/` — APB master (`apb_master.sv`), slave (`apb_slave.sv`), and full system (`apb_system.sv`)
- `svtb/` — SystemVerilog testbench (`test_apb_master.sv`)
