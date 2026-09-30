// SPDX-FileCopyrightText: 2007-2014 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

module arith_SquareRoot #(
  parameter int BITS = 16
) (
  input  logic                Clock,
  input  logic                Reset,
  input  logic [BITS-1:0]     Radicand,
  input  logic                Start,
  output logic [(BITS-1)/2:0] Result,
  output logic                Ready
);
  localparam int STEPS     = (BITS + 1) / 2;
  localparam int RMD_W     = BITS + STEPS;
  localparam int RMD_MSB   = RMD_W - 1;
  localparam int DIFF_W    = STEPS + 2;

  logic [RMD_W-1:0] Rmd;
  logic [STEPS-1:0] Vld;
  logic [STEPS-1:0] Res;
  logic [DIFF_W-1:0] diff;

  for (genvar i = 0; i < STEPS; i++) begin : genRes
    assign Res[i] = Rmd[2 * i] & ~Vld[i];
  end

  assign diff = Rmd[RMD_MSB:BITS-2] + ({1'b1, ~Res[STEPS-2:0], 2'b11});
  assign Result = Res;
  assign Ready  = ~Vld[STEPS-1];

  always_ff @(posedge Clock) begin
    if (Reset) begin
      Rmd <= 'x;
      Vld <= 'x;
      Vld[STEPS-1] <= 1'b0;
    end else begin
      if (Start) begin
        Rmd <= {{STEPS{1'b0}}, Radicand};
        Vld <= {STEPS{1'b1}};
      end else if (Vld[STEPS-1]) begin
        Rmd[BITS-1:0] <= {Rmd[BITS-3:0], 1'b0, ~diff[DIFF_W-1]};
        if (diff[DIFF_W-1])
          Rmd[RMD_MSB:BITS] <= Rmd[RMD_MSB-2:BITS-2];
        else
          Rmd[RMD_MSB:BITS] <= diff[DIFF_W-3:0];
        Vld <= {Vld[STEPS-2:0], 1'b0};
      end
    end
  end
endmodule
