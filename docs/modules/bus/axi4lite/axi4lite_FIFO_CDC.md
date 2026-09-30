---
type: Module
title: axi4lite_FIFO_CDC
description: CDC AXI4-Lite FIFOs using `fifo_ic_got` per channel.
tags: [domain:bus.axi4lite, module:axi4lite_FIFO_CDC]
status: draft
resource: src/bus/axi4lite/axi4lite_FIFO_CDC.sv
model: sysml://PoC::Bus_Axi4Lite::axi4lite_FIFO_CDC
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

CDC AXI4-Lite FIFOs using `fifo_ic_got` per channel.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`TRANSACTIONS`, `DATA_REG`, `OUTPUT_REG`, widths

## Ports (summary)

In/Out clocks, resets, Lite buses

Full declarations: `src/bus/axi4lite/axi4lite_FIFO_CDC.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

AW/AR/W cross In→Out; R/B cross Out→In. Dual clocks/resets. Scalar packing.

# Requirements

<a id="REQ-axi4lite_FIFO_CDC-001"></a>

## REQ-axi4lite_FIFO_CDC-001

Ordered writes shall cross domains without loss or reordering.

- Kind: extracted
- Verified by: axi4lite_FIFO_CDC_tb

<a id="REQ-axi4lite_FIFO_CDC-002"></a>

## REQ-axi4lite_FIFO_CDC-002

Read data shall cross back with correct RData.

- Kind: extracted
- Verified by: axi4lite_FIFO_CDC_tb

<a id="REQ-axi4lite_FIFO_CDC-003"></a>

## REQ-axi4lite_FIFO_CDC-003

Out-domain AW stall shall eventually deassert In AWReady.

- Kind: extracted
- Verified by: axi4lite_FIFO_CDC_tb

<a id="REQ-axi4lite_FIFO_CDC-004"></a>

## REQ-axi4lite_FIFO_CDC-004

Two unequal clock ratios shall both pass integrity checks.

- Kind: extracted
- Verified by: axi4lite_FIFO_CDC_tb

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4lite/axi4lite_FIFO_CDC.sv`
