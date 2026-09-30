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
module axi4_Termination_Manager #(
  parameter int ADDR_W = 32,
  parameter int DATA_W = 32,
  parameter int USER_W = 1,
  parameter int ID_W   = 1,
  parameter bit VALUE  = 1'b0,
  parameter type m2s_t = axi4_full_types#(ADDR_W, DATA_W, USER_W, ID_W)::bus_m2s_t,
  parameter type s2m_t = axi4_full_types#(ADDR_W, DATA_W, USER_W, ID_W)::bus_s2m_t
) (
  output m2s_t AXI4_M2S,
  input  s2m_t AXI4_S2M /* unused */
);
  import poc_axi4_full::*;

  assign AXI4_M2S = axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::initialize_bus_m2s(VALUE);

endmodule
