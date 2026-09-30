# Module documentation template (internal)

Use this structure for every `type: Module` concept page. Concept ID = path without `.md`. Keep pages short: Purpose, Schema summary, Behaviour from RTL, Requirements with IDs.

```yaml
---
type: Module
title: <module_name>
description: <one line>
tags: [domain:<area>, module:<name>]
status: draft
resource: src/<domain>/<module>.sv
model: sysml://PoC::<Domain>::<module>   # optional; URI of the part def
provenance:
  upstream_path: github.com/VHDL/PoC
  pinned_tag: v3.0.0
  pinned_commit: b9040273
---
```

SHALL prose belongs in `# Requirements` only: anchor, `## REQ-<MODULE>-<NNN>`, one paragraph containing `shall`, then `- Kind:` and `- Verified by:`.

## Required sections

1. **# Purpose**
2. **# When to use**
3. **# Schema** (parameters and ports tables)
4. **# Behaviour**
5. **# Requirements** (required for translated entities: `REQ-<module>-NNN` with `shall` + `Verified by:`; mark `none` when no TB)
6. **# Assumptions** (optional)
7. **# Integration**
8. **# Examples**
9. **# Verification**
10. **# Agent notes**
11. **# Related**

Link using bundle-root paths under `docs/modules/` when that catalog exists.
