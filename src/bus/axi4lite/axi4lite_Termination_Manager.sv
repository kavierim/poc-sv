// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273
// VHDL: PoC/src/bus/axi4lite/axi4lite_Termination_Manager.vhdl

`timescale 1ns/1ps

module axi4lite_Termination_Manager #(
  parameter int  ADDR_W = 32,
  parameter int  DATA_W = 32,
  parameter bit  VALUE  = 1'b0
) (
  output poc_axi4lite::T_AXI4Lite_Bus_M2S AXI4Lite_M2S,
  input  poc_axi4lite::T_AXI4Lite_Bus_S2M AXI4Lite_S2M
);
  import poc_axi4lite::*;

  assign AXI4Lite_M2S = initialize_axi4lite_bus_m2s(VALUE);

endmodule
