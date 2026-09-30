// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

// Generic-only: RAM_TYPE_OPTIMIZED URAM/BRAM/LUT splitting deferred; delegates to ocram_SimpleDualPort.

module ocram_SimpleDualPort_Optimized #(
  parameter poc_mem::ram_type_t RAM_TYPE     = poc_mem::RAM_TYPE_AUTO,
  parameter int                 ADDRESS_BITS = 8,
  parameter int                 DATA_BITS    = 8,
  parameter string              FILENAME     = ""
) (
  input  logic                    Write_Clock,
  input  logic                    Write_ClockEnable,
  input  logic                    Write_WriteEnable,
  input  logic [ADDRESS_BITS-1:0] Write_Address,
  input  logic [DATA_BITS-1:0]    Write_DataIn,

  input  logic                    Read_Clock,
  input  logic                    Read_ClockEnable,
  input  logic [ADDRESS_BITS-1:0] Read_Address,
  output logic [DATA_BITS-1:0]    Read_DataOut
);

  ocram_SimpleDualPort #(
    .ADDRESS_BITS(ADDRESS_BITS),
    .DATA_BITS   (DATA_BITS),
    .RAM_TYPE    (RAM_TYPE),
    .FILENAME    (FILENAME)
  ) sdp_ram (
    .Write_Clock      (Write_Clock),
    .Read_Clock       (Read_Clock),
    .Write_ClockEnable(Write_ClockEnable),
    .Write_WriteEnable(Write_WriteEnable),
    .Write_Address    (Write_Address),
    .Write_DataIn     (Write_DataIn),
    .Read_Address     (Read_Address),
    .Read_ClockEnable (Read_ClockEnable),
    .Read_DataOut     (Read_DataOut)
  );

endmodule
