// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

module arith_PRNG #(
  parameter int          BITS = 16,
  parameter logic [BITS-1:0] SEED = '0
) (
  input  logic             Clock,
  input  logic             Reset,
  input  logic [BITS-1:0]  InitialValue,
  input  logic             Got,
  output logic [BITS-1:0]  Value
);
  import poc_arith::*;

  initial begin
`ifndef SYNTHESIS
    if (BITS < 3 || BITS > 168)
      $fatal(1, "arith_PRNG: width %0d not supported (3..168)", BITS);
`endif
  end

  logic [BITS-1:0]  val_r;
  logic [BITS-1:0]  lfsr_out;
  /* verilator lint_off UNUSEDSIGNAL */
  logic [167:0]     lfsr_inp;
  logic [167:0]     lfsr_full;
  /* verilator lint_on UNUSEDSIGNAL */

  initial val_r = SEED;

  always_comb begin
    lfsr_inp = '0;
    lfsr_inp[BITS-1:0] = val_r;
    lfsr_full          = arith_prbs_lfsr(lfsr_inp, BITS);
    lfsr_out           = lfsr_full[BITS-1:0];
  end

  always_ff @(posedge Clock) begin
    if (Reset)
      val_r <= InitialValue;
    else if (Got)
      val_r <= lfsr_out;
  end

  assign Value = val_r;
endmodule
