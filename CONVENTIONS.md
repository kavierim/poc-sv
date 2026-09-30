<!--
SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland

Ancillary repository file (not Covered Source). RTL is under Apache-2.0; see NOTICE.
-->

# PoC_sv conventions

Translation and coding contract for this SystemVerilog port. Upstream pin: [VHDL/PoC](https://github.com/VHDL/PoC) tag **v3.0.0**, commit `b9040273`.

## Scope of this port

- **Verilator 5** only for simulation (`--timing`, `--assert`). Reference lint: `--lint-only -Wall -Wno-DECLFILENAME`.
- No vendor branches (Xilinx, Altera), no OSVVM packages or OSVVM-based testbenches, no `project_configuration` / board templates from upstream PoC.
- PoC VHDL packages become SystemVerilog packages with a **`poc_` prefix** (`utils` → `poc_utils`, `axi4` → `poc_axi4`, `axi4lite` → `poc_axi4lite`, `axi4stream` → `poc_axi4stream`, `fifo` helpers in `poc_fifo` or domain packages as upstream groups them).

## File layout and naming

- Tree mirrors upstream under `src/` (for example `src/bus/axi4/axi4_FIFO.sv` from `axi4_FIFO.vhdl`).
- One VHDL entity → one `module` in the matching `.sv` file. **No** architecture name in the filename.
- Line endings: **LF**.
- Every `.sv` file sets `` `timescale 1ns/1ps `` immediately after the header block.

## Covered Source headers (Apache-2.0)

Every new file under `src/`, `sim/`, or `fv/` starts with SPDX and a modification notice. **Retain** upstream `SPDX-FileCopyrightText` lines from the VHDL file (for example `The PoC-Library Authors`, `Technische Universitaet Dresden` where present). Add the translator line and `SPDX-License-Identifier: Apache-2.0`.

```systemverilog
// SPDX-FileCopyrightText: <years> The PoC-Library Authors
// SPDX-FileCopyrightText: <years> Technische Universitaet Dresden   // when present upstream
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273
```

| Category | Paths | Per-file header |
| --- | --- | --- |
| Covered Source | `src/**/*.sv`, `sim/**/*.sv`, `fv/**/*.sv` | PoC copyright lines + Kari + `Apache-2.0` + translation block |
| Licence / notice | `LICENSES/Apache-2.0.txt`, `NOTICE` | No SPDX header |
| Documentation | `docs/**` | None |
| Ancillary | `CHANGELOG.md`, `verilator/*.f`, `verilator/run_all.sh`, `.github/**`, `.gitignore`, `README.md`, this file | Kari copyright only; note RTL is Apache-2.0 and point to `NOTICE` |

## Types and parameters

| VHDL | SystemVerilog |
| --- | --- |
| `std_logic`, `std_ulogic` | `logic` |
| `std_logic_vector(N-1 downto 0)` | `logic [N-1:0]` |
| `unsigned(N-1 downto 0)` | `logic [N-1:0]` (unsigned arithmetic via casts or package helpers) |
| `signed(N-1 downto 0)` | `logic signed [N-1:0]` |
| `boolean` generic | `parameter bit` |
| `natural` / `positive` / `integer` | `parameter int` or `parameter int unsigned` as appropriate |
| `type data_t` generic | `parameter type data_t = logic [7:0]` |

Index **0** is the LSB on `[N-1:0]` vectors (VHDL `downto`). Use `poc_utils::downto_width` when `log2ceil` can return 0.

## Records, sized packages, and ports

PoC exposes many records on entity ports and in `*_Sized` generic packages. SystemVerilog has no unconstrained record port type.

- **Do not** flatten record ports into unrelated signal names and **do not** replace PoC bus records with `interface` types; keep field names aligned with upstream.
- Use **packed structs** for fixed layouts and **macros** for width-parameterized record shapes: `localparam` for width expressions that contain commas, then a `` `POC_*_T `` macro to declare the type.
- Width-dependent helpers: classes or package functions callable from parameters where Verilator allows (`poc_utils::log2ceil(...)` in parameter lists; avoid dotted class methods in parameters).

## Simulation semantics (Verilator)

- Two-valued default: `'U'` and `'X'` from VHDL become `0` or explicit reset behaviour unless a test documents otherwise.
- Clocks and delays: `#delay` and `--timing` on the Verilator command line.
- Self-checking tests use `$fatal` / `$error`; do not port OSVVM scoreboards or AXI4 VIP harnesses verbatim.
- Regression: `JOBS=1` and per-test `timeout` in [`verilator/run_all.sh`](verilator/run_all.sh) (default 120s) so hung sims do not pile up in WSL.
- **Lint vs sim flags:** Reference RTL lint is `verilator --lint-only -Wall -Wno-DECLFILENAME -f verilator/poc.f` (no extra waivers). [`verilator/run_all.sh`](verilator/run_all.sh) adds simulation-only waivers (`-Wno-MULTITOP`, `-Wno-UNOPTFLAT`, width/pin/range) so TB builds stay practical; do not copy those onto the lint command unless a warning is documented here.

## Documented Verilator deviations from VHDL

When upstream VHDL is correct but Verilator elaboration differs, document the workaround here and in `docs/log.md`. Do not silently simplify behaviour.

| Module | VHDL | PoC_sv |
| --- | --- | --- |
| `axi4_Mux` | `generate` on `PIPELINE_IN(i) > 0` per port; write/read see `In_M2S_g` | Verilator 5 does not treat unpacked `PIPELINE_IN[gi]` as a generate constant; derive `PIPELINE_IN_MASK` (bit *i* when `PIPELINE_IN[i] > 0`) via a `static function` + `localparam`. Generate `if` instantiates the input FIFO; the `else` branch is the only `In_S2M` bypass (so the FIFO is not a second driver). M2S bypass for unset bits stays in comb. Transaction and `In_M2S_write` / `In_M2S_read` use `In_M2S_g`, matching VHDL after the glue. |
| `axi4_DeMux` | `generate` on `PIPELINE_OUT(i) > 0` per port (`axi4_FIFO` glue); `lssb` one-hot on hit vector | Same mask pattern as `axi4_Mux`: `pipeline_out_mask()` sets `PIPELINE_OUT_MASK` (not a constant 0). In-module `demux_lssb` / `demux_lssb_idx` replace `poc_utils::bits#(PORTS)` in `always_comb` (`demux_lssb` matches `poc_utils::lssb`: lowest set bit only). Read OoO `DataIn` from forward-vector `AR_ID` slice on demux output (VHDL `read_blk`). Write OoO `Put` only in `ST_Idle` (not when AW completes in `ST_AddressOnly`). |
| `bus_Arbiter` | `OUTPUT_REG` false: `Arbitrated <= Arbitrated` in VHDL (likely typo) | `OUTPUT_REG=0`: `Arbitrated` driven from `Arbitrate` combinatorially; grants from `ChannelPointer_nxt` (functional fix vs upstream self-assign). |
| `axi4stream_Mux` / `axi4stream_DeMux` | `poc_utils::bits#(PORTS)` in `process(all)` | Verilator 5.020 C++ error when `PORTS` is 3 (`PORTS+1` response mux in `axi4_DeMux`): use module-local `mux_onehot2bin`, reductions `\|`/`&`, or `strm_demux_lssb_idx` instead of `bits` class in `always_comb`. |
| `dstruct_OutOfOrderBuffer` | `bits#(NUM_INDEX)::bin2onehot` / `reverse` in comb | Verilator 5.020 C++ error when `NUM_INDEX` is 1 (`axi4lite_DeMux` outstanding IDs): module-local `ooo_bin2onehot` / `ooo_reverse`. |
| `arith_cca` | Carry-compaction adder tree | Behavioral `a + b + c` only (simulation); generics `L`/`X` kept for API match. |
| `arith_Adder_Wide` | Configurable wide adder | Behavioral `A + B + CarryIn` only (simulation); architecture/blocking generics are no-ops. |
| `ocram_SimpleDualPort_Optimized` | Vendor RAM_TYPE splitting | Delegates to `ocram_SimpleDualPort`; URAM/BRAM/LUT optimization deferred. |
| `fifo_ic_got` | `goti = Read_Got` in read domain | Same assignment in SV (CDC read `Valid` path). Full RTL lint (`verilator/poc.f`, Verilator 5.020): internal error in `V3DfgPeephole` on write-domain `wr_cnt` (sim/TB builds OK); not a functional SV deviation. |
| `axi4stream_FIFO_CDC` | `Read_proc` drives `Out_M2S` fields | Per-field drive in read comb, not whole-struct assign from an internal record. |
| `axi4stream_FIFO_TempGot` / `axi4stream_FIFO_TempPut` | `started <= ffrs(...)` on rising edge of `Clock` | Omitted: signal is assigned in VHDL but never read (no functional effect). |

Compare every fix to `PoC/src/` at tag v3.0.0 before merging.

## Verification

- Testbenches: `sim/**/*_tb.sv`, one top per file, run via [`verilator/run_all.sh`](verilator/run_all.sh).
- Formal collateral (optional): `fv/**/*_sva.sv` bound when the port adds assertions.

## Frozen upstream reference

| Item | Value |
| --- | --- |
| Repository | https://github.com/VHDL/PoC |
| Tag | v3.0.0 |
| Commit | b9040273 |

| VHDL (PoC v3.0.0) | SystemVerilog (frozen) |
| --- | --- |
| `config` | `poc_config` (`src/common/config.sv`) |
| `utils` | `poc_utils` (`src/common/utils.sv`) |
| `strings` | `poc_strings` (`src/common/strings.sv`) |
| `vectors` | `poc_vectors` (`src/common/vectors.sv`) |

Do not rename these packages in later waves.
