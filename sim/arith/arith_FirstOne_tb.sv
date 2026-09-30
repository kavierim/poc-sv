// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-29, Kari Vierimaa, Kempele, Finland.
// arith_FirstOne: lowest-set grant, Index, TokenOut when none.

`timescale 1ns/1ps

module arith_FirstOne_tb;
  localparam int BITS = 8;

  logic TokenIn;
  logic [BITS-1:0] Request;
  logic [BITS-1:0] Grant;
  logic TokenOut;
  logic [$clog2(BITS)-1:0] Index;

  arith_FirstOne #(.BITS(BITS)) dut (
    .TokenIn(TokenIn),
    .Request(Request),
    .Grant(Grant),
    .TokenOut(TokenOut),
    .Index(Index)
  );

  initial begin
    TokenIn = 1'b1;

    Request = 8'b0000_0000;
    #1;
    if (Grant !== '0) $fatal(1, "arith_FirstOne_tb: Grant not 0");
    if (TokenOut !== 1'b1) $fatal(1, "arith_FirstOne_tb: TokenOut expected 1");

    Request = 8'b0001_0000;
    #1;
    if (Grant !== 8'b0001_0000) $fatal(1, "arith_FirstOne_tb: Grant %b", Grant);
    if (Index !== 4) $fatal(1, "arith_FirstOne_tb: Index %0d expected 4", Index);
    if (TokenOut !== 1'b0) $fatal(1, "arith_FirstOne_tb: TokenOut expected 0");

    // Lowest wins among multiple
    Request = 8'b1010_0100;
    #1;
    if (Grant !== 8'b0000_0100) $fatal(1, "arith_FirstOne_tb: lowest Grant %b", Grant);
    if (Index !== 2) $fatal(1, "arith_FirstOne_tb: Index %0d expected 2", Index);

    // TokenIn=0 masks all
    TokenIn = 1'b0;
    Request = 8'b1111_1111;
    #1;
    if (Grant !== '0) $fatal(1, "arith_FirstOne_tb: TokenIn=0 must zero Grant");

    $display("PASS arith_FirstOne_tb");
    $finish;
  end
endmodule
