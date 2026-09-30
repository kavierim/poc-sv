// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Self-checking Verilator testbench for axi4lite_OCRAM_Adapter.

`timescale 1ns/1ps

module axi4lite_OCRAM_Adapter_tb;
  import poc_axi4_common::*;
  import poc_axi4lite::*;

  localparam int ADDR_W = 32;
  localparam int DATA_W = 32;
  localparam int OCRAM_ADDR_W = 10;
  localparam int OCRAM_DATA_W = 32;

  logic clk = 1'b0;
  logic reset = 1'b1;

  T_AXI4Lite_Bus_M2S m2s;
  T_AXI4Lite_Bus_S2M s2m;
  logic [OCRAM_ADDR_W-1:0] ocram_addr;
  logic                    ocram_we;
  logic [OCRAM_DATA_W/8-1:0] ocram_be;
  logic [OCRAM_DATA_W-1:0] ocram_din;
  logic [OCRAM_DATA_W-1:0] ocram_dout;

  logic [OCRAM_DATA_W-1:0] mem[0:(1<<OCRAM_ADDR_W)-1];

  always #5 clk = ~clk;

  axi4lite_OCRAM_Adapter #(
    .OCRAM_ADDRESS_BITS (OCRAM_ADDR_W),
    .OCRAM_DATA_BITS    (OCRAM_DATA_W),
    .ADDR_W             (ADDR_W),
    .DATA_W             (DATA_W)
  ) dut (
    .Clock             (clk),
    .Reset             (reset),
    .AXI4Lite_m2s      (m2s),
    .AXI4Lite_s2m      (s2m),
    .OCRAM_Address     (ocram_addr),
    .OCRAM_WriteEnable (ocram_we),
    .OCRAM_ByteEnable  (ocram_be),
    .OCRAM_DataIn      (ocram_din),
    .OCRAM_DataOut     (ocram_dout)
  );

  always_ff @(posedge clk) begin
    ocram_din <= mem[ocram_addr];
    if (ocram_we)
      mem[ocram_addr] <= ocram_dout;
  end

  task automatic axi_write(input logic [31:0] addr, input logic [31:0] data);
    m2s = initialize_axi4lite_bus_m2s(1'b0);
    @(posedge clk);
    m2s.AWValid = 1'b1;
    m2s.WValid  = 1'b1;
    m2s.BReady  = 1'b1;
    m2s.AWAddr  = addr;
    m2s.WData   = data;
    m2s.WStrb   = '1;
    while (!(s2m.AWReady && s2m.WReady))
      @(posedge clk);
    while (!s2m.BValid)
      @(posedge clk);
    if (s2m.BResp != C_AXI4_RESPONSE_OKAY)
      $fatal(1, "write response not OKAY at 0x%h", addr);
    @(posedge clk);
    m2s.AWValid = 1'b0;
    m2s.WValid  = 1'b0;
  endtask

  task automatic axi_read(input logic [31:0] addr, input logic [31:0] expected);
    logic [31:0] got;
    m2s = initialize_axi4lite_bus_m2s(1'b0);
    @(posedge clk);
    m2s.ARValid = 1'b1;
    m2s.RReady  = 1'b1;
    m2s.ARAddr  = addr;
    while (!s2m.ARReady)
      @(posedge clk);
    while (!s2m.RValid)
      @(posedge clk);
    got = s2m.RData;
    if (s2m.RResp != C_AXI4_RESPONSE_OKAY)
      $fatal(1, "read response not OKAY at 0x%h", addr);
    if (got !== expected)
      $fatal(1, "read mismatch at 0x%h: got 0x%h expect 0x%h", addr, got, expected);
    @(posedge clk);
    m2s.ARValid = 1'b0;
  endtask

  initial begin
    m2s = initialize_axi4lite_bus_m2s(1'b0);
    s2m = initialize_axi4lite_bus_s2m(1'b0);
    for (int i = 0; i < (1<<OCRAM_ADDR_W); i++)
      mem[i] = '0;
    repeat (3) @(posedge clk);
    reset = 1'b0;
    repeat (2) @(posedge clk);

    axi_write(32'h04, 32'h0000_000F);
    axi_write(32'h08, 32'h0000_00FF);
    axi_write(32'h14, 32'h0000_AFAF);
    axi_read(32'h14, 32'h0000_AFAF);

    repeat (4) @(posedge clk);
    $display("PASS axi4lite_OCRAM_Adapter_tb");
    $finish;
  end

  initial begin
    #50us;
    $fatal(1, "axi4lite_OCRAM_Adapter_tb watchdog");
  end
endmodule
