# Behavioral model playbook

Python models under `model/` exercise stream composition before RTL changes. The shared kernel (`model/kernel/`) is ancillary Apache-2.0 text, identical in spirit to `colibri_sv/model/kernel/`. Behavioral blocks in `poc_model/` are Apache-2.0.

This library and `colibri_sv/model` do **not** import each other. Cross-repo checks add the sibling path only in a test (see Colibri `model/tests/test_compat_poc.py`).

## Cycle model

- One `System.run(n)` advances `n` cycles.
- A beat moves when the source has data and the destination is ready; at most one beat is accepted on a channel per cycle.
- Channels count beats, bytes (`tkeep` or AVST `empty`), and cycles. Optional `clk_hz` yields bits per second on the report.

## Stream beats

| Kind | Beat type | Payload fields |
| --- | --- | --- |
| AXI-Stream (`axis`) | `StreamBeat` | `tdata`, `tkeep`, `tlast`, `tid`, `tdest`, `tuser` |
| Avalon-ST (`avst`) | `AvstBeat` | `data`, `empty`, `sop`, `eop` |

`Valid`/`Ready` is the channel handshake, not a beat field.

## Connect rules

`System.connect` rejects width or kind mismatches (`data_width`, `keep_width`, `id_width`, `dest_width`, `user_width`, and `kind`). AVST meets AXIS only through Colibri adapters `avst_to_axis` / `axis_to_avst` when composing across libraries; PoC models stay on AXI-Stream.

## Runnable PoC blocks

| Module | Class |
| --- | --- |
| [`axi4stream_FIFO`](../modules/bus/axi4stream/axi4stream_FIFO.md) | `poc_model.axi4stream_FIFO.axi4stream_FIFO` |
| [`axi4stream_Mux`](../modules/bus/axi4stream/axi4stream_Mux.md) | `poc_model.axi4stream_Mux.axi4stream_Mux` |

## Licences

| Tree | Licence |
| --- | --- |
| `model/poc_model/**` | Apache-2.0 |
| `model/kernel/**` | Ancillary Apache-2.0 (shared text with Colibri) |
| `model/tests/**` | Ancillary Apache-2.0 |

## Check

```sh
cd model
uv run pytest
```
