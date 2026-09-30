---
type: Module
title: axi4stream_FIFO_TempPut
description: Stream FIFO with temporary Put (commit/rollback) on the write side.
tags: [domain:bus.axi4stream, module:axi4stream_FIFO_TempPut]
status: draft
resource: src/bus/axi4stream/axi4stream_FIFO_TempPut.sv
model: sysml://PoC::Bus_Axi4Stream::axi4stream_FIFO_TempPut
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Stream FIFO with temporary Put (commit/rollback) on the write side.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

stream/FIFO sizing parameters

## Ports (summary)

`Clock`, `Reset`, stream + temp-put controls

Full declarations: `src/bus/axi4stream/axi4stream_FIFO_TempPut.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Uncommitted puts can be discarded; commit makes data visible to the reader.

# Requirements

<a id="REQ-axi4stream_FIFO_TempPut-001"></a>

## REQ-axi4stream_FIFO_TempPut-001

Committed data shall become readable; rolled-back uncommitted beats shall not appear on Out.

- Kind: extracted
- Verified by: axi4stream_FIFO_TempPut_tb

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4stream/axi4stream_FIFO_TempPut.sv`
