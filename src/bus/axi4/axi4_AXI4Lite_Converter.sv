// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

import poc_axi4_full::*;
import poc_axi4lite::*;

// verilator lint_off MULTITOP
module axi4_AXI4Lite_Converter #(
  parameter int ADDR_W = 32,
  parameter int DATA_W = 32,
  parameter int USER_W = 1,
  parameter int ID_W   = 1,
  parameter int LITE_ADDR_W = ADDR_W,
  parameter int LITE_DATA_W = DATA_W,
  parameter int RESPONSE_FIFO_DEPTH = 16,
  parameter type full_m2s_t = axi4_full_types#(ADDR_W, DATA_W, USER_W, ID_W)::bus_m2s_t,
  parameter type full_s2m_t = axi4_full_types#(ADDR_W, DATA_W, USER_W, ID_W)::bus_s2m_t,
  parameter type lite_m2s_t = axi4lite_types#(LITE_ADDR_W, LITE_DATA_W)::bus_m2s_t,
  parameter type lite_s2m_t = axi4lite_types#(LITE_ADDR_W, LITE_DATA_W)::bus_s2m_t
) (
  input  logic Clock,
  input  logic Reset,

  input  full_m2s_t In_M2S,
  output full_s2m_t In_S2M,

  output lite_m2s_t Out_M2S,
  input  lite_s2m_t Out_S2M
);
  localparam int ID_BITS = poc_utils::downto_width(ID_W);

  logic Response_B_fifo_ful;
  logic Response_R_fifo_ful;
  logic Response_B_got;
  logic Response_R_got;

  assign Out_M2S.AWValid = In_M2S.AWValid & ~Response_B_fifo_ful;
  assign Out_M2S.AWAddr  = vec_resize#(ADDR_W, LITE_ADDR_W)::resize(In_M2S.AWAddr);
  assign Out_M2S.AWCache = In_M2S.AWCache;
  assign Out_M2S.AWProt  = In_M2S.AWProt;
  assign Out_M2S.WValid  = In_M2S.WValid;
  assign Out_M2S.WData   = vec_resize#(DATA_W, LITE_DATA_W)::resize(In_M2S.WData);
  assign Out_M2S.WStrb   = In_M2S.WStrb;
  assign Out_M2S.BReady  = In_M2S.BReady;
  assign Out_M2S.ARValid = In_M2S.ARValid & ~Response_R_fifo_ful;
  assign Out_M2S.ARAddr  = vec_resize#(ADDR_W, LITE_ADDR_W)::resize(In_M2S.ARAddr);
  assign Out_M2S.ARCache = In_M2S.ARCache;
  assign Out_M2S.ARProt  = In_M2S.ARProt;
  assign Out_M2S.RReady  = In_M2S.RReady;

  assign In_S2M.AWReady = Out_S2M.AWReady & ~Response_B_fifo_ful;
  assign In_S2M.WReady  = Out_S2M.WReady;
  assign In_S2M.BValid  = Out_S2M.BValid;
  assign In_S2M.BResp   = Out_S2M.BResp;
  assign In_S2M.ARReady = Out_S2M.ARReady & ~Response_R_fifo_ful;
  assign In_S2M.RValid  = Out_S2M.RValid;
  assign In_S2M.RData   = vec_resize#(LITE_DATA_W, DATA_W)::resize(Out_S2M.RData);
  assign In_S2M.RResp   = Out_S2M.RResp;
  assign In_S2M.RLast   = 1'b1;
  assign In_S2M.BUser   = '0;
  assign In_S2M.RUser   = '0;

  fifo_Shift #(
    .DATA_BITS(ID_BITS),
    .MIN_DEPTH(RESPONSE_FIFO_DEPTH)
  ) Response_R_fifo (
    .Clock  (Clock),
    .Reset  (Reset),
    .Put    (In_M2S.ARValid & Out_S2M.ARReady & ~Response_R_fifo_ful),
    .DataIn (In_M2S.ARID),
    .Full   (Response_R_fifo_ful),
    .Got    (Response_R_got),
    .DataOut(In_S2M.RID),
    .Valid  ()
  );
  assign Response_R_got = Out_S2M.RValid & In_M2S.RReady;

  fifo_Shift #(
    .DATA_BITS(ID_BITS),
    .MIN_DEPTH(RESPONSE_FIFO_DEPTH)
  ) Response_B_fifo (
    .Clock  (Clock),
    .Reset  (Reset),
    .Put    (In_M2S.AWValid & Out_S2M.AWReady & ~Response_B_fifo_ful),
    .DataIn (In_M2S.AWID),
    .Full   (Response_B_fifo_ful),
    .Got    (Response_B_got),
    .DataOut(In_S2M.BID),
    .Valid  ()
  );
  assign Response_B_got = Out_S2M.BValid & In_M2S.BReady;

endmodule
