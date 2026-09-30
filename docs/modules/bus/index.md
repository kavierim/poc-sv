# Bus modules

AXI interconnect and helpers under `src/bus/`. Naming: [CONVENTIONS.md](../../../CONVENTIONS.md). Run tests: [getting-started](../../playbooks/getting-started.md), [verification](../../playbooks/verification.md).

| Area | Index | Highlights |
| --- | --- | --- |
| AXI4 full | [axi4/](axi4/index.md) | DeMux, Mux, FIFO, FIFO_CDC, Lite converter, sink/terminations |
| AXI4-Lite | [axi4lite/](axi4lite/index.md) | DeMux, FIFO, FIFO_CDC, Register, OCRAM adapter, terminations |
| AXI4-Stream | [axi4stream/](axi4stream/index.md) | Mux/DeMux, FIFO/CDC, TempGot/Put, Stage, Pause, terminations |
| Shared | [bus_Arbiter](bus_Arbiter.md) | Used by AXI muxes |

Untranslated peripherals and buses are listed once under [docs/index.md](../index.md) (Known limits). Catalog: [modules](../index.md).
