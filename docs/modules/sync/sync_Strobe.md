---
type: Module
title: sync_Strobe
description: Strobe/level synchronizer helper.
tags: [domain:sync, module:sync_Strobe]
status: draft
resource: src/sync/sync_Strobe.sv
model: sysml://PoC::Sync::sync_Strobe
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Strobe/level synchronizer helper.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

See source file

## Ports (summary)

See source file

Full declarations: `src/sync/sync_Strobe.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Synchronizes strobe signalling per PoC sync_Strobe.

# Requirements

<a id="REQ-sync_Strobe-001"></a>

## REQ-sync_Strobe-001

The module shall present a synchronized strobe to the destination clock domain.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/sync/sync_Strobe.sv`
