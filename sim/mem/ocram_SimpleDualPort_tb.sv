// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-29, Kari Vierimaa, Kempele, Finland.
// ocram_SimpleDualPort: write/read, CE gating, dual-clock read after write.

`timescale 1ns/1ps

module ocram_SimpleDualPort_tb;
  localparam int ADDRESS_BITS = 4;
  localparam int DATA_BITS = 8;

  logic Write_Clock = 0;
  logic Read_Clock = 0;
  logic Write_ClockEnable = 1;
  logic Write_WriteEnable = 0;
  logic Read_ClockEnable = 1;
  logic [ADDRESS_BITS-1:0] Write_Address = '0;
  logic [ADDRESS_BITS-1:0] Read_Address = '0;
  logic [DATA_BITS-1:0] Write_DataIn = '0;
  logic [DATA_BITS-1:0] Read_DataOut;

  always #4 Write_Clock = ~Write_Clock;
  always #6 Read_Clock  = ~Read_Clock;

  ocram_SimpleDualPort #(
    .ADDRESS_BITS(ADDRESS_BITS),
    .DATA_BITS(DATA_BITS)
  ) dut (
    .Write_Clock(Write_Clock),
    .Write_ClockEnable(Write_ClockEnable),
    .Write_WriteEnable(Write_WriteEnable),
    .Write_Address(Write_Address),
    .Write_DataIn(Write_DataIn),
    .Read_Clock(Read_Clock),
    .Read_ClockEnable(Read_ClockEnable),
    .Read_Address(Read_Address),
    .Read_DataOut(Read_DataOut)
  );

  task automatic write_word(input logic [ADDRESS_BITS-1:0] a, input logic [DATA_BITS-1:0] d);
    @(posedge Write_Clock);
    Write_Address = a;
    Write_DataIn = d;
    Write_WriteEnable = 1'b1;
    @(posedge Write_Clock);
    Write_WriteEnable = 1'b0;
  endtask

  task automatic read_expect(input logic [ADDRESS_BITS-1:0] a, input logic [DATA_BITS-1:0] d);
    @(posedge Read_Clock);
    Read_Address = a;
    @(posedge Read_Clock);
    if (Read_DataOut !== d)
      $fatal(1, "ocram_SimpleDualPort_tb: addr %0d got %h expected %h", a, Read_DataOut, d);
  endtask

  initial begin
    repeat (4) @(posedge Write_Clock);

    write_word(4'h3, 8'h5A);
    write_word(4'h7, 8'hC3);
    // CE low must not write
    Write_ClockEnable = 1'b0;
    write_word(4'h3, 8'h00);
    Write_ClockEnable = 1'b1;

    repeat (4) @(posedge Read_Clock);
    read_expect(4'h3, 8'h5A);
    read_expect(4'h7, 8'hC3);

    // Read CE gating: freeze output when CE low
    begin
      logic [DATA_BITS-1:0] held;
      Read_ClockEnable = 1'b0;
      Read_Address = 4'h7;
      @(posedge Read_Clock);
      held = Read_DataOut;
      Read_Address = 4'h3;
      @(posedge Read_Clock);
      if (Read_DataOut !== held)
        $fatal(1, "ocram_SimpleDualPort_tb: CE low should hold Read_DataOut");
      Read_ClockEnable = 1'b1;
      @(posedge Read_Clock);
      if (Read_DataOut !== 8'h5A)
        $fatal(1, "ocram_SimpleDualPort_tb: CE re-enable read %h", Read_DataOut);
    end

    $display("PASS ocram_SimpleDualPort_tb");
    $finish;
  end

  initial begin
    #100us;
    $fatal(1, "ocram_SimpleDualPort_tb watchdog");
  end
endmodule
