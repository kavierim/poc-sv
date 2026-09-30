// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-28, Kari Vierimaa, Kempele, Finland.
// Self-checking Verilator testbench for axi4_DeMux.

`timescale 1ns/1ps

module axi4_DeMux_tb;
  import poc_axi4_full::*;
  import poc_axi4_common::*;

  localparam int ADDR_W = 32;
  localparam int DATA_W = 32;
  localparam int USER_W = 1;
  localparam int ID_W   = 1;
  localparam int PORTS  = 2;

  // Port 0: 0x1000–0x1FFF; port 1: 0x1400–0x1BFF (overlap 0x1400–0x1BFF → lowest index).
  localparam logic [31:0] BASE_ADDR[PORTS] = '{32'h0000_1000, 32'h0000_1400};
  localparam logic [31:0] BASE_MASK[PORTS] = '{32'h0000_0FFF, 32'h0000_07FF};

  typedef axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::bus_m2s_t m2s_t;
  typedef axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::bus_s2m_t s2m_t;

  logic Clock = 0;
  logic Reset = 1;

  m2s_t In_M2S;
  s2m_t In_S2M;
  m2s_t Out_M2S[PORTS];
  s2m_t Out_S2M[PORTS];
  s2m_t term_s2m[PORTS];
  logic block_p0_aw = 1'b0;

  axi4_DeMux #(
    .PORTS(PORTS),
    .ADDR_W(ADDR_W),
    .DATA_W(DATA_W),
    .USER_W(USER_W),
    .ID_W(ID_W),
    .BASE_ADDRESS(BASE_ADDR),
    .BASE_ADDRESS_MASK(BASE_MASK)
  ) dut (
    .Clock(Clock), .Reset(Reset),
    .In_M2S(In_M2S), .In_S2M(In_S2M),
    .Out_M2S(Out_M2S), .Out_S2M(Out_S2M)
  );

  for (genvar i = 0; i < PORTS; i++) begin : slaves
    axi4_Termination_Subordinate #(
      .ADDR_W(ADDR_W), .DATA_W(DATA_W), .USER_W(USER_W), .ID_W(ID_W),
      .RESPONSE_CODE(C_AXI4_RESPONSE_OKAY)
    ) term (
      .Clock(Clock), .Reset(Reset),
      .AXI4_M2S(Out_M2S[i]), .AXI4_S2M(term_s2m[i])
    );
  end

  always_comb begin
    for (int i = 0; i < PORTS; i++) begin
      Out_S2M[i] = term_s2m[i];
      if (i == 0 && block_p0_aw)
        Out_S2M[i].AWReady = 1'b0;
    end
  end

  always #5 Clock = ~Clock;

  task automatic idle_m2s();
    In_M2S = axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::initialize_bus_m2s(1'b0);
    In_M2S.BReady = 1'b1;
    In_M2S.RReady = 1'b1;
  endtask

  task automatic test_aw_before_w();
    idle_m2s();
    @(posedge Clock);
    In_M2S.AWValid = 1'b1;
    In_M2S.AWAddr  = 32'h0000_1004;
    In_M2S.AWID    = 1'b1;
    In_M2S.WValid  = 1'b0;

    wait (In_S2M.AWReady);
    @(posedge Clock);
    In_M2S.AWValid = 1'b0;

    @(posedge Clock);
    In_M2S.WValid  = 1'b1;
    In_M2S.WData   = 32'h55AA55AA;
    In_M2S.WLast   = 1'b1;
    In_M2S.WStrb   = '1;

    wait (In_S2M.BValid);
    @(posedge Clock);
    if (In_S2M.BResp != C_AXI4_RESPONSE_OKAY)
      $fatal(1, "axi4_DeMux_tb: port0 write BResp %0d", In_S2M.BResp);
    if (In_S2M.BID != 1'b1)
      $fatal(1, "axi4_DeMux_tb: BID %0b expected AWID 1", In_S2M.BID);
    In_M2S.WValid = 1'b0;
  endtask

  task automatic test_overlap_lowest_port();
    logic saw_p0_aw;
    logic saw_p1_aw;
    idle_m2s();
    saw_p0_aw = 1'b0;
    saw_p1_aw = 1'b0;

    fork
      forever begin
        @(posedge Clock);
        if (Out_M2S[0].AWValid && Out_S2M[0].AWReady)
          saw_p0_aw = 1'b1;
        if (Out_M2S[1].AWValid && Out_S2M[1].AWReady)
          saw_p1_aw = 1'b1;
      end
    join_none

    @(posedge Clock);
    In_M2S.AWValid = 1'b1;
    In_M2S.AWAddr  = 32'h0000_1500;
    In_M2S.AWID    = 1'b0;
    In_M2S.WValid  = 1'b1;
    In_M2S.WData   = 32'h0BAD_C0DE;
    In_M2S.WLast   = 1'b1;
    In_M2S.WStrb   = '1;

    wait (In_S2M.BValid);
    @(posedge Clock);
    if (In_S2M.BResp != C_AXI4_RESPONSE_OKAY)
      $fatal(1, "axi4_DeMux_tb: overlap write BResp %0d", In_S2M.BResp);
    if (~saw_p0_aw)
      $fatal(1, "axi4_DeMux_tb: overlap AW must hit port 0");
    if (saw_p1_aw)
      $fatal(1, "axi4_DeMux_tb: overlap AW must not hit port 1");
    In_M2S.AWValid = 1'b0;
    In_M2S.WValid  = 1'b0;
    disable fork;
  endtask

  task automatic pulse_reset();
    Reset = 1'b1;
    block_p0_aw = 1'b0;
    repeat (3) @(posedge Clock);
    Reset = 1'b0;
    repeat (2) @(posedge Clock);
  endtask

  task automatic test_w_before_aw();
    pulse_reset();
    idle_m2s();

    block_p0_aw = 1'b1;

    @(posedge Clock);
    In_M2S.AWValid = 1'b1;
    In_M2S.AWAddr  = 32'h0000_1008;
    In_M2S.AWID    = 1'b0;
    In_M2S.WValid  = 1'b1;
    In_M2S.WData   = 32'h1234_5678;
    In_M2S.WLast   = 1'b1;
    In_M2S.WStrb   = '1;

    wait (Out_M2S[0].WValid && Out_S2M[0].WReady);
    @(posedge Clock);
    In_M2S.WValid = 1'b0;

    block_p0_aw = 1'b0;
    wait (Out_M2S[0].AWValid && Out_S2M[0].AWReady);
    @(posedge Clock);
    In_M2S.AWValid = 1'b0;

    wait (In_S2M.BValid);
    @(posedge Clock);
    if (In_S2M.BResp != C_AXI4_RESPONSE_OKAY)
      $fatal(1, "axi4_DeMux_tb: W-before-AW BResp %0d", In_S2M.BResp);
    if (In_S2M.BID != 1'b0)
      $fatal(1, "axi4_DeMux_tb: W-before-AW BID %0b expected 0", In_S2M.BID);
    while (In_S2M.BValid)
      @(posedge Clock);

    repeat (8) begin
      @(posedge Clock);
      if (In_S2M.BValid)
        $fatal(1, "axi4_DeMux_tb: extra BValid (double OoO slot?)");
    end
  endtask

  task automatic test_read_port0_sideband();
    idle_m2s();
    @(posedge Clock);
    In_M2S.ARValid  = 1'b1;
    In_M2S.ARAddr   = 32'h0000_1500;
    In_M2S.ARID     = 1'b1;
    In_M2S.ARLen    = 8'd0;
    In_M2S.ARCache  = 4'b1010;
    In_M2S.ARProt   = 3'b101;
    In_M2S.ARQOS    = 4'b1100;
    In_M2S.ARRegion = 4'b0011;

    fork
      begin
        wait (Out_M2S[0].ARValid);
        if (Out_M2S[0].ARCache != 4'b1010)
          $fatal(1, "axi4_DeMux_tb: port0 ARCache %b", Out_M2S[0].ARCache);
        if (Out_M2S[0].ARProt != 3'b101)
          $fatal(1, "axi4_DeMux_tb: port0 ARProt %b", Out_M2S[0].ARProt);
        if (Out_M2S[0].ARQOS != 4'b1100)
          $fatal(1, "axi4_DeMux_tb: port0 ARQOS %b", Out_M2S[0].ARQOS);
        if (Out_M2S[0].ARRegion != 4'b0011)
          $fatal(1, "axi4_DeMux_tb: port0 ARRegion %b", Out_M2S[0].ARRegion);
      end
    join_none

    wait (In_S2M.RValid);
    @(posedge Clock);
    if (In_S2M.RResp != C_AXI4_RESPONSE_OKAY)
      $fatal(1, "axi4_DeMux_tb: overlap-region read RResp %0d", In_S2M.RResp);
    if (In_S2M.RID != 1'b1)
      $fatal(1, "axi4_DeMux_tb: RID %0b expected ARID 1", In_S2M.RID);
    In_M2S.ARValid = 1'b0;
    disable fork;
  endtask

  initial begin
    In_M2S = axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::initialize_bus_m2s(1'b0);

    repeat (4) @(posedge Clock);
    Reset = 0;

    test_aw_before_w();
    test_overlap_lowest_port();
    test_w_before_aw();
    test_read_port0_sideband();

    $display("axi4_DeMux_tb: PASS");
    $finish;
  end

  initial begin
    #200us;
    $fatal(1, "axi4_DeMux_tb watchdog");
  end
endmodule
