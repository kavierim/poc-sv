// SPDX-FileCopyrightText: 2017-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273
// VHDL: PoC/src/bus/axi4/axi4_Common.pkg.vhdl

`timescale 1ns/1ps

package poc_axi4_common;

  /* verilator lint_off UNUSEDPARAM */

  typedef logic [1:0] T_AXI4_Response;
  localparam T_AXI4_Response C_AXI4_RESPONSE_OKAY         = 2'b00;
  localparam T_AXI4_Response C_AXI4_RESPONSE_EX_OKAY      = 2'b01;
  localparam T_AXI4_Response C_AXI4_RESPONSE_SLAVE_ERROR  = 2'b10;
  localparam T_AXI4_Response C_AXI4_RESPONSE_DECODE_ERROR = 2'b11;
  localparam T_AXI4_Response C_AXI4_RESPONSE_INIT         = 2'b00;

  typedef logic [3:0] T_AXI4_Cache;
  localparam T_AXI4_Cache C_AXI4_CACHE_INIT = 4'b0000;
  localparam T_AXI4_Cache C_AXI4_CACHE      = 4'b0011;

  typedef logic [3:0] T_AXI4_QoS;
  localparam T_AXI4_QoS C_AXI4_QOS_INIT = 4'b0000;

  typedef logic [3:0] T_AXI4_Region;
  localparam T_AXI4_Region C_AXI4_REGION_INIT = 4'b0000;

  typedef logic [2:0] T_AXI4_Size;
  localparam T_AXI4_Size C_AXI4_SIZE_1    = 3'b000;
  localparam T_AXI4_Size C_AXI4_SIZE_2    = 3'b001;
  localparam T_AXI4_Size C_AXI4_SIZE_4    = 3'b010;
  localparam T_AXI4_Size C_AXI4_SIZE_8    = 3'b011;
  localparam T_AXI4_Size C_AXI4_SIZE_16   = 3'b100;
  localparam T_AXI4_Size C_AXI4_SIZE_32   = 3'b101;
  localparam T_AXI4_Size C_AXI4_SIZE_64   = 3'b110;
  localparam T_AXI4_Size C_AXI4_SIZE_128  = 3'b111;
  localparam T_AXI4_Size C_AXI4_SIZE_INIT = 3'b000;

  typedef logic [1:0] T_AXI4_Burst;
  localparam T_AXI4_Burst C_AXI4_BURST_FIXED = 2'b00;
  localparam T_AXI4_Burst C_AXI4_BURST_INCR  = 2'b01;
  localparam T_AXI4_Burst C_AXI4_BURST_WRAP  = 2'b10;
  localparam T_AXI4_Burst C_AXI4_BURST_INIT  = 2'b00;

  typedef logic [2:0] T_AXI4_Protect;
  localparam T_AXI4_Protect C_AXI4_PROTECT_INIT = 3'b000;
  localparam T_AXI4_Protect C_AXI4_PROTECT      = 3'b000;

  /* verilator lint_on UNUSEDPARAM */

endpackage
