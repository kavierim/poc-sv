---
type: Module
title: axi4stream_Stage
description: AXI4-Stream pipeline of `STAGES` using `fifo_Stage`.
tags: [domain:bus.axi4stream, module:axi4stream_Stage]
status: draft
resource: src/bus/axi4stream/axi4stream_Stage.sv
model: sysml://PoC::Bus_Axi4Stream::axi4stream_Stage
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

AXI4-Stream pipeline of `STAGES` using `fifo_Stage`.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`STAGES`, stream widths

## Ports (summary)

`Clock`, `Reset`, In/Out stream

Full declarations: `src/bus/axi4stream/axi4stream_Stage.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Packs Data/Keep/Last/User/Dest/ID into a stage FIFO; Ready = ~Full.

# Requirements

<a id="REQ-axi4stream_Stage-001"></a>

## REQ-axi4stream_Stage-001

With Out stalled, In beats shall remain ordered and present Valid at Out head.

- Kind: extracted
- Verified by: axi4stream_Stage_tb

<a id="REQ-axi4stream_Stage-002"></a>

## REQ-axi4stream_Stage-002

Keep/User/ID shall be preserved through the stage pipeline.

- Kind: extracted
- Verified by: axi4stream_Stage_tb

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4stream/axi4stream_Stage.sv`
