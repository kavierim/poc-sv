---
type: Module
title: fifo_cc_got
description: Same-clock FIFO with Put/Got (Valid/Full) interface.
tags: [domain:fifo, module:fifo_cc_got]
status: draft
resource: src/fifo/fifo_cc_got.sv
model: sysml://PoC::Fifo::fifo_cc_got
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Same-clock FIFO with Put/Got (Valid/Full) interface.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`DATA_BITS`, `MIN_DEPTH`, `STATE_REG`, `DATA_REG`, …

## Ports (summary)

`Clock`, `Reset`, Put/DataIn/Full, Got/DataOut/Valid

Full declarations: `src/fifo/fifo_cc_got.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

RAM or LUT-shift implementation; pointer wrap; optional state registers.

# Requirements

<a id="REQ-fifo_cc_got-001"></a>

## REQ-fifo_cc_got-001

After reset, Valid shall be low.

- Kind: extracted
- Verified by: fifo_cc_got_tb

<a id="REQ-fifo_cc_got-002"></a>

## REQ-fifo_cc_got-002

Data shall FIFO in order; Full shall assert when capacity is reached.

- Kind: extracted
- Verified by: fifo_cc_got_tb

<a id="REQ-fifo_cc_got-003"></a>

## REQ-fifo_cc_got-003

Reset mid-stream shall discard pending words (Valid low after reset).

- Kind: extracted
- Verified by: fifo_cc_got_tb

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/fifo/fifo_cc_got.sv`
