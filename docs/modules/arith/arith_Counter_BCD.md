---
type: Module
title: arith_Counter_BCD
description: BCD counter.
tags: [domain:arith, module:arith_Counter_BCD]
status: draft
resource: src/arith/arith_Counter_BCD.sv
model: sysml://PoC::Arith::arith_Counter_BCD
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

BCD counter.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

See source file

## Ports (summary)

See source file

Full declarations: `src/arith/arith_Counter_BCD.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Counts in BCD under enable/reset.

# Requirements

<a id="REQ-arith_Counter_BCD-001"></a>

## REQ-arith_Counter_BCD-001

Count sequence shall follow BCD increment rules.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/arith/arith_Counter_BCD.sv`
