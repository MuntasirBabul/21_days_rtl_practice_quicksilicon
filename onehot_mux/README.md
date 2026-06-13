# One-Hot Mux (5 Implementation Styles)

## 1. Explanation of the Design

This design (`rtl/onehot_mux.sv`) implements a **4-to-1 one-hot multiplexer** using five different RTL coding styles. The select signal `sel_i` is one-hot (exactly one bit high at a time), and the module selects the corresponding bit from the 4-bit input `a_i`.

| Port          | Dir    | Width | Description                                |
|---------------|--------|-------|--------------------------------------------|
| `a_i`         | input  | 4     | 4-bit data input                           |
| `sel_i`       | input  | 4     | One-hot select (bit `k` selects `a_i[k]`) |
| `y_ter_o`     | output | 1     | Output: ternary-operator implementation    |
| `y_case_o`    | output | 1     | Output: `case` statement                   |
| `y_ifelse_o`  | output | 1     | Output: `if-else` chain                    |
| `y_loop_o`    | output | 1     | Output: `for` loop with OR reduction       |
| `y_aor_o`     | output | 1     | Output: and-or tree                        |

All five outputs should always produce the same result for valid (one-hot) inputs.

> **Note — known RTL bug:** The `for` loop in the `always_comb` block uses `i` without declaring it. Should be `for (int i = 0; ...)`.

## 2. How the Design Works

All five styles implement the same logic function: select `a_i[k]` when `sel_i[k]` is set.

| Style | RTL Construct | Notes |
|-------|---------------|-------|
| Ternary | `sel_i[0] ? a_i[0] : sel_i[1] ? ...` | Priority chain; first asserted select wins |
| Case | `case(sel_i) 4'b0001: ...` | Clean and readable; synthesis may generate same hardware |
| If-else | `if (sel_i[0]) ... else if (sel_i[1]) ...` | Equivalent to ternary but explicit |
| For loop | `y |= (sel_i[i] & a_i[i])` | Generates `NUM_PORTS` AND gates feeding an OR tree |
| And-or tree | `(sel_i[0]&a_i[0]) \| ... \| (sel_i[3]&a_i[3])` | Most explicit; synthesis-friendly; same gates as loop |

The **and-or tree** style (`y_aor_o`) is what synthesis tools typically infer for any of the other styles given a one-hot constraint, so all implementations should map to identical netlists after optimization.

## 3. Advantages and Use Cases

**Advantages**
- Demonstrates that multiple RTL coding styles can describe the same hardware — understanding their equivalence prevents confusion when reading others' code.
- The and-or tree is particularly efficient for one-hot selects because it avoids any implicit priority encoding.
- The `for` loop style scales cleanly to wider muxes by changing a single parameter.

**Use cases**
- **Datapath steering** in pipelines where a one-hot control signal selects a data source.
- **Register file read ports** where a one-hot word-line drives the output mux.
- Implementing **crossbar switch outputs** when each output has exactly one active driver.
- Replacing binary-encoded muxes where the decoder has already been done upstream, saving the decode step.

## Directory Structure

- `rtl/` — design (`onehot_mux.sv`)
- `svtb/` — SystemVerilog testbench (`test_onehot_mux.sv`)
