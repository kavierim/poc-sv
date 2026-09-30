# Agent instructions (PoC_sv)

## Documentation

- Documentation root: [`docs/`](docs/index.md).
- Module template: [`docs/MODULE_TEMPLATE.md`](docs/MODULE_TEMPLATE.md).

## RTL

- Sources under `src/`. Follow [`CONVENTIONS.md`](CONVENTIONS.md).
- Verify with `sim/**/*_tb.sv` and [`verilator/run_all.sh`](verilator/run_all.sh).
- Root integration manifests (`poc.f`, `Bender.yml`, `poc.core`) and [`tools/gen_packaging.py`](tools/gen_packaging.py): after changing `verilator/files/*.f`, regenerate those manifests with `python tools/gen_packaging.py` (or `uv run` if a project env is added later).

## Maintaining docs

Edit pages under `docs/` directly (see [`docs/MODULE_TEMPLATE.md`](docs/MODULE_TEMPLATE.md)). Keep each module page in sync with its `resource` RTL file.

SysML v2 is present under [`sysml/`](sysml/PoC.sysml): edit `sysml/parts/` before the matching RTL. SHALL text stays in module page `# Requirements`. Stubs live in `sysml/req/`. Typed ports use `in item Name : Type`. Check with `uv run python tools/check_sysml_ssot.py` from the repo root. See [`docs/playbooks/sysml.md`](docs/playbooks/sysml.md). Do not copy SHALL text into stubs.

## Behavioral models

Python models live under [`model/`](model/) (`poc_model/`, shared `kernel/`). See [`docs/playbooks/model.md`](docs/playbooks/model.md). Run `uv run pytest` from `model/`. Do not add a dependency on `colibri_sv`.

## Parallel work

- Own one `docs/modules/<domain>/` tree per change.
- Append meaningful updates to [`docs/log.md`](docs/log.md).
- Do not duplicate `CONVENTIONS.md` in documentation pages; link it.

## Upstream

VHDL reference: tag **v3.0.0**, commit `b9040273` on [VHDL/PoC](https://github.com/VHDL/PoC).

Do not add vendor (Xilinx/Altera) primitives, OSVVM test harnesses, `ucf/`, or PoC `tools/` Python infrastructure to this port.
