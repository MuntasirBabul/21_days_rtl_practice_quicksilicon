# Fixed Priority Arbiter

## 1. Explanation of the Design

This design (`rtl/fixed_priority_arbiter.sv`) implements a **parameterized fixed-priority arbiter**. When multiple requestors assert `req_i` simultaneously, the port with the lowest index wins — port 0 has the highest priority, port `NUM_PORTS-1` the lowest.

| Port    | Dir    | Width       | Description                             |
|---------|--------|-------------|-----------------------------------------|
| `req_i` | input  | `NUM_PORTS` | One-hot or multi-hot request vector     |
| `gnt_o` | output | `NUM_PORTS` | One-hot grant — only one port wins      |

The design is purely **combinational** (no clock or reset).

> **Note — directory name:** The folder is currently named `fixed_priority_arbiter.sv` (with a `.sv` suffix). It should be `fixed_priority_arbiter`. This also causes the `\`include` path in `round_robin_arbiter` to be incorrect.

## 2. How the Design Works

```systemverilog
assign gnt_o[0] = req_i[0];

for (i = 1; i < NUM_PORTS; i++) begin
  assign gnt_o[i] = req_i[i] & ~(|gnt_o[i-1:0]);
end
```

- Port 0 is granted unconditionally whenever it requests.
- Port `i` is granted only if it requests **and** no lower-indexed port has already been granted (`~(|gnt_o[i-1:0])`).
- The result is always a one-hot (or zero) vector: at most one port wins per cycle.
- No registers are needed — the grant is available within a single combinational path.

Example (NUM_PORTS = 4):

| req_i | gnt_o |
|-------|-------|
| 1111  | 0001  |
| 1110  | 0010  |
| 1100  | 0100  |
| 1000  | 1000  |
| 0000  | 0000  |

## 3. Advantages and Use Cases

**Advantages**
- Extremely simple and fast — only a chain of AND/OR gates; synthesis results in a short critical path.
- Fully parameterizable for any number of ports.
- Deterministic: lowest-index port always wins when multiple requests arrive simultaneously.

**Use cases**
- **Bus arbitration** where one master must always have guaranteed access (e.g., a CPU over a DMA controller).
- Building block for more sophisticated arbiters — the `round_robin_arbiter` in this repo wraps two instances of this module.
- Interrupt priority encoders.
- Hazard resolution in pipelines (e.g., forwarding path priority).

## Directory Structure

- `rtl/` — design (`fixed_priority_arbiter.sv`)
- `svtb/` — SystemVerilog testbench (`test_fixed_priority_arbiter.sv`)
