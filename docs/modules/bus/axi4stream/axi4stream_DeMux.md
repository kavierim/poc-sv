---
type: Module
title: axi4stream_DeMux
description: AXI4-Stream demultiplexer steered by DeMuxControl one-hot/mask.
tags: [domain:bus.axi4stream, module:axi4stream_DeMux]
status: draft
resource: src/bus/axi4stream/axi4stream_DeMux.sv
model: sysml://PoC::Bus_Axi4Stream::axi4stream_DeMux
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

AXI4-Stream demultiplexer steered by DeMuxControl one-hot/mask.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`PORTS`, stream widths

## Ports (summary)

`Clock`, `Reset`, DeMuxControl, In/Out[]

Full declarations: `src/bus/axi4stream/axi4stream_DeMux.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Routes In beats to selected Out port; lowest-index helper for control.

# Requirements

<a id="REQ-axi4stream_DeMux-001"></a>

## REQ-axi4stream_DeMux-001

Beats shall appear only on the selected port with matching Data/Last.

- Kind: extracted
- Verified by: axi4stream_DeMux_tb

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4stream/axi4stream_DeMux.sv`
