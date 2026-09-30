// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

import poc_axi4stream::*;

// verilator lint_off MULTITOP
module axi4stream_Stage #(
  parameter int DATA_BITS = 32,
  parameter int USER_BITS = 1,
  parameter int DEST_BITS = 1,
  parameter int ID_BITS   = 1,
  parameter int KEEP_BITS = 0,
  parameter int STAGES    = 2,
  parameter type m2s_t = axi4stream_sized#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::m2s_t,
  parameter type s2m_t = axi4stream_sized#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::s2m_t
) (
  input  logic Clock,
  input  logic Reset,

  input  m2s_t In_M2S,
  output s2m_t In_S2M,

  output m2s_t Out_M2S,
  input  s2m_t Out_S2M
);
  import poc_utils::div_ceil;

  localparam int KEEP_W = (KEEP_BITS > 0) ? KEEP_BITS : div_ceil(DATA_BITS, 8);

  localparam int POS_DATA = 0;
  localparam int POS_KEEP = POS_DATA + DATA_BITS;
  localparam int POS_LAST = POS_KEEP + KEEP_W;
  localparam int POS_USER = POS_LAST + 1;
  localparam int POS_DEST = POS_USER + USER_BITS;
  localparam int POS_ID   = POS_DEST + DEST_BITS;
  localparam int FIFO_W   = POS_ID + ID_BITS;

  logic              FIFO_full;
  logic              FIFO_put;
  logic [FIFO_W-1:0] FIFO_data_in;
  logic [FIFO_W-1:0] FIFO_data_out;

  assign FIFO_data_in[POS_DATA+:DATA_BITS] = In_M2S.Data;
  assign FIFO_data_in[POS_KEEP+:KEEP_W]    = In_M2S.Keep;
  assign FIFO_data_in[POS_LAST]            = In_M2S.Last;
  assign FIFO_data_in[POS_USER+:USER_BITS] = In_M2S.User;
  assign FIFO_data_in[POS_DEST+:DEST_BITS] = In_M2S.Dest;
  assign FIFO_data_in[POS_ID+:ID_BITS]     = In_M2S.ID;

  assign FIFO_put     = In_M2S.Valid;
  assign In_S2M.Ready = ~FIFO_full;

  fifo_Stage #(
    .DATA_BITS(FIFO_W),
    .STAGES   (STAGES)
  ) FIFO (
    .Clock  (Clock),
    .Reset  (Reset),
    .Put    (FIFO_put),
    .DataIn (FIFO_data_in),
    .Full   (FIFO_full),
    .Valid  (Out_M2S.Valid),
    .DataOut(FIFO_data_out),
    .Got    (Out_S2M.Ready)
  );

  assign Out_M2S.Data = FIFO_data_out[POS_DATA+:DATA_BITS];
  assign Out_M2S.Keep = FIFO_data_out[POS_KEEP+:KEEP_W];
  assign Out_M2S.Last = FIFO_data_out[POS_LAST];
  assign Out_M2S.User = FIFO_data_out[POS_USER+:USER_BITS];
  assign Out_M2S.Dest = FIFO_data_out[POS_DEST+:DEST_BITS];
  assign Out_M2S.ID   = FIFO_data_out[POS_ID+:ID_BITS];

endmodule
