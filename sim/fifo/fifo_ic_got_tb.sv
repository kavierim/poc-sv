// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-29, Kari Vierimaa, Kempele, Finland.
// fifo_ic_got CDC: ordered multi-beat integrity at two clock ratios.

`timescale 1ns/1ps

module fifo_ic_got_tb;
  localparam int DATA_BITS = 8;
  localparam int MIN_DEPTH = 8;
  localparam int N = 6;

  logic Write_Clock = 0;
  logic Read_Clock  = 0;
  logic Write_Reset = 1;
  logic Read_Reset  = 1;
  int unsigned wr_half = 5;
  int unsigned rd_half = 5;

  logic Write_Put, Write_Full, Read_Got, Read_Valid;
  logic [DATA_BITS-1:0] Write_DataIn, Read_DataOut;

  always #(wr_half) Write_Clock = ~Write_Clock;
  always #(rd_half) Read_Clock  = ~Read_Clock;

  fifo_ic_got #(
    .DATA_BITS(DATA_BITS),
    .MIN_DEPTH(MIN_DEPTH)
  ) dut (
    .Write_Clock(Write_Clock), .Write_Reset(Write_Reset),
    .Write_Put(Write_Put), .Write_DataIn(Write_DataIn), .Write_Full(Write_Full),
    .Write_EmptyState(),
    .Read_Clock(Read_Clock), .Read_Reset(Read_Reset),
    .Read_Got(Read_Got), .Read_DataOut(Read_DataOut), .Read_Valid(Read_Valid),
    .Read_FillState()
  );

  task automatic push(input logic [DATA_BITS-1:0] d);
    @(posedge Write_Clock);
    while (Write_Full) begin
      @(posedge Write_Clock);
      if ($time > 500_000) $fatal(1, "fifo_ic_got_tb: stuck Full");
    end
    Write_DataIn = d;
    Write_Put = 1'b1;
    @(posedge Write_Clock);
    Write_Put = 1'b0;
  endtask

  task automatic pop_expect(input logic [DATA_BITS-1:0] d);
    while (~Read_Valid) begin
      @(posedge Read_Clock);
      if ($time > 1_000_000) $fatal(1, "fifo_ic_got_tb: stuck empty for %h", d);
    end
    if (Read_DataOut !== d)
      $fatal(1, "fifo_ic_got_tb: got %h expected %h", Read_DataOut, d);
    Read_Got = 1'b1;
    @(posedge Read_Clock);
    Read_Got = 1'b0;
    @(posedge Read_Clock);
  endtask

  task automatic run_ratio(input int unsigned wh, input int unsigned rh);
    int i;
    wr_half = wh;
    rd_half = rh;
    Write_Put = 0;
    Read_Got = 0;
    Write_DataIn = '0;
    Write_Reset = 1;
    Read_Reset = 1;
    repeat (10) @(posedge Write_Clock);
    repeat (10) @(posedge Read_Clock);
    Write_Reset = 0;
    Read_Reset = 0;
    // Allow gray pointers to settle after reset (CDC)
    repeat (16) @(posedge Write_Clock);
    repeat (16) @(posedge Read_Clock);

    // One beat sanity
    push(8'h5A);
    pop_expect(8'h5A);

    for (i = 0; i < N; i++)
      push(8'(8'h30 + i));
    // Allow crossing
    repeat (8) @(posedge Read_Clock);
    for (i = 0; i < N; i++)
      pop_expect(8'(8'h30 + i));

    // Fill while read stalled, then drain in order
    for (i = 0; i < 4; i++)
      push(8'(8'hA0 + i));
    repeat (12) @(posedge Read_Clock);
    for (i = 0; i < 4; i++)
      pop_expect(8'(8'hA0 + i));
  endtask

  initial begin
    run_ratio(4, 7);
    run_ratio(7, 4);
    $display("PASS fifo_ic_got_tb");
    $finish;
  end

  initial begin
    #500us;
    $fatal(1, "fifo_ic_got_tb watchdog");
  end
endmodule
