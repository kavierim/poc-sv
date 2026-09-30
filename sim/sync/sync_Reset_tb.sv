// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-29, Kari Vierimaa, Kempele, Finland.
// sync_Reset: async assert, sync release with D=0.

`timescale 1ns/1ps

module sync_Reset_tb;
  localparam int SYNC_DEPTH = 2;

  logic Clock = 0;
  logic Input = 1;
  logic D = 0;
  logic Output;

  always #5 Clock = ~Clock;

  sync_Reset #(.SYNC_DEPTH(SYNC_DEPTH)) dut (
    .Clock(Clock),
    .Input(Input),
    .D(D),
    .Output(Output)
  );

  initial begin
    int c;
    // Async assert keeps Output high
    Input = 1'b1;
    #1;
    if (Output !== 1'b1)
      $fatal(1, "sync_Reset_tb: Output not 1 while Input asserted");

    // Release Input; D=0 should deassert Output after SYNC_DEPTH clocks
    @(negedge Clock);
    Input = 1'b0;
    D = 1'b0;
    for (c = 0; c < SYNC_DEPTH + 3; c++)
      @(posedge Clock);
    if (Output !== 1'b0)
      $fatal(1, "sync_Reset_tb: Output still asserted after sync release");

    // Re-assert async
    Input = 1'b1;
    #1;
    if (Output !== 1'b1)
      $fatal(1, "sync_Reset_tb: re-assert failed");

    $display("PASS sync_Reset_tb");
    $finish;
  end

  initial begin
    #50us;
    $fatal(1, "sync_Reset_tb watchdog");
  end
endmodule
