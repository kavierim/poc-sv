---
type: Module
title: axi4lite_Termination_Manager
description: Tie-off unused AXI4-Lite manager interface.
tags: [domain:bus.axi4lite, module:axi4lite_Termination_Manager]
status: draft
resource: src/bus/axi4lite/axi4lite_Termination_Manager.sv
model: sysml://PoC::Bus_Axi4Lite::axi4lite_Termination_Manager
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Tie-off unused AXI4-Lite manager interface.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

widths / VALUE as implemented

## Ports (summary)

Lite manager outputs

Full declarations: `src/bus/axi4lite/axi4lite_Termination_Manager.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Drives idle/initialize pattern on manager M2S.

# Requirements

<a id="REQ-axi4lite_Termination_Manager-001"></a>

## REQ-axi4lite_Termination_Manager-001

Manager outputs shall remain in the initialized idle pattern.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4lite/axi4lite_Termination_Manager.sv`
