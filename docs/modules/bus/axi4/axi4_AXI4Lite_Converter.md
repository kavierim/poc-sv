---
type: Module
title: axi4_AXI4Lite_Converter
description: Bridge AXI4 full (single-beat) manager to AXI4-Lite subordinate.
tags: [domain:bus.axi4, module:axi4_AXI4Lite_Converter]
status: draft
resource: src/bus/axi4/axi4_AXI4Lite_Converter.sv
model: sysml://PoC::Bus_Axi4::axi4_AXI4Lite_Converter
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Bridge AXI4 full (single-beat) manager to AXI4-Lite subordinate.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

widths, `RESPONSE_FIFO_DEPTH`

## Ports (summary)

`Clock`, `Reset`, full In bus, Lite Out bus

Full declarations: `src/bus/axi4/axi4_AXI4Lite_Converter.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Maps AW/AR/W/R/B between full and Lite structs with width resize helpers. Stores AWID/ARID in shift FIFOs so BID/RID are restored. Forces `RLast=1`. Does not implement multi-beat burst conversion.

# Requirements

<a id="REQ-axi4_AXI4Lite_Converter-001"></a>

## REQ-axi4_AXI4Lite_Converter-001

A single-beat write shall present matching Lite AWAddr/WData and return BID equal to AWID.

- Kind: extracted
- Verified by: axi4_AXI4Lite_Converter_tb

<a id="REQ-axi4_AXI4Lite_Converter-002"></a>

## REQ-axi4_AXI4Lite_Converter-002

A single-beat read shall return RData from Lite, RID equal to ARID, and RLast asserted.

- Kind: extracted
- Verified by: axi4_AXI4Lite_Converter_tb

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4/axi4_AXI4Lite_Converter.sv`
