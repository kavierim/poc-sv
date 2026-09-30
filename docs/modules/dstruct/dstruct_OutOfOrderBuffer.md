---
type: Module
title: dstruct_OutOfOrderBuffer
description: Buffer storing words by index for out-of-order completion (AXI ID remap).
tags: [domain:dstruct, module:dstruct_OutOfOrderBuffer]
status: draft
resource: src/dstruct/dstruct_OutOfOrderBuffer.sv
model: sysml://PoC::Dstruct::dstruct_OutOfOrderBuffer
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Buffer storing words by index for out-of-order completion (AXI ID remap).

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`DATA_BITS`, `NUM_INDEX`

## Ports (summary)

`Clock`, `Reset`, Put/DataIn/Full/IndexOut, Got/IndexIn/DataOut/Valid

Full declarations: `src/dstruct/dstruct_OutOfOrderBuffer.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Put allocates IndexOut; Got with IndexIn returns DataOut when Valid.

# Requirements

<a id="REQ-dstruct_OutOfOrderBuffer-001"></a>

## REQ-dstruct_OutOfOrderBuffer-001

Data Put at an index shall be returned when Got with that index while Valid.

- Kind: extracted
- Verified by: indirect via axi4_DeMux/Mux

<a id="REQ-dstruct_OutOfOrderBuffer-002"></a>

## REQ-dstruct_OutOfOrderBuffer-002

Full shall assert when no free indices remain.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/dstruct/dstruct_OutOfOrderBuffer.sv`
