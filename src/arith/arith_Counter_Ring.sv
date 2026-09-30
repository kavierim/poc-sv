// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

module arith_Counter_Ring #(
  parameter int  BITS            = 8,
  parameter bit  INVERT_FEEDBACK = 1'b0
) (
  input  logic             Clock,
  input  logic             Reset,
  input  logic [BITS-1:0] Seed,
  input  logic             Increment,
  input  logic             Decrement,
  output logic [BITS-1:0]  Value
);
  import poc_utils::*;

  logic invert;
  logic [BITS-1:0] Counter;

  assign invert = to_sl_b(INVERT_FEEDBACK);

  always_ff @(posedge Clock) begin
    if (Reset)
      Counter <= Seed;
    else if (Increment)
      Counter <= {Counter[BITS-2:0], Counter[BITS-1] ^ invert};
    else if (Decrement)
      Counter <= {Counter[0] ^ invert, Counter[BITS-1:1]};
  end

  assign Value = Counter;
endmodule
