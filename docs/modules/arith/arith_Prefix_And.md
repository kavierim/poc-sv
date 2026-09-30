---
type: Module
title: arith_Prefix_And
description: Prefix-AND network.
tags: [domain:arith, module:arith_Prefix_And]
status: draft
resource: src/arith/arith_Prefix_And.sv
model: sysml://PoC::Arith::arith_Prefix_And
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Prefix-AND network.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`BITS`

## Ports (summary)

`x`, `y`

Full declarations: `src/arith/arith_Prefix_And.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Analogous to Prefix_Or for AND (see RTL).

# Requirements

<a id="REQ-arith_Prefix_And-001"></a>

## REQ-arith_Prefix_And-001

The module shall compute the PoC prefix-AND function of x.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/arith/arith_Prefix_And.sv`
