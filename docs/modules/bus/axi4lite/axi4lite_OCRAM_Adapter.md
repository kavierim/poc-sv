---
type: Module
title: axi4lite_OCRAM_Adapter
description: AXI4-Lite to on-chip RAM control (address, WE, byte enables, data).
tags: [domain:bus.axi4lite, module:axi4lite_OCRAM_Adapter]
status: draft
resource: src/bus/axi4lite/axi4lite_OCRAM_Adapter.sv
model: sysml://PoC::Bus_Axi4Lite::axi4lite_OCRAM_Adapter
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

AXI4-Lite to on-chip RAM control (address, WE, byte enables, data).

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`OCRAM_ADDRESS_BITS`, `OCRAM_DATA_BITS`, pipeline/delay knobs, widths

## Ports (summary)

Lite bus + OCRAM Address/WE/BE/DataIn/DataOut

Full declarations: `src/bus/axi4lite/axi4lite_OCRAM_Adapter.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

FSM sequences write address/data and read respond. Drives OCRAM_* control; byte enables from WStrb. Optional input stages and read delay.

# Requirements

<a id="REQ-axi4lite_OCRAM_Adapter-001"></a>

## REQ-axi4lite_OCRAM_Adapter-001

A Lite write shall assert OCRAM write enables with matching data/address for the transaction.

- Kind: extracted
- Verified by: axi4lite_OCRAM_Adapter_tb (smoke)

<a id="REQ-axi4lite_OCRAM_Adapter-002"></a>

## REQ-axi4lite_OCRAM_Adapter-002

A Lite read shall return OCRAM read data as RData with OKAY when the memory responds.

- Kind: extracted
- Verified by: axi4lite_OCRAM_Adapter_tb (smoke)

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4lite/axi4lite_OCRAM_Adapter.sv`
