---
type: Module
title: fifo_Stage
description: Elastic pipeline of STAGES registers with Full/Valid/Got.
tags: [domain:fifo, module:fifo_Stage]
status: draft
resource: src/fifo/fifo_Stage.sv
model: sysml://PoC::Fifo::fifo_Stage
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Elastic pipeline of STAGES registers with Full/Valid/Got.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`DATA_BITS`, `STAGES`, `LIGHT_WEIGHT`

## Ports (summary)

`Clock`, `Reset`, Put/DataIn/Full, Valid/DataOut/Got

Full declarations: `src/fifo/fifo_Stage.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Full or light-weight stage cells; chains Ready backwards.

# Requirements

<a id="REQ-fifo_Stage-001"></a>

## REQ-fifo_Stage-001

Stalled Got shall keep head DataOut stable with Valid high once data is present.

- Kind: extracted
- Verified by: fifo_Stage_tb

<a id="REQ-fifo_Stage-002"></a>

## REQ-fifo_Stage-002

Reset shall clear Valid.

- Kind: extracted
- Verified by: fifo_Stage_tb

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/fifo/fifo_Stage.sv`
