// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Self-checking Verilator testbench (ReadWrite subset of upstream OSVVM case).

`timescale 1ns/1ps

module axi4lite_Register_tb;
  import poc_axi4_common::*;
  import poc_axi4lite::*;

  localparam int ADDR_W = 32;
  localparam int DATA_W = 32;
  localparam int N_USER = 5;

  logic [31:0] reg_read[N_USER + 2];
  logic [N_USER + 1:0] reg_read_hit;
  logic [31:0] reg_write[N_USER + 2];
  logic [N_USER + 1:0] reg_write_hit;
  logic [N_USER + 1:0] reg_write_strobe;

  logic clk = 1'b0;
  logic reset = 1'b1;
  logic irq;

  T_AXI4Lite_Bus_M2S m2s;
  T_AXI4Lite_Bus_S2M s2m;

  always #5 clk = ~clk;

  axi4lite_Register #(
    .N_USER_CFG         (5),
    .SIM_READWRITE_CFG  (1'b1),
    .ENABLE_INTERRUPT   (1'b0)
  ) dut (
    .Clock                        (clk),
    .Reset                        (reset),
    .AXI4Lite_m2s                 (m2s),
    .AXI4Lite_s2m                 (s2m),
    .AXI4Lite_irq                 (irq),
    .RegisterFile_ReadPort        (reg_read),
    .RegisterFile_ReadPort_hit    (reg_read_hit),
    .RegisterFile_WritePort       (reg_write),
    .RegisterFile_WritePort_hit   (reg_write_hit),
    .RegisterFile_WritePort_strobe(reg_write_strobe)
  );

  initial begin
    for (int i = 0; i < N_USER; i++)
      reg_write_strobe[i] = (i == 2 || i == 3 || i == 4) ? 1'b0 : 1'b1;
  end

  task automatic axi_write(input logic [31:0] addr, input logic [31:0] data, input bit expect_decerr = 1'b0);
    m2s = initialize_axi4lite_bus_m2s(1'b0);
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
    if (expect_decerr) begin
      if (s2m.BResp != C_AXI4_RESPONSE_DECODE_ERROR)
        $fatal(1, "expected DECERR write at 0x%h", addr);
    end else if (s2m.BResp != C_AXI4_RESPONSE_OKAY)
      $fatal(1, "write not OKAY at 0x%h", addr);
    @(posedge clk);
    m2s.AWValid = 1'b0;
    m2s.WValid  = 1'b0;
  endtask

  task automatic axi_read_check(input logic [31:0] addr, input logic [31:0] expected);
    logic [31:0] got;
    m2s.ARValid = 1'b1;
    m2s.RReady  = 1'b1;
    m2s.ARAddr  = addr;
    while (!s2m.ARReady)
      @(posedge clk);
    while (!s2m.RValid)
      @(posedge clk);
    got = s2m.RData;
    if (s2m.RResp != C_AXI4_RESPONSE_OKAY)
      $fatal(1, "read not OKAY at 0x%h", addr);
    if (got !== expected)
      $fatal(1, "read mismatch at 0x%h got 0x%h expect 0x%h", addr, got, expected);
    @(posedge clk);
    m2s.ARValid = 1'b0;
  endtask

  initial begin
    m2s = initialize_axi4lite_bus_m2s(1'b0);
    s2m = initialize_axi4lite_bus_s2m(1'b0);
    repeat (3) @(posedge clk);
    reset = 1'b0;
    repeat (2) @(posedge clk);

    axi_write(32'h08, 32'h02);
    axi_read_check(32'h08, 32'h02);
    axi_write(32'h10, 32'hFF);
    axi_read_check(32'h10, 32'hFF);
    axi_write(32'h14, 32'h2A);
    axi_read_check(32'h14, 32'h2A);

    axi_write(32'h0C, 32'h0, 1'b1);
    axi_write(32'h18, 32'h0, 1'b1);
    axi_write(32'h1C, 32'h0, 1'b1);
    axi_write(32'h50, 32'h0, 1'b1);

    repeat (4) @(posedge clk);
    $display("PASS axi4lite_Register_tb");
    $finish;
  end

  initial begin
    #100us;
    $fatal(1, "axi4lite_Register_tb watchdog");
  end
endmodule
