---
type: Module
title: ocram_SimpleDualPort_WriteFirst
description: Simple dual-port with write-first on write port where applicable.
tags: [domain:mem.ocram, module:ocram_SimpleDualPort_WriteFirst]
status: draft
resource: src/mem/ocram/ocram_SimpleDualPort_WriteFirst.sv
model: sysml://PoC::Mem::ocram_SimpleDualPort_WriteFirst
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Simple dual-port with write-first on write port where applicable.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

See source file

## Ports (summary)

Write/Read

Full declarations: `src/mem/ocram/ocram_SimpleDualPort_WriteFirst.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

SDP variant; see RTL for CE/WE timing.

# Requirements

<a id="REQ-ocram_SimpleDualPort_WriteFirst-001"></a>

## REQ-ocram_SimpleDualPort_WriteFirst-001

The module shall implement SDP storage with write-first semantics as coded.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/mem/ocram/ocram_SimpleDualPort_WriteFirst.sv`
