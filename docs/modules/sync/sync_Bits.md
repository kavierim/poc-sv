---
type: Module
title: sync_Bits
description: Multi-bit 2-flop (or deeper) synchronizer.
tags: [domain:sync, module:sync_Bits]
status: draft
resource: src/sync/sync_Bits.sv
model: sysml://PoC::Sync::sync_Bits
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Multi-bit 2-flop (or deeper) synchronizer.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`BITS`, `INIT`, `SYNC_DEPTH`, `REGISTER_OUTPUT`

## Ports (summary)

`Clock`, `Input`, `Output`

Full declarations: `src/sync/sync_Bits.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Per-bit meta+sync chain of `SYNC_DEPTH`; INIT seeds FFs; Input overwrites after sync delay.

# Requirements

<a id="REQ-sync_Bits-001"></a>

## REQ-sync_Bits-001

Output shall not equal a new Input in the first cycle after Input changes (depth≥2).

- Kind: extracted
- Verified by: sync_Bits_tb

<a id="REQ-sync_Bits-002"></a>

## REQ-sync_Bits-002

After SYNC_DEPTH+margin clocks, Output shall equal Input.

- Kind: extracted
- Verified by: sync_Bits_tb

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/sync/sync_Bits.sv`
