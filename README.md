<!--
SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland

Ancillary repository file (not Covered Source). RTL is under Apache-2.0; see NOTICE.
-->

# PoC SystemVerilog Library - Reusable AXI4 / FIFO / Sync RTL with Verilator and Yosys ASIC Checks

[![Verilator](https://github.com/kavierim/poc-sv/actions/workflows/verilator.yml/badge.svg)](https://github.com/kavierim/poc-sv/actions/workflows/verilator.yml)
[![ASIC synth](https://github.com/kavierim/poc-sv/actions/workflows/asic-synth.yml/badge.svg)](https://github.com/kavierim/poc-sv/actions/workflows/asic-synth.yml)

`poc-sv` is an unofficial [SystemVerilog](https://en.wikipedia.org/wiki/SystemVerilog) port of the VHDL **[PoC-Library](https://github.com/VHDL/PoC)** (“Pile of Cores”) v3.0.0. It ships reusable **RTL** for **AXI4**, **AXI4-Lite**, and **AXI4-Stream**, plus FIFOs, synchronizers, on-chip memory, and arithmetic blocks. Regression uses **[Verilator](https://www.veripool.org/verilator/) 5**; CI also runs **Yosys ASIC synthesis** (`read_slang` + generic `synth`).

Pinned to upstream tag [**v3.0.0**](https://github.com/VHDL/PoC/releases/tag/v3.0.0) (commit [`b9040273`](https://github.com/VHDL/PoC/commit/b9040273)). Apache-2.0. Not endorsed by OSVG or the upstream PoC maintainers.

## Overview

PoC is a large VHDL IP catalog. This repository ports a working subset to SystemVerilog so SoC and FPGA projects can instantiate the same interconnect and glue blocks without a VHDL toolchain. Each translated entity has Purpose, Behaviour, and `REQ-*` IDs under [`docs/modules/`](docs/modules/index.md). Known gaps (untranslated UART / `bus/stream` / `bus/drp`, formal scaffolding only) are listed under [Status](#status).

## Key features

- **Buses** under `src/bus/`: AXI4, AXI4-Lite, and AXI4-Stream (mux/demux, FIFOs including CDC, register file, OCRAM adapter, stream stage and termination) and a shared arbiter
- **FIFOs, sync, memory, arithmetic:** clock-domain FIFOs, synchronizers, on-chip RAM, portable arithmetic, out-of-order buffer
- **66** module documentation pages ([catalog](docs/modules/index.md)); **28** self-checking Verilator testbenches
- **CI:** Verilator suite + Yosys ASIC smoke (`read_slang` + generic `synth`) on every push/PR
- **Behavioral Python models** under `model/` (`uv run pytest`) for AXI-Stream FIFO and Mux before RTL edits
- **Integration manifests:** `poc.f`, `Bender.yml`, `poc.core`

## Architecture / tech stack

| Layer | Path / tool |
| --- | --- |
| SystemVerilog RTL | `src/` (`bus`, `fifo`, `sync`, `mem`, `arith`, `dstruct`, `common`) |
| Simulation | Verilator 5 (`--timing`, `--assert`); `verilator/run_all.sh` |
| ASIC smoke | Yosys via oss-cad-suite; `tools/synth_asic.py` (`read_slang` + `synth`) |
| Behavioral models | `model/poc_model/` + shared kernel; [uv](https://docs.astral.sh/uv/) + pytest |
| Requirements / SysML | `docs/modules/`, `sysml/`, `tools/check_sysml_ssot.py` |

ASIC smoke is a generic synthesis check, not a Liberty or SRAM macro signoff; on-chip memories may become flip-flops. **Exception:** `arith_TRNG` is listed as `SKIP` — it is a combinational-loop entropy source that no synthesizable parent instantiates (ABC rejects the loops). Details: [`docs/playbooks/asic-synth.md`](docs/playbooks/asic-synth.md).

## Quickstart / installation

Needs Verilator 5 and GNU `timeout(1)`. On Windows, use WSL or another Linux environment.

```sh
# from the repository root
sudo apt install verilator   # Debian/Ubuntu / WSL example
JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh
```

Exit 0 means all `sim/**/*_tb.sv` passed. Full notes: [`docs/playbooks/getting-started.md`](docs/playbooks/getting-started.md).

Optional ASIC smoke (oss-cad-suite with `read_slang`; do not commit machine-specific suite paths):

```sh
source "$HOME/oss-cad-suite/environment"
python3 tools/synth_asic.py
```

Optional behavioral model tests:

```sh
cd model
uv run pytest
```

## Usage / example

**Full Verilator regression** (repository root):

```sh
JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh
```

Logs land under `obj_dir/<tb_name>/` (`run.log`, `result`). Matrix and focus areas: [`docs/playbooks/verification.md`](docs/playbooks/verification.md).

**Yosys ASIC smoke** for every synthesizable `module` under `src/` (see [`asic-synth.md`](docs/playbooks/asic-synth.md)):

```sh
source "$HOME/oss-cad-suite/environment"
python3 tools/synth_asic.py
```

**Python stream models** (AXI-Stream FIFO / Mux; see [`docs/playbooks/model.md`](docs/playbooks/model.md)):

```sh
cd model
uv run pytest
```

Wire RTL via the file lists in `poc.f`, `Bender.yml`, or `poc.core`. Module ports and requirements are per-entity under [`docs/modules/`](docs/modules/index.md).

## Continuous integration

| Workflow | What it checks |
| --- | --- |
| [`.github/workflows/verilator.yml`](.github/workflows/verilator.yml) | Full Verilator suite (`verilator/run_all.sh`, 28 testbenches) |
| [`.github/workflows/asic-synth.yml`](.github/workflows/asic-synth.yml) | Yosys ASIC smoke via [`tools/synth_asic.py`](tools/synth_asic.py) |

## Documentation

| | |
| --- | --- |
| Start here | [`docs/index.md`](docs/index.md) |
| Run & verify | [`docs/playbooks/getting-started.md`](docs/playbooks/getting-started.md), [`verification.md`](docs/playbooks/verification.md), [`asic-synth.md`](docs/playbooks/asic-synth.md) |
| SysML & models | [`docs/playbooks/sysml.md`](docs/playbooks/sysml.md), [`model.md`](docs/playbooks/model.md) |
| Modules & requirements | [`docs/modules/index.md`](docs/modules/index.md) |
| Translation rules | [`CONVENTIONS.md`](CONVENTIONS.md) |

## Status

Regression is the Verilator suite plus the ASIC synth smoke in CI. Known limits:

- Not translated yet: AXI4-Lite UART / GitVersion / HighResolutionClock; `bus/stream`; `bus/drp`.
- `fv/` has assertion scaffolding only — no formal runner.
- Full-library `verilator --lint-only -f verilator/poc.f` can hit a known Verilator ICE on `fifo_ic_got`; dedicated `fifo_ic_got_tb` builds and passes (see [`CONVENTIONS.md`](CONVENTIONS.md)).
- ASIC smoke skips `arith_TRNG` (combinational-loop TRNG); memories may map to flops — see [`asic-synth.md`](docs/playbooks/asic-synth.md).

Cite upstream PoC when you publish work that uses it (see the upstream README).

## Licence

Apache License 2.0 for Covered Source (`src/`, `sim/`, `fv/`). See [`LICENSES/Apache-2.0.txt`](LICENSES/Apache-2.0.txt), [`LICENSE.md`](LICENSE.md), [`NOTICE`](NOTICE). History: [`CHANGELOG.md`](CHANGELOG.md).

## Layout

| Path | Contents |
| --- | --- |
| `src/` | SystemVerilog RTL and packages |
| `sim/` | Self-checking Verilator testbenches |
| `docs/` | Module docs, playbooks, requirements |
| `sysml/` | SysML v2 parts, types, req stubs, [`PoC.sysml`](sysml/PoC.sysml) index — see [sysml playbook](docs/playbooks/sysml.md) |
| `model/` | Behavioral Python models (`poc_model/`) and shared kernel — see [model playbook](docs/playbooks/model.md) |
| `tools/check_sysml_ssot.py` | Checks SysML parts, stubs, and RTL ports |
| `tools/synth_asic.py` | Yosys ASIC smoke (`read_slang` + generic `synth`) |
| `verilator/run_all.sh` | Full regression |
| `poc.f`, `Bender.yml`, `poc.core` | Integration manifests |
