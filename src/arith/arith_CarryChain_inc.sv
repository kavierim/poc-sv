// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

module arith_CarryChain_inc #(
  parameter int BITS = 8
) (
  input  logic [BITS-1:0] A,
  input  logic            CarryIn,
  output logic [BITS-1:0] Sum
);
  import poc_utils::*;

  assign Sum = A + {{(BITS - 1){1'b0}}, CarryIn};
endmodule
