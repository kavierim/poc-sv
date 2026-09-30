---
type: Module
title: fifo_Shift
description: Shift-register FIFO (small depths).
tags: [domain:fifo, module:fifo_Shift]
status: draft
resource: src/fifo/fifo_Shift.sv
model: sysml://PoC::Fifo::fifo_Shift
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Shift-register FIFO (small depths).

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`DATA_BITS`, `MIN_DEPTH`

## Ports (summary)

Put/Got style as in RTL

Full declarations: `src/fifo/fifo_Shift.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

LUT-style shift storage used by `fifo_cc_got` when enabled.

# Requirements

<a id="REQ-fifo_Shift-001"></a>

## REQ-fifo_Shift-001

The module shall store and forward words in order under Put/Got handshake.

- Kind: extracted
- Verified by: none (covered indirectly via fifo_cc_got LUT path)

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/fifo/fifo_Shift.sv`
