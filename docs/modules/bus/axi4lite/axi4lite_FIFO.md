---
type: Module
title: axi4lite_FIFO
description: Same-clock AXI4-Lite channel FIFOs (`TRANSACTIONS` depth).
tags: [domain:bus.axi4lite, module:axi4lite_FIFO]
status: draft
resource: src/bus/axi4lite/axi4lite_FIFO.sv
model: sysml://PoC::Bus_Axi4Lite::axi4lite_FIFO
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Same-clock AXI4-Lite channel FIFOs (`TRANSACTIONS` depth).

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`TRANSACTIONS`, `ADDR_W`, `DATA_W`

## Ports (summary)

`Clock`, `Reset`, In/Out Lite buses

Full declarations: `src/bus/axi4lite/axi4lite_FIFO.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Five independent FIFOs for AW/AR/W/R/B. `TRANSACTIONS≤3` uses `fifo_Stage`; deeper uses `fifo_cc_got`. Scalar pack offsets (Verilator-safe).

# Requirements

<a id="REQ-axi4lite_FIFO-001"></a>

## REQ-axi4lite_FIFO-001

WData and AWAddr shall pass In→Out unaltered when accepted.

- Kind: extracted
- Verified by: axi4lite_FIFO_tb

<a id="REQ-axi4lite_FIFO-002"></a>

## REQ-axi4lite_FIFO-002

RData shall pass Out→In unaltered.

- Kind: extracted
- Verified by: axi4lite_FIFO_tb

<a id="REQ-axi4lite_FIFO-003"></a>

## REQ-axi4lite_FIFO-003

Stalling Out AWReady shall cause In AWReady to deassert when the AW FIFO fills.

- Kind: extracted
- Verified by: axi4lite_FIFO_tb

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4lite/axi4lite_FIFO.sv`
