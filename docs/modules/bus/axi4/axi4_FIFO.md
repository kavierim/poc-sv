---
type: Module
title: axi4_FIFO
description: Same-clock buffering of all five AXI4 channels (AW/AR/W/R/B).
tags: [domain:bus.axi4, module:axi4_FIFO]
status: draft
resource: src/bus/axi4/axi4_FIFO.sv
model: sysml://PoC::Bus_Axi4::axi4_FIFO
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Same-clock buffering of all five AXI4 channels (AW/AR/W/R/B).

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`ADDR_W`, `DATA_W`, `USER_W`, `ID_W`, `FRAMES`, `FRAME_DEPTH`

## Ports (summary)

`Clock`, `Reset`, `In_M2S`/`In_S2M`, `Out_M2S`/`Out_S2M`

Full declarations: `src/bus/axi4/axi4_FIFO.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Packs each channel into an independent FIFO (`fifo_Stage` for small `FRAMES`, `fifo_cc_got` for deeper). Ready/Valid back-pressure per channel. Passes payload fields including ID/User/sideband through pack/unpack helpers.

# Requirements

<a id="REQ-axi4_FIFO-001"></a>

## REQ-axi4_FIFO-001

Write data and address presented on In shall appear on Out in order without alteration when the subordinate accepts them.

- Kind: extracted
- Verified by: axi4_FIFO_tb

<a id="REQ-axi4_FIFO-002"></a>

## REQ-axi4_FIFO-002

BID/RID shall be preserved through the FIFO for a completed write/read.

- Kind: extracted
- Verified by: axi4_FIFO_tb

<a id="REQ-axi4_FIFO-003"></a>

## REQ-axi4_FIFO-003

When a channel FIFO is full, the corresponding In Ready shall deassert (back-pressure).

- Kind: extracted
- Verified by: none (no dedicated Full check in TB)

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4/axi4_FIFO.sv`
