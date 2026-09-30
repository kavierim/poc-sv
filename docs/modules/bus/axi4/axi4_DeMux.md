---
type: Module
title: axi4_DeMux
description: Address-decode demultiplexer: one AXI4 manager to PORTS subordinates.
tags: [domain:bus.axi4, module:axi4_DeMux]
status: draft
resource: src/bus/axi4/axi4_DeMux.sv
model: sysml://PoC::Bus_Axi4::axi4_DeMux
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Address-decode demultiplexer: one AXI4 manager to PORTS subordinates.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`PORTS`, `ADDR_W`, `DATA_W`, `USER_W`, `ID_W`, `BASE_ADDRESS[]`, `BASE_ADDRESS_MASK[]`, `PIPELINE_IN`, `PIPELINE_OUT[]`, outstanding counts

## Ports (summary)

`Clock`, `Reset`, `In_M2S`/`In_S2M`, `Out_M2S[PORTS]`/`Out_S2M[PORTS]`

Full declarations: `src/bus/axi4/axi4_DeMux.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Single `Clock`/`Reset`. Write and read paths decode `AWAddr`/`ARAddr` against `BASE_ADDRESS[i]` with `BASE_ADDRESS_MASK[i]` (compare after masking don't-care bits). Overlapping hits select the **lowest** port index (`demux_lssb`). Unmapped addresses return decode-error responses. Optional `PIPELINE_IN`/`PIPELINE_OUT` insert FIFO glue. Write FSM supports AW-before-W and W-before-AW with at most one outstanding OoO Put per transaction; B/R IDs remapped through OoO buffers.

# Requirements

<a id="REQ-axi4_DeMux-001"></a>

## REQ-axi4_DeMux-001

The demultiplexer shall forward a write or read transaction to the lowest-index port whose base/mask match the address.

- Kind: extracted
- Verified by: axi4_DeMux_tb (overlap)

<a id="REQ-axi4_DeMux-002"></a>

## REQ-axi4_DeMux-002

When no port matches the address, the demultiplexer shall complete the transaction with a decode-error response on the manager interface.

- Kind: extracted
- Verified by: partial: DECERR exercised on Lite wrapper; full AXI4 DECERR not in TB

<a id="REQ-axi4_DeMux-003"></a>

## REQ-axi4_DeMux-003

Write channel shall accept AW-before-W and W-before-AW without losing the write beat or generating a duplicate B response for a single transaction.

- Kind: extracted
- Verified by: axi4_DeMux_tb

<a id="REQ-axi4_DeMux-004"></a>

## REQ-axi4_DeMux-004

BID/RID returned to the manager shall match the corresponding AWID/ARID of the issued transaction.

- Kind: extracted
- Verified by: axi4_DeMux_tb

<a id="REQ-axi4_DeMux-005"></a>

## REQ-axi4_DeMux-005

AR sideband fields (Cache, Prot, QoS, Region) shall be preserved on the selected subordinate port.

- Kind: extracted
- Verified by: axi4_DeMux_tb

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4/axi4_DeMux.sv`
