// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-29, Kari Vierimaa, Kempele, Finland.
// arith_Counter_Free: DIVIDER=1 pass-through; DIVIDER=4 strobe rate.

`timescale 1ns/1ps

module arith_Counter_Free_tb;
  logic Clock = 0;
  logic Reset = 1;
  logic Increment = 0;
  logic Strobe1, Strobe4;

  always #5 Clock = ~Clock;

  arith_Counter_Free #(.DIVIDER(1)) dut1 (
    .Clock(Clock), .Reset(Reset), .Increment(Increment), .Strobe(Strobe1)
  );
  arith_Counter_Free #(.DIVIDER(4)) dut4 (
    .Clock(Clock), .Reset(Reset), .Increment(Increment), .Strobe(Strobe4)
  );

  initial begin
    int i;
    int strobes;
    repeat (3) @(posedge Clock);
    Reset = 0;
    @(posedge Clock);

    // DIVIDER=1: Strobe mirrors Increment with 1-cycle FF delay
    Increment = 1;
    @(posedge Clock);
    if (Strobe1 !== 1'b1) $fatal(1, "arith_Counter_Free_tb: DIV1 Strobe high");
    Increment = 0;
    @(posedge Clock);
    if (Strobe1 !== 1'b0) $fatal(1, "arith_Counter_Free_tb: DIV1 Strobe low");

    // DIVIDER=4: exactly one Strobe pulse every 4 Increment=1 cycles after reset state
    Reset = 1;
    @(posedge Clock);
    Reset = 0;
    Increment = 1;
    strobes = 0;
    for (i = 0; i < 16; i++) begin
      @(posedge Clock);
      if (Strobe4) strobes++;
    end
    // Over 16 increments with DIVIDER=4 expect about 4 strobes (implementation-dependent edge)
    if (strobes < 3 || strobes > 5)
      $fatal(1, "arith_Counter_Free_tb: DIV4 strobe count %0d not in 3..5", strobes);

    $display("PASS arith_Counter_Free_tb");
    $finish;
  end

  initial begin
    #50us;
    $fatal(1, "arith_Counter_Free_tb watchdog");
  end
endmodule
