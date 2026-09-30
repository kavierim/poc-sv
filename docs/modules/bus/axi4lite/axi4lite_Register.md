---
type: Module
title: axi4lite_Register
description: Configurable AXI4-Lite register file with user RW ports and optional IRQ.
tags: [domain:bus.axi4lite, module:axi4lite_Register]
status: draft
resource: src/bus/axi4lite/axi4lite_Register.sv
model: sysml://PoC::Bus_Axi4Lite::axi4lite_Register
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Configurable AXI4-Lite register file with user RW ports and optional IRQ.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`N_USER_CFG`, interrupt params, `RESPONSE_ON_ERROR`, `SIM_READWRITE_CFG`, …

## Ports (summary)

`Clock`, `Reset`, Lite bus, irq, register file ports

Full declarations: `src/bus/axi4lite/axi4lite_Register.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Decodes addresses against a register descriptor (sim helper config when `SIM_READWRITE_CFG`). Returns OKAY on hits and `RESPONSE_ON_ERROR` (default DECERR) on misses. Exposes ReadPort/WritePort/hit/strobe for user logic. Port notes 32-bit DATA_W focus.

# Requirements

<a id="REQ-axi4lite_Register-001"></a>

## REQ-axi4lite_Register-001

A write/read to a configured RW register shall return OKAY and retain written data on readback.

- Kind: extracted
- Verified by: axi4lite_Register_tb

<a id="REQ-axi4lite_Register-002"></a>

## REQ-axi4lite_Register-002

Accesses to illegal/unconfigured addresses shall return RESPONSE_ON_ERROR (DECERR in default sim cfg).

- Kind: extracted
- Verified by: axi4lite_Register_tb

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4lite/axi4lite_Register.sv`
