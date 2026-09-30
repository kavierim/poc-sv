---
type: Module
title: axi4lite_DeMux
description: AXI4-Lite demultiplexer (wrapper around `axi4_DeMux` with Lite↔full conversion).
tags: [domain:bus.axi4lite, module:axi4lite_DeMux]
status: draft
resource: src/bus/axi4lite/axi4lite_DeMux.sv
model: sysml://PoC::Bus_Axi4Lite::axi4lite_DeMux
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

AXI4-Lite demultiplexer (wrapper around `axi4_DeMux` with Lite↔full conversion).

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`NUM_PORTS`, `BASE_ADDRESS[]`, `BASE_ADDRESS_MASK[]`, `PIPELINE_*`, widths

## Ports (summary)

`Clock`, `Reset`, Lite In/Out arrays

Full declarations: `src/bus/axi4lite/axi4lite_DeMux.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Converts Lite buses to AXI4 full, instantiates `axi4_DeMux` with outstanding=1, converts back. Same base/mask / lowest-port / DECERR semantics as full DeMux.

# Requirements

<a id="REQ-axi4lite_DeMux-001"></a>

## REQ-axi4lite_DeMux-001

Writes shall present WData on the selected subordinate port.

- Kind: extracted
- Verified by: axi4lite_DeMux_tb

<a id="REQ-axi4lite_DeMux-002"></a>

## REQ-axi4lite_DeMux-002

Reads shall return RData from the selected subordinate.

- Kind: extracted
- Verified by: axi4lite_DeMux_tb

<a id="REQ-axi4lite_DeMux-003"></a>

## REQ-axi4lite_DeMux-003

Overlapping address windows shall select the lowest port index.

- Kind: extracted
- Verified by: axi4lite_DeMux_tb

<a id="REQ-axi4lite_DeMux-004"></a>

## REQ-axi4lite_DeMux-004

Unmapped addresses shall complete with decode-error responses.

- Kind: extracted
- Verified by: axi4lite_DeMux_tb

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4lite/axi4lite_DeMux.sv`
