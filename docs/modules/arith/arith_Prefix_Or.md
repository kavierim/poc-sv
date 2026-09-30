---
type: Module
title: arith_Prefix_Or
description: Prefix-OR network (PoC optimized structure).
tags: [domain:arith, module:arith_Prefix_Or]
status: draft
resource: src/arith/arith_Prefix_Or.sv
model: sysml://PoC::Arith::arith_Prefix_Or
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Prefix-OR network (PoC optimized structure).

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`BITS`

## Ports (summary)

`x`, `y`

Full declarations: `src/arith/arith_Prefix_Or.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

y[0]=x[0]; y[1]=x[0]|x[1]; upper bits via PoC carry trick — not a naive loop for all BITS.

# Requirements

<a id="REQ-arith_Prefix_Or-001"></a>

## REQ-arith_Prefix_Or-001

y[0] shall equal x[0]; y[1] shall equal x[0]|x[1].

- Kind: extracted
- Verified by: arith_Prefix_Or_tb

<a id="REQ-arith_Prefix_Or-002"></a>

## REQ-arith_Prefix_Or-002

A nonzero x shall produce a nonzero y.

- Kind: extracted
- Verified by: arith_Prefix_Or_tb

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/arith/arith_Prefix_Or.sv`
