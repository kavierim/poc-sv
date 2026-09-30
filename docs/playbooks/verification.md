# Verification playbook

Self-checking Verilator testbenches under `sim/**/*_tb.sv`. Upstream: PoC VHDL v3.0.0. This port uses lightweight procedural `$fatal` checks (not OSVVM).

Per-module requirements and honest coverage notes: [`docs/modules/`](../modules/index.md) (`REQ-*` → **Verified by:**).

## Regression

From the repository root:

```bash
JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh
```

Pass: exit 0 and `N passed, 0 failed, N total`. Logs under `obj_dir/<tb>/`.

## Suite (28 TBs)

### Bus — AXI4 / Lite / Stream

| Testbench | DUT | What it proves | Known gaps |
| --- | --- | --- | --- |
| `axi4_DeMux_tb` | `axi4_DeMux` | Overlap → lowest port, W-before-AW, BID/RID, AR sideband | Multi-beat, `PIPELINE_*` |
| `axi4_Mux_tb` | `axi4_Mux` | Sink WData, BID, RID | Multi-port contention |
| `axi4_FIFO_tb` | `axi4_FIFO` | Write/read through FIFO to sink | Deep FRAMES, multi-beat |
| `axi4_FIFO_CDC_tb` | `axi4_FIFO_CDC` | Dual clocks; ordered WData; RData; AWReady under Out stall; **two clock ratios** | Metastability stress |
| `axi4_AXI4Lite_Converter_tb` | `axi4_AXI4Lite_Converter` | Lite payload, BID/RID, RLast | Burst rejection |
| `axi4lite_DeMux_tb` | `axi4lite_DeMux` | WData, RData, overlap, DECERR | Pipeline modes |
| `axi4lite_FIFO_tb` | `axi4lite_FIFO` | Payload + AW back-pressure | — |
| `axi4lite_FIFO_CDC_tb` | `axi4lite_FIFO_CDC` | Dual clocks; ordered WData; RData; AWReady under stall; **two ratios** | Metastability stress |
| `axi4lite_Register_tb` | `axi4lite_Register` | RW + DECERR | — |
| `axi4lite_OCRAM_Adapter_tb` | `axi4lite_OCRAM_Adapter` | OCRAM path | Byte lanes |
| `axi4stream_*` (9 TBs) | Mux/DeMux/FIFO*/Stage/Pause/Term | Payload, CDC smoke, TempPut/Got, Stage stall | Deep configurations |

### Support libraries

| Testbench | DUT | What it proves |
| --- | --- | --- |
| `fifo_cc_got_tb` | `fifo_cc_got` | Empty after reset; single word; fill to Full; wrap; reset mid-stream |
| `fifo_ic_got_tb` | `fifo_ic_got` | CDC ordered beats; two clock ratios; fill then drain |
| `fifo_Stage_tb` | `fifo_Stage` | Stalled Valid head; ordered drain; reset clears |
| `sync_Bits_tb` | `sync_Bits` | Sync depth delay; multi-bit update |
| `sync_Reset_tb` | `sync_Reset` | Async assert; sync deassert |
| `ocram_SimpleDualPort_tb` | `ocram_SimpleDualPort` | Write/read; write CE gate; read CE hold |
| `arith_FirstOne_tb` | `arith_FirstOne` | Lowest grant, Index, TokenIn/Out |
| `arith_Counter_Free_tb` | `arith_Counter_Free` | DIVIDER=1 mirror; DIVIDER=4 strobe rate |
| `arith_Prefix_Or_tb` | `arith_Prefix_Or` | Documented `y[0]`/`y[1]` structure |

CDC clock ratios: Verilator is event-driven (no real metastability). Unequal periods exercise gray-pointer crossing in both directions.

## Known gaps

| Item | Reason |
| --- | --- |
| Remaining arith / sync / fifo / ocram variants | Representative TBs above |
| AXI4-Lite UART / GitVersion / HRC; `bus/stream`; `bus/drp` | Not translated |
| Formal `fv/` | Scaffold only — no formal runner |
| Full-library `verilator --lint-only -f verilator/poc.f` | Known Verilator ICE on `fifo_ic_got` (`CONVENTIONS.md`); dedicated TB passes |
