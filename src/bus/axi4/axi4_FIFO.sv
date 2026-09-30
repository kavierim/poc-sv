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
module axi4_FIFO #(
  parameter int ADDR_W = 32,
  parameter int DATA_W = 32,
  parameter int USER_W = 1,
  parameter int ID_W   = 1,
  parameter int FRAMES = 0,
  parameter int FRAME_DEPTH = 1,
  parameter type m2s_t = axi4_full_types#(ADDR_W, DATA_W, USER_W, ID_W)::bus_m2s_t,
  parameter type s2m_t = axi4_full_types#(ADDR_W, DATA_W, USER_W, ID_W)::bus_s2m_t
) (
  input  logic Clock,
  input  logic Reset,

  input  m2s_t In_M2S,
  output s2m_t In_S2M,

  output m2s_t Out_M2S,
  input  s2m_t Out_S2M
);
  import poc_utils::*;

  localparam int ID_BITS   = downto_width(ID_W);
  localparam int USER_BITS = downto_width(USER_W);
  localparam int WSTRB_W   = div_ceil(DATA_W, 8);

  localparam int AW_W = ID_BITS + USER_BITS + ADDR_W + 4 + 3 + 8 + 3 + 2 + 1 + 4 + 4;
  localparam int AR_W = AW_W;
  localparam int W_W  = USER_BITS + WSTRB_W + DATA_W + 1;
  localparam int R_W  = ID_BITS + USER_BITS + 2 + DATA_W + 1;
  localparam int B_W  = ID_BITS + USER_BITS + 2;

  localparam int OFF_AW = 0;
  localparam int OFF_AR = AW_W;
  localparam int OFF_W  = AW_W + AR_W;
  localparam int OFF_R  = AW_W + AR_W + W_W;
  localparam int OFF_B  = AW_W + AR_W + W_W + R_W;

  logic [4:0] In_Ready_vec;
  logic [4:0] In_Valid_vec;
  logic [4:0] Out_Ready_vec;
  logic [4:0] Out_Valid_vec;
  logic [OFF_B + B_W-1:0] DataFIFO_DataIn;
  logic [OFF_B + B_W-1:0] DataFIFO_DataOut;

  function automatic logic [AW_W-1:0] pack_aw(
    input logic [ID_BITS-1:0] awid,
    input logic [USER_BITS-1:0] awuser,
    input logic [ADDR_W-1:0] awaddr,
    input logic [3:0] awcache,
    input logic [2:0] awprot,
    input logic [7:0] awlen,
    input logic [2:0] awsize,
    input logic [1:0] awburst,
    input logic awlock,
    input logic [3:0] awqos,
    input logic [3:0] awregion
  );
    logic [AW_W-1:0] v;
    int p = 0;
    v[p+:ID_BITS] = awid; p += ID_BITS;
    v[p+:USER_BITS] = awuser; p += USER_BITS;
    v[p+:ADDR_W] = awaddr; p += ADDR_W;
    v[p+:4] = awcache; p += 4;
    v[p+:3] = awprot; p += 3;
    v[p+:8] = awlen; p += 8;
    v[p+:3] = awsize; p += 3;
    v[p+:2] = awburst; p += 2;
    v[p+:1] = awlock; p += 1;
    v[p+:4] = awqos; p += 4;
    v[p+:4] = awregion;
    return v;
  endfunction

  function automatic void unpack_aw(
    input logic [AW_W-1:0] v,
    output logic [ID_BITS-1:0] awid,
    output logic [USER_BITS-1:0] awuser,
    output logic [ADDR_W-1:0] awaddr,
    output logic [3:0] awcache,
    output logic [2:0] awprot,
    output logic [7:0] awlen,
    output logic [2:0] awsize,
    output logic [1:0] awburst,
    output logic awlock,
    output logic [3:0] awqos,
    output logic [3:0] awregion
  );
    int p = 0;
    awid = v[p+:ID_BITS]; p += ID_BITS;
    awuser = v[p+:USER_BITS]; p += USER_BITS;
    awaddr = v[p+:ADDR_W]; p += ADDR_W;
    awcache = v[p+:4]; p += 4;
    awprot = v[p+:3]; p += 3;
    awlen = v[p+:8]; p += 8;
    awsize = v[p+:3]; p += 3;
    awburst = v[p+:2]; p += 2;
    awlock = v[p+:1]; p += 1;
    awqos = v[p+:4]; p += 4;
    awregion = v[p+:4];
  endfunction

  assign DataFIFO_DataIn[OFF_AW+:AW_W] = pack_aw(
    In_M2S.AWID, In_M2S.AWUser, In_M2S.AWAddr, In_M2S.AWCache, In_M2S.AWProt,
    In_M2S.AWLen, In_M2S.AWSize, In_M2S.AWBurst, In_M2S.AWLock[0], In_M2S.AWQOS, In_M2S.AWRegion
  );
  assign DataFIFO_DataIn[OFF_AR+:AR_W] = pack_aw(
    In_M2S.ARID, In_M2S.ARUser, In_M2S.ARAddr, In_M2S.ARCache, In_M2S.ARProt,
    In_M2S.ARLen, In_M2S.ARSize, In_M2S.ARBurst, In_M2S.ARLock[0], In_M2S.ARQOS, In_M2S.ARRegion
  );
  assign DataFIFO_DataIn[OFF_W+:W_W] = {In_M2S.WUser, In_M2S.WStrb, In_M2S.WData, In_M2S.WLast};
  assign DataFIFO_DataIn[OFF_R+:R_W] = {Out_S2M.RID, Out_S2M.RUser, Out_S2M.RResp, Out_S2M.RData, Out_S2M.RLast};
  assign DataFIFO_DataIn[OFF_B+:B_W] = {Out_S2M.BID, Out_S2M.BUser, Out_S2M.BResp};

  logic awlock_unpack;
  logic arlock_unpack;

  always_comb begin
    unpack_aw(
      DataFIFO_DataOut[OFF_AW+:AW_W],
      Out_M2S.AWID, Out_M2S.AWUser, Out_M2S.AWAddr, Out_M2S.AWCache, Out_M2S.AWProt,
      Out_M2S.AWLen, Out_M2S.AWSize, Out_M2S.AWBurst, awlock_unpack, Out_M2S.AWQOS, Out_M2S.AWRegion
    );
    unpack_aw(
      DataFIFO_DataOut[OFF_AR+:AR_W],
      Out_M2S.ARID, Out_M2S.ARUser, Out_M2S.ARAddr, Out_M2S.ARCache, Out_M2S.ARProt,
      Out_M2S.ARLen, Out_M2S.ARSize, Out_M2S.ARBurst, arlock_unpack, Out_M2S.ARQOS, Out_M2S.ARRegion
    );
  end
  assign Out_M2S.AWLock = '{awlock_unpack};
  assign Out_M2S.ARLock = '{arlock_unpack};
  assign {Out_M2S.WUser, Out_M2S.WStrb, Out_M2S.WData, Out_M2S.WLast} = DataFIFO_DataOut[OFF_W+:W_W];
  assign {In_S2M.RID, In_S2M.RUser, In_S2M.RResp, In_S2M.RData, In_S2M.RLast} = DataFIFO_DataOut[OFF_R+:R_W];
  assign {In_S2M.BID, In_S2M.BUser, In_S2M.BResp} = DataFIFO_DataOut[OFF_B+:B_W];

  assign In_S2M.AWReady = In_Ready_vec[0];
  assign In_S2M.ARReady = In_Ready_vec[1];
  assign In_S2M.WReady  = In_Ready_vec[2];
  assign Out_M2S.RReady = In_Ready_vec[3];
  assign Out_M2S.BReady = In_Ready_vec[4];

  assign In_Valid_vec[0] = In_M2S.AWValid;
  assign In_Valid_vec[1] = In_M2S.ARValid;
  assign In_Valid_vec[2] = In_M2S.WValid;
  assign In_Valid_vec[3] = Out_S2M.RValid;
  assign In_Valid_vec[4] = Out_S2M.BValid;

  assign Out_Ready_vec[0] = Out_S2M.AWReady;
  assign Out_Ready_vec[1] = Out_S2M.ARReady;
  assign Out_Ready_vec[2] = Out_S2M.WReady;
  assign Out_Ready_vec[3] = In_M2S.RReady;
  assign Out_Ready_vec[4] = In_M2S.BReady;

  assign Out_M2S.AWValid = Out_Valid_vec[0];
  assign Out_M2S.ARValid = Out_Valid_vec[1];
  assign Out_M2S.WValid  = Out_Valid_vec[2];
  assign In_S2M.RValid   = Out_Valid_vec[3];
  assign In_S2M.BValid   = Out_Valid_vec[4];

  for (genvar i = 0; i < 5; i++) begin : gen_ch
    localparam int CH_W = (i == 0) ? AW_W : (i == 1) ? AR_W : (i == 2) ? W_W : (i == 3) ? R_W : B_W;
    localparam int CH_OFF = (i == 0) ? OFF_AW : (i == 1) ? OFF_AR : (i == 2) ? OFF_W : (i == 3) ? OFF_R : OFF_B;
    localparam int CH_MIN = (i <= 1 || i == 4) ? FRAMES : FRAMES * FRAME_DEPTH;

    logic                 DataFIFO_put;
    logic [CH_W-1:0]      DataFIFO_DataIn_i;
    logic [CH_W-1:0]      DataFIFO_DataOut_i;
    logic                 DataFIFO_Full;
    logic                 DataFIFO_got;
    logic                 DataFIFO_Valid;

    assign DataFIFO_put      = In_Valid_vec[i] & ~DataFIFO_Full;
    assign In_Ready_vec[i]   = ~DataFIFO_Full;
    assign DataFIFO_DataIn_i = DataFIFO_DataIn[CH_OFF+:CH_W];
    assign DataFIFO_DataOut[CH_OFF+:CH_W] = DataFIFO_DataOut_i;
    assign DataFIFO_got      = Out_Ready_vec[i];
    assign Out_Valid_vec[i]  = DataFIFO_Valid;

    if (FRAMES > 3) begin : gen_cc
      fifo_cc_got #(
        .DATA_BITS(CH_W),
        .MIN_DEPTH(CH_MIN),
        .STATE_REG(1'b1)
      ) DataFifo (
        .Clock   (Clock),
        .Reset   (Reset),
        .Put     (DataFIFO_put),
        .DataIn  (DataFIFO_DataIn_i),
        .Full    (DataFIFO_Full),
        .Got     (DataFIFO_got),
        .DataOut (DataFIFO_DataOut_i),
        .Valid   (DataFIFO_Valid),
        .EmptyState('0),
        .FillState('0)
      );
    end else begin : gen_stage
      fifo_Stage #(
        .DATA_BITS(CH_W),
        .STAGES   (FRAMES + 1),
        .LIGHT_WEIGHT((i == 0) || (i == 1) || (i == 4))
      ) Stage (
        .Clock  (Clock),
        .Reset  (Reset),
        .Put    (DataFIFO_put),
        .DataIn (DataFIFO_DataIn_i),
        .Full   (DataFIFO_Full),
        .Valid  (DataFIFO_Valid),
        .DataOut(DataFIFO_DataOut_i),
        .Got    (DataFIFO_got)
      );
    end
  end

endmodule
