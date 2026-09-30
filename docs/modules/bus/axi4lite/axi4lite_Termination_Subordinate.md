---
type: Module
title: axi4lite_Termination_Subordinate
description: Lite subordinate returning fixed RESPONSE_CODE (RData=0).
tags: [domain:bus.axi4lite, module:axi4lite_Termination_Subordinate]
status: draft
resource: src/bus/axi4lite/axi4lite_Termination_Subordinate.sv
model: sysml://PoC::Bus_Axi4Lite::axi4lite_Termination_Subordinate
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Lite subordinate returning fixed RESPONSE_CODE (RData=0).

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`RESPONSE_CODE`, widths

## Ports (summary)

`Clock`, `Reset`, Lite bus

Full declarations: `src/bus/axi4lite/axi4lite_Termination_Subordinate.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Small FIFOs handshake AW/W/AR; B/R use RESPONSE_CODE.

# Requirements

<a id="REQ-axi4lite_Termination_Subordinate-001"></a>

## REQ-axi4lite_Termination_Subordinate-001

Completed transactions shall return RESPONSE_CODE on BResp/RResp.

- Kind: extracted
- Verified by: exercised via axi4lite_DeMux_tb / FIFO TBs

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4lite/axi4lite_Termination_Subordinate.sv`
