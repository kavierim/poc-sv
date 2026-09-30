---
type: Module
title: axi4_Mux
description: AXI4 multiplexer: PORTS managers to one subordinate via arbitration.
tags: [domain:bus.axi4, module:axi4_Mux]
status: draft
resource: src/bus/axi4/axi4_Mux.sv
model: sysml://PoC::Bus_Axi4::axi4_Mux
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

AXI4 multiplexer: PORTS managers to one subordinate via arbitration.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`PORTS`, widths, `PIPELINE_IN[]`, `PIPELINE_OUT`, outstanding counts

## Ports (summary)

`Clock`, `Reset`, `In_M2S[PORTS]`/`In_S2M[PORTS]`, `Out_M2S`/`Out_S2M`

Full declarations: `src/bus/axi4/axi4_Mux.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Single `Clock`/`Reset`. `bus_Arbiter` grants write and read address channels among inputs. Optional per-port `PIPELINE_IN` and output pipeline. Transaction path merges W/R data; B/R responses return to the granted manager with ID remap.

# Requirements

<a id="REQ-axi4_Mux-001"></a>

## REQ-axi4_Mux-001

The multiplexer shall forward write data from the granted manager to the subordinate without corruption.

- Kind: extracted
- Verified by: axi4_Mux_tb

<a id="REQ-axi4_Mux-002"></a>

## REQ-axi4_Mux-002

BID returned to a manager shall match that manager's AWID for the completed write.

- Kind: extracted
- Verified by: axi4_Mux_tb

<a id="REQ-axi4_Mux-003"></a>

## REQ-axi4_Mux-003

RID and read data path shall complete a granted single-beat read with OKAY (when subordinate returns OKAY).

- Kind: extracted
- Verified by: axi4_Mux_tb

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4/axi4_Mux.sv`
