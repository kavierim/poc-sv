# Maintainer log

Internal chronology for maintainers. New readers should use the [README](../README.md) and [docs/index.md](index.md) instead.

## 2026-09-30

- README: document both GitHub CI workflows (Verilator + ASIC synth smoke), `arith_TRNG` SKIP exception, and that the smoke is not Liberty/SRAM signoff (memories may become flops).
- ASIC synth smoke: `tools/synth_asic.py` (Yosys `read_slang` + generic `synth -top`), CI `.github/workflows/asic-synth.yml` (oss-cad-suite `20260930` linux-x64). Playbook [`asic-synth.md`](playbooks/asic-synth.md). AXI bus typedefs hoisted to package-scope `*_types` classes; `poc_utils`/`poc_strings`/`ocram` sim-only paths guarded with `` `ifndef SYNTHESIS ``. `axi4_DeMux` read path inlined (second `axi4stream_Mux` tripped a Yosys/slang assert). `arith_TRNG` documented SKIP (comb-loop TRNG). Synth **65 pass / 0 fail / 1 skip**; Verilator **28/28**.
- SysML library index [`sysml/PoC.sysml`](../sysml/PoC.sysml); playbooks [sysml](playbooks/sysml.md), [model](playbooks/model.md), [stream-interfaces](playbooks/stream-interfaces.md). `model:` URI on all module pages; `# Model` on `axi4stream_FIFO` / `axi4stream_Mux`. Behavioral models under `model/`; checker `tools/check_sysml_ssot.py`. `AGENTS.md` / README updated for SysML and models.
- Docs polish for new readers: README / docs index / playbooks; removed machine-specific paths; module REQ pages kept.
- Regenerator: `tools/gen_module_docs.py` (catalog wording aligned with user docs).

## 2026-09-29 (TB expansion)

- New TBs: `axi4_FIFO_CDC`, `axi4lite_FIFO_CDC`, `fifo_cc_got`, `fifo_ic_got`, `fifo_Stage`, `sync_Bits`, `sync_Reset`, `ocram_SimpleDualPort`, `arith_FirstOne`, `arith_Counter_Free`, `arith_Prefix_Or`.
- `run_all.sh` lists for `sim/{fifo,sync,arith,mem}`; Lite/full CDC FIFO fixes.
- Regression: **28/28 pass** (Verilator 5, `JOBS=1`, `SIM_TIMEOUT=180`).
- `fv/`: no formal runner.

## 2026-09-29

- TBs: `axi4_FIFO`, `axi4lite_FIFO`, `axi4_AXI4Lite_Converter`, `axi4stream_Stage`; stronger Lite DeMux / stream Mux.
- `axi4lite_FIFO.sv`: scalar channel packing for Verilator.
- Docs playbooks; regression **17/17**.

## 2026-09-28

- Verification playbook; P0 TB hardening (DeMux overlap, Mux BID/RID, stream payload).
- DeMux pipeline/mask and VHDL audit follow-ups; packaging includes Lite DeMux file list.
- Regression **13/13**.

## 2026-09-27

- Scaffold: licence, README, CONVENTIONS, Verilator runner, packaging manifests.
- AXI4-Stream completion (Pause, TempGot/Put, terminations) and early smoke TBs.
- Upstream pin PoC v3.0.0 (`b9040273`).
