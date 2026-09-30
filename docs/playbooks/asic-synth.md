# ASIC synthesis smoke check

Generic Yosys ASIC smoke for every RTL `module` under `src/`. This is not an FPGA flow (`synth_xilinx` / `synth_ice40` are not used) and does not require a Liberty file or SRAM macros. Memories may become flip-flops.

## Pass criteria

For each module name `NAME`:

```text
read_slang -I src --std 1800-2017 -D SYNTHESIS --top NAME <src/**/*.sv>
hierarchy -top NAME
synth -top NAME
stat
```

Exit 0 only when every synthesizable module PASSes. Package-only files (no `module`) are skipped.

## Local run

Yosys comes from [oss-cad-suite](https://github.com/YosysHQ/oss-cad-suite-build) (release stamp `20260930`, with built-in `read_slang`). Activate the suite, then from the repository root:

```bash
# example on a machine with the suite installed under $HOME/oss-cad-suite
source "$HOME/oss-cad-suite/environment"
python3 tools/synth_asic.py
```

Do not commit machine-specific suite paths into this repository. CI downloads the same linux-x64 release (see `.github/workflows/asic-synth.yml`).

## Skips

| Module | Reason |
| --- | --- |
| `arith_TRNG` | Intentional combinational-loop entropy source. Not instantiated by any other synthesizable parent. ABC rejects the loops; fixing them would change the block’s purpose. Listed as `SKIP` in the script output, not a silent omit. |

## Related checks

Synthesis fixes must not break simulation. After RTL changes aimed at synth:

```bash
JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh
```

Verilator CI (`.github/workflows/verilator.yml`) remains separate from the ASIC synth workflow.
