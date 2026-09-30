// SPDX-FileCopyrightText: 2007-2017 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

module arith_TRNG #(
  parameter int BITS = 8
) (
  input  logic             Clock,
  output logic [BITS-1:0] Value
);
  import poc_utils::*;

  /* verilator lint_off UNOPTFLAT */
  logic [BITS-1:0] osc;

  for (genvar i = 0; i < BITS; i++) begin : genOscillate
    assign osc[i] = (i < 3 ? 1'b1 : 1'b0) ^ osc[(i - 1 + BITS) % BITS] ^ osc[i] ^ osc[(i + 1) % BITS];
  end
  /* verilator lint_on UNOPTFLAT */

  sync_Bits #(
    .BITS(BITS)
  ) sync (
    .Clock (Clock),
    .Input (osc),
    .Output(Value)
  );
endmodule
