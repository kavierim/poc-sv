---
type: Module
title: sync_Command
description: Command/handshake synchronizer between clock domains.
tags: [domain:sync, module:sync_Command]
status: draft
resource: src/sync/sync_Command.sv
model: sysml://PoC::Sync::sync_Command
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
# Purpose

Command/handshake synchronizer between clock domains.

# When to use

See the [domain index](index.md).

# Schema

## Parameters (summary)

See source file

## Ports (summary)

See source file

Full declarations: `src/sync/sync_Command.sv`. Naming rules: [`CONVENTIONS.md`](../../../CONVENTIONS.md).

# Behaviour

Req/ack style crossing for command words.

# Requirements

<a id="REQ-sync_Command-001"></a>

## REQ-sync_Command-001

A posted command shall be observed once in the destination domain when handshake completes.

- Kind: extracted
- Verified by: none

# Verification

Testbench matrix: [`verification.md`](../../playbooks/verification.md). From the repository root: `JOBS=1 SIM_TIMEOUT=180 ./verilator/run_all.sh`.

# Related

- Domain: [index.md](index.md)
- RTL: `src/sync/sync_Command.sv`
