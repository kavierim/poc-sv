// SPDX-FileCopyrightText: 2007-2015 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

module arith_Same #(
  parameter int BITS = 8
) (
  input  logic            g,
  input  logic [BITS-1:0] x,
  output logic            y
);
  import poc_utils::*;

  localparam int K = 4;
  localparam int M = (BITS - 2 + 1 / BITS) / (K - 1) + 1;

  logic [M-1:0] p;
  logic [M:0]   s;

  for (genvar i = 0; i < M; i++) begin : genCC
    localparam int LO = i * (K - 1);
    localparam int HI = imin(BITS - 1, (i + 1) * (K - 1));
    always_comb begin
      if (x[HI:LO] == '0)
        p[i] = 1'b1;
      else if (x[HI:LO] == {HI - LO + 1{1'b1}})
        p[i] = 1'b1;
      else
        p[i] = 1'b0;
    end
  end

  assign s = {1'b0, p} + {{(M - 1){1'b0}}, g};
  assign y = s[M];
endmodule
