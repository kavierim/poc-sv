// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-29, Kari Vierimaa, Kempele, Finland.
// Self-checking Verilator testbench for axi4_AXI4Lite_Converter (ID remap + payload).

`timescale 1ns/1ps

module axi4_AXI4Lite_Converter_tb;
  import poc_axi4_full::*;
  import poc_axi4_common::*;
  import poc_axi4lite::*;

  localparam int ADDR_W = 32;
  localparam int DATA_W = 32;
  localparam int USER_W = 1;
  localparam int ID_W   = 4;

  typedef axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::bus_m2s_t full_m2s_t;
  typedef axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::bus_s2m_t full_s2m_t;
  typedef axi4lite_sized#(ADDR_W, DATA_W)::bus_m2s_t lite_m2s_t;
  typedef axi4lite_sized#(ADDR_W, DATA_W)::bus_s2m_t lite_s2m_t;

  logic Clock = 0;
  logic Reset = 1;

  full_m2s_t In_M2S;
  full_s2m_t In_S2M;
  lite_m2s_t Out_M2S;
  lite_s2m_t Out_S2M;

  logic aw_pend, w_pend, ar_pend;

  axi4_AXI4Lite_Converter #(
    .ADDR_W(ADDR_W), .DATA_W(DATA_W), .USER_W(USER_W), .ID_W(ID_W),
    .RESPONSE_FIFO_DEPTH(4)
  ) dut (
    .Clock(Clock), .Reset(Reset),
    .In_M2S(In_M2S), .In_S2M(In_S2M),
    .Out_M2S(Out_M2S), .Out_S2M(Out_S2M)
  );

  always #5 Clock = ~Clock;

  always_ff @(posedge Clock) begin
    if (Reset) begin
      aw_pend <= 1'b0;
      w_pend  <= 1'b0;
      ar_pend <= 1'b0;
      Out_S2M <= initialize_axi4lite_bus_s2m(1'b0);
    end else begin
      Out_S2M.AWReady <= ~aw_pend;
      Out_S2M.WReady  <= ~w_pend;
      Out_S2M.ARReady <= ~ar_pend;

      if (Out_M2S.AWValid && Out_S2M.AWReady)
        aw_pend <= 1'b1;
      if (Out_M2S.WValid && Out_S2M.WReady) begin
        w_pend <= 1'b1;
        if (Out_M2S.WData !== 32'hA5A5_5A5A)
          $fatal(1, "converter: lite WData %h", Out_M2S.WData);
        if (Out_M2S.AWValid && Out_S2M.AWReady && Out_M2S.AWAddr !== 32'h40)
          $fatal(1, "converter: lite AWAddr %h", Out_M2S.AWAddr);
      end

      Out_S2M.BValid <= aw_pend & w_pend;
      Out_S2M.BResp  <= C_AXI4_RESPONSE_OKAY;
      if (aw_pend && w_pend && Out_M2S.BReady) begin
        aw_pend <= 1'b0;
        w_pend  <= 1'b0;
      end

      if (Out_M2S.ARValid && Out_S2M.ARReady) begin
        ar_pend <= 1'b1;
        if (Out_M2S.ARAddr !== 32'h80)
          $fatal(1, "converter: lite ARAddr %h", Out_M2S.ARAddr);
      end
      Out_S2M.RValid <= ar_pend;
      Out_S2M.RResp  <= C_AXI4_RESPONSE_OKAY;
      Out_S2M.RData  <= 32'h1234_5678;
      if (ar_pend && Out_M2S.RReady)
        ar_pend <= 1'b0;
    end
  end

  initial begin
    In_M2S = axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::initialize_bus_m2s(1'b0);

    repeat (4) @(posedge Clock);
    Reset = 0;

    // Write with non-zero AWID — must come back on BID
    @(posedge Clock);
    In_M2S.AWValid = 1'b1;
    In_M2S.AWAddr  = 32'h40;
    In_M2S.AWID    = 4'hA;
    In_M2S.AWLen   = 8'd0;
    In_M2S.WValid  = 1'b1;
    In_M2S.WData   = 32'hA5A5_5A5A;
    In_M2S.WLast   = 1'b1;
    In_M2S.WStrb   = '1;
    In_M2S.BReady  = 1'b1;

    while (~In_S2M.BValid) begin
      @(posedge Clock);
      if ($time > 500_000)
        $fatal(1, "converter: timeout BValid");
    end
    if (In_S2M.BResp != C_AXI4_RESPONSE_OKAY)
      $fatal(1, "converter: BResp %0d", In_S2M.BResp);
    if (In_S2M.BID !== 4'hA)
      $fatal(1, "converter: BID %h expected A", In_S2M.BID);
    @(posedge Clock);
    In_M2S.AWValid = 1'b0;
    In_M2S.WValid  = 1'b0;

    // Read with ARID — RID + RData + RLast
    @(posedge Clock);
    In_M2S.ARValid = 1'b1;
    In_M2S.ARAddr  = 32'h80;
    In_M2S.ARID    = 4'h5;
    In_M2S.ARLen   = 8'd0;
    In_M2S.RReady  = 1'b1;

    forever begin
      @(posedge Clock);
      if ($time > 500_000)
        $fatal(1, "converter: timeout RValid");
      if (In_S2M.RValid) begin
        if (~In_S2M.RLast)
          $fatal(1, "converter: RLast must be 1 for Lite conversion");
        if (In_S2M.RResp != C_AXI4_RESPONSE_OKAY)
          $fatal(1, "converter: RResp %0d", In_S2M.RResp);
        if (In_S2M.RID !== 4'h5)
          $fatal(1, "converter: RID %h expected 5", In_S2M.RID);
        if (In_S2M.RData !== 32'h1234_5678)
          $fatal(1, "converter: RData %h", In_S2M.RData);
        break;
      end
    end
    @(posedge Clock);
    In_M2S.ARValid = 1'b0;

    $display("PASS axi4_AXI4Lite_Converter_tb");
    $finish;
  end

  initial begin
    #100us;
    $fatal(1, "axi4_AXI4Lite_Converter_tb watchdog");
  end
endmodule
