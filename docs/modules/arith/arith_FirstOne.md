---
type: Module
title: arith_FirstOne
description: Find lowest set request bit; one-hot Grant and binary Index.
tags: [domain:arith, module:arith_FirstOne]
status: draft
resource: src/arith/arith_FirstOne.sv
model: sysml://PoC::Arith::arith_FirstOne
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Find lowest set request bit; one-hot Grant and binary Index.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`BITS`

## Ports (summary)

`TokenIn`, `Request`, `Grant`, `TokenOut`, `Index`

Full declarations: `src/arith/arith_FirstOne.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Combinational: TokenIn gates; TokenOut if no request.

# Requirements

<a id="REQ-arith_FirstOne-001"></a>

## REQ-arith_FirstOne-001

With TokenIn=1, Grant shall be one-hot of the lowest set Request bit.

- Kind: extracted
- Verified by: arith_FirstOne_tb

<a id="REQ-arith_FirstOne-002"></a>

## REQ-arith_FirstOne-002

With no Request bits set, TokenOut shall be 1 and Grant 0.

- Kind: extracted
- Verified by: arith_FirstOne_tb

<a id="REQ-arith_FirstOne-003"></a>

## REQ-arith_FirstOne-003

With TokenIn=0, Grant shall be 0.

- Kind: extracted
- Verified by: arith_FirstOne_tb

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/arith/arith_FirstOne.sv`
