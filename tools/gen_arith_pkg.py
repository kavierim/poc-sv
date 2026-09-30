#!/usr/bin/env python3
"""Generate src/arith/arith.sv (poc_arith) from upstream arith.pkg.vhdl tap table."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
UPSTREAM = ROOT.parent / "PoC" / "src" / "arith" / "arith.pkg.vhdl"
OUT = ROOT / "src" / "arith" / "arith.sv"

HEADER = """// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

"""


def parse_taps(vhdl: str) -> list[tuple[int, list[int]]]:
    m = re.search(r"constant C_TAPPOSITION_LIST.*:= \((.*?)\);", vhdl, re.S)
    if not m:
        raise SystemExit("tap table not found")
    entries: list[tuple[int, list[int]]] = []
    for line in m.group(1).splitlines():
        line = line.strip().rstrip(",")
        if not line:
            continue
        mm = re.match(r"(\d+)\s*=>\s*\((.*)\)", line)
        if not mm:
            continue
        w = int(mm.group(1))
        taps = [0, 0, 0, 0, 0]
        for part in re.split(r",\s*", mm.group(2)):
            part = part.strip()
            if part.startswith("others"):
                break
            kv = re.match(r"(\d+)\s*=>\s*(\d+)", part)
            if kv:
                taps[int(kv.group(1))] = int(kv.group(2))
        entries.append((w, taps))
    return entries


def main() -> None:
    vhdl = UPSTREAM.read_text(encoding="utf-8")
    entries = parse_taps(vhdl)
    case_lines = [
        f"      {w}: taps = '{{{t[0]}, {t[1]}, {t[2]}, {t[3]}, {t[4]}}};"
        for w, t in entries
    ]
    body = f"""package poc_arith;
  import poc_utils::*;

  typedef enum logic [1:0] {{
    AAM,
    CAI,
    CCA,
    PAI
  }} t_adder_architecture_e;

  typedef enum logic [1:0] {{
    DFLT,
    FIX,
    ASC,
    DESC
  }} t_adder_blocking_scheme_e;

  typedef enum logic [1:0] {{
    PLAIN,
    CCC,
    PPN_KS,
    PPN_BK
  }} t_adder_carry_skip_scheme_e;

  function automatic int arith_DividerLatency(input int dividendBits, input int radixExponent);
    return (dividendBits + radixExponent - 1) / radixExponent;
  endfunction

  function automatic logic [167:0] arith_prbs_lfsr(input logic [167:0] value, int width);
    int taps[5];
    logic temp;
    case (width)
{chr(10).join(case_lines)}
      default: begin
        $fatal(1, "arith_prbs_lfsr: width %0d not yet supported (3..168)", width);
        taps = '{{default: 0}};
      end
    endcase
    temp = value[width - 1];
    for (int i = 0; i < 5; i++) begin
      if (taps[i] > 0)
        temp = temp ~^ value[taps[i] - 1];
    end
    value[width - 1] = temp;
    for (int k = width; k < 168; k++)
      value[k] = 1'b0;
    return value;
  endfunction

endpackage
"""
    OUT.write_text(HEADER + body, newline="\n")
    print(f"wrote {OUT} ({len(entries)} tap widths)")


if __name__ == "__main__":
    main()
