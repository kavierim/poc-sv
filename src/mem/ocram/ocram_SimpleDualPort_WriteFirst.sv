// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2008-2015 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

module ocram_SimpleDualPort_WriteFirst #(
  parameter int    ADDRESS_BITS = 8,
  parameter int    DATA_BITS    = 8,
  parameter string FILENAME     = ""
) (
  input  logic                    Clock,
  input  logic                    ClockEnable,
  input  logic                    Write_Enable,
  input  logic [ADDRESS_BITS-1:0] Write_Address,
  input  logic [DATA_BITS-1:0]    Write_DataIn,
  input  logic [ADDRESS_BITS-1:0] Read_Address,
  output logic [DATA_BITS-1:0]    Read_DataOut
);

  logic [DATA_BITS-1:0] WriteData_d;
  logic                 Forward_d;
  logic [DATA_BITS-1:0] RAM_DataOut;

  always_ff @(posedge Clock) begin
    case (poc_ocram::to_x01_sl(ClockEnable))
      1'b1: begin
        WriteData_d <= Write_DataIn;
        Forward_d <= poc_ocram::address_cmp#(ADDRESS_BITS)::is_equal(Write_Address, Read_Address) &
                     Write_Enable;
      end
      1'b0: ;
      default: begin
        WriteData_d <= 'x;
        Forward_d   <= 1'bx;
      end
    endcase
  end

  ocram_SimpleDualPort #(
    .ADDRESS_BITS(ADDRESS_BITS),
    .DATA_BITS   (DATA_BITS),
    .FILENAME    (FILENAME)
  ) ram_sdp (
    .Write_Clock      (Clock),
    .Write_ClockEnable(ClockEnable),
    .Write_WriteEnable(Write_Enable),
    .Write_Address    (Write_Address),
    .Write_DataIn     (Write_DataIn),
    .Read_Clock       (Clock),
    .Read_ClockEnable (ClockEnable),
    .Read_Address     (Read_Address),
    .Read_DataOut     (RAM_DataOut)
  );

  always_comb begin
    case (Forward_d)
      1'b1: Read_DataOut = WriteData_d;
      1'b0: Read_DataOut = RAM_DataOut;
      default: Read_DataOut = 'x;
    endcase
  end

endmodule
