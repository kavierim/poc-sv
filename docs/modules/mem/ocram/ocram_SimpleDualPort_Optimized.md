---
type: Module
title: ocram_SimpleDualPort_Optimized
description: Optimized SDP used inside FIFO RAM backends.
tags: [domain:mem.ocram, module:ocram_SimpleDualPort_Optimized]
status: draft
resource: src/mem/ocram/ocram_SimpleDualPort_Optimized.sv
model: sysml://PoC::Mem::ocram_SimpleDualPort_Optimized
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Optimized SDP used inside FIFO RAM backends.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

See source file

## Ports (summary)

Write/Read

Full declarations: `src/mem/ocram/ocram_SimpleDualPort_Optimized.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Same SDP idea; optimized generate for synthesis/sim.

# Requirements

<a id="REQ-ocram_SimpleDualPort_Optimized-001"></a>

## REQ-ocram_SimpleDualPort_Optimized-001

The module shall provide correct SDP read-after-write behaviour for FIFO use.

- Kind: extracted
- Verified by: indirect via fifo_cc_got_tb

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/mem/ocram/ocram_SimpleDualPort_Optimized.sv`
