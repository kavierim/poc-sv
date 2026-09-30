---
type: Module
title: fifo_cc_got_tempgot
description: Same-clock FIFO with temporary Got (commit/rollback read).
tags: [domain:fifo, module:fifo_cc_got_tempgot]
status: draft
resource: src/fifo/fifo_cc_got_tempgot.sv
model: sysml://PoC::Fifo::fifo_cc_got_tempgot
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Same-clock FIFO with temporary Got (commit/rollback read).

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

See source file

## Ports (summary)

See source file

Full declarations: `src/fifo/fifo_cc_got_tempgot.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Extends got-FIFO with provisional read pointer.

# Requirements

<a id="REQ-fifo_cc_got_tempgot-001"></a>

## REQ-fifo_cc_got_tempgot-001

Rollback shall restore unread data; commit shall advance the read pointer permanently.

- Kind: extracted
- Verified by: indirect via axi4stream_FIFO_TempGot

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/fifo/fifo_cc_got_tempgot.sv`
