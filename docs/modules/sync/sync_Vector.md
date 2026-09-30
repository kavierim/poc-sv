---
type: Module
title: sync_Vector
description: Vector synchronizer (multi-bit with common control).
tags: [domain:sync, module:sync_Vector]
status: draft
resource: src/sync/sync_Vector.sv
model: sysml://PoC::Sync::sync_Vector
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Vector synchronizer (multi-bit with common control).

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

See source file

## Ports (summary)

See source file

Full declarations: `src/sync/sync_Vector.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Safe vector crossing per PoC (typically handshake or gray); see RTL parameters.

# Requirements

<a id="REQ-sync_Vector-001"></a>

## REQ-sync_Vector-001

The module shall deliver a consistent vector to the destination domain per configured mode.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/sync/sync_Vector.sv`
