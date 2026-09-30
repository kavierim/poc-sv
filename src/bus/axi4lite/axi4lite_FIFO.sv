// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-29, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273
// VHDL: PoC/src/bus/axi4lite/axi4lite_FIFO.vhdl
// Note: Channel widths/offsets are elaborated as scalar localparams (Verilator 5
// cannot constant-fold isum_vec on dynamic int arrays in this context).

`timescale 1ns/1ps

module axi4lite_FIFO #(
  parameter int TRANSACTIONS = 2,
  parameter int ADDR_W       = 32,
  parameter int DATA_W       = 32
) (
  input  logic                                    Clock,
  input  logic                                    Reset,
  input  poc_axi4lite::T_AXI4Lite_Bus_M2S In_M2S,
  output poc_axi4lite::T_AXI4Lite_Bus_S2M In_S2M,
  output poc_axi4lite::T_AXI4Lite_Bus_M2S Out_M2S,
  input  poc_axi4lite::T_AXI4Lite_Bus_S2M Out_S2M
);
  import poc_axi4_common::*;
  import poc_axi4lite::*;
  import poc_utils::*;

  localparam int STRB_W     = div_ceil(DATA_W, 8);
  localparam int CACHE_W    = 4;
  localparam int PROTECT_W  = 3;
  localparam int RESPONSE_W = 2;

  localparam int AW_POS = 0;
  localparam int AR_POS = 1;
  localparam int W_POS  = 2;
  localparam int R_POS  = 3;
  localparam int B_POS  = 4;

  localparam int AW_W = ADDR_W + CACHE_W + PROTECT_W;
  localparam int AR_W = ADDR_W + CACHE_W + PROTECT_W;
  localparam int W_W  = DATA_W + STRB_W;
  localparam int R_W  = DATA_W + RESPONSE_W;
  localparam int B_W  = RESPONSE_W;

  localparam int OFF_AW = 0;
  localparam int OFF_AR = AW_W;
  localparam int OFF_W  = AW_W + AR_W;
  localparam int OFF_R  = AW_W + AR_W + W_W;
  localparam int OFF_B  = AW_W + AR_W + W_W + R_W;
  localparam int PACK_W = OFF_B + B_W;

  logic [0:4] In_Ready_vec;
  logic [0:4] In_Valid_vec;
  logic [0:4] Out_Ready_vec;
  logic [0:4] Out_Valid_vec;
  logic [PACK_W-1:0] DataFIFO_DataIn;
  logic [PACK_W-1:0] DataFIFO_DataOut;

  assign In_S2M.AWReady  = In_Ready_vec[AW_POS];
  assign In_S2M.ARReady  = In_Ready_vec[AR_POS];
  assign In_S2M.WReady   = In_Ready_vec[W_POS];
  assign Out_M2S.RReady  = In_Ready_vec[R_POS];
  assign Out_M2S.BReady  = In_Ready_vec[B_POS];

  assign In_Valid_vec[AW_POS] = In_M2S.AWValid;
  assign In_Valid_vec[AR_POS] = In_M2S.ARValid;
  assign In_Valid_vec[W_POS]  = In_M2S.WValid;
  assign In_Valid_vec[R_POS]  = Out_S2M.RValid;
  assign In_Valid_vec[B_POS]  = Out_S2M.BValid;

  assign Out_Ready_vec[AW_POS] = Out_S2M.AWReady;
  assign Out_Ready_vec[AR_POS] = Out_S2M.ARReady;
  assign Out_Ready_vec[W_POS]  = Out_S2M.WReady;
  assign Out_Ready_vec[R_POS]  = In_M2S.RReady;
  assign Out_Ready_vec[B_POS]  = In_M2S.BReady;

  assign Out_M2S.AWValid = Out_Valid_vec[AW_POS];
  assign Out_M2S.ARValid = Out_Valid_vec[AR_POS];
  assign Out_M2S.WValid  = Out_Valid_vec[W_POS];
  assign In_S2M.RValid   = Out_Valid_vec[R_POS];
  assign In_S2M.BValid   = Out_Valid_vec[B_POS];

  assign DataFIFO_DataIn[OFF_AW +: AW_W] = {In_M2S.AWProt, In_M2S.AWCache, In_M2S.AWAddr};
  assign DataFIFO_DataIn[OFF_AR +: AR_W] = {In_M2S.ARProt, In_M2S.ARCache, In_M2S.ARAddr};
  assign DataFIFO_DataIn[OFF_W  +: W_W]  = {In_M2S.WStrb, In_M2S.WData};
  assign DataFIFO_DataIn[OFF_R  +: R_W]  = {Out_S2M.RResp, Out_S2M.RData};
  assign DataFIFO_DataIn[OFF_B  +: B_W]  = Out_S2M.BResp;

  // Unpack uses the same field order as pack above (LSB = Addr/Data).
  assign Out_M2S.AWAddr  = DataFIFO_DataOut[OFF_AW +: ADDR_W];
  assign Out_M2S.AWCache = DataFIFO_DataOut[OFF_AW+ADDR_W +: CACHE_W];
  assign Out_M2S.AWProt  = DataFIFO_DataOut[OFF_AW+ADDR_W+CACHE_W +: PROTECT_W];
  assign Out_M2S.ARAddr  = DataFIFO_DataOut[OFF_AR +: ADDR_W];
  assign Out_M2S.ARCache = DataFIFO_DataOut[OFF_AR+ADDR_W +: CACHE_W];
  assign Out_M2S.ARProt  = DataFIFO_DataOut[OFF_AR+ADDR_W+CACHE_W +: PROTECT_W];
  assign Out_M2S.WData   = DataFIFO_DataOut[OFF_W +: DATA_W];
  assign Out_M2S.WStrb   = DataFIFO_DataOut[OFF_W+DATA_W +: STRB_W];
  assign In_S2M.RData    = DataFIFO_DataOut[OFF_R +: DATA_W];
  assign In_S2M.RResp    = T_AXI4_Response'(DataFIFO_DataOut[OFF_R+DATA_W +: RESPONSE_W]);
  assign In_S2M.BResp    = T_AXI4_Response'(DataFIFO_DataOut[OFF_B +: RESPONSE_W]);

  for (genvar gi = 0; gi <= 4; gi++) begin : gen_fifo
    localparam int CH_W = (gi == 0) ? AW_W :
                          (gi == 1) ? AR_W :
                          (gi == 2) ? W_W  :
                          (gi == 3) ? R_W  : B_W;
    localparam int CH_OFF = (gi == 0) ? OFF_AW :
                            (gi == 1) ? OFF_AR :
                            (gi == 2) ? OFF_W  :
                            (gi == 3) ? OFF_R  : OFF_B;

    logic                 DataFIFO_put;
    logic [CH_W-1:0]      DataFIFO_DataIn_i;
    logic [CH_W-1:0]      DataFIFO_DataOut_i;
    logic                 DataFIFO_Full;
    logic                 DataFIFO_got;
    logic                 DataFIFO_Valid;

    assign DataFIFO_put      = In_Valid_vec[gi] & ~DataFIFO_Full;
    assign In_Ready_vec[gi]  = ~DataFIFO_Full;
    assign DataFIFO_DataIn_i = DataFIFO_DataIn[CH_OFF +: CH_W];
    assign DataFIFO_DataOut[CH_OFF +: CH_W] = DataFIFO_DataOut_i;
    assign DataFIFO_got      = Out_Ready_vec[gi];
    assign Out_Valid_vec[gi] = DataFIFO_Valid;

    if (TRANSACTIONS > 3) begin : gen_deep_fifo
      fifo_cc_got #(
        .DATA_BITS        (CH_W),
        .MIN_DEPTH        (TRANSACTIONS),
        .DATA_REG         (1'b0),
        .STATE_REG        (1'b1),
        .OUTPUT_REG       (1'b0),
        .EMPTY_STATE_BITS (0),
        .FILL_STATE_BITS  (0)
      ) DataFifo (
        .Clock      (Clock),
        .Reset      (Reset),
        .Put        (DataFIFO_put),
        .DataIn     (DataFIFO_DataIn_i),
        .Full       (DataFIFO_Full),
        .EmptyState (),
        .Got        (DataFIFO_got),
        .DataOut    (DataFIFO_DataOut_i),
        .Valid      (DataFIFO_Valid),
        .FillState  ()
      );
    end else begin : gen_stage
      fifo_Stage #(
        .DATA_BITS    (CH_W),
        .STAGES       (TRANSACTIONS + 1),
        .LIGHT_WEIGHT (1'b1)
      ) Stage (
        .Clock   (Clock),
        .Reset   (Reset),
        .Put     (DataFIFO_put),
        .DataIn  (DataFIFO_DataIn_i),
        .Full    (DataFIFO_Full),
        .Valid   (DataFIFO_Valid),
        .DataOut (DataFIFO_DataOut_i),
        .Got     (DataFIFO_got)
      );
    end
  end

endmodule
