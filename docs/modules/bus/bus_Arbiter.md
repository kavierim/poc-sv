---
type: Module
title: bus_Arbiter
description: Multi-port arbiter (round-robin style) used by AXI muxes.
tags: [domain:bus, module:bus_Arbiter]
status: draft
resource: src/bus/bus_Arbiter.sv
model: sysml://PoC::Bus::bus_Arbiter
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Multi-port arbiter (round-robin style) used by AXI muxes.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`PORTS`, `STRATEGY`, `OUTPUT_REG`

## Ports (summary)

`Clock`, `Reset`, Request/Grant vectors, GrantIndex

Full declarations: `src/bus/bus_Arbiter.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Grants among `PORTS` requests. Default STRATEGY implemented; non-default strategies `$fatal` at elaboration/runtime. Optional `OUTPUT_REG`.

# Requirements

<a id="REQ-bus_Arbiter-001"></a>

## REQ-bus_Arbiter-001

Exactly one grant shall be asserted among requesting ports when arbitration runs (for supported STRATEGY).

- Kind: extracted
- Verified by: indirect via axi4_Mux_tb / axi4stream_Mux_tb

<a id="REQ-bus_Arbiter-002"></a>

## REQ-bus_Arbiter-002

Unsupported STRATEGY values shall not silently mis-arbitrate (fatal/not implemented).

- Kind: extracted
- Verified by: none (fatal path)

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/bus_Arbiter.sv`
