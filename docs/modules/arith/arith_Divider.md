---
type: Module
title: arith_Divider
description: Integer divider.
tags: [domain:arith, module:arith_Divider]
status: draft
resource: src/arith/arith_Divider.sv
model: sysml://PoC::Arith::arith_Divider
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Integer divider.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

See source file

## Ports (summary)

See source file

Full declarations: `src/arith/arith_Divider.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Produces quotient/remainder per RTL protocol.

# Requirements

<a id="REQ-arith_Divider-001"></a>

## REQ-arith_Divider-001

Quotient and remainder shall satisfy dividend = q*divisor+r with r<divisor for valid ops.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/arith/arith_Divider.sv`
