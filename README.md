<!--
SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland

Ancillary repository file (not Covered Source). RTL is under Apache-2.0; see NOTICE.
-->

# PoC SystemVerilog (PoC_sv)

[![Verilator](https://github.com/kavierim/poc-sv/actions/workflows/verilator.yml/badge.svg)](https://github.com/kavierim/poc-sv/actions/workflows/verilator.yml)
[![ASIC synth](https://github.com/kavierim/poc-sv/actions/workflows/asic-synth.yml/badge.svg)](https://github.com/kavierim/poc-sv/actions/workflows/asic-synth.yml)

Unofficial [SystemVerilog](https://en.wikipedia.org/wiki/SystemVerilog) port of the VHDL **[PoC-Library](https://github.com/VHDL/PoC)** (“Pile of Cores”) — reusable interconnect, FIFO, memory, sync, and arithmetic blocks — simulated with **[Verilator](https://www.veripool.org/verilator/) 5**.

Pinned to upstream tag [**v3.0.0**](https://github.com/VHDL/PoC/releases/tag/v3.0.0) (commit [`b9040273`](https://github.com/VHDL/PoC/commit/b9040273)). Not endorsed by OSVG or the upstream PoC maintainers.

## Contents

66 module pages, grouped as in the [module catalog](docs/modules/index.md):

- **Buses** under `src/bus/`: AXI4, AXI4-Lite, and AXI4-Stream (mux and demux, FIFOs including clock-domain crossing, register file, OCRAM adapter, stream stage and termination) and a shared arbiter.
- **FIFOs, sync, memory, and arithmetic:** clock-domain FIFOs, synchronizers, on-chip RAM, portable arithmetic, and an out-of-order buffer.
- **Requirements:** each entity has Purpose, Behaviour, and `REQ-*` IDs under [`docs/modules/`](docs/modules/index.md).
- **Simulation:** 28 self-checking testbenches, one command from the repository root.
- **CI:** GitHub Actions runs the Verilator suite and an ASIC synthesis smoke (`read_slang` + generic `synth`).

## Quick start

Needs Verilator 5 (`--timing`, `--assert`) and GNU `timeout(1)`. On Windows, use WSL or another Linux environment.

```sh
# from the repository root
sudo apt install verilator   # Debian/Ubuntu / WSL example
JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh
```

Exit 0 means all `sim/**/*_tb.sv` passed. Details: [`docs/playbooks/getting-started.md`](docs/playbooks/getting-started.md).

## Continuous integration

On every push and pull request, GitHub Actions runs two workflows:

| Workflow | What it checks |
| --- | --- |
| [`.github/workflows/verilator.yml`](.github/workflows/verilator.yml) | Full Verilator suite (`verilator/run_all.sh`, 28 testbenches) |
| [`.github/workflows/asic-synth.yml`](.github/workflows/asic-synth.yml) | Yosys ASIC smoke via [`tools/synth_asic.py`](tools/synth_asic.py): `read_slang` + generic `synth` for each RTL module |

The ASIC job is a generic synthesis smoke, not a Liberty or SRAM macro signoff; on-chip memories may become flip-flops. **Exception:** `arith_TRNG` is listed as `SKIP` — it is a combinational-loop entropy source that no synthesizable parent instantiates (ABC rejects the loops). Details and local oss-cad-suite setup: [`docs/playbooks/asic-synth.md`](docs/playbooks/asic-synth.md).

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
