---
type: Module
title: arith_PRNG
description: Pseudo-random number generator.
tags: [domain:arith, module:arith_PRNG]
status: draft
resource: src/arith/arith_PRNG.sv
model: sysml://PoC::Arith::arith_PRNG
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Pseudo-random number generator.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

See source file

## Ports (summary)

See source file

Full declarations: `src/arith/arith_PRNG.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

LFSR/PRNG state advances on clock/enable.

# Requirements

<a id="REQ-arith_PRNG-001"></a>

## REQ-arith_PRNG-001

The module shall advance deterministic PRNG state each enabled cycle from the seed/reset value.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/arith/arith_PRNG.sv`
