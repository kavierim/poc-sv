---
type: Module
title: axi4stream_Pause
description: Gates stream progress based on Pause (optional packet mode).
tags: [domain:bus.axi4stream, module:axi4stream_Pause]
status: draft
resource: src/bus/axi4stream/axi4stream_Pause.sv
model: sysml://PoC::Bus_Axi4Stream::axi4stream_Pause
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Gates stream progress based on Pause (optional packet mode).

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`PACKET_MODE`, stream widths

## Ports (summary)

`Clock`, `Reset`, `Pause`, status, In/Out stream

Full declarations: `src/bus/axi4stream/axi4stream_Pause.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

When Pause asserted, blocks forwarding per PACKET_MODE rules; status outputs In_Packet/Data_Available/Data_Blocked.

# Requirements

<a id="REQ-axi4stream_Pause-001"></a>

## REQ-axi4stream_Pause-001

While Pause is asserted, Out shall not complete a new beat handshake that the pause mode forbids.

- Kind: extracted
- Verified by: axi4stream_Pause_tb

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4stream/axi4stream_Pause.sv`
