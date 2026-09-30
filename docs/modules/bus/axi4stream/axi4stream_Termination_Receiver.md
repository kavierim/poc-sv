---
type: Module
title: axi4stream_Termination_Receiver
description: Sink unused stream source (always Ready or patterned).
tags: [domain:bus.axi4stream, module:axi4stream_Termination_Receiver]
status: draft
resource: src/bus/axi4stream/axi4stream_Termination_Receiver.sv
model: sysml://PoC::Bus_Axi4Stream::axi4stream_Termination_Receiver
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Sink unused stream source (always Ready or patterned).

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

VALUE / widths

## Ports (summary)

stream sink ports

Full declarations: `src/bus/axi4stream/axi4stream_Termination_Receiver.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Terminates M2S by driving Ready per VALUE/mode.

# Requirements

<a id="REQ-axi4stream_Termination_Receiver-001"></a>

## REQ-axi4stream_Termination_Receiver-001

Receiver Ready shall follow the configured termination VALUE behaviour.

- Kind: extracted
- Verified by: axi4stream_Termination_tb

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4stream/axi4stream_Termination_Receiver.sv`
