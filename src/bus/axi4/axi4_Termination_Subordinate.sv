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
module axi4_Termination_Subordinate #(
  parameter int ADDR_W = 32,
  parameter int DATA_W = 32,
  parameter int USER_W = 1,
  parameter int ID_W   = 1,
  parameter poc_axi4_common::T_AXI4_Response RESPONSE_CODE = poc_axi4_common::C_AXI4_RESPONSE_SLAVE_ERROR,
  parameter type m2s_t = axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::bus_m2s_t,
  parameter type s2m_t = axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::bus_s2m_t
) (
  input  logic Clock,
  input  logic Reset,

  input  m2s_t AXI4_M2S,
  output s2m_t AXI4_S2M
);
  import poc_axi4_common::*;

  localparam int ID_BITS = poc_utils::downto_width(ID_W);

  logic fifo_aw_valid;
  logic fifo_w_valid;
  logic AWFull_i;
  logic WFull_i;
  logic ARFull_i;
  logic empty_st_aw, fill_st_aw;
  logic empty_st_w, fill_st_w;
  logic empty_st_r, fill_st_r;

  assign AXI4_S2M.AWReady = ~AWFull_i;
  assign AXI4_S2M.WReady  = ~WFull_i;
  assign AXI4_S2M.BValid  = fifo_aw_valid & fifo_w_valid;
  assign AXI4_S2M.BResp   = RESPONSE_CODE;
  assign AXI4_S2M.BUser   = '0;
  assign AXI4_S2M.ARReady = ~ARFull_i;
  assign AXI4_S2M.RData   = '0;
  assign AXI4_S2M.RResp   = RESPONSE_CODE;
  assign AXI4_S2M.RLast   = 1'b1;
  assign AXI4_S2M.RUser   = '0;

  fifo_cc_got #(
    .DATA_BITS(ID_BITS),
    .MIN_DEPTH(4)
  ) fifo_aw (
    .Clock  (Clock),
    .Reset  (Reset),
    .Put    (AXI4_M2S.AWValid),
    .DataIn (AXI4_M2S.AWID),
    .Full   (AWFull_i),
    .Got    (AXI4_M2S.BReady & fifo_w_valid),
    .DataOut(AXI4_S2M.BID),
    .Valid  (fifo_aw_valid),
    .EmptyState(empty_st_aw),
    .FillState(fill_st_aw)
  );

  fifo_cc_got #(
    .DATA_BITS(1),
    .MIN_DEPTH(4)
  ) fifo_w (
    .Clock  (Clock),
    .Reset  (Reset),
    .Put    (AXI4_M2S.WValid),
    .DataIn (1'b0),
    .Full   (WFull_i),
    .Got    (AXI4_M2S.BReady & fifo_aw_valid),
    .DataOut(),
    .Valid  (fifo_w_valid),
    .EmptyState(empty_st_w),
    .FillState(fill_st_w)
  );

  fifo_cc_got #(
    .DATA_BITS(ID_BITS),
    .MIN_DEPTH(4)
  ) fifo_r (
    .Clock  (Clock),
    .Reset  (Reset),
    .Put    (AXI4_M2S.ARValid),
    .DataIn (AXI4_M2S.ARID),
    .Full   (ARFull_i),
    .Got    (AXI4_M2S.RReady),
    .DataOut(AXI4_S2M.RID),
    .Valid  (AXI4_S2M.RValid),
    .EmptyState(empty_st_r),
    .FillState(fill_st_r)
  );

endmodule
