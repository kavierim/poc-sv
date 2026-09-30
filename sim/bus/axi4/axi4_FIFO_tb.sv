// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-29, Kari Vierimaa, Kempele, Finland.
// Self-checking Verilator testbench for axi4_FIFO (write/read payload + ID).

`timescale 1ns/1ps

module axi4_FIFO_tb;
  import poc_axi4_full::*;
  import poc_axi4_common::*;

  localparam int ADDR_W = 32;
  localparam int DATA_W = 32;
  localparam int USER_W = 1;
  localparam int ID_W   = 1;

  localparam int WDATA_LO = 0;
  localparam int WDATA_HI = (DATA_W / 4) - 1;
  localparam int RDATA_LO = 2 * (DATA_W / 4);
  localparam int RDATA_HI = 3 * (DATA_W / 4) - 1;

  typedef axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::bus_m2s_t m2s_t;
  typedef axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::bus_s2m_t s2m_t;

  logic Clock = 0;
  logic Reset = 1;

  m2s_t In_M2S;
  s2m_t In_S2M;
  m2s_t Out_M2S;
  s2m_t Out_S2M;

  axi4_FIFO #(
    .ADDR_W(ADDR_W), .DATA_W(DATA_W), .USER_W(USER_W), .ID_W(ID_W),
    .FRAMES(2), .FRAME_DEPTH(1)
  ) dut (
    .Clock(Clock), .Reset(Reset),
    .In_M2S(In_M2S), .In_S2M(In_S2M),
    .Out_M2S(Out_M2S), .Out_S2M(Out_S2M)
  );

  axi4_Sink #(
    .ADDR_W(ADDR_W), .DATA_W(DATA_W), .USER_W(USER_W), .ID_W(ID_W)
  ) sink (
    .Clock(Clock), .Reset(Reset),
    .AXI4_M2S(Out_M2S), .AXI4_S2M(Out_S2M)
  );

  always #5 Clock = ~Clock;

  initial begin
    logic saw_wdata;

    In_M2S = axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::initialize_bus_m2s(1'b0);

    repeat (4) @(posedge Clock);
    Reset = 0;

    saw_wdata = 1'b0;
    fork
      forever begin
        @(posedge Clock);
        if (Out_M2S.WValid && Out_S2M.WReady) begin
          if (Out_M2S.WData !== 32'hCAFEBABE)
            $fatal(1, "axi4_FIFO_tb: sink WData %h expected CAFEBABE", Out_M2S.WData);
          if (Out_M2S.AWValid && Out_S2M.AWReady && Out_M2S.AWAddr !== 32'h1000)
            $fatal(1, "axi4_FIFO_tb: AWAddr %h expected 1000", Out_M2S.AWAddr);
          saw_wdata = 1'b1;
        end
      end
    join_none

    // Single-beat write
    @(posedge Clock);
    In_M2S.AWValid = 1'b1;
    In_M2S.AWAddr  = 32'h1000;
    In_M2S.AWID    = 1'b1;
    In_M2S.AWLen   = 8'd0;
    In_M2S.WValid  = 1'b1;
    In_M2S.WData   = 32'hCAFEBABE;
    In_M2S.WLast   = 1'b1;
    In_M2S.WStrb   = '1;
    In_M2S.BReady  = 1'b1;

    while (~In_S2M.BValid) begin
      @(posedge Clock);
      if ($time > 500_000)
        $fatal(1, "axi4_FIFO_tb: timeout write BValid");
    end
    if (In_S2M.BResp != C_AXI4_RESPONSE_OKAY)
      $fatal(1, "axi4_FIFO_tb: BResp %0d", In_S2M.BResp);
    if (In_S2M.BID !== 1'b1)
      $fatal(1, "axi4_FIFO_tb: BID %0b expected 1", In_S2M.BID);
    if (~saw_wdata)
      $fatal(1, "axi4_FIFO_tb: write data never reached sink");
    @(posedge Clock);
    In_M2S.AWValid = 1'b0;
    In_M2S.WValid  = 1'b0;

    // Single-beat read
    @(posedge Clock);
    In_M2S.ARValid = 1'b1;
    In_M2S.ARAddr  = 32'h2000;
    In_M2S.ARID    = 1'b0;
    In_M2S.ARLen   = 8'd0;
    In_M2S.RReady  = 1'b1;

    forever begin
      @(posedge Clock);
      if ($time > 500_000)
        $fatal(1, "axi4_FIFO_tb: timeout read RValid");
      if (In_S2M.RValid & In_S2M.RLast) begin
        if (In_S2M.RResp != C_AXI4_RESPONSE_OKAY)
          $fatal(1, "axi4_FIFO_tb: RResp %0d", In_S2M.RResp);
        if (In_S2M.RID !== 1'b0)
          $fatal(1, "axi4_FIFO_tb: RID %0b expected 0", In_S2M.RID);
        if (In_S2M.RData[RDATA_HI:RDATA_LO] !== '0)
          $fatal(1, "axi4_FIFO_tb: sink RDATA field expected 0");
        break;
      end
    end
    @(posedge Clock);
    In_M2S.ARValid = 1'b0;

    disable fork;
    $display("PASS axi4_FIFO_tb");
    $finish;
  end

  initial begin
    #100us;
    $fatal(1, "axi4_FIFO_tb watchdog");
  end
endmodule
