---
type: Module
title: arith_Shifter_Barrel
description: Barrel shifter.
tags: [domain:arith, module:arith_Shifter_Barrel]
status: draft
resource: src/arith/arith_Shifter_Barrel.sv
model: sysml://PoC::Arith::arith_Shifter_Barrel
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Barrel shifter.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

See source file

## Ports (summary)

See source file

Full declarations: `src/arith/arith_Shifter_Barrel.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Shifts/rotates by select.

# Requirements

<a id="REQ-arith_Shifter_Barrel-001"></a>

## REQ-arith_Shifter_Barrel-001

Output shall equal input shifted/rotated by the select amount.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/arith/arith_Shifter_Barrel.sv`
