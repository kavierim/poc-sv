---
type: Module
title: axi4_Sink
description: AXI4 subordinate sink for simulation/stimulus: accepts writes and returns patterned reads.
tags: [domain:bus.axi4, module:axi4_Sink]
status: draft
resource: src/bus/axi4/axi4_Sink.sv
model: sysml://PoC::Bus_Axi4::axi4_Sink
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

AXI4 subordinate sink for simulation/stimulus: accepts writes and returns patterned reads.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`ADDR_W`, `DATA_W`, `USER_W`, `ID_W`

## Ports (summary)

`Clock`, `Reset`, `AXI4_M2S`/`AXI4_S2M`

Full declarations: `src/bus/axi4/axi4_Sink.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Tracks write bursts and returns OKAY B responses. Read data fields are derived from internal counters/patterns (used by Mux/FIFO TBs). Single `Clock`/`Reset`.

# Requirements

<a id="REQ-axi4_Sink-001"></a>

## REQ-axi4_Sink-001

An accepted single-beat write shall complete with BResp OKAY and BID matching AWID.

- Kind: extracted
- Verified by: exercised via axi4_Mux_tb / axi4_FIFO_tb

<a id="REQ-axi4_Sink-002"></a>

## REQ-axi4_Sink-002

An accepted single-beat read shall complete with RLast and OKAY.

- Kind: extracted
- Verified by: exercised via axi4_Mux_tb / axi4_FIFO_tb

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4/axi4_Sink.sv`
