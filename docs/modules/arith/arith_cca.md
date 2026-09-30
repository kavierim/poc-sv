---
type: Module
title: arith_cca
description: Carry-chain arithmetic helper (CCA).
tags: [domain:arith, module:arith_cca]
status: draft
resource: src/arith/arith_cca.sv
model: sysml://PoC::Arith::arith_cca
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Carry-chain arithmetic helper (CCA).

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

See source file

## Ports (summary)

See source file

Full declarations: `src/arith/arith_cca.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

PoC CCA primitive wrapper.

# Requirements

<a id="REQ-arith_cca-001"></a>

## REQ-arith_cca-001

The module shall match PoC CCA Boolean/arithmetic function in RTL.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/arith/arith_cca.sv`
