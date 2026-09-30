---
type: Module
title: fifo_ic_assembly
description: Independent-clock assembly buffer: write-side address/data packing with gray-group CDC.
tags: [domain:fifo, module:fifo_ic_assembly]
status: draft
resource: src/fifo/fifo_ic_assembly.sv
model: sysml://PoC::Fifo::fifo_ic_assembly
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Independent-clock assembly buffer: write-side address/data packing with gray-group CDC.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`D_BITS`, `A_BITS`, `G_BITS`

## Ports (summary)

`clk_wr`/`rst_wr`, `base`/`failed`, `addr`/`din`/`put`, `clk_rd`/`rst_rd`, `dout`/`vld`/`got`

Full declarations: `src/fifo/fifo_ic_assembly.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Write domain posts `addr`/`din` with `put`; read domain presents `dout`/`vld` with `got`. `base`/`failed` report write-side status. Uses gray pointer groups of `G_BITS`.

# Requirements

<a id="REQ-fifo_ic_assembly-001"></a>

## REQ-fifo_ic_assembly-001

Accepted write puts shall become readable on the read clock in order when got is applied.

- Kind: extracted
- Verified by: none (no dedicated TB)

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/fifo/fifo_ic_assembly.sv`
