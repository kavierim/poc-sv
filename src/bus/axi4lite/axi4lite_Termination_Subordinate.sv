// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273
// VHDL: PoC/src/bus/axi4lite/axi4lite_Termination_Subordinate.vhdl

`timescale 1ns/1ps

module axi4lite_Termination_Subordinate #(
  parameter int               ADDR_W        = 32,
  parameter int               DATA_W        = 32,
  parameter poc_axi4_common::T_AXI4_Response   RESPONSE_CODE = poc_axi4_common::C_AXI4_RESPONSE_SLAVE_ERROR
) (
  input  logic                                    Clock,
  input  logic                                    Reset,
  input  poc_axi4lite::T_AXI4Lite_Bus_M2S AXI4Lite_M2S,
  output poc_axi4lite::T_AXI4Lite_Bus_S2M AXI4Lite_S2M
);
  import poc_axi4_common::*;
  import poc_axi4lite::*;

  logic fifo_aw_valid;
  logic fifo_w_valid;
  logic AWFull_i;
  logic WFull_i;
  logic ARFull_i;

  assign AXI4Lite_S2M.AWReady = ~AWFull_i;
  assign AXI4Lite_S2M.WReady  = ~WFull_i;
  assign AXI4Lite_S2M.BValid  = fifo_aw_valid & fifo_w_valid;
  assign AXI4Lite_S2M.BResp   = RESPONSE_CODE;
  assign AXI4Lite_S2M.ARReady = ~ARFull_i;
  assign AXI4Lite_S2M.RData   = '0;
  assign AXI4Lite_S2M.RResp   = RESPONSE_CODE;

  fifo_cc_got #(
    .DATA_BITS (1),
    .MIN_DEPTH (4)
  ) fifo_aw (
    .Clock   (Clock),
    .Reset   (Reset),
    .Put     (AXI4Lite_M2S.AWValid),
    .DataIn  (1'b0),
    .Full    (AWFull_i),
    .EmptyState (),
    .Got     (AXI4Lite_M2S.BReady & fifo_w_valid),
    .DataOut (),
    .Valid   (fifo_aw_valid),
    .FillState ()
  );

  fifo_cc_got #(
    .DATA_BITS (1),
    .MIN_DEPTH (4)
  ) fifo_w (
    .Clock   (Clock),
    .Reset   (Reset),
    .Put     (AXI4Lite_M2S.WValid),
    .DataIn  (1'b0),
    .Full    (WFull_i),
    .EmptyState (),
    .Got     (AXI4Lite_M2S.BReady & fifo_aw_valid),
    .DataOut (),
    .Valid   (fifo_w_valid),
    .FillState ()
  );

  fifo_cc_got #(
    .DATA_BITS (1),
    .MIN_DEPTH (4)
  ) fifo_r (
    .Clock   (Clock),
    .Reset   (Reset),
    .Put     (AXI4Lite_M2S.ARValid),
    .DataIn  (1'b0),
    .Full    (ARFull_i),
    .EmptyState (),
    .Got     (AXI4Lite_M2S.RReady),
    .DataOut (),
    .Valid   (AXI4Lite_S2M.RValid),
    .FillState ()
  );

endmodule
