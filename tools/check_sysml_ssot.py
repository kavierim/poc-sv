#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
# SPDX-License-Identifier: Apache-2.0
# Ancillary. RTL is Apache-2.0; see NOTICE.

"""Verify the PoC SysML model, requirement stubs, and RTL stay aligned.

The model is edited first. This checker reports divergence; it does not write files.

Run from PoC_sv:

    uv run python tools/check_sysml_ssot.py
    uv run python tools/check_sysml_ssot.py --module axi4stream_FIFO
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DOCS = ROOT / "docs" / "modules"
PARTS = ROOT / "sysml" / "parts"
TYPES = ROOT / "sysml" / "types"
REQ_DIR = ROOT / "sysml" / "req"

REQ_ID = r"REQ-[A-Za-z0-9_]+-\d+"
REQ_HEADING = re.compile(rf"^##\s+({REQ_ID})\s*$", re.MULTILINE)
REQ_ANCHOR = re.compile(rf'<a id="({REQ_ID})"></a>')
STUB_REQ = re.compile(rf"requirement def <'({REQ_ID})'>")
STUB_OKF_DOC = re.compile(
    rf"requirement def <'({REQ_ID})'> (\w+) \{{[^}}]*doc /\* OKF: ([^#]+)#({REQ_ID}) \*/",
    re.DOTALL,
)
PART_DEF = re.compile(r"part def (\w+)")
IN_ITEM = re.compile(r"^\s*(in|out|inout) item (\w+)(?:\s*:\s*(\w+))?;", re.MULTILINE)
ITEM_DEF = re.compile(r"\bitem def (\w+)")
SATISFY_REQ = re.compile(r"satisfy\s+requirement\s+(REQ_[A-Za-z0-9_]+)\s*;")
SHALL_IN_STUB = re.compile(r"\bshall\b", re.IGNORECASE)
APACHE_SPDX = re.compile(r"SPDX-License-Identifier:\s*Apache-2\.0")
CERN_SPDX = re.compile(r"SPDX-License-Identifier:\s*CERN-OHL-W")
RTL_PATH = re.compile(r'rtlPath\s*=\s*"([^"]+)"')


@dataclass
class Param:
    name: str
    sysml_type: str
    default: str | None
    sv_expr: bool = False


@dataclass
class Port:
    name: str
    direction: str  # in | out | inout
    sv_decl: str


@dataclass
class ModuleHeader:
    name: str
    params: list[Param] = field(default_factory=list)
    ports: list[Port] = field(default_factory=list)


@dataclass
class SysmlPort:
    name: str
    direction: str
    type_name: str | None


def strip_sv_comments(text: str) -> str:
    out: list[str] = []
    i = 0
    n = len(text)
    while i < n:
        if text.startswith("//", i):
            i = text.find("\n", i)
            if i < 0:
                break
            continue
        if text.startswith("/*", i):
            end = text.find("*/", i + 2)
            if end < 0:
                break
            i = end + 2
            continue
        out.append(text[i])
        i += 1
    return "".join(out)


def find_balanced(text: str, start: int, open_ch: str, close_ch: str) -> int:
    if start >= len(text) or text[start] != open_ch:
        raise ValueError(f"expected {open_ch} at {start}")
    depth = 0
    i = start
    while i < len(text):
        ch = text[i]
        if ch == open_ch:
            depth += 1
        elif ch == close_ch:
            depth -= 1
            if depth == 0:
                return i
        i += 1
    raise ValueError(f"unbalanced {open_ch} from {start}")


def split_top_level(text: str) -> list[str]:
    parts: list[str] = []
    buf: list[str] = []
    depth = 0
    for ch in text:
        if ch in "([{":
            depth += 1
        elif ch in ")]}":
            depth -= 1
        if ch == "," and depth == 0:
            piece = "".join(buf).strip()
            if piece:
                parts.append(piece)
            buf = []
            continue
        buf.append(ch)
    tail = "".join(buf).strip()
    if tail:
        parts.append(tail)
    return parts


def classify_default(expr: str) -> tuple[str, bool]:
    expr = expr.strip()
    if re.fullmatch(r"-?\d+", expr):
        return "Integer", False
    if re.fullmatch(r"1'[bB][01]", expr) or expr in ("1'b0", "1'b1"):
        return "Boolean", False
    if re.fullmatch(r"1'[bB][01]+", expr):
        return "String", True
    return "String", True


def parse_parameter(chunk: str) -> Param | None:
    chunk = chunk.strip()
    if not chunk or chunk.startswith("localparam"):
        return None
    if not chunk.startswith("parameter"):
        return None
    rest = chunk[len("parameter") :].strip()
    if rest.startswith("type "):
        m = re.match(r"type\s+(\w+)\s*=\s*(.+)$", rest, re.DOTALL)
        if m:
            return Param(m.group(1), "String", m.group(2).strip(), True)
        return None
    eq = rest.find("=")
    head = rest[:eq].strip() if eq >= 0 else rest.strip()
    default = rest[eq + 1 :].strip() if eq >= 0 else None
    tokens = head.split()
    if not tokens:
        return None
    name = tokens[-1]
    type_blob = " ".join(tokens[:-1])
    if "type" in type_blob.split():
        return Param(name, "String", default or "", True)
    if re.search(r"\btime\b", type_blob):
        return Param(name, "String", default or "", True)
    if re.search(r"\bstring\b", type_blob):
        return Param(name, "String", default or '""', True)
    if re.search(r"\bint\b", type_blob):
        if default:
            st, sv = classify_default(default)
            return Param(name, st, default, sv)
        return Param(name, "Integer", None, False)
    if re.search(r"\bbit\b", type_blob):
        if default:
            st, sv = classify_default(default)
            return Param(name, st, default, sv)
        return Param(name, "Boolean", None, False)
    if default:
        st, sv = classify_default(default)
        return Param(name, st, default, sv)
    return Param(name, "String", None, True)


def parse_port(chunk: str) -> Port | None:
    chunk = re.sub(r"\s+", " ", chunk.strip())
    m = re.match(r"(input|output|inout)\s+(.+)$", chunk, re.IGNORECASE)
    if not m:
        return None
    raw = m.group(1).lower()
    direction = {"input": "in", "output": "out", "inout": "inout"}[raw]
    decl = m.group(2).strip().rstrip(",")
    # Name may be followed by unpacked dimensions: Out_M2S[PORTS], Value [DIGITS].
    name_m = re.search(r"(\w+)(?:\s*\[[^\]]*\])*\s*$", decl)
    if not name_m:
        return None
    return Port(name_m.group(1), direction, decl)


def parse_module_header(text: str, path: Path) -> ModuleHeader | None:
    clean = strip_sv_comments(text)
    m = re.search(r"\bmodule\s+(\w+)", clean)
    if not m:
        return None
    name = m.group(1)
    pos = m.end()

    def skip_ws_and_imports(p: int) -> int:
        """Skip whitespace and package import statements after the module name."""
        while p < len(clean):
            while p < len(clean) and clean[p].isspace():
                p += 1
            if clean.startswith("import", p):
                semi = clean.find(";", p)
                if semi < 0:
                    raise ValueError(f"{path}: malformed import after module {name}")
                p = semi + 1
                continue
            break
        return p

    pos = skip_ws_and_imports(pos)
    param_text = ""
    if pos < len(clean) and clean[pos] == "#":
        open_paren = clean.find("(", pos)
        if open_paren < 0:
            raise ValueError(f"{path}: malformed parameter list")
        close_paren = find_balanced(clean, open_paren, "(", ")")
        param_text = clean[open_paren + 1 : close_paren]
        pos = close_paren + 1
        pos = skip_ws_and_imports(pos)
    pos = skip_ws_and_imports(pos)
    if pos >= len(clean) or clean[pos] != "(":
        raise ValueError(f"{path}: expected port list after module {name}")
    port_close = find_balanced(clean, pos, "(", ")")
    port_text = clean[pos + 1 : port_close]

    params: list[Param] = []
    for piece in split_top_level(param_text):
        p = parse_parameter(piece)
        if p:
            params.append(p)

    ports: list[Port] = []
    for piece in split_top_level(port_text):
        p = parse_port(piece)
        if p:
            ports.append(p)

    return ModuleHeader(name, params, ports)


def rtl_port_names(sv_path: Path, module: str) -> set[str]:
    text = sv_path.read_text(encoding="utf-8")
    header = parse_module_header(text, sv_path)
    if header is None or header.name != module:
        return set()
    return {p.name for p in header.ports}


def req_id_to_satisfy(req_id: str) -> str:
    """REQ-FOO-001 / REQ-axi4_FIFO-001 -> REQ_FOO_001 / REQ_axi4_FIFO_001."""
    return req_id.replace("-", "_")


def parse_sysml_ports(content: str) -> list[SysmlPort]:
    return [
        SysmlPort(name=m.group(2), direction=m.group(1), type_name=m.group(3))
        for m in IN_ITEM.finditer(content)
    ]


def collect_item_defs() -> set[str]:
    names: set[str] = set()
    if not TYPES.is_dir():
        return names
    for path in TYPES.rglob("*.sysml"):
        text = path.read_text(encoding="utf-8")
        names.update(m.group(1) for m in ITEM_DEF.finditer(text))
    return names


def resolve_rtl_path(content: str, module: str, part_rel: str, errors: list[str]) -> Path | None:
    m = RTL_PATH.search(content)
    if m:
        rel = m.group(1).replace("\\", "/")
        sv_path = ROOT / rel
        if not sv_path.is_file():
            errors.append(f"{part_rel}: ArtifactTrace rtlPath missing file {rel}")
            return None
        return sv_path
    candidates = list(SRC.rglob(f"{module}.sv"))
    if not candidates:
        errors.append(f"{part_rel}: no RTL module {module}.sv under src/")
        return None
    if len(candidates) > 1:
        errors.append(
            f"{part_rel}: multiple RTL candidates for {module}.sv; add @ArtifactTrace rtlPath"
        )
        return None
    return candidates[0]


def load_req_stubs(errors: list[str]) -> tuple[set[str], dict[str, str]]:
    """Return stub ids and map satisfy-name -> REQ id."""
    stub_ids: set[str] = set()
    satisfy_to_id: dict[str, str] = {}
    if not REQ_DIR.is_dir():
        return stub_ids, satisfy_to_id

    for req_path in sorted(REQ_DIR.rglob("*.sysml")):
        rel = req_path.relative_to(ROOT).as_posix()
        text = req_path.read_text(encoding="utf-8")
        if CERN_SPDX.search(text):
            errors.append(f"{rel}: requirement stubs must not carry CERN-OHL-W SPDX")
        if not APACHE_SPDX.search(text):
            errors.append(f"{rel}: missing SPDX-License-Identifier: Apache-2.0")

        for match in re.finditer(
            rf"requirement def <'{REQ_ID}'>\s+\w+\s*\{{[^}}]*\}}", text, re.DOTALL
        ):
            if SHALL_IN_STUB.search(match.group(0)):
                errors.append(f"{rel}: requirement stub contains SHALL text in body")

        for m in STUB_REQ.finditer(text):
            rid = m.group(1)
            stub_ids.add(rid)
            satisfy_to_id[req_id_to_satisfy(rid)] = rid

        for m in STUB_OKF_DOC.finditer(text):
            rid, short, doc_path, anchor = m.group(1), m.group(2), m.group(3), m.group(4)
            expected_short = req_id_to_satisfy(rid)
            if rid != anchor:
                errors.append(f"{rel}: stub {rid} OKF anchor mismatch {anchor}")
            if short != expected_short:
                errors.append(f"{rel}: stub {rid} short name {short} != {expected_short}")
            doc_file = ROOT / doc_path
            if not doc_file.is_file():
                errors.append(f"{rel}: stub {rid} OKF doc missing {doc_path}")
                continue
            doc_text = doc_file.read_text(encoding="utf-8")
            headings = {h.group(1) for h in REQ_HEADING.finditer(doc_text)}
            anchors = {a.group(1) for a in REQ_ANCHOR.finditer(doc_text)}
            if rid not in headings:
                errors.append(f"{rel}: stub {rid} missing ## heading in {doc_path}")
            if rid not in anchors:
                errors.append(f"{rel}: stub {rid} missing markdown anchor in {doc_path}")

        for rid in STUB_REQ.findall(text):
            if not any(m.group(1) == rid for m in STUB_OKF_DOC.finditer(text)):
                errors.append(f"{rel}: stub {rid} missing OKF: docs/modules/...#REQ-... doc")

    return stub_ids, satisfy_to_id


def main() -> int:
    ap = argparse.ArgumentParser(description="Check PoC SysML single-source alignment (read-only).")
    ap.add_argument("--module", help="Only check parts/stubs for this module stem")
    args = ap.parse_args()

    part_files = sorted(PARTS.rglob("*.sysml")) if PARTS.is_dir() else []
    if not part_files:
        print("check_sysml_ssot: nothing to check yet (sysml/parts is empty)")
        return 0

    errors: list[str] = []
    item_defs = collect_item_defs()
    stub_ids, satisfy_to_id = load_req_stubs(errors)

    if args.module:
        part_files = [p for p in part_files if p.stem == args.module]
        if not part_files:
            errors.append(f"--module {args.module}: no matching part under sysml/parts/")

    for part_path in part_files:
        rel = part_path.relative_to(ROOT).as_posix()
        content = part_path.read_text(encoding="utf-8")
        if CERN_SPDX.search(content):
            errors.append(f"{rel}: Covered Source parts must not carry CERN-OHL-W SPDX")
        if not APACHE_SPDX.search(content):
            errors.append(f"{rel}: missing SPDX-License-Identifier: Apache-2.0")

        m = PART_DEF.search(content)
        if not m:
            errors.append(f"{rel}: no part def")
            continue
        module = m.group(1)
        if module != part_path.stem:
            errors.append(f"{rel}: part def {module} != filename stem")

        sysml_ports = parse_sysml_ports(content)
        sysml_names = {p.name for p in sysml_ports}
        for port in sysml_ports:
            if port.type_name is not None and port.type_name not in item_defs:
                errors.append(
                    f"{rel}: port {port.name} type {port.type_name} has no item def under sysml/types/"
                )

        sv_path = resolve_rtl_path(content, module, rel, errors)
        if sv_path is None:
            continue
        rtl = rtl_port_names(sv_path, module)
        if not rtl and sv_path.is_file():
            errors.append(f"{rel}: could not parse module {module} ports from {sv_path.relative_to(ROOT).as_posix()}")
            continue
        if sysml_names != rtl:
            missing = rtl - sysml_names
            extra = sysml_names - rtl
            errors.append(
                f"{rel}: RTL ports differ from the model; edit the model first, then RTL. "
                f"missing_in_rtl={sorted(extra)} missing_in_model={sorted(missing)}"
            )

        for short in SATISFY_REQ.findall(content):
            if short not in satisfy_to_id:
                errors.append(
                    f"{rel}: satisfy {short} has no matching requirement stub "
                    f"(hyphens vs underscores: REQ-FOO-001 <-> REQ_FOO_001)"
                )

    if errors:
        for err in errors:
            print(err, file=sys.stderr)
        print(f"check failed ({len(errors)} errors)", file=sys.stderr)
        return 1

    scope = args.module or "all"
    print(f"check_sysml_ssot: ok ({scope})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
