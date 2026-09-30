// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273
// VHDL: PoC/src/bus/axi4lite/axi4lite_DeMux.vhdl

`timescale 1ns/1ps

module axi4lite_DeMux #(
  parameter int  NUM_PORTS = 1,
  parameter logic [31:0] BASE_ADDRESS[NUM_PORTS] = '{32'h0},
  parameter logic [31:0] BASE_ADDRESS_MASK[NUM_PORTS] = '{32'hFFFF_FFFF},
  parameter int  PIPELINE_IN = 0,
  parameter int  PIPELINE_OUT[NUM_PORTS] = '{default: 0},
  parameter int  ADDR_W = 32,
  parameter int  DATA_W = 32,
  parameter int  ID_W   = 1,
  parameter int  USER_W = 1
) (
  input  logic Clock,
  input  logic Reset,
  input  poc_axi4lite::T_AXI4Lite_Bus_M2S In_M2S,
  output poc_axi4lite::T_AXI4Lite_Bus_S2M In_S2M,
  output poc_axi4lite::T_AXI4Lite_Bus_M2S Out_M2S[NUM_PORTS],
  input  poc_axi4lite::T_AXI4Lite_Bus_S2M Out_S2M[NUM_PORTS]
);
  import poc_axi4::*;

  typedef axi4_convert#(ADDR_W, DATA_W, ID_W, USER_W)::full_m2s_t full_m2s_t;
  typedef axi4_convert#(ADDR_W, DATA_W, ID_W, USER_W)::full_s2m_t full_s2m_t;

  full_m2s_t In_M2S_full;
  full_s2m_t In_S2M_full;
  full_m2s_t Out_M2S_full[NUM_PORTS];
  full_s2m_t Out_S2M_full[NUM_PORTS];

  assign In_M2S_full = axi4_convert#(ADDR_W, DATA_W, ID_W, USER_W)::to_AXI4_BUS_M2S(In_M2S);
  assign In_S2M      = axi4_convert#(ADDR_W, DATA_W, ID_W, USER_W)::to_AXI4LITE_BUS_S2M(In_S2M_full);

  genvar i;
  generate
    for (i = 0; i < NUM_PORTS; i++) begin : assign_gen
      assign Out_M2S[i]      = axi4_convert#(ADDR_W, DATA_W, ID_W, USER_W)::to_AXI4LITE_BUS_M2S(Out_M2S_full[i]);
      assign Out_S2M_full[i] = axi4_convert#(ADDR_W, DATA_W, ID_W, USER_W)::to_AXI4_BUS_S2M(Out_S2M[i]);
    end
  endgenerate

  axi4_DeMux #(
    .PORTS                   (NUM_PORTS),
    .BASE_ADDRESS            (BASE_ADDRESS),
    .BASE_ADDRESS_MASK       (BASE_ADDRESS_MASK),
    .PIPELINE_IN             (PIPELINE_IN),
    .PIPELINE_OUT            (PIPELINE_OUT),
    .ADDR_W                  (ADDR_W),
    .DATA_W                  (DATA_W),
    .ID_W                    (ID_W),
    .USER_W                  (USER_W),
    .NUM_OUTSTANDING_READS   (1),
    .NUM_OUTSTANDING_WRITES  (1)
  ) Full_DeMux (
    .Clock   (Clock),
    .Reset   (Reset),
    .In_M2S  (In_M2S_full),
    .In_S2M  (In_S2M_full),
    .Out_M2S (Out_M2S_full),
    .Out_S2M (Out_S2M_full)
  );

endmodule
