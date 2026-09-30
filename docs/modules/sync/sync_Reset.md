---
type: Module
title: sync_Reset
description: Asynchronous assert, synchronous deassert reset synchronizer.
tags: [domain:sync, module:sync_Reset]
status: draft
resource: src/sync/sync_Reset.sv
model: sysml://PoC::Sync::sync_Reset
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Asynchronous assert, synchronous deassert reset synchronizer.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`SYNC_DEPTH`

## Ports (summary)

`Clock`, `Input`, `D`, `Output`

Full declarations: `src/sync/sync_Reset.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Async set of chain when Input high; shifts D when released.

# Requirements

<a id="REQ-sync_Reset-001"></a>

## REQ-sync_Reset-001

While Input is asserted, Output shall be high.

- Kind: extracted
- Verified by: sync_Reset_tb

<a id="REQ-sync_Reset-002"></a>

## REQ-sync_Reset-002

After Input release with D=0, Output shall go low after sync depth.

- Kind: extracted
- Verified by: sync_Reset_tb

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/sync/sync_Reset.sv`
