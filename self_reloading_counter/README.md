# Self-Reloading Counter

## 1. Explanation of the Design

This design (`rtl/self_reloading_counter.sv`) is a 4-bit up-counter that can be **loaded with a value on demand** and that **automatically reloads itself** with that value whenever it reaches its terminal count (`0xF`). Instead of wrapping to zero like a plain counter, it wraps back to the programmed load value.

| Port         | Direction | Width | Description                                   |
|--------------|-----------|-------|-----------------------------------------------|
| `clk`        | input     | 1     | Clock                                         |
| `reset`      | input     | 1     | Asynchronous reset                            |
| `load_i`     | input     | 1     | When high, load `load_val_i` into the counter |
| `load_val_i` | input     | 4     | Value to load / reload from                   |
| `count_o`    | output    | 4     | Current count                                 |

## 2. How the Design Works

The next count value is chosen by a priority ladder inside the clocked process:

```systemverilog
count_o = load_i ? load_val_i
        : (count_o == 4'hF) ? load_val_i
        : count_o + 'b1;
```

1. **Reset** clears the counter to `0`.
2. **Explicit load:** if `load_i` is asserted, the counter takes `load_val_i` on the next clock edge.
3. **Self-reload:** if the counter has reached the maximum value `4'hF`, it reloads `load_val_i` automatically — no external strobe needed.
4. **Count:** otherwise it increments by 1.

The result is a repeating sequence `load_val → load_val+1 → … → 0xF → load_val → …`, i.e. a **modulo counter whose period is programmable** (`16 − load_val` counts per cycle).

## 3. Advantages and Use Cases

**Advantages**
- The reload happens in hardware with zero software/control overhead — the period is set once and the counter free-runs.
- Programmable period from a single load value, without redesigning the counter.
- Simple priority scheme (load > terminal-count reload > increment) is easy to reason about and extend.

**Use cases**
- **Programmable timers / periodic interrupt generators** — the classic auto-reload timer found in microcontrollers.
- **Baud-rate generators and clock dividers** with a software-programmable divide ratio.
- **PWM period counters**, where the count window repeats continuously.
- Refresh counters (e.g., DRAM refresh interval) and any fixed-interval event generator.

## Directory Structure

- `rtl/` — design (`self_reloading_counter.sv`)
