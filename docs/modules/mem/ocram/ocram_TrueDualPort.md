---
type: Module
title: ocram_TrueDualPort
description: True dual-port RAM (two R/W ports).
tags: [domain:mem.ocram, module:ocram_TrueDualPort]
status: draft
resource: src/mem/ocram/ocram_TrueDualPort.sv
model: sysml://PoC::Mem::ocram_TrueDualPort
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

True dual-port RAM (two R/W ports).

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

See source file

## Ports (summary)

Port A/B

Full declarations: `src/mem/ocram/ocram_TrueDualPort.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Independent port clocks/enables; conflict behaviour as in generic model.

# Requirements

<a id="REQ-ocram_TrueDualPort-001"></a>

## REQ-ocram_TrueDualPort-001

Each port shall read/write its addressed location when enabled.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/mem/ocram/ocram_TrueDualPort.sv`
