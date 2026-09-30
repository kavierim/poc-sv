---
type: Module
title: axi4stream_FIFO_TempGot
description: Stream FIFO with Out_Commit / Out_Rollback on the read side (TempGot).
tags: [domain:bus.axi4stream, module:axi4stream_FIFO_TempGot]
status: draft
resource: src/bus/axi4stream/axi4stream_FIFO_TempGot.sv
model: sysml://PoC::Bus_Axi4Stream::axi4stream_FIFO_TempGot
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Stream FIFO with Out_Commit / Out_Rollback on the read side (TempGot).

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

`FRAMES`, `MAX_PACKET_DEPTH`, stream widths, `METADATA_IS_DYNAMIC`

## Ports (summary)

`Clock`, `Reset`, In/Out stream, `Out_Commit`, `Out_Rollback`

Full declarations: `src/bus/axi4stream/axi4stream_FIFO_TempGot.sv`. Naming rules: [`CONVENTIONS.md`](../../../../CONVENTIONS.md).

# Behaviour

Buffers In→Out like a stream FIFO. `Out_Rollback` restores the read pointer to the last commit; `Out_Commit` advances the committed read cursor. Uses `fifo_cc_got_tempgot` internally.

# Requirements

<a id="REQ-axi4stream_FIFO_TempGot-001"></a>

## REQ-axi4stream_FIFO_TempGot-001

After Commit, previously accepted Out beats shall not reappear; Rollback shall restore uncommitted beats.

- Kind: extracted
- Verified by: axi4stream_FIFO_TempGot_tb

# Verification

Testbench matrix: [`verification.md`](../../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/bus/axi4stream/axi4stream_FIFO_TempGot.sv`
