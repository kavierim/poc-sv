<!--
SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland

Ancillary repository file (not Covered Source). RTL is under Apache-2.0; see NOTICE.
-->

# Changelog

Release notes for [poc-sv](https://github.com/kavierim/poc-sv). Version numbers track this port, not upstream VHDL/PoC.

## [0.1.8-docs] - 2026-09-30

Module documentation (Purpose / Behaviour / `REQ-<module>-NNN`), domain indexes, and README/docs polish for new readers (repo-relative run instructions; no machine paths). No RTL/TB changes.

### Added

- Entity pages and domain indexes for translated modules
- Catalog and playbook link-up from README / `docs/index.md`

## [0.1.7-tests] - 2026-09-29

CDC AXI FIFOs, core `fifo_*`, `sync_Bits`/`sync_Reset`, `ocram_SimpleDualPort`, and sample arith TBs. Regression **28/28**.

### Added

- `sim/bus/axi4/axi4_FIFO_CDC_tb.sv`, `sim/bus/axi4lite/axi4lite_FIFO_CDC_tb.sv`
- `sim/fifo/{fifo_cc_got,fifo_ic_got,fifo_Stage}_tb.sv`
- `sim/sync/{sync_Bits,sync_Reset}_tb.sv`
- `sim/mem/ocram_SimpleDualPort_tb.sv`
- `sim/arith/{arith_FirstOne,arith_Counter_Free,arith_Prefix_Or}_tb.sv`
- `verilator/files/sim_{fifo,sync,arith,mem}.f`

## [0.1.6-tests] - 2026-09-29

Verification expansion and FIFO Verilator fix. New TBs for `axi4_FIFO`, `axi4lite_FIFO`, `axi4_AXI4Lite_Converter`, `axi4stream_Stage`; strengthened `axi4lite_DeMux` (RData, overlap, DECERR) and `axi4stream_Mux` (multi-beat back-pressure). `axi4lite_FIFO` channel packing uses scalar localparams so Verilator 5 can elaborate the DUT as a TB top.

### Added

- Verilator regression **17/17** (`JOBS=1`, `SIM_TIMEOUT=180`, WSL).
- Docs: getting-started playbook; verification matrix updated.

## [0.1.5-tests] - 2026-09-28

P0 verification pass: stronger smoke TBs (`axi4_DeMux` overlapping decode + W-before-AW, `axi4_Mux` BID/RID and sink data, AXI4-Stream Mux/DeMux payload/`Keep`), optional `axi4lite_DeMux` downstream `WData` check. Playbook [`docs/playbooks/verification.md`](docs/playbooks/verification.md) documents gaps vs PoC OSVVM and regression (`SIM_TIMEOUT=180` recommended).

### Added

- Verilator regression **13/13** (`JOBS=1`, `SIM_TIMEOUT=180`).

## [0.1.4-audit-demux] - 2026-09-28

Second VHDL audit fixes on **`axi4_DeMux`**: `demux_lssb` matches PoC `lssb` (lowest hit only); write FSM no extra OoO `Put` in `ST_AddressOnly`; AR forward unpack field order and OoO `DataIn` from `ARID` slice per VHDL. **`axi4_DeMux_tb`**: AR sideband checks. **`CONVENTIONS`**: `bus_Arbiter` `OUTPUT_REG=0` documented vs VHDL self-assign.

### Fixed

- Verilator regression **13/13** unchanged after fixes.

## [0.1.3-review] - 2026-09-28

Review fixes against PoC v3.0.0: `axi4_DeMux` `PIPELINE_OUT_MASK` follows `PIPELINE_OUT[]` (output FIFO glue was forced off); `axi4_Mux` write/read path uses post-glue `In_M2S_g` and does not double-drive `In_S2M` when an input FIFO is present. Smoke TBs for `axi4stream_FIFO_TempPut` and AXI4-Stream terminations. `verilator/poc.f` includes `axi4lite_DeMux`. Source line endings normalized to LF.

### Added

- Verilator regression **13/13** (`JOBS=1`, `SIM_TIMEOUT=120`, WSL): previous 11 plus `axi4stream_FIFO_TempPut_tb` and `axi4stream_Termination_tb`.

## [0.1.2-axi4stream-complete] - 2026-09-27

Complete AXI4-Stream entity set from PoC v3.0.0: **Pause**, **FIFO_TempGot**, **FIFO_TempPut**, **Termination_Receiver**, **Termination_Transmitter**. Smoke TBs for Pause and FIFO_TempGot.

### Added

- Verilator regression **11/11** (`JOBS=1`, `SIM_TIMEOUT=120`).

## [0.1.1-review-fixes] - 2026-09-27

Post-review: VHDL-faithful **`axi4_DeMux`** (write/read FSMs, OoO IDs, B/R stream mux, `PIPELINE_OUT` glue); stronger **`axi4_DeMux_tb`** (split AW/W, BID/RID). **`axi4_Mux`**: `PIPELINE_IN_MASK` derived from `PIPELINE_IN[]`. Packaging: **`axi4lite_DeMux`** in Bender/FuseSoC lists; removed axi4stream **MODDUP** compile. CONVENTIONS documents arith behavioral stubs and `fifo_ic_got` lint internal error.

### Fixed

- Verilator regression **9/9** (`JOBS=1`, `SIM_TIMEOUT=120`) after DeMux rewrite.

## [0.1.0-wave3-integration] - 2026-09-27

Wave 3 AXI integration pass: file lists, Verilator port typing (`parameter type`), `run_all.sh`, packaging generator.

### Fixed

- Verilator regression **9/9** (`JOBS=1`, `SIM_TIMEOUT=120`): `axi4_Mux` (`PIPELINE_IN_MASK`, `In_M2S` write path, arbiter `OUTPUT_REG`), `axi4stream_FIFO_CDC` (per-field `Out_M2S` read drive), `fifo_ic_got` `goti`/`Read_Got` alignment with VHDL.

## [0.1.0-wave1] - 2026-09-27

Wave 1 common packages: `poc_config`, `poc_utils`, `poc_strings`, `poc_vectors` under `src/common/`. Verilator lint (`--lint-only -Wall -Wno-DECLFILENAME`) clean via `verilator/poc.f` and `verilator/files/common.f`.

## [0.0.0-scaffold] - 2026-09-27

Repository scaffold (wave 0): Apache-2.0 layout, NOTICE, README, AGENTS.md, CONVENTIONS.md, empty `src/`/`sim/`/`fv/` trees, docs skeleton, Verilator `run_all.sh` stub, GitHub Actions workflow, and `.gitignore`. No RTL yet. Upstream pin: PoC tag v3.0.0 (`b9040273`).
