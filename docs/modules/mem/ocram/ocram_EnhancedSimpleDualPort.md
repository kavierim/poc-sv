---
type: Module
title: ocram_EnhancedSimpleDualPort
description: Enhanced SDP variant from PoC.
tags: [domain:mem.ocram, module:ocram_EnhancedSimpleDualPort]
status: draft
resource: src/mem/ocram/ocram_EnhancedSimpleDualPort.sv
model: sysml://PoC::Mem::ocram_EnhancedSimpleDualPort
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Enhanced SDP variant from PoC.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

See source file

## Ports (summary)

See source file

Full declarations: `src/mem/ocram/ocram_EnhancedSimpleDualPort.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Additional enables/features per RTL.

# Requirements

<a id="REQ-ocram_EnhancedSimpleDualPort-001"></a>

## REQ-ocram_EnhancedSimpleDualPort-001

The module shall implement the enhanced SDP port protocol as in the SV source.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/mem/ocram/ocram_EnhancedSimpleDualPort.sv`
