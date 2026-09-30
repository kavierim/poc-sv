# Stream interfaces (AXI4-Stream)

PoC stream modules use packed `m2s_t` / `s2m_t` records from [`poc_axi4stream.sv`](../../src/bus/axi4stream/poc_axi4stream.sv). SysML mirrors those fields in `sysml/types/axi4stream.sysml` (`axi4stream_m2s`, `axi4stream_s2m`). Parts keep typed ports such as `in item In_M2S : axi4stream_m2s;` — fields are not flattened onto the part.

## `m2s_t` fields (RTL / SysML)

| Field | Role |
| --- | --- |
| `Valid` | Beat present (handshake with Ready) |
| `Data` | Payload |
| `Keep` | Byte enables |
| `Last` | End of packet |
| `User` | Sideband |
| `Dest` | Routing |
| `ID` | Stream identifier |

`s2m_t` carries `Ready` (and reverse `User` when used).

## Python behavioral models

The shared kernel uses lowercase AXI-Stream beat fields: `tdata`, `tkeep`, `tlast`, `tid`, `tdest`, `tuser`. Channel `Valid`/`Ready` is the handshake. See [model playbook](model.md).

## Related

- [axi4stream modules](../modules/bus/axi4stream/index.md)
- [SysML playbook](sysml.md)
