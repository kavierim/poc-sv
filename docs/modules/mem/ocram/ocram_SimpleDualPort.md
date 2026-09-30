---
type: Module
title: ocram_SimpleDualPort
description: Simple dual-port RAM (1W1R) with independent clocks.
tags: [domain:mem.ocram, module:ocram_SimpleDualPort]
status: draft
resource: src/mem/ocram/ocram_SimpleDualPort.sv
model: sysml://PoC::Mem::ocram_SimpleDualPort
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Simple dual-port RAM (1W1R) with independent clocks.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`ADDRESS_BITS`, `DATA_BITS`, `RAM_TYPE`, `FILENAME`

## Ports (summary)

Write_* and Read_*

Full declarations: `src/mem/ocram/ocram_SimpleDualPort.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Write on Write_Clock when CE&WE; read registered on Read_Clock when CE.

# Requirements

<a id="REQ-ocram_SimpleDualPort-001"></a>

## REQ-ocram_SimpleDualPort-001

Data written with WE shall be readable at that address after the write is committed.

- Kind: extracted
- Verified by: ocram_SimpleDualPort_tb

<a id="REQ-ocram_SimpleDualPort-002"></a>

## REQ-ocram_SimpleDualPort-002

Write with ClockEnable low shall not update memory.

- Kind: extracted
- Verified by: ocram_SimpleDualPort_tb

<a id="REQ-ocram_SimpleDualPort-003"></a>

## REQ-ocram_SimpleDualPort-003

Read with ClockEnable low shall hold Read_DataOut.

- Kind: extracted
- Verified by: ocram_SimpleDualPort_tb

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/mem/ocram/ocram_SimpleDualPort.sv`
