// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-29, Kari Vierimaa, Kempele, Finland.
// sync_Bits: depth delay and multi-bit independence (INIT is FF seed, overwritten by Input).

`timescale 1ns/1ps

module sync_Bits_tb;
  localparam int BITS = 4;
  localparam int SYNC_DEPTH = 3;

  logic Clock = 0;
  logic [BITS-1:0] Input = 4'hA;
  logic [BITS-1:0] Output;

  always #5 Clock = ~Clock;

  sync_Bits #(
    .BITS(BITS),
    .INIT(32'h0000_000A),
    .SYNC_DEPTH(SYNC_DEPTH),
    .REGISTER_OUTPUT(1'b0)
  ) dut (
    .Clock(Clock),
    .Input(Input),
    .Output(Output)
  );

  initial begin
    int c;
    // Hold Input=INIT through sync depth → Output settles to A
    for (c = 0; c < SYNC_DEPTH + 3; c++)
      @(posedge Clock);
    if (Output !== 4'hA)
      $fatal(1, "sync_Bits_tb: Output %h expected A", Output);

    Input = 4'h5;
    @(posedge Clock);
    // Still old value for at least one cycle (meta stage)
    if (Output === 4'h5)
      $fatal(1, "sync_Bits_tb: Output updated too early");

    for (c = 0; c < SYNC_DEPTH + 2; c++)
      @(posedge Clock);
    if (Output !== 4'h5)
      $fatal(1, "sync_Bits_tb: Output %h expected 5 after sync", Output);

    Input = 4'h4;
    for (c = 0; c < SYNC_DEPTH + 2; c++)
      @(posedge Clock);
    if (Output !== 4'h4)
      $fatal(1, "sync_Bits_tb: Output %h expected 4", Output);

    $display("PASS sync_Bits_tb");
    $finish;
  end

  initial begin
    #50us;
    $fatal(1, "sync_Bits_tb watchdog");
  end
endmodule
