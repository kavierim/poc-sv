// SPDX-FileCopyrightText: 2007-2015 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

module arith_Counter_Free #(
  parameter int DIVIDER = 1
) (
  input  logic Clock,
  input  logic Reset,
  input  logic Increment,
  output logic Strobe
);
  import poc_utils::*;

  if (DIVIDER == 1) begin : genNoDiv
    always_ff @(posedge Clock) begin
      if (Reset)
        Strobe <= 1'b0;
      else
        Strobe <= Increment;
    end
  end else begin : genDoDiv
    localparam int BITS = log2ceil(DIVIDER);
    logic [BITS:0] Cnt;
    logic          cin;

    assign cin = ~Increment;

    always_ff @(posedge Clock) begin
      logic [BITS:0] addend;
      if (Reset)
        Cnt <= DIVIDER - 2;
      else begin
        if (Cnt[BITS] == 1'b0)
          addend = {BITS + 1{1'b1}};
        else
          addend = DIVIDER - 1;
        Cnt <= Cnt + addend + cin;
      end
    end

    assign Strobe = Cnt[BITS];
  end
endmodule
