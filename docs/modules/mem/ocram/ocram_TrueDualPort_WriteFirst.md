---
type: Module
title: ocram_TrueDualPort_WriteFirst
description: True dual-port RAM with write-first read semantics.
tags: [domain:mem.ocram, module:ocram_TrueDualPort_WriteFirst]
status: draft
resource: src/mem/ocram/ocram_TrueDualPort_WriteFirst.sv
model: sysml://PoC::Mem::ocram_TrueDualPort_WriteFirst
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

True dual-port RAM with write-first read semantics.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

See source file

## Ports (summary)

Port A/B

Full declarations: `src/mem/ocram/ocram_TrueDualPort_WriteFirst.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Same-port read during write returns new data.

# Requirements

<a id="REQ-ocram_TrueDualPort_WriteFirst-001"></a>

## REQ-ocram_TrueDualPort_WriteFirst-001

On a port write with read, read data shall reflect write-first behaviour.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/mem/ocram/ocram_TrueDualPort_WriteFirst.sv`
