---
type: Module
title: fifo_ic_got
description: Independent-clock (CDC) FIFO with Put/Got.
tags: [domain:fifo, module:fifo_ic_got]
status: draft
resource: src/fifo/fifo_ic_got.sv
model: sysml://PoC::Fifo::fifo_ic_got
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Independent-clock (CDC) FIFO with Put/Got.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`DATA_BITS`, `MIN_DEPTH`, `DATA_REG`, `OUTPUT_REG`

## Ports (summary)

Write_* and Read_* clock/reset/data/handshake

Full declarations: `src/fifo/fifo_ic_got.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Gray-coded write/read pointers synchronized across domains; Write_Full / Read_Valid.

# Requirements

<a id="REQ-fifo_ic_got-001"></a>

## REQ-fifo_ic_got-001

Words pushed on Write_Clock shall appear in order on Read_Clock.

- Kind: extracted
- Verified by: fifo_ic_got_tb

<a id="REQ-fifo_ic_got-002"></a>

## REQ-fifo_ic_got-002

Integrity shall hold for two unequal clock ratios in Verilator.

- Kind: extracted
- Verified by: fifo_ic_got_tb

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/fifo/fifo_ic_got.sv`
