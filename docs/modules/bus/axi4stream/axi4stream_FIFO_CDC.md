---
type: Module
title: axi4stream_FIFO_CDC
description: Clock-crossing AXI4-Stream FIFO.
tags: [domain:bus.axi4stream, module:axi4stream_FIFO_CDC]
status: draft
resource: src/bus/axi4stream/axi4stream_FIFO_CDC.sv
model: sysml://PoC::Bus_Axi4Stream::axi4stream_FIFO_CDC
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Clock-crossing AXI4-Stream FIFO.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`FRAMES`, `MAX_PACKET_DEPTH`, `NO_META_FIFO`, widths

## Ports (summary)

In/Out clocks, resets, streams

Full declarations: `src/bus/axi4stream/axi4stream_FIFO_CDC.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Dual clocks/resets; crosses packed stream words via async FIFO primitives.

# Requirements

<a id="REQ-axi4stream_FIFO_CDC-001"></a>

## REQ-axi4stream_FIFO_CDC-001

A beat written on In_Clock shall appear on Out_Clock with matching Data/Last.

- Kind: extracted
- Verified by: axi4stream_FIFO_CDC_tb

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4stream/axi4stream_FIFO_CDC.sv`
