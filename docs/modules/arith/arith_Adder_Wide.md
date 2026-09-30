---
type: Module
title: arith_Adder_Wide
description: Wide adder structure.
tags: [domain:arith, module:arith_Adder_Wide]
status: draft
resource: src/arith/arith_Adder_Wide.sv
model: sysml://PoC::Arith::arith_Adder_Wide
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Wide adder structure.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

See source file

## Ports (summary)

See source file

Full declarations: `src/arith/arith_Adder_Wide.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Multi-bit add with PoC partitioning.

# Requirements

<a id="REQ-arith_Adder_Wide-001"></a>

## REQ-arith_Adder_Wide-001

Sum/carry shall equal unsigned addition of the operands for the configured width.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/arith/arith_Adder_Wide.sv`
