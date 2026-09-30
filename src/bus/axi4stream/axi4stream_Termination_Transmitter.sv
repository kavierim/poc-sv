// SPDX-FileCopyrightText: 2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273
// VHDL: PoC/src/bus/axi4stream/axi4stream_Termination_Transmitter.vhdl

`timescale 1ns/1ps

import poc_axi4stream::*;

// verilator lint_off MULTITOP
module axi4stream_Termination_Transmitter #(
  parameter logic VALUE     = 1'b0,
  parameter int   DATA_BITS = 32,
  parameter int   USER_BITS = 1,
  parameter int   DEST_BITS = 1,
  parameter int   ID_BITS   = 1,
  parameter int   KEEP_BITS = 0,
  parameter type m2s_t = axi4stream_types#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::m2s_t,
  parameter type s2m_t = axi4stream_types#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::s2m_t
) (
  output m2s_t Out_M2S,
  input  s2m_t Out_S2M
);
  assign Out_M2S = axi4stream_sized#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::initialize_m2s(VALUE);
endmodule
