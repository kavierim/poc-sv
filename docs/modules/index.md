# Modules

Each translated entity has a page with **Purpose**, **Behaviour**, and **Requirements** (`REQ-<module>-NNN`).
Open a domain index, then the module you need. Upstream pin: PoC v3.0.0 (`b9040273`).

| Domain | Index |
| --- | --- |
| AXI4 | [bus/axi4](bus/axi4/index.md) |
| AXI4-Lite | [bus/axi4lite](bus/axi4lite/index.md) |
| AXI4-Stream | [bus/axi4stream](bus/axi4stream/index.md) |
| Bus shared | [bus](bus/index.md) |
| FIFO | [fifo](fifo/index.md) |
| Sync | [sync](sync/index.md) |
| Arith | [arith](arith/index.md) |
| OCRAM | [mem/ocram](mem/ocram/index.md) |
| Dstruct | [dstruct](dstruct/index.md) |

Packages (`poc_*`, `common/*`, domain package files) are type/helper libraries — see [`CONVENTIONS.md`](../../CONVENTIONS.md).
Repo-wide gaps (untranslated UART/stream/drp, formal `fv/`, Verilator lint ICE): [`docs/index.md`](../index.md).

66 entity pages. TB mapping: each REQ **Verified by:** field and [verification.md](../playbooks/verification.md).
