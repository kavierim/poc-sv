// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-29, Kari Vierimaa, Kempele, Finland.
// fifo_Stage: stall, ordered drain, sideband-free data path.

`timescale 1ns/1ps

module fifo_Stage_tb;
  localparam int DATA_BITS = 8;
  localparam int STAGES = 3;

  logic Clock = 0;
  logic Reset = 1;
  logic Put, Full, Valid, Got;
  logic [DATA_BITS-1:0] DataIn, DataOut;

  always #5 Clock = ~Clock;

  fifo_Stage #(
    .DATA_BITS(DATA_BITS),
    .STAGES(STAGES),
    .LIGHT_WEIGHT(1'b0)
  ) dut (
    .Clock(Clock), .Reset(Reset),
    .Put(Put), .DataIn(DataIn), .Full(Full),
    .Valid(Valid), .DataOut(DataOut), .Got(Got)
  );

  task automatic push(input logic [DATA_BITS-1:0] d);
    while (Full) begin
      @(posedge Clock);
      if ($time > 100_000) $fatal(1, "fifo_Stage_tb: Full stuck");
    end
    Put = 1'b1;
    DataIn = d;
    @(posedge Clock);
    Put = 1'b0;
  endtask

  initial begin
    int i;
    Put = 0; Got = 0; DataIn = '0;
    repeat (3) @(posedge Clock);
    Reset = 0;

    Got = 0;
    push(8'h11);
    push(8'h22);
    push(8'h33);
    repeat (STAGES) @(posedge Clock);
    if (~Valid) $fatal(1, "fifo_Stage_tb: expected Valid while stalled");
    if (DataOut !== 8'h11) $fatal(1, "fifo_Stage_tb: head %h", DataOut);

    for (i = 0; i < 3; i++) begin
      while (~Valid) @(posedge Clock);
      if (DataOut !== (i == 0 ? 8'h11 : i == 1 ? 8'h22 : 8'h33))
        $fatal(1, "fifo_Stage_tb: beat %0d = %h", i, DataOut);
      Got = 1;
      @(posedge Clock);
      Got = 0;
      @(posedge Clock);
    end

    // Reset clears pipeline
    push(8'hAA);
    Reset = 1;
    @(posedge Clock);
    Reset = 0;
    @(posedge Clock);
    if (Valid) $fatal(1, "fifo_Stage_tb: Valid after reset");

    $display("PASS fifo_Stage_tb");
    $finish;
  end

  initial begin
    #50us;
    $fatal(1, "fifo_Stage_tb watchdog");
  end
endmodule
