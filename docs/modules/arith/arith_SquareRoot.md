---
type: Module
title: arith_SquareRoot
description: Integer square-root unit.
tags: [domain:arith, module:arith_SquareRoot]
status: draft
resource: src/arith/arith_SquareRoot.sv
model: sysml://PoC::Arith::arith_SquareRoot
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Integer square-root unit.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

See source file

## Ports (summary)

See source file

Full declarations: `src/arith/arith_SquareRoot.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Computes floor(sqrt(x)) per RTL.

# Requirements

<a id="REQ-arith_SquareRoot-001"></a>

## REQ-arith_SquareRoot-001

Result r shall satisfy r^2 ≤ x < (r+1)^2 for valid inputs.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/arith/arith_SquareRoot.sv`
