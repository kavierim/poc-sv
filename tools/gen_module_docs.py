#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
# Ancillary: generates docs/modules/*.md from embedded module catalog.

"""Generate PoC_sv module documentation pages (Purpose / Behaviour / Requirements)."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MOD = ROOT / "docs" / "modules"

# Each entry: id, title, resource, domain_rel (link path from page to domain index),
# purpose, behaviour, schema (params/ports short), reqs: list of (id_suffix, shall, verified_by|None)
# verified_by is TB name or "none (no dedicated TB)"

MODULES: list[dict] = []


def add(**kw):
    MODULES.append(kw)


# ---- AXI4 ----
add(
    path="bus/axi4/axi4_DeMux.md",
    title="axi4_DeMux",
    resource="src/bus/axi4/axi4_DeMux.sv",
    domain="bus/axi4",
    purpose="Address-decode demultiplexer: one AXI4 manager to PORTS subordinates.",
    behaviour=(
        "Single `Clock`/`Reset`. Write and read paths decode `AWAddr`/`ARAddr` against "
        "`BASE_ADDRESS[i]` with `BASE_ADDRESS_MASK[i]` (compare after masking don't-care bits). "
        "Overlapping hits select the **lowest** port index (`demux_lssb`). Unmapped addresses "
        "return decode-error responses. Optional `PIPELINE_IN`/`PIPELINE_OUT` insert FIFO glue. "
        "Write FSM supports AW-before-W and W-before-AW with at most one outstanding OoO Put per "
        "transaction; B/R IDs remapped through OoO buffers."
    ),
    schema_params="`PORTS`, `ADDR_W`, `DATA_W`, `USER_W`, `ID_W`, `BASE_ADDRESS[]`, `BASE_ADDRESS_MASK[]`, `PIPELINE_IN`, `PIPELINE_OUT[]`, outstanding counts",
    schema_ports="`Clock`, `Reset`, `In_M2S`/`In_S2M`, `Out_M2S[PORTS]`/`Out_S2M[PORTS]`",
    reqs=[
        ("001", "The demultiplexer shall forward a write or read transaction to the lowest-index port whose base/mask match the address.", "axi4_DeMux_tb (overlap)"),
        ("002", "When no port matches the address, the demultiplexer shall complete the transaction with a decode-error response on the manager interface.", "partial: DECERR exercised on Lite wrapper; full AXI4 DECERR not in TB"),
        ("003", "Write channel shall accept AW-before-W and W-before-AW without losing the write beat or generating a duplicate B response for a single transaction.", "axi4_DeMux_tb"),
        ("004", "BID/RID returned to the manager shall match the corresponding AWID/ARID of the issued transaction.", "axi4_DeMux_tb"),
        ("005", "AR sideband fields (Cache, Prot, QoS, Region) shall be preserved on the selected subordinate port.", "axi4_DeMux_tb"),
    ],
)

add(
    path="bus/axi4/axi4_Mux.md",
    title="axi4_Mux",
    resource="src/bus/axi4/axi4_Mux.sv",
    domain="bus/axi4",
    purpose="AXI4 multiplexer: PORTS managers to one subordinate via arbitration.",
    behaviour=(
        "Single `Clock`/`Reset`. `bus_Arbiter` grants write and read address channels among "
        "inputs. Optional per-port `PIPELINE_IN` and output pipeline. Transaction path merges "
        "W/R data; B/R responses return to the granted manager with ID remap."
    ),
    schema_params="`PORTS`, widths, `PIPELINE_IN[]`, `PIPELINE_OUT`, outstanding counts",
    schema_ports="`Clock`, `Reset`, `In_M2S[PORTS]`/`In_S2M[PORTS]`, `Out_M2S`/`Out_S2M`",
    reqs=[
        ("001", "The multiplexer shall forward write data from the granted manager to the subordinate without corruption.", "axi4_Mux_tb"),
        ("002", "BID returned to a manager shall match that manager's AWID for the completed write.", "axi4_Mux_tb"),
        ("003", "RID and read data path shall complete a granted single-beat read with OKAY (when subordinate returns OKAY).", "axi4_Mux_tb"),
    ],
)

add(
    path="bus/axi4/axi4_FIFO.md",
    title="axi4_FIFO",
    resource="src/bus/axi4/axi4_FIFO.sv",
    domain="bus/axi4",
    purpose="Same-clock buffering of all five AXI4 channels (AW/AR/W/R/B).",
    behaviour=(
        "Packs each channel into an independent FIFO (`fifo_Stage` for small `FRAMES`, "
        "`fifo_cc_got` for deeper). Ready/Valid back-pressure per channel. Passes payload "
        "fields including ID/User/sideband through pack/unpack helpers."
    ),
    schema_params="`ADDR_W`, `DATA_W`, `USER_W`, `ID_W`, `FRAMES`, `FRAME_DEPTH`",
    schema_ports="`Clock`, `Reset`, `In_M2S`/`In_S2M`, `Out_M2S`/`Out_S2M`",
    reqs=[
        ("001", "Write data and address presented on In shall appear on Out in order without alteration when the subordinate accepts them.", "axi4_FIFO_tb"),
        ("002", "BID/RID shall be preserved through the FIFO for a completed write/read.", "axi4_FIFO_tb"),
        ("003", "When a channel FIFO is full, the corresponding In Ready shall deassert (back-pressure).", "none (no dedicated Full check in TB)"),
    ],
)

add(
    path="bus/axi4/axi4_FIFO_CDC.md",
    title="axi4_FIFO_CDC",
    resource="src/bus/axi4/axi4_FIFO_CDC.sv",
    domain="bus/axi4",
    purpose="Clock-domain crossing for all five AXI4 channels via `fifo_ic_got`.",
    behaviour=(
        "Manager-to-subordinate channels (AW/AR/W) cross `In_Clock`→`Out_Clock`; "
        "response channels (R/B) cross `Out_Clock`→`In_Clock`. Independent resets per domain. "
        "`FRAMES` must be positive (VHDL `positive`; SV default 2). Gray-coded pointers in `fifo_ic_got`."
    ),
    schema_params="`FRAMES` (≥1), `FRAME_DEPTH`, `DATA_REG`, `OUTPUT_REG`, widths",
    schema_ports="`In_Clock`/`In_Reset`, `Out_Clock`/`Out_Reset`, In/Out AXI4 buses",
    reqs=[
        ("001", "Ordered write beats pushed on In shall appear on Out without loss or reordering under normal operation.", "axi4_FIFO_CDC_tb"),
        ("002", "Read data returned on Out shall be delivered to In with preserved RID and payload.", "axi4_FIFO_CDC_tb"),
        ("003", "When the Out domain stalls a forward channel, In Ready for that channel shall eventually deassert.", "axi4_FIFO_CDC_tb"),
        ("004", "Behaviour shall hold for unequal In/Out clock periods (event-driven CDC check, not metastability proof).", "axi4_FIFO_CDC_tb (two ratios)"),
    ],
)

add(
    path="bus/axi4/axi4_AXI4Lite_Converter.md",
    title="axi4_AXI4Lite_Converter",
    resource="src/bus/axi4/axi4_AXI4Lite_Converter.sv",
    domain="bus/axi4",
    purpose="Bridge AXI4 full (single-beat) manager to AXI4-Lite subordinate.",
    behaviour=(
        "Maps AW/AR/W/R/B between full and Lite structs with width resize helpers. "
        "Stores AWID/ARID in shift FIFOs so BID/RID are restored. Forces `RLast=1`. "
        "Does not implement multi-beat burst conversion."
    ),
    schema_params="widths, `RESPONSE_FIFO_DEPTH`",
    schema_ports="`Clock`, `Reset`, full In bus, Lite Out bus",
    reqs=[
        ("001", "A single-beat write shall present matching Lite AWAddr/WData and return BID equal to AWID.", "axi4_AXI4Lite_Converter_tb"),
        ("002", "A single-beat read shall return RData from Lite, RID equal to ARID, and RLast asserted.", "axi4_AXI4Lite_Converter_tb"),
    ],
)

add(
    path="bus/axi4/axi4_Sink.md",
    title="axi4_Sink",
    resource="src/bus/axi4/axi4_Sink.sv",
    domain="bus/axi4",
    purpose="AXI4 subordinate sink for simulation/stimulus: accepts writes and returns patterned reads.",
    behaviour=(
        "Tracks write bursts and returns OKAY B responses. Read data fields are derived from "
        "internal counters/patterns (used by Mux/FIFO TBs). Single `Clock`/`Reset`."
    ),
    schema_params="`ADDR_W`, `DATA_W`, `USER_W`, `ID_W`",
    schema_ports="`Clock`, `Reset`, `AXI4_M2S`/`AXI4_S2M`",
    reqs=[
        ("001", "An accepted single-beat write shall complete with BResp OKAY and BID matching AWID.", "exercised via axi4_Mux_tb / axi4_FIFO_tb"),
        ("002", "An accepted single-beat read shall complete with RLast and OKAY.", "exercised via axi4_Mux_tb / axi4_FIFO_tb"),
    ],
)

add(
    path="bus/axi4/axi4_Termination_Manager.md",
    title="axi4_Termination_Manager",
    resource="src/bus/axi4/axi4_Termination_Manager.sv",
    domain="bus/axi4",
    purpose="Tie-off unused AXI4 manager port to a constant idle/drive pattern.",
    behaviour="Combinational assign of `initialize_bus_m2s(VALUE)` to `AXI4_M2S`. No clock.",
    schema_params="widths, `VALUE`",
    schema_ports="`AXI4_M2S` (out), `AXI4_S2M` (unused in)",
    reqs=[
        ("001", "AXI4_M2S shall equal the initialize_bus_m2s pattern for VALUE.", "none (combinational helper)"),
    ],
)

add(
    path="bus/axi4/axi4_Termination_Subordinate.md",
    title="axi4_Termination_Subordinate",
    resource="src/bus/axi4/axi4_Termination_Subordinate.sv",
    domain="bus/axi4",
    purpose="AXI4 subordinate that accepts transactions and returns a fixed response code.",
    behaviour=(
        "Uses small FIFOs to handshake AW/W/AR and returns `RESPONSE_CODE` on B/R "
        "(RData typically zero). Single `Clock`/`Reset`."
    ),
    schema_params="widths, `RESPONSE_CODE`",
    schema_ports="`Clock`, `Reset`, `AXI4_M2S`/`AXI4_S2M`",
    reqs=[
        ("001", "Completed writes/reads shall return BResp/RResp equal to RESPONSE_CODE.", "exercised via axi4_DeMux_tb terminations"),
    ],
)

# ---- AXI4-Lite ----
add(
    path="bus/axi4lite/axi4lite_DeMux.md",
    title="axi4lite_DeMux",
    resource="src/bus/axi4lite/axi4lite_DeMux.sv",
    domain="bus/axi4lite",
    purpose="AXI4-Lite demultiplexer (wrapper around `axi4_DeMux` with Lite↔full conversion).",
    behaviour=(
        "Converts Lite buses to AXI4 full, instantiates `axi4_DeMux` with outstanding=1, "
        "converts back. Same base/mask / lowest-port / DECERR semantics as full DeMux."
    ),
    schema_params="`NUM_PORTS`, `BASE_ADDRESS[]`, `BASE_ADDRESS_MASK[]`, `PIPELINE_*`, widths",
    schema_ports="`Clock`, `Reset`, Lite In/Out arrays",
    reqs=[
        ("001", "Writes shall present WData on the selected subordinate port.", "axi4lite_DeMux_tb"),
        ("002", "Reads shall return RData from the selected subordinate.", "axi4lite_DeMux_tb"),
        ("003", "Overlapping address windows shall select the lowest port index.", "axi4lite_DeMux_tb"),
        ("004", "Unmapped addresses shall complete with decode-error responses.", "axi4lite_DeMux_tb"),
    ],
)

add(
    path="bus/axi4lite/axi4lite_FIFO.md",
    title="axi4lite_FIFO",
    resource="src/bus/axi4lite/axi4lite_FIFO.sv",
    domain="bus/axi4lite",
    purpose="Same-clock AXI4-Lite channel FIFOs (`TRANSACTIONS` depth).",
    behaviour=(
        "Five independent FIFOs for AW/AR/W/R/B. `TRANSACTIONS≤3` uses `fifo_Stage`; "
        "deeper uses `fifo_cc_got`. Scalar pack offsets (Verilator-safe)."
    ),
    schema_params="`TRANSACTIONS`, `ADDR_W`, `DATA_W`",
    schema_ports="`Clock`, `Reset`, In/Out Lite buses",
    reqs=[
        ("001", "WData and AWAddr shall pass In→Out unaltered when accepted.", "axi4lite_FIFO_tb"),
        ("002", "RData shall pass Out→In unaltered.", "axi4lite_FIFO_tb"),
        ("003", "Stalling Out AWReady shall cause In AWReady to deassert when the AW FIFO fills.", "axi4lite_FIFO_tb"),
    ],
)

add(
    path="bus/axi4lite/axi4lite_FIFO_CDC.md",
    title="axi4lite_FIFO_CDC",
    resource="src/bus/axi4lite/axi4lite_FIFO_CDC.sv",
    domain="bus/axi4lite",
    purpose="CDC AXI4-Lite FIFOs using `fifo_ic_got` per channel.",
    behaviour="AW/AR/W cross In→Out; R/B cross Out→In. Dual clocks/resets. Scalar packing.",
    schema_params="`TRANSACTIONS`, `DATA_REG`, `OUTPUT_REG`, widths",
    schema_ports="In/Out clocks, resets, Lite buses",
    reqs=[
        ("001", "Ordered writes shall cross domains without loss or reordering.", "axi4lite_FIFO_CDC_tb"),
        ("002", "Read data shall cross back with correct RData.", "axi4lite_FIFO_CDC_tb"),
        ("003", "Out-domain AW stall shall eventually deassert In AWReady.", "axi4lite_FIFO_CDC_tb"),
        ("004", "Two unequal clock ratios shall both pass integrity checks.", "axi4lite_FIFO_CDC_tb"),
    ],
)

add(
    path="bus/axi4lite/axi4lite_Register.md",
    title="axi4lite_Register",
    resource="src/bus/axi4lite/axi4lite_Register.sv",
    domain="bus/axi4lite",
    purpose="Configurable AXI4-Lite register file with user RW ports and optional IRQ.",
    behaviour=(
        "Decodes addresses against a register descriptor (sim helper config when "
        "`SIM_READWRITE_CFG`). Returns OKAY on hits and `RESPONSE_ON_ERROR` (default DECERR) "
        "on misses. Exposes ReadPort/WritePort/hit/strobe for user logic. Port notes 32-bit DATA_W focus."
    ),
    schema_params="`N_USER_CFG`, interrupt params, `RESPONSE_ON_ERROR`, `SIM_READWRITE_CFG`, …",
    schema_ports="`Clock`, `Reset`, Lite bus, irq, register file ports",
    reqs=[
        ("001", "A write/read to a configured RW register shall return OKAY and retain written data on readback.", "axi4lite_Register_tb"),
        ("002", "Accesses to illegal/unconfigured addresses shall return RESPONSE_ON_ERROR (DECERR in default sim cfg).", "axi4lite_Register_tb"),
    ],
)

add(
    path="bus/axi4lite/axi4lite_OCRAM_Adapter.md",
    title="axi4lite_OCRAM_Adapter",
    resource="src/bus/axi4lite/axi4lite_OCRAM_Adapter.sv",
    domain="bus/axi4lite",
    purpose="AXI4-Lite to on-chip RAM control (address, WE, byte enables, data).",
    behaviour=(
        "FSM sequences write address/data and read respond. Drives OCRAM_* control; "
        "byte enables from WStrb. Optional input stages and read delay."
    ),
    schema_params="`OCRAM_ADDRESS_BITS`, `OCRAM_DATA_BITS`, pipeline/delay knobs, widths",
    schema_ports="Lite bus + OCRAM Address/WE/BE/DataIn/DataOut",
    reqs=[
        ("001", "A Lite write shall assert OCRAM write enables with matching data/address for the transaction.", "axi4lite_OCRAM_Adapter_tb (smoke)"),
        ("002", "A Lite read shall return OCRAM read data as RData with OKAY when the memory responds.", "axi4lite_OCRAM_Adapter_tb (smoke)"),
    ],
)

add(
    path="bus/axi4lite/axi4lite_Termination_Manager.md",
    title="axi4lite_Termination_Manager",
    resource="src/bus/axi4lite/axi4lite_Termination_Manager.sv",
    domain="bus/axi4lite",
    purpose="Tie-off unused AXI4-Lite manager interface.",
    behaviour="Drives idle/initialize pattern on manager M2S.",
    schema_params="widths / VALUE as implemented",
    schema_ports="Lite manager outputs",
    reqs=[("001", "Manager outputs shall remain in the initialized idle pattern.", "none")],
)

add(
    path="bus/axi4lite/axi4lite_Termination_Subordinate.md",
    title="axi4lite_Termination_Subordinate",
    resource="src/bus/axi4lite/axi4lite_Termination_Subordinate.sv",
    domain="bus/axi4lite",
    purpose="Lite subordinate returning fixed RESPONSE_CODE (RData=0).",
    behaviour="Small FIFOs handshake AW/W/AR; B/R use RESPONSE_CODE.",
    schema_params="`RESPONSE_CODE`, widths",
    schema_ports="`Clock`, `Reset`, Lite bus",
    reqs=[
        ("001", "Completed transactions shall return RESPONSE_CODE on BResp/RResp.", "exercised via axi4lite_DeMux_tb / FIFO TBs"),
    ],
)

# ---- AXI4-Stream ----
add(
    path="bus/axi4stream/axi4stream_Mux.md",
    title="axi4stream_Mux",
    resource="src/bus/axi4stream/axi4stream_Mux.sv",
    domain="bus/axi4stream",
    purpose="AXI4-Stream multiplexer with arbiter and MuxControl mask.",
    behaviour="Arbitrates among PORTS inputs; forwards Data/Keep/Last/User/Dest/ID to Out.",
    schema_params="`PORTS`, stream widths, MuxControl",
    schema_ports="`Clock`, `Reset`, `MuxControl`, In[]/Out stream",
    reqs=[
        ("001", "Merged output beats shall preserve Data, Last, and Keep from the selected input.", "axi4stream_Mux_tb"),
        ("002", "Multi-beat packets shall remain ordered under mid-packet Out back-pressure.", "axi4stream_Mux_tb"),
    ],
)

add(
    path="bus/axi4stream/axi4stream_DeMux.md",
    title="axi4stream_DeMux",
    resource="src/bus/axi4stream/axi4stream_DeMux.sv",
    domain="bus/axi4stream",
    purpose="AXI4-Stream demultiplexer steered by DeMuxControl one-hot/mask.",
    behaviour="Routes In beats to selected Out port; lowest-index helper for control.",
    schema_params="`PORTS`, stream widths",
    schema_ports="`Clock`, `Reset`, DeMuxControl, In/Out[]",
    reqs=[
        ("001", "Beats shall appear only on the selected port with matching Data/Last.", "axi4stream_DeMux_tb"),
    ],
)

add(
    path="bus/axi4stream/axi4stream_FIFO.md",
    title="axi4stream_FIFO",
    resource="src/bus/axi4stream/axi4stream_FIFO.sv",
    domain="bus/axi4stream",
    purpose="Same-clock AXI4-Stream packet FIFO with optional metadata FIFO.",
    behaviour="Buffers stream beats; `FRAMES`/`MAX_PACKET_DEPTH` size storage; Valid/Ready handshake.",
    schema_params="`FRAMES`, `MAX_PACKET_DEPTH`, stream widths, metadata flags",
    schema_ports="`Clock`, `Reset`, In/Out stream",
    reqs=[
        ("001", "A packet pushed In shall emerge Out in the same beat order with matching Data/Last.", "axi4stream_FIFO_tb"),
    ],
)

add(
    path="bus/axi4stream/axi4stream_FIFO_CDC.md",
    title="axi4stream_FIFO_CDC",
    resource="src/bus/axi4stream/axi4stream_FIFO_CDC.sv",
    domain="bus/axi4stream",
    purpose="Clock-crossing AXI4-Stream FIFO.",
    behaviour="Dual clocks/resets; crosses packed stream words via async FIFO primitives.",
    schema_params="`FRAMES`, `MAX_PACKET_DEPTH`, `NO_META_FIFO`, widths",
    schema_ports="In/Out clocks, resets, streams",
    reqs=[
        ("001", "A beat written on In_Clock shall appear on Out_Clock with matching Data/Last.", "axi4stream_FIFO_CDC_tb"),
    ],
)

add(
    path="bus/axi4stream/axi4stream_FIFO_TempGot.md",
    title="axi4stream_FIFO_TempGot",
    resource="src/bus/axi4stream/axi4stream_FIFO_TempGot.sv",
    domain="bus/axi4stream",
    purpose="Stream FIFO with Out_Commit / Out_Rollback on the read side (TempGot).",
    behaviour=(
        "Buffers In→Out like a stream FIFO. `Out_Rollback` restores the read pointer to the last commit; "
        "`Out_Commit` advances the committed read cursor. Uses `fifo_cc_got_tempgot` internally."
    ),
    schema_params="`FRAMES`, `MAX_PACKET_DEPTH`, stream widths, `METADATA_IS_DYNAMIC`",
    schema_ports="`Clock`, `Reset`, In/Out stream, `Out_Commit`, `Out_Rollback`",
    reqs=[
        ("001", "After Commit, previously accepted Out beats shall not reappear; Rollback shall restore uncommitted beats.", "axi4stream_FIFO_TempGot_tb"),
    ],
)

add(
    path="bus/axi4stream/axi4stream_FIFO_TempPut.md",
    title="axi4stream_FIFO_TempPut",
    resource="src/bus/axi4stream/axi4stream_FIFO_TempPut.sv",
    domain="bus/axi4stream",
    purpose="Stream FIFO with temporary Put (commit/rollback) on the write side.",
    behaviour="Uncommitted puts can be discarded; commit makes data visible to the reader.",
    schema_params="stream/FIFO sizing parameters",
    schema_ports="`Clock`, `Reset`, stream + temp-put controls",
    reqs=[
        ("001", "Committed data shall become readable; rolled-back uncommitted beats shall not appear on Out.", "axi4stream_FIFO_TempPut_tb"),
    ],
)

add(
    path="bus/axi4stream/axi4stream_Stage.md",
    title="axi4stream_Stage",
    resource="src/bus/axi4stream/axi4stream_Stage.sv",
    domain="bus/axi4stream",
    purpose="AXI4-Stream pipeline of `STAGES` using `fifo_Stage`.",
    behaviour="Packs Data/Keep/Last/User/Dest/ID into a stage FIFO; Ready = ~Full.",
    schema_params="`STAGES`, stream widths",
    schema_ports="`Clock`, `Reset`, In/Out stream",
    reqs=[
        ("001", "With Out stalled, In beats shall remain ordered and present Valid at Out head.", "axi4stream_Stage_tb"),
        ("002", "Keep/User/ID shall be preserved through the stage pipeline.", "axi4stream_Stage_tb"),
    ],
)

add(
    path="bus/axi4stream/axi4stream_Pause.md",
    title="axi4stream_Pause",
    resource="src/bus/axi4stream/axi4stream_Pause.sv",
    domain="bus/axi4stream",
    purpose="Gates stream progress based on Pause (optional packet mode).",
    behaviour="When Pause asserted, blocks forwarding per PACKET_MODE rules; status outputs In_Packet/Data_Available/Data_Blocked.",
    schema_params="`PACKET_MODE`, stream widths",
    schema_ports="`Clock`, `Reset`, `Pause`, status, In/Out stream",
    reqs=[
        ("001", "While Pause is asserted, Out shall not complete a new beat handshake that the pause mode forbids.", "axi4stream_Pause_tb"),
    ],
)

add(
    path="bus/axi4stream/axi4stream_Termination_Receiver.md",
    title="axi4stream_Termination_Receiver",
    resource="src/bus/axi4stream/axi4stream_Termination_Receiver.sv",
    domain="bus/axi4stream",
    purpose="Sink unused stream source (always Ready or patterned).",
    behaviour="Terminates M2S by driving Ready per VALUE/mode.",
    schema_params="VALUE / widths",
    schema_ports="stream sink ports",
    reqs=[("001", "Receiver Ready shall follow the configured termination VALUE behaviour.", "axi4stream_Termination_tb")],
)

add(
    path="bus/axi4stream/axi4stream_Termination_Transmitter.md",
    title="axi4stream_Termination_Transmitter",
    resource="src/bus/axi4stream/axi4stream_Termination_Transmitter.sv",
    domain="bus/axi4stream",
    purpose="Drive unused stream sink with idle/constant Valid pattern.",
    behaviour="Drives M2S initialize pattern from VALUE.",
    schema_params="VALUE / widths",
    schema_ports="stream source ports",
    reqs=[("001", "Transmitter Valid/data shall follow initialize pattern for VALUE.", "axi4stream_Termination_tb")],
)

# ---- bus_Arbiter ----
add(
    path="bus/bus_Arbiter.md",
    title="bus_Arbiter",
    resource="src/bus/bus_Arbiter.sv",
    domain="bus",
    purpose="Multi-port arbiter (round-robin style) used by AXI muxes.",
    behaviour=(
        "Grants among `PORTS` requests. Default STRATEGY implemented; non-default strategies "
        "`$fatal` at elaboration/runtime. Optional `OUTPUT_REG`."
    ),
    schema_params="`PORTS`, `STRATEGY`, `OUTPUT_REG`",
    schema_ports="`Clock`, `Reset`, Request/Grant vectors, GrantIndex",
    reqs=[
        ("001", "Exactly one grant shall be asserted among requesting ports when arbitration runs (for supported STRATEGY).", "indirect via axi4_Mux_tb / axi4stream_Mux_tb"),
        ("002", "Unsupported STRATEGY values shall not silently mis-arbitrate (fatal/not implemented).", "none (fatal path)"),
    ],
)

# ---- FIFO ----
add(
    path="fifo/fifo_cc_got.md",
    title="fifo_cc_got",
    resource="src/fifo/fifo_cc_got.sv",
    domain="fifo",
    purpose="Same-clock FIFO with Put/Got (Valid/Full) interface.",
    behaviour="RAM or LUT-shift implementation; pointer wrap; optional state registers.",
    schema_params="`DATA_BITS`, `MIN_DEPTH`, `STATE_REG`, `DATA_REG`, …",
    schema_ports="`Clock`, `Reset`, Put/DataIn/Full, Got/DataOut/Valid",
    reqs=[
        ("001", "After reset, Valid shall be low.", "fifo_cc_got_tb"),
        ("002", "Data shall FIFO in order; Full shall assert when capacity is reached.", "fifo_cc_got_tb"),
        ("003", "Reset mid-stream shall discard pending words (Valid low after reset).", "fifo_cc_got_tb"),
    ],
)

add(
    path="fifo/fifo_ic_got.md",
    title="fifo_ic_got",
    resource="src/fifo/fifo_ic_got.sv",
    domain="fifo",
    purpose="Independent-clock (CDC) FIFO with Put/Got.",
    behaviour="Gray-coded write/read pointers synchronized across domains; Write_Full / Read_Valid.",
    schema_params="`DATA_BITS`, `MIN_DEPTH`, `DATA_REG`, `OUTPUT_REG`",
    schema_ports="Write_* and Read_* clock/reset/data/handshake",
    reqs=[
        ("001", "Words pushed on Write_Clock shall appear in order on Read_Clock.", "fifo_ic_got_tb"),
        ("002", "Integrity shall hold for two unequal clock ratios in Verilator.", "fifo_ic_got_tb"),
    ],
)

add(
    path="fifo/fifo_Stage.md",
    title="fifo_Stage",
    resource="src/fifo/fifo_Stage.sv",
    domain="fifo",
    purpose="Elastic pipeline of STAGES registers with Full/Valid/Got.",
    behaviour="Full or light-weight stage cells; chains Ready backwards.",
    schema_params="`DATA_BITS`, `STAGES`, `LIGHT_WEIGHT`",
    schema_ports="`Clock`, `Reset`, Put/DataIn/Full, Valid/DataOut/Got",
    reqs=[
        ("001", "Stalled Got shall keep head DataOut stable with Valid high once data is present.", "fifo_Stage_tb"),
        ("002", "Reset shall clear Valid.", "fifo_Stage_tb"),
    ],
)

add(
    path="fifo/fifo_Shift.md",
    title="fifo_Shift",
    resource="src/fifo/fifo_Shift.sv",
    domain="fifo",
    purpose="Shift-register FIFO (small depths).",
    behaviour="LUT-style shift storage used by `fifo_cc_got` when enabled.",
    schema_params="`DATA_BITS`, `MIN_DEPTH`",
    schema_ports="Put/Got style as in RTL",
    reqs=[
        ("001", "Shall store and forward words in order under Put/Got handshake.", "none (covered indirectly via fifo_cc_got LUT path)"),
    ],
)

add(
    path="fifo/fifo_cc_got_tempgot.md",
    title="fifo_cc_got_tempgot",
    resource="src/fifo/fifo_cc_got_tempgot.sv",
    domain="fifo",
    purpose="Same-clock FIFO with temporary Got (commit/rollback read).",
    behaviour="Extends got-FIFO with provisional read pointer.",
    schema_params="See source file",
    schema_ports="See source file",
    reqs=[
        ("001", "Rollback shall restore unread data; commit shall advance the read pointer permanently.", "indirect via axi4stream_FIFO_TempGot"),
    ],
)

add(
    path="fifo/fifo_cc_got_tempput.md",
    title="fifo_cc_got_tempput",
    resource="src/fifo/fifo_cc_got_tempput.sv",
    domain="fifo",
    purpose="Same-clock FIFO with temporary Put (commit/rollback write).",
    behaviour="Provisional write pointer until commit.",
    schema_params="See source file",
    schema_ports="See source file",
    reqs=[
        ("001", "Uncommitted puts shall be discardable; committed data shall be readable in order.", "indirect via axi4stream_FIFO_TempPut"),
    ],
)

add(
    path="fifo/fifo_ic_assembly.md",
    title="fifo_ic_assembly",
    resource="src/fifo/fifo_ic_assembly.sv",
    domain="fifo",
    purpose="Independent-clock assembly buffer: write-side address/data packing with gray-group CDC.",
    behaviour=(
        "Write domain posts `addr`/`din` with `put`; read domain presents `dout`/`vld` with `got`. "
        "`base`/`failed` report write-side status. Uses gray pointer groups of `G_BITS`."
    ),
    schema_params="`D_BITS`, `A_BITS`, `G_BITS`",
    schema_ports="`clk_wr`/`rst_wr`, `base`/`failed`, `addr`/`din`/`put`, `clk_rd`/`rst_rd`, `dout`/`vld`/`got`",
    reqs=[
        ("001", "Accepted write puts shall become readable on the read clock in order when got is applied.", "none (no dedicated TB)"),
    ],
)

# ---- SYNC ----
add(
    path="sync/sync_Bits.md",
    title="sync_Bits",
    resource="src/sync/sync_Bits.sv",
    domain="sync",
    purpose="Multi-bit 2-flop (or deeper) synchronizer.",
    behaviour="Per-bit meta+sync chain of `SYNC_DEPTH`; INIT seeds FFs; Input overwrites after sync delay.",
    schema_params="`BITS`, `INIT`, `SYNC_DEPTH`, `REGISTER_OUTPUT`",
    schema_ports="`Clock`, `Input`, `Output`",
    reqs=[
        ("001", "Output shall not equal a new Input in the first cycle after Input changes (depth≥2).", "sync_Bits_tb"),
        ("002", "After SYNC_DEPTH+margin clocks, Output shall equal Input.", "sync_Bits_tb"),
    ],
)

add(
    path="sync/sync_Reset.md",
    title="sync_Reset",
    resource="src/sync/sync_Reset.sv",
    domain="sync",
    purpose="Asynchronous assert, synchronous deassert reset synchronizer.",
    behaviour="Async set of chain when Input high; shifts D when released.",
    schema_params="`SYNC_DEPTH`",
    schema_ports="`Clock`, `Input`, `D`, `Output`",
    reqs=[
        ("001", "While Input is asserted, Output shall be high.", "sync_Reset_tb"),
        ("002", "After Input release with D=0, Output shall go low after sync depth.", "sync_Reset_tb"),
    ],
)

add(
    path="sync/sync_Pulse.md",
    title="sync_Pulse",
    resource="src/sync/sync_Pulse.sv",
    domain="sync",
    purpose="Pulse synchronizer: captures Input rising edge into an async latch, then SYNC_DEPTH flops.",
    behaviour=(
        "Per bit: rising edge of `Input` sets `Data_async`; cleared when sync_out is high and Input low. "
        "Meta+sync chain clocks into `Clock`. Output is the last sync stage (level until cleared)."
    ),
    schema_params="`BITS`, `SYNC_DEPTH`",
    schema_ports="`Clock`, `Input[BITS]`, `Output[BITS]`",
    reqs=[("001", "A rising edge on Input shall assert Output after the synchronizer latency until the clear condition occurs.", "none")],
)

add(
    path="sync/sync_Strobe.md",
    title="sync_Strobe",
    resource="src/sync/sync_Strobe.sv",
    domain="sync",
    purpose="Strobe/level synchronizer helper.",
    behaviour="Synchronizes strobe signalling per PoC sync_Strobe.",
    schema_params="See source file",
    schema_ports="See source file",
    reqs=[("001", "Shall present a synchronized strobe to the destination clock domain.", "none")],
)

add(
    path="sync/sync_Vector.md",
    title="sync_Vector",
    resource="src/sync/sync_Vector.sv",
    domain="sync",
    purpose="Vector synchronizer (multi-bit with common control).",
    behaviour="Safe vector crossing per PoC (typically handshake or gray); see RTL parameters.",
    schema_params="See source file",
    schema_ports="See source file",
    reqs=[("001", "Shall deliver a consistent vector to the destination domain per configured mode.", "none")],
)

add(
    path="sync/sync_Command.md",
    title="sync_Command",
    resource="src/sync/sync_Command.sv",
    domain="sync",
    purpose="Command/handshake synchronizer between clock domains.",
    behaviour="Req/ack style crossing for command words.",
    schema_params="See source file",
    schema_ports="See source file",
    reqs=[("001", "A posted command shall be observed once in the destination domain when handshake completes.", "none")],
)

# ---- OCRAM ----
add(
    path="mem/ocram/ocram_SimpleDualPort.md",
    title="ocram_SimpleDualPort",
    resource="src/mem/ocram/ocram_SimpleDualPort.sv",
    domain="mem/ocram",
    purpose="Simple dual-port RAM (1W1R) with independent clocks.",
    behaviour="Write on Write_Clock when CE&WE; read registered on Read_Clock when CE.",
    schema_params="`ADDRESS_BITS`, `DATA_BITS`, `RAM_TYPE`, `FILENAME`",
    schema_ports="Write_* and Read_*",
    reqs=[
        ("001", "Data written with WE shall be readable at that address after the write is committed.", "ocram_SimpleDualPort_tb"),
        ("002", "Write with ClockEnable low shall not update memory.", "ocram_SimpleDualPort_tb"),
        ("003", "Read with ClockEnable low shall hold Read_DataOut.", "ocram_SimpleDualPort_tb"),
    ],
)

add(
    path="mem/ocram/ocram_SinglePort.md",
    title="ocram_SinglePort",
    resource="src/mem/ocram/ocram_SinglePort.sv",
    domain="mem/ocram",
    purpose="Single-port RAM.",
    behaviour="Shared address for read/write on one clock.",
    schema_params="address/data bits, RAM_TYPE",
    schema_ports="Clock, enable, WE, address, data",
    reqs=[("001", "Writes shall update the addressed word; reads shall return stored data per timing mode.", "none")],
)

add(
    path="mem/ocram/ocram_TrueDualPort.md",
    title="ocram_TrueDualPort",
    resource="src/mem/ocram/ocram_TrueDualPort.sv",
    domain="mem/ocram",
    purpose="True dual-port RAM (two R/W ports).",
    behaviour="Independent port clocks/enables; conflict behaviour as in generic model.",
    schema_params="See source file",
    schema_ports="Port A/B",
    reqs=[("001", "Each port shall read/write its addressed location when enabled.", "none")],
)

add(
    path="mem/ocram/ocram_TrueDualPort_WriteFirst.md",
    title="ocram_TrueDualPort_WriteFirst",
    resource="src/mem/ocram/ocram_TrueDualPort_WriteFirst.sv",
    domain="mem/ocram",
    purpose="True dual-port RAM with write-first read semantics.",
    behaviour="Same-port read during write returns new data.",
    schema_params="See source file",
    schema_ports="Port A/B",
    reqs=[("001", "On a port write with read, read data shall reflect write-first behaviour.", "none")],
)

add(
    path="mem/ocram/ocram_TrueDualPort_Simulation.md",
    title="ocram_TrueDualPort_Simulation",
    resource="src/mem/ocram/ocram_TrueDualPort_Simulation.sv",
    domain="mem/ocram",
    purpose="Simulation-oriented true dual-port model.",
    behaviour="Array-backed model for sim.",
    schema_params="See source file",
    schema_ports="Port A/B",
    reqs=[("001", "Shall match functional read/write of the generic TDP model in simulation.", "none")],
)

add(
    path="mem/ocram/ocram_SimpleDualPort_WriteFirst.md",
    title="ocram_SimpleDualPort_WriteFirst",
    resource="src/mem/ocram/ocram_SimpleDualPort_WriteFirst.sv",
    domain="mem/ocram",
    purpose="Simple dual-port with write-first on write port where applicable.",
    behaviour="SDP variant; see RTL for CE/WE timing.",
    schema_params="See source file",
    schema_ports="Write/Read",
    reqs=[("001", "Shall implement SDP storage with write-first semantics as coded.", "none")],
)

add(
    path="mem/ocram/ocram_SimpleDualPort_Optimized.md",
    title="ocram_SimpleDualPort_Optimized",
    resource="src/mem/ocram/ocram_SimpleDualPort_Optimized.sv",
    domain="mem/ocram",
    purpose="Optimized SDP used inside FIFO RAM backends.",
    behaviour="Same SDP idea; optimized generate for synthesis/sim.",
    schema_params="See source file",
    schema_ports="Write/Read",
    reqs=[("001", "Shall provide correct SDP read-after-write behaviour for FIFO use.", "indirect via fifo_cc_got_tb")],
)

add(
    path="mem/ocram/ocram_EnhancedSimpleDualPort.md",
    title="ocram_EnhancedSimpleDualPort",
    resource="src/mem/ocram/ocram_EnhancedSimpleDualPort.sv",
    domain="mem/ocram",
    purpose="Enhanced SDP variant from PoC.",
    behaviour="Additional enables/features per RTL.",
    schema_params="See source file",
    schema_ports="See source file",
    reqs=[("001", "Shall implement the enhanced SDP port protocol as in the SV source.", "none")],
)

# ---- ARITH (representative + remaining short) ----
add(
    path="arith/arith_FirstOne.md",
    title="arith_FirstOne",
    resource="src/arith/arith_FirstOne.sv",
    domain="arith",
    purpose="Find lowest set request bit; one-hot Grant and binary Index.",
    behaviour="Combinational: TokenIn gates; TokenOut if no request.",
    schema_params="`BITS`",
    schema_ports="`TokenIn`, `Request`, `Grant`, `TokenOut`, `Index`",
    reqs=[
        ("001", "With TokenIn=1, Grant shall be one-hot of the lowest set Request bit.", "arith_FirstOne_tb"),
        ("002", "With no Request bits set, TokenOut shall be 1 and Grant 0.", "arith_FirstOne_tb"),
        ("003", "With TokenIn=0, Grant shall be 0.", "arith_FirstOne_tb"),
    ],
)

add(
    path="arith/arith_Counter_Free.md",
    title="arith_Counter_Free",
    resource="src/arith/arith_Counter_Free.sv",
    domain="arith",
    purpose="Free-running divider/strobe counter.",
    behaviour="DIVIDER=1 registers Increment; else modular counter asserts Strobe.",
    schema_params="`DIVIDER`",
    schema_ports="`Clock`, `Reset`, `Increment`, `Strobe`",
    reqs=[
        ("001", "For DIVIDER=1, Strobe shall follow Increment with register delay.", "arith_Counter_Free_tb"),
        ("002", "For DIVIDER>1, Strobe shall assert at the divided rate while Increment is held.", "arith_Counter_Free_tb"),
    ],
)

add(
    path="arith/arith_Prefix_Or.md",
    title="arith_Prefix_Or",
    resource="src/arith/arith_Prefix_Or.sv",
    domain="arith",
    purpose="Prefix-OR network (PoC optimized structure).",
    behaviour="y[0]=x[0]; y[1]=x[0]|x[1]; upper bits via PoC carry trick — not a naive loop for all BITS.",
    schema_params="`BITS`",
    schema_ports="`x`, `y`",
    reqs=[
        ("001", "y[0] shall equal x[0]; y[1] shall equal x[0]|x[1].", "arith_Prefix_Or_tb"),
        ("002", "A nonzero x shall produce a nonzero y.", "arith_Prefix_Or_tb"),
    ],
)

add(
    path="arith/arith_Prefix_And.md",
    title="arith_Prefix_And",
    resource="src/arith/arith_Prefix_And.sv",
    domain="arith",
    purpose="Prefix-AND network.",
    behaviour="Analogous to Prefix_Or for AND (see RTL).",
    schema_params="`BITS`",
    schema_ports="`x`, `y`",
    reqs=[("001", "Shall compute the PoC prefix-AND function of x.", "none")],
)

add(
    path="arith/arith_Adder_Wide.md",
    title="arith_Adder_Wide",
    resource="src/arith/arith_Adder_Wide.sv",
    domain="arith",
    purpose="Wide adder structure.",
    behaviour="Multi-bit add with PoC partitioning.",
    schema_params="See source file",
    schema_ports="See source file",
    reqs=[("001", "Sum/carry shall equal unsigned addition of the operands for the configured width.", "none")],
)

add(
    path="arith/arith_CarryChain_inc.md",
    title="arith_CarryChain_inc",
    resource="src/arith/arith_CarryChain_inc.sv",
    domain="arith",
    purpose="Increment via carry chain (A+CarryIn).",
    behaviour="Used heavily by FIFO pointers.",
    schema_params="`BITS`",
    schema_ports="`A`, `CarryIn`, `Sum`",
    reqs=[("001", "Sum shall equal A+CarryIn (mod 2^BITS with carry as implemented).", "indirect via fifo_* TBs")],
)

add(
    path="arith/arith_cca.md",
    title="arith_cca",
    resource="src/arith/arith_cca.sv",
    domain="arith",
    purpose="Carry-chain arithmetic helper (CCA).",
    behaviour="PoC CCA primitive wrapper.",
    schema_params="See source file",
    schema_ports="See source file",
    reqs=[("001", "Shall match PoC CCA Boolean/arithmetic function in RTL.", "none")],
)

add(
    path="arith/arith_Convert_Binary2BCD.md",
    title="arith_Convert_Binary2BCD",
    resource="src/arith/arith_Convert_Binary2BCD.sv",
    domain="arith",
    purpose="Binary to BCD conversion.",
    behaviour="Sequential/combinational conversion per RTL.",
    schema_params="See source file",
    schema_ports="See source file",
    reqs=[("001", "Output BCD shall represent the binary input value.", "none")],
)

add(
    path="arith/arith_Counter_BCD.md",
    title="arith_Counter_BCD",
    resource="src/arith/arith_Counter_BCD.sv",
    domain="arith",
    purpose="BCD counter.",
    behaviour="Counts in BCD under enable/reset.",
    schema_params="See source file",
    schema_ports="See source file",
    reqs=[("001", "Count sequence shall follow BCD increment rules.", "none")],
)

add(
    path="arith/arith_Counter_Gray.md",
    title="arith_Counter_Gray",
    resource="src/arith/arith_Counter_Gray.sv",
    domain="arith",
    purpose="Gray-code counter.",
    behaviour="Increments Gray encoding each enable.",
    schema_params="See source file",
    schema_ports="See source file",
    reqs=[("001", "Successive outputs shall differ by one bit (Gray property).", "none")],
)

add(
    path="arith/arith_Counter_Ring.md",
    title="arith_Counter_Ring",
    resource="src/arith/arith_Counter_Ring.sv",
    domain="arith",
    purpose="Ring counter.",
    behaviour="Rotating one-hot/token.",
    schema_params="See source file",
    schema_ports="See source file",
    reqs=[("001", "Shall rotate the token each enabled cycle.", "none")],
)

add(
    path="arith/arith_Divider.md",
    title="arith_Divider",
    resource="src/arith/arith_Divider.sv",
    domain="arith",
    purpose="Integer divider.",
    behaviour="Produces quotient/remainder per RTL protocol.",
    schema_params="See source file",
    schema_ports="See source file",
    reqs=[("001", "Quotient and remainder shall satisfy dividend = q*divisor+r with r<divisor for valid ops.", "none")],
)

add(
    path="arith/arith_PRNG.md",
    title="arith_PRNG",
    resource="src/arith/arith_PRNG.sv",
    domain="arith",
    purpose="Pseudo-random number generator.",
    behaviour="LFSR/PRNG state advances on clock/enable.",
    schema_params="See source file",
    schema_ports="See source file",
    reqs=[("001", "Shall advance deterministic PRNG state each enabled cycle from the seed/reset value.", "none")],
)

add(
    path="arith/arith_TRNG.md",
    title="arith_TRNG",
    resource="src/arith/arith_TRNG.sv",
    domain="arith",
    purpose="Entropy/TRNG helper (simulation/synthesis dependent).",
    behaviour="Not suitable as a sole cryptographic entropy source without review.",
    schema_params="See source file",
    schema_ports="See source file",
    reqs=[("001", "Shall produce a free-running entropy/bit stream as implemented (non-deterministic in HW).", "none")],
)

add(
    path="arith/arith_Same.md",
    title="arith_Same",
    resource="src/arith/arith_Same.sv",
    domain="arith",
    purpose="Detect all-0 / all-1 chunks (sameness) with generate carry.",
    behaviour="Partitioned compare to 0/1 vectors; y indicates overall sameness with g.",
    schema_params="`BITS`",
    schema_ports="`g`, `x`, `y`",
    reqs=[("001", "y shall reflect whether x chunks are uniform 0/1 per PoC Same algorithm.", "none")],
)

add(
    path="arith/arith_Scaler.md",
    title="arith_Scaler",
    resource="src/arith/arith_Scaler.sv",
    domain="arith",
    purpose="Numeric scaler/gain block.",
    behaviour="Scales input per parameters.",
    schema_params="See source file",
    schema_ports="See source file",
    reqs=[("001", "Output shall equal the configured scaling of the input.", "none")],
)

add(
    path="arith/arith_Shifter_Barrel.md",
    title="arith_Shifter_Barrel",
    resource="src/arith/arith_Shifter_Barrel.sv",
    domain="arith",
    purpose="Barrel shifter.",
    behaviour="Shifts/rotates by select.",
    schema_params="See source file",
    schema_ports="See source file",
    reqs=[("001", "Output shall equal input shifted/rotated by the select amount.", "none")],
)

add(
    path="arith/arith_SquareRoot.md",
    title="arith_SquareRoot",
    resource="src/arith/arith_SquareRoot.sv",
    domain="arith",
    purpose="Integer square-root unit.",
    behaviour="Computes floor(sqrt(x)) per RTL.",
    schema_params="See source file",
    schema_ports="See source file",
    reqs=[("001", "Result r shall satisfy r^2 ≤ x < (r+1)^2 for valid inputs.", "none")],
)

# ---- dstruct ----
add(
    path="dstruct/dstruct_OutOfOrderBuffer.md",
    title="dstruct_OutOfOrderBuffer",
    resource="src/dstruct/dstruct_OutOfOrderBuffer.sv",
    domain="dstruct",
    purpose="Buffer storing words by index for out-of-order completion (AXI ID remap).",
    behaviour="Put allocates IndexOut; Got with IndexIn returns DataOut when Valid.",
    schema_params="`DATA_BITS`, `NUM_INDEX`",
    schema_ports="`Clock`, `Reset`, Put/DataIn/Full/IndexOut, Got/IndexIn/DataOut/Valid",
    reqs=[
        ("001", "Data Put at an index shall be returned when Got with that index while Valid.", "indirect via axi4_DeMux/Mux"),
        ("002", "Full shall assert when no free indices remain.", "none"),
    ],
)


def render_module(m: dict) -> str:
    stem = m["title"]
    req_prefix = "REQ-" + stem.replace("-", "_")
    depth = m["path"].count("/")
    # docs/modules/<path> → repo root needs depth+2; playbooks is under docs/ → depth+1
    conv = "../" * (depth + 2) + "CONVENTIONS.md"
    ver = "../" * (depth + 1) + "playbooks/verification.md"

    lines = [
        "---",
        "type: Module",
        f"title: {stem}",
        f"description: {m['purpose']}",
        f"tags: [domain:{m['domain'].replace('/', '.')}, module:{stem}]",
        "status: draft",
        f"resource: {m['resource']}",
        "provenance:",
        "  upstream_path: github.com/VHDL/PoC",
        "  pinned_tag: v3.0.0",
        "  pinned_commit: b9040273",
        "---",
        "",
        "# Purpose",
        "",
        m["purpose"],
        "",
        "# When to use",
        "",
        "See the [domain index](index.md).",
        "",
        "# Schema",
        "",
        "## Parameters (summary)",
        "",
        m["schema_params"],
        "",
        "## Ports (summary)",
        "",
        m["schema_ports"],
        "",
        f"Full declarations: `{m['resource']}`. Naming rules: [`CONVENTIONS.md`]({conv}).",
        "",
        "# Behaviour",
        "",
        m["behaviour"],
        "",
        "# Requirements",
        "",
    ]
    for num, shall, verified in m["reqs"]:
        rid = f"{req_prefix}-{num}"
        if " shall " in shall:
            text = shall
        elif shall.startswith("Shall "):
            text = "The module shall " + shall[len("Shall ") :]
        else:
            text = f"The module shall ensure: {shall}"
        lines += [
            f'<a id="{rid}"></a>',
            "",
            f"## {rid}",
            "",
            text,
            "",
            "- Kind: extracted",
            f"- Verified by: {verified}",
            "",
        ]
    lines += [
        "# Verification",
        "",
        f"Testbench matrix: [`verification.md`]({ver}). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.",
        "",
        "# Related",
        "",
        "- Domain: [index.md](index.md)",
        f"- RTL: `{m['resource']}`",
        "",
    ]
    return "\n".join(lines)


def write_domain_index(domain: str, title: str, intro: str, extra: str = "") -> None:
    rows = [m for m in MODULES if m["domain"] == domain]
    rel_ver = "../" * (domain.count("/") + 1) + "playbooks/verification.md"
    rel_cat = "../" * (domain.count("/") + 1) + "index.md"
    text = "\n".join(
        [
            f"# {title}",
            "",
            intro,
            "",
            "| Module | Resource | Doc |",
            "| --- | --- | --- |",
        ]
        + [
            f"| `{m['title']}` | `{m['resource']}` | [{Path(m['path']).name}]({Path(m['path']).name}) |"
            for m in rows
        ]
        + (["", extra] if extra else [])
        + [
            "",
            f"- [Modules catalog]({rel_cat})",
            f"- [Verification playbook]({rel_ver})",
            "",
        ]
    )
    out = MOD / domain / "index.md"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(text, encoding="utf-8", newline="\n")


def main():
    for m in MODULES:
        out = MOD / m["path"]
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(render_module(m), encoding="utf-8", newline="\n")
        print("wrote", out.relative_to(ROOT))

    write_domain_index(
        "bus/axi4",
        "AXI4 modules",
        "AXI4 full entities under `src/bus/axi4/`. Packages `poc_axi4*.sv` are type libraries (no REQ pages).",
        "Not translated: OSVVM packages.",
    )
    write_domain_index(
        "bus/axi4lite",
        "AXI4-Lite modules",
        "AXI4-Lite entities under `src/bus/axi4lite/`.",
        "Not translated: `axi4lite_UART`, `axi4lite_GitVersionRegister`, `axi4lite_HighResolutionClock`, OSVVM pkgs.",
    )
    write_domain_index(
        "bus/axi4stream",
        "AXI4-Stream modules",
        "AXI4-Stream entities under `src/bus/axi4stream/`.",
    )
    # docs/modules/bus/index.md is maintained by hand (overview + links to AXI subtrees).
    write_domain_index(
        "fifo",
        "FIFO modules",
        "FIFO primitives under `src/fifo/`. Package `fifo.sv` has no separate REQ page.",
    )
    write_domain_index(
        "sync",
        "Synchronizer modules",
        "Generic sync entities under `src/sync/` (no vendor Xilinx/Altera branches).",
    )
    write_domain_index(
        "arith",
        "Arithmetic modules",
        "Portable arith entities under `src/arith/` (no `xilinx/` tree).",
    )
    write_domain_index(
        "mem/ocram",
        "On-chip RAM (ocram)",
        "Generic ocram entities under `src/mem/ocram/` (no Altera-only tree).",
    )
    write_domain_index(
        "dstruct",
        "Data structures",
        "Structured buffers under `src/dstruct/`.",
    )

    catalog = "\n".join(
        [
            "# Modules",
            "",
            "Each translated entity has a page with **Purpose**, **Behaviour**, and **Requirements** (`REQ-<module>-NNN`).",
            "Open a domain index, then the module you need. Upstream pin: PoC v3.0.0 (`b9040273`).",
            "",
            "| Domain | Index |",
            "| --- | --- |",
            "| AXI4 | [bus/axi4](bus/axi4/index.md) |",
            "| AXI4-Lite | [bus/axi4lite](bus/axi4lite/index.md) |",
            "| AXI4-Stream | [bus/axi4stream](bus/axi4stream/index.md) |",
            "| Bus shared | [bus](bus/index.md) |",
            "| FIFO | [fifo](fifo/index.md) |",
            "| Sync | [sync](sync/index.md) |",
            "| Arith | [arith](arith/index.md) |",
            "| OCRAM | [mem/ocram](mem/ocram/index.md) |",
            "| Dstruct | [dstruct](dstruct/index.md) |",
            "",
            "Packages (`poc_*`, `common/*`, domain package files) are type/helper libraries — see [`CONVENTIONS.md`](../../CONVENTIONS.md).",
            "Repo-wide gaps (untranslated UART/stream/drp, formal `fv/`, Verilator lint ICE): [`docs/index.md`](../index.md).",
            "",
            f"{len(MODULES)} entity pages. TB mapping: each REQ **Verified by:** field and [verification.md](../playbooks/verification.md).",
            "",
        ]
    )
    (MOD / "index.md").write_text(catalog, encoding="utf-8", newline="\n")
    print("wrote docs/modules/index.md", "modules=", len(MODULES))


if __name__ == "__main__":
    main()
