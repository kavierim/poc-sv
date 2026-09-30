// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2008-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

module ocram_TrueDualPort_WriteFirst #(
  parameter int    ADDRESS_BITS = 8,
  parameter int    DATA_BITS    = 8,
  parameter string FILENAME     = ""
) (
  input  logic                    Clock,
  input  logic                    ClockEnable,
  input  logic                    PortA_WriteEnable,
  input  logic                    PortB_WriteEnable,
  input  logic [ADDRESS_BITS-1:0] PortA_Address,
  input  logic [ADDRESS_BITS-1:0] PortB_Address,
  input  logic [DATA_BITS-1:0]    PortA_DataIn,
  input  logic [DATA_BITS-1:0]    PortB_DataIn,
  output logic [DATA_BITS-1:0]    PortA_DataOut,
  output logic [DATA_BITS-1:0]    PortB_DataOut
);

  logic [DATA_BITS-1:0] wd1_r;
  logic [DATA_BITS-1:0] wd2_r;
  logic                 fwd1_r;
  logic                 fwd2_r;
  logic [DATA_BITS-1:0] ram_q1;
  logic [DATA_BITS-1:0] ram_q2;
  always_ff @(posedge Clock) begin
    logic addr_eq;
    case (poc_ocram::to_x01_sl(ClockEnable))
      1'b1: begin
        wd1_r   <= PortA_DataIn;
        wd2_r   <= PortB_DataIn;
        addr_eq = poc_ocram::address_cmp#(ADDRESS_BITS)::is_equal(PortA_Address, PortB_Address);
        fwd1_r  <= addr_eq & PortA_WriteEnable;
        fwd2_r  <= addr_eq & PortB_WriteEnable;
      end
      1'b0: ;
      default: begin
        wd1_r  <= 'x;
        fwd1_r <= 1'bx;
        fwd2_r <= 1'bx;
      end
    endcase

    if (fwd1_r && fwd2_r)
      $error("ocram_TrueDualPort_WriteFirst: both ports write to the same address.");
  end

  ocram_TrueDualPort #(
    .ADDRESS_BITS(ADDRESS_BITS),
    .DATA_BITS   (DATA_BITS),
    .FILENAME    (FILENAME)
  ) ram_tdp (
    .PortA_Clock      (Clock),
    .PortB_Clock      (Clock),
    .PortA_ClockEnable(ClockEnable),
    .PortB_ClockEnable(ClockEnable),
    .PortA_WriteEnable(PortA_WriteEnable),
    .PortB_WriteEnable(PortB_WriteEnable),
    .PortA_Address    (PortA_Address),
    .PortB_Address    (PortB_Address),
    .PortA_DataIn     (PortA_DataIn),
    .PortB_DataIn     (PortB_DataIn),
    .PortA_DataOut    (ram_q1),
    .PortB_DataOut    (ram_q2)
  );

  always_comb begin
    case (fwd1_r)
      1'b1: PortB_DataOut = wd1_r;
      1'b0: PortB_DataOut = ram_q2;
      default: PortB_DataOut = 'x;
    endcase
    case (fwd2_r)
      1'b1: PortA_DataOut = wd2_r;
      1'b0: PortA_DataOut = ram_q1;
      default: PortA_DataOut = 'x;
    endcase
  end

endmodule
