---
type: Module
title: fifo_cc_got_tempput
description: Same-clock FIFO with temporary Put (commit/rollback write).
tags: [domain:fifo, module:fifo_cc_got_tempput]
status: draft
resource: src/fifo/fifo_cc_got_tempput.sv
model: sysml://PoC::Fifo::fifo_cc_got_tempput
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Same-clock FIFO with temporary Put (commit/rollback write).

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

See source file

## Ports (summary)

See source file

Full declarations: `src/fifo/fifo_cc_got_tempput.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Provisional write pointer until commit.

# Requirements

<a id="REQ-fifo_cc_got_tempput-001"></a>

## REQ-fifo_cc_got_tempput-001

Uncommitted puts shall be discardable; committed data shall be readable in order.

- Kind: extracted
- Verified by: indirect via axi4stream_FIFO_TempPut

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/fifo/fifo_cc_got_tempput.sv`
