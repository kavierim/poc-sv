// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-28, Kari Vierimaa, Kempele, Finland.
// Self-checking Verilator testbench for axi4_Mux.

`timescale 1ns/1ps

module axi4_Mux_tb;
  import poc_axi4_full::*;
  import poc_axi4_common::*;

  localparam int ADDR_W = 32;
  localparam int DATA_W = 32;
  localparam int USER_W = 1;
  localparam int ID_W   = 1;
  localparam int PORTS  = 2;

  localparam int WDATA_LO = 0;
  localparam int WDATA_HI = (DATA_W / 4) - 1;
  localparam int RDATA_LO = 2 * (DATA_W / 4);
  localparam int RDATA_HI = 3 * (DATA_W / 4) - 1;

  typedef axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::bus_m2s_t m2s_t;
  typedef axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::bus_s2m_t s2m_t;

  logic Clock = 0;
  logic Reset = 1;

  m2s_t In_M2S[PORTS];
  s2m_t In_S2M[PORTS];
  m2s_t Out_M2S;
  s2m_t Out_S2M;

  axi4_Mux #(
    .PORTS(PORTS), .ADDR_W(ADDR_W), .DATA_W(DATA_W), .USER_W(USER_W), .ID_W(ID_W)
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

    In_M2S[0] = axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::initialize_bus_m2s(1'b0);
    In_M2S[1] = axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::initialize_bus_m2s(1'b0);

    repeat (4) @(posedge Clock);
    Reset = 0;

    saw_wdata = 1'b0;
    fork
      forever begin
        @(posedge Clock);
        if (Out_M2S.WValid && Out_S2M.WReady) begin
          if (Out_M2S.WData !== 32'hDEADBEEF)
            $fatal(1, "axi4_Mux_tb: sink WData %h expected DEADBEEF", Out_M2S.WData);
          saw_wdata = 1'b1;
        end
      end
    join_none

    // Single-beat write on port 0
    @(posedge Clock);
    In_M2S[0].AWValid = 1'b1;
    In_M2S[0].AWAddr  = 32'h1000;
    In_M2S[0].AWID    = 1'b0;
    In_M2S[0].AWLen   = 8'd0;
    In_M2S[0].WValid  = 1'b1;
    In_M2S[0].WData   = 32'hDEADBEEF;
    In_M2S[0].WLast   = 1'b1;
    In_M2S[0].WStrb   = '1;
    In_M2S[0].BReady  = 1'b1;

    while (~(In_S2M[0].BValid)) begin
      @(posedge Clock);
      if ($time > 500_000)
        $fatal(1, "axi4_Mux_tb: timeout waiting write BValid");
    end
    if (In_S2M[0].BResp != C_AXI4_RESPONSE_OKAY)
      $fatal(1, "axi4_Mux_tb: unexpected BResp %0d", In_S2M[0].BResp);
    if (In_S2M[0].BID !== 1'b0)
      $fatal(1, "axi4_Mux_tb: BID %0b expected AWID 0", In_S2M[0].BID);
    if (~saw_wdata)
      $fatal(1, "axi4_Mux_tb: write data never reached sink");
    @(posedge Clock);

    In_M2S[0].AWValid = 1'b0;
    In_M2S[0].WValid  = 1'b0;

    // Single-beat read on port 1
    @(posedge Clock);
    In_M2S[1].ARValid = 1'b1;
    In_M2S[1].ARAddr  = 32'h2000;
    In_M2S[1].ARID    = 1'b1;
    In_M2S[1].ARLen   = 8'd0;
    In_M2S[1].RReady  = 1'b1;

    forever begin
      @(posedge Clock);
      if ($time > 500_000)
        $fatal(1, "axi4_Mux_tb: timeout waiting read RValid");
      if (In_S2M[1].RValid & In_S2M[1].RLast) begin
        if (In_S2M[1].RResp != C_AXI4_RESPONSE_OKAY)
          $fatal(1, "axi4_Mux_tb: unexpected RResp %0d", In_S2M[1].RResp);
        if (In_S2M[1].RID !== 1'b1)
          $fatal(1, "axi4_Mux_tb: RID %0b expected ARID 1", In_S2M[1].RID);
        if (In_S2M[1].RData[RDATA_HI:RDATA_LO] !== '0)
          $fatal(1, "axi4_Mux_tb: sink RDATA field %0d expected 0 on first beat",
                In_S2M[1].RData[RDATA_HI:RDATA_LO]);
        break;
      end
    end
    @(posedge Clock);

    disable fork;

    $display("axi4_Mux_tb: PASS");
    $finish;
  end

  initial begin
    #100us;
    $fatal(1, "axi4_Mux_tb watchdog");
  end
endmodule
