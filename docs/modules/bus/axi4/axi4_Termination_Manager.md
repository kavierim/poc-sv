---
type: Module
title: axi4_Termination_Manager
description: Tie-off unused AXI4 manager port to a constant idle/drive pattern.
tags: [domain:bus.axi4, module:axi4_Termination_Manager]
status: draft
resource: src/bus/axi4/axi4_Termination_Manager.sv
model: sysml://PoC::Bus_Axi4::axi4_Termination_Manager
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Tie-off unused AXI4 manager port to a constant idle/drive pattern.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

widths, `VALUE`

## Ports (summary)

`AXI4_M2S` (out), `AXI4_S2M` (unused in)

Full declarations: `src/bus/axi4/axi4_Termination_Manager.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Combinational assign of `initialize_bus_m2s(VALUE)` to `AXI4_M2S`. No clock.

# Requirements

<a id="REQ-axi4_Termination_Manager-001"></a>

## REQ-axi4_Termination_Manager-001

AXI4_M2S shall equal the initialize_bus_m2s pattern for VALUE.

- Kind: extracted
- Verified by: none (combinational helper)

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4/axi4_Termination_Manager.sv`
