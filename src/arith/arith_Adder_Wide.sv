// SPDX-FileCopyrightText: 2007-2015 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

module arith_Adder_Wide
  import poc_arith::*;
  import poc_utils::*;
#(
  parameter int                         BITS        = 32,
  parameter int                         BLOCKS      = 4,
  parameter t_adder_architecture_e      ARCH        = AAM,
  parameter t_adder_blocking_scheme_e     BLOCKING    = DFLT,
  parameter t_adder_carry_skip_scheme_e   SKIPPING    = CCC,
  parameter bit                         P_INCLUSIVE = 1'b0
) (
  input  logic [BITS-1:0] A,
  input  logic [BITS-1:0] B,
  input  logic            CarryIn,
  output logic [BITS-1:0] Sum,
  output logic            CarryOut
);
  logic [BITS:0] full_sum;
  assign full_sum = A + B + {{(BITS - 1){1'b0}}, CarryIn};
  if (BLOCKS < 1) begin end
  if (ARCH == AAM && BLOCKING == DFLT && SKIPPING == CCC && !P_INCLUSIVE) begin end
  assign Sum      = full_sum[BITS-1:0];
  assign CarryOut = full_sum[BITS];
endmodule
