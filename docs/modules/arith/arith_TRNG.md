---
type: Module
title: arith_TRNG
description: Entropy/TRNG helper (simulation/synthesis dependent).
tags: [domain:arith, module:arith_TRNG]
status: draft
resource: src/arith/arith_TRNG.sv
model: sysml://PoC::Arith::arith_TRNG
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Entropy/TRNG helper (simulation/synthesis dependent).

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

See source file

## Ports (summary)

See source file

Full declarations: `src/arith/arith_TRNG.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Not suitable as a sole cryptographic entropy source without review.

# Requirements

<a id="REQ-arith_TRNG-001"></a>

## REQ-arith_TRNG-001

The module shall produce a free-running entropy/bit stream as implemented (non-deterministic in HW).

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/arith/arith_TRNG.sv`
- ASIC synth: intentional `SKIP` in [`asic-synth.md`](../../playbooks/asic-synth.md) (combinational-loop entropy source; no synthesizable parent instantiates it).
