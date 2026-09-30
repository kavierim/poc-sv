---
type: Module
title: ocram_SinglePort
description: Single-port RAM.
tags: [domain:mem.ocram, module:ocram_SinglePort]
status: draft
resource: src/mem/ocram/ocram_SinglePort.sv
model: sysml://PoC::Mem::ocram_SinglePort
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Single-port RAM.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

address/data bits, RAM_TYPE

## Ports (summary)

Clock, enable, WE, address, data

Full declarations: `src/mem/ocram/ocram_SinglePort.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Shared address for read/write on one clock.

# Requirements

<a id="REQ-ocram_SinglePort-001"></a>

## REQ-ocram_SinglePort-001

Writes shall update the addressed word; reads shall return stored data per timing mode.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/mem/ocram/ocram_SinglePort.sv`
