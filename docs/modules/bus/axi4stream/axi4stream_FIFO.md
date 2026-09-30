---
type: Module
title: axi4stream_FIFO
description: Same-clock AXI4-Stream packet FIFO with optional metadata FIFO.
tags: [domain:bus.axi4stream, module:axi4stream_FIFO]
status: draft
resource: src/bus/axi4stream/axi4stream_FIFO.sv
model: sysml://PoC::Bus_Axi4Stream::axi4stream_FIFO
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Same-clock AXI4-Stream packet FIFO with optional metadata FIFO.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`FRAMES`, `MAX_PACKET_DEPTH`, stream widths, metadata flags

## Ports (summary)

`Clock`, `Reset`, In/Out stream

Full declarations: `src/bus/axi4stream/axi4stream_FIFO.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Buffers stream beats; `FRAMES`/`MAX_PACKET_DEPTH` size storage; Valid/Ready handshake.

# Model

Behavioral Python class: poc_model.axi4stream_FIFO.axi4stream_FIFO (model/poc_model/axi4stream_FIFO.py).

# Requirements

<a id="REQ-axi4stream_FIFO-001"></a>

## REQ-axi4stream_FIFO-001

A packet pushed In shall emerge Out in the same beat order with matching Data/Last.

- Kind: extracted
- Verified by: axi4stream_FIFO_tb

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4stream/axi4stream_FIFO.sv`
