---
type: Module
title: axi4stream_Termination_Transmitter
description: Drive unused stream sink with idle/constant Valid pattern.
tags: [domain:bus.axi4stream, module:axi4stream_Termination_Transmitter]
status: draft
resource: src/bus/axi4stream/axi4stream_Termination_Transmitter.sv
model: sysml://PoC::Bus_Axi4Stream::axi4stream_Termination_Transmitter
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Drive unused stream sink with idle/constant Valid pattern.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

VALUE / widths

## Ports (summary)

stream source ports

Full declarations: `src/bus/axi4stream/axi4stream_Termination_Transmitter.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Drives M2S initialize pattern from VALUE.

# Requirements

<a id="REQ-axi4stream_Termination_Transmitter-001"></a>

## REQ-axi4stream_Termination_Transmitter-001

Transmitter Valid/data shall follow initialize pattern for VALUE.

- Kind: extracted
- Verified by: axi4stream_Termination_tb

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4stream/axi4stream_Termination_Transmitter.sv`
