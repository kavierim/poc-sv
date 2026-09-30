// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-29, Kari Vierimaa, Kempele, Finland.
// arith_Prefix_Or: checks documented low-bit structure (y[0], y[1]) and nonzero.

`timescale 1ns/1ps

module arith_Prefix_Or_tb;
  localparam int BITS = 8;
  logic [BITS-1:0] x, y;

  arith_Prefix_Or #(.BITS(BITS)) dut (.x(x), .y(y));

  initial begin
    // Explicit low bits from RTL: y[0]=x[0], y[1]=x[0]|x[1]
    x = 8'b0000_0000;
    #1;
    if (y[0] !== 1'b0 || y[1] !== 1'b0)
      $fatal(1, "arith_Prefix_Or_tb: y[1:0] for zero = %b", y[1:0]);

    x = 8'b0000_0001;
    #1;
    if (y[0] !== 1'b1 || y[1] !== 1'b1)
      $fatal(1, "arith_Prefix_Or_tb: y[1:0] for bit0 = %b", y[1:0]);

    x = 8'b0000_0010;
    #1;
    if (y[0] !== 1'b0 || y[1] !== 1'b1)
      $fatal(1, "arith_Prefix_Or_tb: y[1:0] for bit1 = %b", y[1:0]);

    x = 8'b1000_0000;
    #1;
    if (y === '0)
      $fatal(1, "arith_Prefix_Or_tb: MSB set must produce nonzero y");
    if (y[0] !== 1'b0)
      $fatal(1, "arith_Prefix_Or_tb: y[0] must follow x[0]");

    $display("PASS arith_Prefix_Or_tb");
    $finish;
  end
endmodule
