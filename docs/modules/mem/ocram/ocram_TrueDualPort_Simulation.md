---
type: Module
title: ocram_TrueDualPort_Simulation
description: Simulation-oriented true dual-port model.
tags: [domain:mem.ocram, module:ocram_TrueDualPort_Simulation]
status: draft
resource: src/mem/ocram/ocram_TrueDualPort_Simulation.sv
model: sysml://PoC::Mem::ocram_TrueDualPort_Simulation
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Simulation-oriented true dual-port model.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

See source file

## Ports (summary)

Port A/B

Full declarations: `src/mem/ocram/ocram_TrueDualPort_Simulation.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Array-backed model for sim.

# Requirements

<a id="REQ-ocram_TrueDualPort_Simulation-001"></a>

## REQ-ocram_TrueDualPort_Simulation-001

The module shall match functional read/write of the generic TDP model in simulation.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/mem/ocram/ocram_TrueDualPort_Simulation.sv`
