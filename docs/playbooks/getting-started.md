# Getting started

Unofficial SystemVerilog port of [VHDL/PoC](https://github.com/VHDL/PoC) **v3.0.0** (`b9040273`), simulated with **Verilator 5** only.

## Prerequisites

- Verilator ≥ 5 with `--timing` and `--assert` (Debian/Ubuntu/WSL: `sudo apt install verilator`)
- GNU `timeout(1)` (used by `verilator/run_all.sh` for hang protection)
- On Windows: run from **WSL** or another Linux environment (native Windows Verilator is not assumed)

## Run all tests

From the **repository root** (the directory that contains `verilator/` and `src/`):

```bash
JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh
```

- Exit **0** only when every `sim/**/*_tb.sv` passes.
- Logs: `obj_dir/<tb_name>/run.log` and `obj_dir/<tb_name>/result` (`PASS` / `FAIL` / `TIMEOUT`).
- Default `JOBS=1`; raise only if the machine has RAM for parallel Verilator builds.

Windows: open a WSL shell in your clone and run the same command (no machine-specific path required).

## What is covered

See [verification.md](verification.md) for the TB matrix. Focus areas:

- **AXI4 / AXI4-Lite / AXI4-Stream** interconnect, FIFOs (incl. CDC), and stream helpers — dedicated TBs
- **Representative** coverage for FIFO, sync, OCRAM, and arith primitives

Module behaviour and requirements: [`docs/modules/`](../modules/index.md).

## Optional upstream VHDL

Comparing against the original VHDL is optional. Clone [VHDL/PoC](https://github.com/VHDL/PoC) separately if you need it; this repository is self-contained for simulation.

## Licence

Apache-2.0 Covered Source under `src/`, `sim/`, `fv/`. See [`LICENSE.md`](../../LICENSE.md) and [`NOTICE`](../../NOTICE). Cite upstream PoC when publishing work that uses it.
