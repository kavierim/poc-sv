// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

module arith_Counter_BCD #(
  parameter int DIGITS = 2
) (
  input  logic               Clock,
  input  logic               Reset,
  input  logic               Increment,
  output poc_utils::bcd_t    Value [DIGITS]
);
  import poc_utils::*;

  logic [DIGITS-1:0] p;
  logic [DIGITS:0]   c;

  assign c = ({1'b0, p} ^ ({1'b0, p} + 1'b1));
  wire unused_bcd_carry = |c[DIGITS:0];

  for (genvar i = 0; i < DIGITS; i++) begin : gDigit
    bcd_t cnt_r;
    logic inc_pulse;

    assign p[i] = cnt_r[3] & cnt_r[0];
    assign inc_pulse = Increment & c[i];

    always_ff @(posedge Clock) begin
      if (Reset)
        cnt_r <= 4'h0;
      else if (inc_pulse) begin
        if (p[i])
          cnt_r <= 4'h0;
        else
          cnt_r <= bcd_t'(cnt_r + 4'd1);
      end
    end

    assign Value[i] = cnt_r;
  end
endmodule
