---
type: Module
title: arith_Same
description: Detect all-0 / all-1 chunks (sameness) with generate carry.
tags: [domain:arith, module:arith_Same]
status: draft
resource: src/arith/arith_Same.sv
model: sysml://PoC::Arith::arith_Same
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Detect all-0 / all-1 chunks (sameness) with generate carry.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`BITS`

## Ports (summary)

`g`, `x`, `y`

Full declarations: `src/arith/arith_Same.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Partitioned compare to 0/1 vectors; y indicates overall sameness with g.

# Requirements

<a id="REQ-arith_Same-001"></a>

## REQ-arith_Same-001

y shall reflect whether x chunks are uniform 0/1 per PoC Same algorithm.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/arith/arith_Same.sv`
