// SPDX-FileCopyrightText: 2007-2015 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

module arith_FirstOne #(
  parameter int BITS = 8
) (
  input  logic                  TokenIn,
  input  logic [BITS-1:0]       Request,
  output logic [BITS-1:0]       Grant,
  output logic                  TokenOut,
  output logic [($clog2(BITS) > 0 ? $clog2(BITS) : 1)-1:0] Index
);
  import poc_utils::*;

  localparam int IDX_W = ($clog2(BITS) > 0) ? $clog2(BITS) : 1;

  logic [BITS-1:0]  onehot;
  logic [IDX_W-1:0] binary;
  logic [BITS:0] adder;

  always_comb begin
    adder  = {1'b0, ~Request} + {{BITS{1'b0}}, TokenIn};
    onehot = adder[BITS-1:0] & Request;
    binary = '0;
    for (int i = 0; i < BITS; i++)
      if (onehot[i])
        binary = binary | i[IDX_W-1:0];
    TokenOut = adder[BITS];
    Grant    = onehot;
    Index    = binary;
  end
endmodule
