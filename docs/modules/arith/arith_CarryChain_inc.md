---
type: Module
title: arith_CarryChain_inc
description: Increment via carry chain (A+CarryIn).
tags: [domain:arith, module:arith_CarryChain_inc]
status: draft
resource: src/arith/arith_CarryChain_inc.sv
model: sysml://PoC::Arith::arith_CarryChain_inc
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Increment via carry chain (A+CarryIn).

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`BITS`

## Ports (summary)

`A`, `CarryIn`, `Sum`

Full declarations: `src/arith/arith_CarryChain_inc.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Used heavily by FIFO pointers.

# Requirements

<a id="REQ-arith_CarryChain_inc-001"></a>

## REQ-arith_CarryChain_inc-001

Sum shall equal A+CarryIn (mod 2^BITS with carry as implemented).

- Kind: extracted
- Verified by: indirect via fifo_* TBs

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/arith/arith_CarryChain_inc.sv`
