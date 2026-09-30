---
type: Module
title: axi4_FIFO_CDC
description: Clock-domain crossing for all five AXI4 channels via `fifo_ic_got`.
tags: [domain:bus.axi4, module:axi4_FIFO_CDC]
status: draft
resource: src/bus/axi4/axi4_FIFO_CDC.sv
model: sysml://PoC::Bus_Axi4::axi4_FIFO_CDC
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Clock-domain crossing for all five AXI4 channels via `fifo_ic_got`.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`FRAMES` (≥1), `FRAME_DEPTH`, `DATA_REG`, `OUTPUT_REG`, widths

## Ports (summary)

`In_Clock`/`In_Reset`, `Out_Clock`/`Out_Reset`, In/Out AXI4 buses

Full declarations: `src/bus/axi4/axi4_FIFO_CDC.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Manager-to-subordinate channels (AW/AR/W) cross `In_Clock`→`Out_Clock`; response channels (R/B) cross `Out_Clock`→`In_Clock`. Independent resets per domain. `FRAMES` must be positive (VHDL `positive`; SV default 2). Gray-coded pointers in `fifo_ic_got`.

# Requirements

<a id="REQ-axi4_FIFO_CDC-001"></a>

## REQ-axi4_FIFO_CDC-001

Ordered write beats pushed on In shall appear on Out without loss or reordering under normal operation.

- Kind: extracted
- Verified by: axi4_FIFO_CDC_tb

<a id="REQ-axi4_FIFO_CDC-002"></a>

## REQ-axi4_FIFO_CDC-002

Read data returned on Out shall be delivered to In with preserved RID and payload.

- Kind: extracted
- Verified by: axi4_FIFO_CDC_tb

<a id="REQ-axi4_FIFO_CDC-003"></a>

## REQ-axi4_FIFO_CDC-003

When the Out domain stalls a forward channel, In Ready for that channel shall eventually deassert.

- Kind: extracted
- Verified by: axi4_FIFO_CDC_tb

<a id="REQ-axi4_FIFO_CDC-004"></a>

## REQ-axi4_FIFO_CDC-004

Behaviour shall hold for unequal In/Out clock periods (event-driven CDC check, not metastability proof).

- Kind: extracted
- Verified by: axi4_FIFO_CDC_tb (two ratios)

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4/axi4_FIFO_CDC.sv`
