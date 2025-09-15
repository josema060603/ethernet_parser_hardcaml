# Ethernet L2 Header Parser (Hardcaml / OCaml)

> Streaming Ethernet header parser built in **Hardcaml** (OCaml) with a simple CLI to emit Verilog and a self‑checking testbench.

---

## 📂 Repository layout

```
ethernet_parser_hardcaml/
├─ bin/
│  ├─ main.ml           # CLI: builds the circuit and prints/writes Verilog
│  └─ dune
├─ lib/
│  ├─ parser.ml         # Core design: I/O types + Parser.create (FSM + bit slicing)
│  └─ dune
├─ test/
│  ├─ test_ethernet_parser_hardcaml.ml  # Self‑checking testbench (Cyclesim)
│  └─ dune
├─ dune-project
└─ ethernet_parser_hardcaml.opam
```

---

## 🚀 Quick start

### 1) Install toolchain
```bash
opam switch create . 5.1.1        # or your preferred OCaml version
opam install dune hardcaml         # core deps
```

> If you already have an OCaml switch with `dune` and `hardcaml`, you can skip the install step.

### 2) Build the project
```bash
dune build
```

### 3) Emit Verilog
Two ways:

- **Stdout → redirect to file**
  ```bash
  dune exec ./bin/main.exe > parser.v
  ```

- **Programmatic file output** (supported by `main.ml`):
  ```bash
  dune exec ./bin/main.exe > parser.v
  ```

The generated RTL will look like:
```verilog
module ethernet_header_parser (
  input        clk,
  input  [63:0] tdata,
  input         tvalid,
  output [47:0] dst_mac,
  output [47:0] src_mac,
  output [15:0] eth_type,
  output        valid
);
  // ...
endmodule
```

### 4) Run tests
```bash
dune runtest
```
The testbench drives two 64‑bit words that contain a full L2 header and checks
`dst_mac`, `src_mac`, and `eth_type`. It also runs a couple of payload cycles and a gap.


---

## 🧠 Design overview

### Interface
- **Input** (AXI‑Stream‑style, no tlast included):
  - `clk` — clock
  - `tdata[63:0]` — 64‑bit data bus
  - `tvalid` — asserted when `tdata` is valid
- **No `tlast`**: framing is detected by a **gap** (`tvalid=0`) between packets.

### Bus / byte mapping
Assumption (typical for many FPGA MACs / AXIS cores):
- The **first byte on the wire** (B0) is on `tdata[7:0]`,
- next byte (B1) on `tdata[15:8]`, …,
- up to `tdata[63:56]` (B7).

Cycle 0 carries bytes `B0..B7`, cycle 1 carries `B8..B15`, etc.

### Parsed fields (Ethernet L2)
- **Destination MAC** — 6 bytes (B0..B5)
- **Source MAC** — 6 bytes (B6..B11)
- **EtherType** — 2 bytes (B12..B13)
- Total header = **14 bytes** (112 bits).

### FSM (2‑cycle parse on a 64‑bit bus)
States:
- `IDLE` → wait for `tvalid=1`
- `READ1` → capture `dst_mac` (6B) + upper 2B of `src_mac`
- `READ2` → capture lower 4B of `src_mac` + `eth_type`
- `SEND` → hold outputs stable while payload flows (`tvalid=1`); go back to `IDLE` on gap

**Valid signal policy**
- `valid` is asserted in `SEND` (stays high through payload) until the gap.
  - Alternative: change to a **one‑cycle pulse** on `READ2 → SEND` if you prefer strobe semantics.

### Endianness / packing
- On the wire, multi‑byte fields are **big‑endian (network order)**.
- The bus maps the first wire byte into the **lowest byte lane**.
- The parser packs bytes per‑lane so that printing as hex yields:
  - `dst_mac = 0x112233445566`
  - `src_mac = 0xAABBCCDDEEFF`
  - `eth_type = 0x0800`

---

## 🧪 Example timing

| Cycle | `tvalid` | `tdata[63:0]`           | Action                         |
|:----:|:--------:|:-------------------------|:-------------------------------|
| 0    | 1        | `BBAA665544332211`       | READ1: dst=B0..B5, src[47:32]=B6..B7 |
| 1    | 1        | `DEAD0008FFEEDDCC`       | READ2: src[31:0]=B8..B11, type=B12..B13 |
| 2..N | 1        | payload…                 | SEND: outputs stable, `valid=1` |
| N+1  | 0        | (don’t care)             | IDLE: wait for next frame      |

(Bytes shown MSB..LSB per 64‑bit word; B0 is the first byte on the wire.)

---

## 🧩 Implementation notes

- The design uses **Hardcaml records** for I/O (`module I`, `module O`) with `[@@deriving hardcaml]` for clean port mapping.
- The FSM uses a 2‑bit state register and selective `reg_fb` updates per state.
- **Per‑byte assembly** via `concat_msb` + `select` avoids endianness pitfalls.
- **Framing without `tlast`**: park in `SEND` while `tvalid=1`, return to `IDLE` on the first `tvalid=0` (gap).

---

## 🖼️ FSM diagram (add via draw.io)

```md
(fsm.png)
```




---

## 🛠 Commands reference

- Build: `dune build`
- Emit Verilog to a file: `dune exec ./bin/main.exe -- parser.v`
- Emit Verilog to stdout: `dune exec ./bin/main.exe > parser.v`
- Run tests: `dune runtest`

---

## 🔮 Extensions / ideas

- Optional `tlast` / `tuser` support (SOF/EOF).
- Parameterize bus width (32/64/128) and lane mapping (B0 at lane 0 or lane 7).
- VLAN tag (802.1Q) detect / parse; EthType vs length handling (< 0x0600).
- Backpressure ready/valid if you add downstream handshakes.
- Formal or property‑based checks for header stability across SEND.

---
