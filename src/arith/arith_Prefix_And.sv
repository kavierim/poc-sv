// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

/* verilator lint_off UNUSEDSIGNAL */

module arith_Prefix_And #(
  parameter int BITS = 8
) (
  input  logic [BITS-1:0] x,
  output logic [BITS-1:0] y
);
  import poc_utils::*;

  if (BITS == 1) begin : g0
    assign y = x;
  end else begin : g1
    logic [BITS-1:1] p;
    logic [BITS:0]   s;

    assign y[0] = x[0];
    assign p[1] = x[0] & x[1];
    assign y[1] = p[1];
    if (BITS > 2) begin : g2
      assign p[BITS-1:2] = x[BITS-1:2];
      assign s           = (BITS+1)'({1'b0, p} + 1'b1);
      assign y[BITS-1:2] = s[BITS:3] ^ {1'b0, x[BITS-1:3]};
    end
  end
endmodule

/* verilator lint_on UNUSEDSIGNAL */
