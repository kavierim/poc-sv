// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

module arith_cca #(
  parameter int BITS = 32,
  parameter int L    = 20,
  parameter int X    = 0
) (
  input  logic [BITS-1:0] a,
  input  logic [BITS-1:0] b,
  input  logic            c,
  output logic [BITS-1:0] s
);
  // Generic unsigned add (CCA compaction tree deferred; see wave-2 notes).
  assign s = a + b + {{(BITS - 1){1'b0}}, c};
  if (L == 0 && X == 0) begin end  // keep generics for API match
endmodule
