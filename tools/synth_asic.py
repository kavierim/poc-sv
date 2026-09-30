#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
# SPDX-License-Identifier: Apache-2.0
# Ancillary. RTL is Apache-2.0; see NOTICE.

"""ASIC smoke synthesis for every RTL module under src/.

For each `module` declaration in `src/**/*.sv`, run Yosys with slang:

  read_slang -I src --std 1800-2017 <src tree>
  hierarchy -top <name>
  synth -top <name>
  stat

Package-only files (no module) are skipped. Named entries in SKIP_MODULES are
reported as SKIP (not silent omit). Exit 0 when every non-skipped module
PASSes and every SKIP_MODULES entry was found; any FAIL or missing skip
entry yields exit 1. Requires `yosys` on PATH (oss-cad-suite `environment`
sourced).

Run from the repository root:

    python3 tools/synth_asic.py
"""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"

MODULE_RE = re.compile(r"^\s*module\s+(\w+)", re.MULTILINE)
ERROR_RE = re.compile(r"(?i)(error[:\s].+|ERROR:.*)")

# Combinational-loop entropy source; ABC cannot map it without changing purpose.
# Not instantiated by any other synthesizable module in this tree.
SKIP_MODULES = {
    "arith_TRNG": "combinational-loop TRNG; ABC rejects loops (see docs/playbooks/asic-synth.md)",
}


def find_modules() -> list[tuple[str, Path]]:
    found: list[tuple[str, Path]] = []
    for path in sorted(SRC.rglob("*.sv")):
        text = path.read_text(encoding="utf-8", errors="replace")
        for match in MODULE_RE.finditer(text):
            found.append((match.group(1), path.relative_to(ROOT)))
    return found


def src_files() -> list[str]:
    return [str(p.relative_to(ROOT)).replace("\\", "/") for p in sorted(SRC.rglob("*.sv"))]


def first_error(log: str) -> str:
    for line in log.splitlines():
        if ERROR_RE.search(line) or line.startswith("ERROR"):
            return line.strip()
    for line in log.splitlines():
        stripped = line.strip()
        if stripped:
            return stripped
    return "(no error text captured)"


def synth_module(name: str, files: list[str]) -> tuple[bool, str]:
    file_args = " ".join(files)
    script = (
        f"read_slang -I src --std 1800-2017 -D SYNTHESIS --top {name} {file_args}; "
        f"hierarchy -top {name}; "
        f"synth -top {name}; "
        f"stat"
    )
    proc = subprocess.run(
        ["yosys", "-q", "-p", script],
        cwd=ROOT,
        capture_output=True,
        text=True,
    )
    log = (proc.stdout or "") + (proc.stderr or "")
    return proc.returncode == 0, log


def main() -> int:
    modules = find_modules()
    if not modules:
        print("FAIL: no modules found under src/", file=sys.stderr)
        return 1

    files = src_files()
    passed = 0
    failed = 0
    seen_skips: set[str] = set()

    print(f"ASIC synth: {len(modules)} module(s), {len(files)} source file(s)")
    for name, rel in modules:
        if name in SKIP_MODULES:
            seen_skips.add(name)
            print(f"SKIP  {name}  ({rel})")
            print(f"      {SKIP_MODULES[name]}")
            continue
        ok, log = synth_module(name, files)
        if ok:
            passed += 1
            print(f"PASS  {name}  ({rel})")
        else:
            failed += 1
            err = first_error(log)
            print(f"FAIL  {name}  ({rel})")
            print(f"      {err}")

    missing_skips = sorted(set(SKIP_MODULES) - seen_skips)
    if missing_skips:
        print(
            "FAIL  SKIP_MODULES entry not found under src/: "
            + ", ".join(missing_skips)
        )

    skipped = len(seen_skips)
    print(
        f"Summary: {passed} passed, {failed} failed, {skipped} skipped, "
        f"{passed + failed + skipped} total"
    )
    return 0 if failed == 0 and not missing_skips else 1


if __name__ == "__main__":
    sys.exit(main())
