# PoC_sv documentation

Unofficial SystemVerilog port of [VHDL/PoC](https://github.com/VHDL/PoC) **v3.0.0** (`b9040273`). Start with the [README](../README.md) for a short overview, then:

1. [Getting started](playbooks/getting-started.md) — install Verilator and run the suite
2. [Verification](playbooks/verification.md) — what the 28 testbenches cover
3. [ASIC synth](playbooks/asic-synth.md) — Yosys `read_slang` + generic `synth` smoke
4. [SysML](playbooks/sysml.md) / [behavioral models](playbooks/model.md) — structural model and Python `model/`
5. [Modules](modules/index.md) — Purpose, Behaviour, and `REQ-*` per entity

## Modules by domain

| Domain | Index |
| --- | --- |
| AXI4 | [bus/axi4](modules/bus/axi4/index.md) |
| AXI4-Lite | [bus/axi4lite](modules/bus/axi4lite/index.md) |
| AXI4-Stream | [bus/axi4stream](modules/bus/axi4stream/index.md) |
| Bus shared | [bus](modules/bus/index.md) |
| FIFO | [fifo](modules/fifo/index.md) |
| Sync | [sync](modules/sync/index.md) |
| Arith | [arith](modules/arith/index.md) |
| OCRAM | [mem/ocram](modules/mem/ocram/index.md) |
| Dstruct | [dstruct](modules/dstruct/index.md) |

## Known limits

One place for gaps that apply repo-wide (details also under verification and each module’s `Verified by:`):

- Not translated: AXI4-Lite UART / GitVersion / HighResolutionClock; `bus/stream`; `bus/drp`.
- Formal `fv/`: no runner in this repository.
- Verilator ICE possible on full-library lint of `fifo_ic_got`; dedicated TB is fine — see [`CONVENTIONS.md`](../CONVENTIONS.md).

## Reference

- Translation contract: [`CONVENTIONS.md`](../CONVENTIONS.md)
- Module page template (contributors): [`MODULE_TEMPLATE.md`](MODULE_TEMPLATE.md)
- Licence: [Apache-2.0](../LICENSES/Apache-2.0.txt), [`NOTICE`](../NOTICE)

Pages under `docs/` are descriptive documentation. Covered Source is the SystemVerilog under `src/`, `sim/`, and `fv/`.
