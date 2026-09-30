---
type: Module
title: arith_Scaler
description: Numeric scaler/gain block.
tags: [domain:arith, module:arith_Scaler]
status: draft
resource: src/arith/arith_Scaler.sv
model: sysml://PoC::Arith::arith_Scaler
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Numeric scaler/gain block.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

See source file

## Ports (summary)

See source file

Full declarations: `src/arith/arith_Scaler.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Scales input per parameters.

# Requirements

<a id="REQ-arith_Scaler-001"></a>

## REQ-arith_Scaler-001

Output shall equal the configured scaling of the input.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/arith/arith_Scaler.sv`
