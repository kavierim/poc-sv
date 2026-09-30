---
type: Module
title: arith_Counter_Free
description: Free-running divider/strobe counter.
tags: [domain:arith, module:arith_Counter_Free]
status: draft
resource: src/arith/arith_Counter_Free.sv
model: sysml://PoC::Arith::arith_Counter_Free
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Free-running divider/strobe counter.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`DIVIDER`

## Ports (summary)

`Clock`, `Reset`, `Increment`, `Strobe`

Full declarations: `src/arith/arith_Counter_Free.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

DIVIDER=1 registers Increment; else modular counter asserts Strobe.

# Requirements

<a id="REQ-arith_Counter_Free-001"></a>

## REQ-arith_Counter_Free-001

For DIVIDER=1, Strobe shall follow Increment with register delay.

- Kind: extracted
- Verified by: arith_Counter_Free_tb

<a id="REQ-arith_Counter_Free-002"></a>

## REQ-arith_Counter_Free-002

For DIVIDER>1, Strobe shall assert at the divided rate while Increment is held.

- Kind: extracted
- Verified by: arith_Counter_Free_tb

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/arith/arith_Counter_Free.sv`
