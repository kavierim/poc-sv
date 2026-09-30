# SysML v2 playbook

The structural model comes first. SystemVerilog in `src/` implements it. Observable SHALL text stays in `docs/modules/**/*.md` under **`# Requirements`** (one paragraph per `## REQ-*` heading). Requirement stubs live in `sysml/req/*.sysml` (`OKF: path#id` in `doc`, no SHALL sentence). Each implementing `part def` declares `satisfy requirement` usages for its stubs when the page has `REQ-*` ids.

Do not regenerate `sysml/parts/` from `src/`. Edit the part, then the docs, then the RTL.

## Order of change

1. Edit the `part def` in `sysml/parts/` (ports, parameters, directions).
2. Edit the module page: add or align `# Requirements`, Schema, and `model:` URI.
3. Add or update the matching stub in `sysml/req/` (`OKF: docs/modules/...#REQ-...` in `doc` only).
4. Add `satisfy requirement REQ_<...>;` on the `part def` when the page has that REQ.
5. Change `src/`, then `sim/` or `fv/`, so the RTL satisfies the model and the requirement.

`tools/check_sysml_ssot.py` reports divergence. It does not write files.

## Ownership

| Artifact | Role |
| --- | --- |
| `sysml/parts/**/*.sysml` | Structural contract. One `part def` per module, SystemVerilog name. |
| `docs/modules/**` | SHALL in `# Requirements`; Schema; human-readable notes |
| `sysml/req/*.sysml` | `REQ-*` stubs with `OKF:` doc pointers (fragments by domain) |
| `sysml/types/**` | Packed interface item defs (`axi4stream_m2s`, …). Struct fields live here, not flattened onto the part. |
| `src/**/*.sv` | Implementation of the part |
| `sysml/ArchitectureMeta.sysml`, `sysml/PoC.sysml` | Metadata and the library index |

## Identifiers

- Defining package is unique per module, `PoC_<Domain>_<module>` (for example `PoC_Bus_Axi4Stream_axi4stream_FIFO`).
- [`sysml/PoC.sysml`](../../sysml/PoC.sysml) re-exports those packages. Stable URI: `sysml://PoC::Bus_Axi4Stream::axi4stream_FIFO`.
- Requirement: `REQ-<MODULE>-<NNN>` on the module page. One observable SHALL per heading.
- `model:` in the page frontmatter is the URI above.

## Port syntax

Typed ports use `in item Name : Type` / `out item Name : Type` (for example `in item In_M2S : axi4stream_m2s;`). Scalar ports may omit the type. Integer and boolean parameter defaults are `Integer` and `Boolean`. Other defaults are `String` holding the SystemVerilog expression.

Do not flatten `m2s_t` / `s2m_t` fields onto the part. Those fields belong in `sysml/types/`.

Empty `fvPath` is allowed when there is no formal bind yet.

## Licencing

| Output | Header |
| --- | --- |
| `sysml/parts/**` | Apache-2.0 (same as RTL Covered Source) |
| `sysml/req/**`, `sysml/types/**`, `ArchitectureMeta.sysml`, `PoC.sysml`, `tools/check_sysml_ssot.py` | Kari ancillary only |

## Check

From `PoC_sv`:

```sh
uv run python tools/check_sysml_ssot.py
```
