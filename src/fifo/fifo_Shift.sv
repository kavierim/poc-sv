// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2014 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

// verilator lint_off MULTITOP
module fifo_Shift #(
  parameter int DATA_BITS = 8,
  parameter int MIN_DEPTH = 4
) (
  input  logic                            Clock,
  input  logic                            Reset,
  output logic [poc_utils::log2ceilnz(MIN_DEPTH):0] FillLevel,

  input  logic                            Put,
  input  logic [DATA_BITS-1:0]            DataIn,
  output logic                            Full,

  input  logic                            Got,
  output logic [DATA_BITS-1:0]            DataOut,
  output logic                            Valid
);
  import poc_utils::*;

  localparam int ADDRESS_BITS = log2ceilnz(MIN_DEPTH);
  localparam int DEPTH        = 1 << ADDRESS_BITS;

  logic [DATA_BITS-1:0] Dat[0:DEPTH-1];
  logic [ADDRESS_BITS:0]  Ptr = '1;

  logic ful_i;
  logic vld_i;

  always_ff @(posedge Clock) begin
    if (Put && !ful_i)
      Dat <= {DataIn, Dat[0:DEPTH-2]};
  end

  always_ff @(posedge Clock) begin
    if (Reset)
      Ptr <= '1;
    else if ((Put && !ful_i) != (Got && vld_i)) begin
      if (Put && !ful_i)
        Ptr <= Ptr + 1;
      else
        Ptr <= Ptr - 1;
    end
  end

  assign DataOut  = Dat[Ptr[ADDRESS_BITS-1:0]];
  assign vld_i    = ~Ptr[ADDRESS_BITS];
  assign ful_i    = vld_i && (Ptr[ADDRESS_BITS-1:0] == (DEPTH - 1));
  assign Valid    = vld_i;
  assign Full     = ful_i;
  assign FillLevel = Ptr;

endmodule
