---
type: Module
title: axi4stream_Mux
description: AXI4-Stream multiplexer with arbiter and MuxControl mask.
tags: [domain:bus.axi4stream, module:axi4stream_Mux]
status: draft
resource: src/bus/axi4stream/axi4stream_Mux.sv
model: sysml://PoC::Bus_Axi4Stream::axi4stream_Mux
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

AXI4-Stream multiplexer with arbiter and MuxControl mask.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`PORTS`, stream widths, MuxControl

## Ports (summary)

`Clock`, `Reset`, `MuxControl`, In[]/Out stream

Full declarations: `src/bus/axi4stream/axi4stream_Mux.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Arbitrates among PORTS inputs; forwards Data/Keep/Last/User/Dest/ID to Out.

# Model

Behavioral Python class: poc_model.axi4stream_Mux.axi4stream_Mux (model/poc_model/axi4stream_Mux.py).

# Requirements

<a id="REQ-axi4stream_Mux-001"></a>

## REQ-axi4stream_Mux-001

Merged output beats shall preserve Data, Last, and Keep from the selected input.

- Kind: extracted
- Verified by: axi4stream_Mux_tb

<a id="REQ-axi4stream_Mux-002"></a>

## REQ-axi4stream_Mux-002

Multi-beat packets shall remain ordered under mid-packet Out back-pressure.

- Kind: extracted
- Verified by: axi4stream_Mux_tb

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4stream/axi4stream_Mux.sv`
