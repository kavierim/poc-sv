// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-29, Kari Vierimaa, Kempele, Finland.
// fifo_cc_got: empty/full, wrap, single-word, reset mid-stream.

`timescale 1ns/1ps

module fifo_cc_got_tb;
  localparam int DATA_BITS = 8;
  localparam int MIN_DEPTH = 4;

  logic Clock = 0;
  logic Reset = 1;
  logic Put, Got, Full, Valid;
  logic [DATA_BITS-1:0] DataIn, DataOut;

  always #5 Clock = ~Clock;

  fifo_cc_got #(
    .DATA_BITS(DATA_BITS),
    .MIN_DEPTH(MIN_DEPTH),
    .STATE_REG(1'b1)
  ) dut (
    .Clock(Clock), .Reset(Reset),
    .Put(Put), .DataIn(DataIn), .Full(Full), .EmptyState(),
    .Got(Got), .DataOut(DataOut), .Valid(Valid), .FillState()
  );

  task automatic put_word(input logic [DATA_BITS-1:0] d);
    while (Full) begin
      @(posedge Clock);
      if ($time > 200_000) $fatal(1, "fifo_cc_got_tb: stuck Full before put");
    end
    Put = 1'b1;
    DataIn = d;
    @(posedge Clock);
    Put = 1'b0;
  endtask

  task automatic get_expect(input logic [DATA_BITS-1:0] d);
    while (~Valid) begin
      @(posedge Clock);
      if ($time > 200_000) $fatal(1, "fifo_cc_got_tb: stuck empty");
    end
    if (DataOut !== d)
      $fatal(1, "fifo_cc_got_tb: got %h expected %h", DataOut, d);
    Got = 1'b1;
    @(posedge Clock);
    Got = 1'b0;
  endtask

  initial begin
    int i;
    int nfill;
    logic [DATA_BITS-1:0] q[$];
    Put = 0; Got = 0; DataIn = '0;
    repeat (3) @(posedge Clock);
    Reset = 0;
    @(posedge Clock);

    if (Valid) $fatal(1, "fifo_cc_got_tb: Valid after reset");

    // Single element
    put_word(8'hA5);
    get_expect(8'hA5);
    if (Valid) $fatal(1, "fifo_cc_got_tb: not empty after single");

    // Fill until Full; remember order
    nfill = 0;
    q.delete();
    while (!Full && nfill < 64) begin
      put_word(8'(8'h10 + nfill));
      q.push_back(8'(8'h10 + nfill));
      nfill++;
    end
    if (!Full)
      $fatal(1, "fifo_cc_got_tb: never saw Full after %0d puts", nfill);
    if (nfill < 2)
      $fatal(1, "fifo_cc_got_tb: depth too small");

    // Wrap: take two, add two, drain rest in order
    get_expect(q.pop_front());
    get_expect(q.pop_front());
    put_word(8'hE1);
    q.push_back(8'hE1);
    put_word(8'hE2);
    q.push_back(8'hE2);
    while (q.size() > 0)
      get_expect(q.pop_front());
    if (Valid) $fatal(1, "fifo_cc_got_tb: leftover after wrap");

    // Reset mid-stream clears
    put_word(8'hEE);
    put_word(8'hEF);
    Reset = 1;
    @(posedge Clock);
    Reset = 0;
    @(posedge Clock);
    if (Valid) $fatal(1, "fifo_cc_got_tb: Valid after mid reset");
    put_word(8'h01);
    get_expect(8'h01);

    $display("PASS fifo_cc_got_tb");
    $finish;
  end

  initial begin
    #100us;
    $fatal(1, "fifo_cc_got_tb watchdog");
  end
endmodule
