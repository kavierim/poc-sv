---
type: Module
title: sync_Pulse
description: Pulse synchronizer: captures Input rising edge into an async latch, then SYNC_DEPTH flops.
tags: [domain:sync, module:sync_Pulse]
status: draft
resource: src/sync/sync_Pulse.sv
model: sysml://PoC::Sync::sync_Pulse
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Pulse synchronizer: captures Input rising edge into an async latch, then SYNC_DEPTH flops.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`BITS`, `SYNC_DEPTH`

## Ports (summary)

`Clock`, `Input[BITS]`, `Output[BITS]`

Full declarations: `src/sync/sync_Pulse.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Per bit: rising edge of `Input` sets `Data_async`; cleared when sync_out is high and Input low. Meta+sync chain clocks into `Clock`. Output is the last sync stage (level until cleared).

# Requirements

<a id="REQ-sync_Pulse-001"></a>

## REQ-sync_Pulse-001

A rising edge on Input shall assert Output after the synchronizer latency until the clear condition occurs.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/sync/sync_Pulse.sv`
