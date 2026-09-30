---
type: Module
title: arith_Convert_Binary2BCD
description: Binary to BCD conversion.
tags: [domain:arith, module:arith_Convert_Binary2BCD]
status: draft
resource: src/arith/arith_Convert_Binary2BCD.sv
model: sysml://PoC::Arith::arith_Convert_Binary2BCD
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Binary to BCD conversion.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

See source file

## Ports (summary)

See source file

Full declarations: `src/arith/arith_Convert_Binary2BCD.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Sequential/combinational conversion per RTL.

# Requirements

<a id="REQ-arith_Convert_Binary2BCD-001"></a>

## REQ-arith_Convert_Binary2BCD-001

Output BCD shall represent the binary input value.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/arith/arith_Convert_Binary2BCD.sv`
