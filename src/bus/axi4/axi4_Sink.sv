// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

import poc_axi4_full::*;

// verilator lint_off MULTITOP
module axi4_Sink #(
  parameter int ADDR_W = 32,
  parameter int DATA_W = 32,
  parameter int USER_W = 1,
  parameter int ID_W   = 1,
  parameter type m2s_t = axi4_full_types#(ADDR_W, DATA_W, USER_W, ID_W)::bus_m2s_t,
  parameter type s2m_t = axi4_full_types#(ADDR_W, DATA_W, USER_W, ID_W)::bus_s2m_t
) (
  input  logic Clock,
  input  logic Reset,

  input  m2s_t AXI4_M2S,
  output s2m_t AXI4_S2M
);
  import poc_axi4_common::*;
  import poc_vectors::*;

  localparam int ID_BITS   = poc_utils::downto_width(ID_W);
  localparam int WSTRB_W   = poc_utils::div_ceil(DATA_W, 8);
  localparam int WData_Pos  = 0;
  localparam int WBurst_Pos = 1;
  localparam int RData_Pos  = 2;
  localparam int RBurst_Pos = 3;
  localparam int Split[4] = '{
    DATA_W / 4,
    DATA_W / 4,
    DATA_W / 4,
    DATA_W - 3 * (DATA_W / 4)
  };
  localparam int SPLIT_Q     = DATA_W / 4;
  localparam int WDATA_LO    = 0;
  localparam int WDATA_HI    = SPLIT_Q - 1;
  localparam int WBURST_LO   = SPLIT_Q;
  localparam int WBURST_HI   = 2 * SPLIT_Q - 1;
  localparam int RDATA_LO    = 2 * SPLIT_Q;
  localparam int RDATA_HI    = 3 * SPLIT_Q - 1;
  localparam int RBURST_LO   = 3 * SPLIT_Q;
  localparam int RBURST_HI   = DATA_W - 1;

  typedef enum logic [1:0] {
    W_Idle,
    W_Write_data,
    W_Write_resp_OK,
    W_Write_resp_Error
  } wstate_t;

  typedef enum logic [1:0] {
    R_Idle,
    R_Read_send
  } rstate_t;

  wstate_t wstate     = W_Idle;
  wstate_t nxt_wstate;
  rstate_t rstate     = R_Idle;
  rstate_t nxt_rstate;

  logic [7:0]              AWLen_d = '0;
  logic [7:0]              AWLen;
  logic [7:0]              ARLen_d = '0;
  logic [7:0]              ARLen;
  logic [ID_BITS-1:0]      AWID_d  = '0;
  logic [ID_BITS-1:0]      AWID;
  logic [ID_BITS-1:0]      ARID_d  = '0;
  logic [ID_BITS-1:0]      ARID;

  logic WData_inc;
  logic WBurst_inc;
  logic [Split[WData_Pos]-1:0]  WData_Count  = '0;
  logic [Split[WBurst_Pos]-1:0] WBurst_Count = '0;
  logic RData_inc;
  logic RBurst_inc;
  logic [Split[RData_Pos]-1:0]  RData_Count  = '0;
  logic [Split[RBurst_Pos]-1:0] RBurst_Count = '0;

  logic WTransf_Inc;
  logic WTransf_Rst;
  logic [7:0] WTransf_count = '0;
  logic RTransf_Inc;
  logic RTransf_Rst;
  logic [7:0] RTransf_count = '0;

  logic Is_WriteData;
  logic Is_ReadData;

  assign AXI4_S2M.RUser = '0;
  assign AXI4_S2M.BUser = '0;

  assign AXI4_S2M.RData[WBURST_HI:WBURST_LO] = WBurst_Count;
  assign AXI4_S2M.RData[WDATA_HI:WDATA_LO]   = WData_Count;
  assign AXI4_S2M.RData[RBURST_HI:RBURST_LO] = RBurst_Count;
  assign AXI4_S2M.RData[RDATA_HI:RDATA_LO]   = RData_Count;

  assign WData_inc   = Is_WriteData & AXI4_S2M.WReady & AXI4_M2S.WValid;
  assign WTransf_Inc = WData_inc;
  assign WBurst_inc  = Is_WriteData & AXI4_S2M.WReady & AXI4_M2S.WValid & AXI4_M2S.WLast;
  assign WTransf_Rst = WBurst_inc;

  assign RData_inc   = Is_ReadData & AXI4_S2M.RValid & AXI4_M2S.RReady;
  assign RTransf_Inc = RData_inc;
  assign RBurst_inc  = Is_ReadData & AXI4_S2M.RValid & AXI4_M2S.RReady & AXI4_S2M.RLast;
  assign RTransf_Rst = RBurst_inc;

  always_ff @(posedge Clock) begin
    if (AXI4_M2S.AWValid & AXI4_S2M.AWReady)
      AWLen_d <= AXI4_M2S.AWLen;
  end
  assign AWLen = (AXI4_M2S.AWValid & AXI4_S2M.AWReady) ? AXI4_M2S.AWLen : AWLen_d;

  always_ff @(posedge Clock) begin
    if (AXI4_M2S.ARValid & AXI4_S2M.ARReady)
      ARLen_d <= AXI4_M2S.ARLen;
  end
  assign ARLen = (AXI4_M2S.ARValid & AXI4_S2M.ARReady) ? AXI4_M2S.ARLen : ARLen_d;

  assign AXI4_S2M.RLast = (unsigned'(ARLen) == RTransf_count);

  always_ff @(posedge Clock) begin
    if (AXI4_M2S.AWValid & AXI4_S2M.AWReady)
      AWID_d <= AXI4_M2S.AWID;
  end
  assign AWID = (AXI4_M2S.AWValid & AXI4_S2M.AWReady) ? AXI4_M2S.AWID : AWID_d;

  always_ff @(posedge Clock) begin
    if (AXI4_M2S.ARValid & AXI4_S2M.ARReady)
      ARID_d <= AXI4_M2S.ARID;
  end
  assign ARID = (AXI4_M2S.ARValid & AXI4_S2M.ARReady) ? AXI4_M2S.ARID : ARID_d;

  assign AXI4_S2M.BID = AWID;
  assign AXI4_S2M.RID = ARID;

  assign Is_WriteData = (wstate == W_Write_data);
  assign Is_ReadData  = (rstate == R_Read_send);

  assign AXI4_S2M.WReady = Is_WriteData;
  assign AXI4_S2M.RValid = Is_ReadData;

  always_comb begin
    nxt_wstate         = wstate;
    AXI4_S2M.AWReady   = 1'b0;
    AXI4_S2M.BResp     = C_AXI4_RESPONSE_OKAY;
    AXI4_S2M.BValid    = 1'b0;

    unique case (wstate)
      W_Idle: begin
        if (AXI4_M2S.AWValid) begin
          AXI4_S2M.AWReady = 1'b1;
          nxt_wstate       = W_Write_data;
        end
      end
      W_Write_data: begin
        if ((WTransf_count == unsigned'(AWLen)) &
            (AXI4_S2M.WReady & AXI4_M2S.WValid & AXI4_M2S.WLast))
          nxt_wstate = W_Write_resp_OK;
        else if (AXI4_S2M.WReady & AXI4_M2S.WValid & AXI4_M2S.WLast)
          nxt_wstate = W_Write_resp_Error;
      end
      W_Write_resp_OK: begin
        AXI4_S2M.BValid = 1'b1;
        if (AXI4_M2S.BReady)
          nxt_wstate = W_Idle;
      end
      W_Write_resp_Error: begin
        AXI4_S2M.BValid = 1'b1;
        AXI4_S2M.BResp  = C_AXI4_RESPONSE_DECODE_ERROR;
        if (AXI4_M2S.BReady)
          nxt_wstate = W_Idle;
      end
      default: nxt_wstate = W_Idle;
    endcase
  end

  always_comb begin
    nxt_rstate         = rstate;
    AXI4_S2M.ARReady   = 1'b0;
    AXI4_S2M.RResp     = C_AXI4_RESPONSE_OKAY;

    unique case (rstate)
      R_Idle: begin
        if (AXI4_M2S.ARValid) begin
          AXI4_S2M.ARReady = 1'b1;
          nxt_rstate       = R_Read_send;
        end
      end
      R_Read_send: begin
        if (AXI4_S2M.RLast & AXI4_S2M.RValid & AXI4_M2S.RReady)
          nxt_rstate = R_Idle;
      end
      default: nxt_rstate = R_Idle;
    endcase
  end

  always_ff @(posedge Clock) begin
    if (Reset) begin
      wstate <= W_Idle;
      rstate <= R_Idle;
    end else begin
      wstate <= nxt_wstate;
      rstate <= nxt_rstate;
    end
  end

  always_ff @(posedge Clock) begin
    if (Reset) begin
      WData_Count   <= '0;
      WBurst_Count  <= '0;
      RData_Count   <= '0;
      RBurst_Count  <= '0;
      WTransf_count <= '0;
      RTransf_count <= '0;
    end else begin
      if (WData_inc)
        WData_Count <= WData_Count + 1;
      if (WBurst_inc)
        WBurst_Count <= WBurst_Count + 1;
      if (RData_inc)
        RData_Count <= RData_Count + 1;
      if (RBurst_inc)
        RBurst_Count <= RBurst_Count + 1;
      if (WTransf_Rst)
        WTransf_count <= '0;
      else if (WTransf_Inc)
        WTransf_count <= WTransf_count + 1;
      if (RTransf_Rst)
        RTransf_count <= '0;
      else if (RTransf_Inc)
        RTransf_count <= RTransf_count + 1;
    end
  end

endmodule
