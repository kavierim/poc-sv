---
type: Module
title: axi4_Termination_Subordinate
description: AXI4 subordinate that accepts transactions and returns a fixed response code.
tags: [domain:bus.axi4, module:axi4_Termination_Subordinate]
status: draft
resource: src/bus/axi4/axi4_Termination_Subordinate.sv
model: sysml://PoC::Bus_Axi4::axi4_Termination_Subordinate
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

AXI4 subordinate that accepts transactions and returns a fixed response code.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

widths, `RESPONSE_CODE`

## Ports (summary)

`Clock`, `Reset`, `AXI4_M2S`/`AXI4_S2M`

Full declarations: `src/bus/axi4/axi4_Termination_Subordinate.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Uses small FIFOs to handshake AW/W/AR and returns `RESPONSE_CODE` on B/R (RData typically zero). Single `Clock`/`Reset`.

# Requirements

<a id="REQ-axi4_Termination_Subordinate-001"></a>

## REQ-axi4_Termination_Subordinate-001

Completed writes/reads shall return BResp/RResp equal to RESPONSE_CODE.

- Kind: extracted
- Verified by: exercised via axi4_DeMux_tb terminations

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4/axi4_Termination_Subordinate.sv`
