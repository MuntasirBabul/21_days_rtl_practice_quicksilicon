# Round-Robin Arbiter

## 1. Explanation of the Design

This design (`rtl/round_robin_arbiter.sv`) implements a **4-port round-robin arbiter** built on top of two instances of `fixed_priority_arbiter`. Round-robin ensures that every requestor eventually gets the bus — no port can be starved indefinitely — by rotating priority after each grant.

| Port    | Dir    | Width | Description                                  |
|---------|--------|-------|----------------------------------------------|
| `clk`   | input  | 1     | Clock                                        |
| `reset` | input  | 1     | Asynchronous active-high reset               |
| `req_i` | input  | 4     | Request vector (any combination of ports)    |
| `gnt_o` | output | 4     | One-hot grant — exactly one port wins        |

> **Note — known RTL bug:** The `` `include `` path is `../../fixed_priority_arbiter/rtl/fixed_priority_arbiter.sv`, but the actual folder is named `fixed_priority_arbiter.sv` (with `.sv` extension). The correct path would be `../../fixed_priority_arbiter.sv/rtl/fixed_priority_arbiter.sv`. Renaming the directory to `fixed_priority_arbiter` would fix both this include and the directory naming issue.

## 2. How the Design Works

The design uses a **mask-based round-robin** technique:

1. A 4-bit `mask_q` register tracks which ports have already been served since the last full rotation. After a grant on port `k`, the mask disables all ports `0..k` (sets them to 0) so they lose priority until the higher-numbered ports get a turn.

2. **Masked requests** = `req_i & mask_q`. A `fixed_priority_arbiter` instance (`maskedGnt`) grants the lowest-indexed *unmasked* requestor.

3. **Raw requests** = `req_i`. A second `fixed_priority_arbiter` instance (`rawGnt`) grants with no mask applied — used as a fallback when `mask_req` is all-zero (every pending requestor is in the masked-out group, meaning the rotation has gone full-circle).

4. Final grant: `gnt_o = |mask_req ? mask_gnt : raw_gnt`.

### Mask update logic

| Last grant | Next mask |
|-----------|-----------|
| port 0    | `1110`    |
| port 1    | `1100`    |
| port 2    | `1000`    |
| port 3    | `0000`    |

When the mask becomes `0000`, the raw arbiter takes over and grants the highest-priority waiting port, after which the mask is set based on that grant.

## 3. Advantages and Use Cases

**Advantages**
- **Starvation-free:** every active requestor is guaranteed a grant within `NUM_PORTS` cycles.
- Reuses the simple `fixed_priority_arbiter` as a building block — shows how to compose arbiters.
- The mask-based approach requires only one additional register and two OR gates beyond two fixed-priority instances.

**Use cases**
- **Bus fabrics:** granting access to a shared memory or peripheral among multiple bus masters (DMA, CPU, GPU).
- **Network switch schedulers:** fairness between output ports or flows.
- **Multi-core cache coherence:** arbitrating snoop requests across cores.
- **FIFO draining:** fairly servicing multiple FIFOs that feed a single serializer.

## Directory Structure

- `rtl/` — design (`round_robin_arbiter.sv`)
- `svtb/` — SystemVerilog testbench (`test_round_robin_arbiter.sv`)
