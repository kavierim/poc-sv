// SPDX-FileCopyrightText: 2008-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

module ocram_TrueDualPort #(
  parameter int    ADDRESS_BITS = 8,
  parameter int    DATA_BITS    = 8,
  parameter string FILENAME     = ""
) (
  input  logic                    PortA_Clock,
  input  logic                    PortA_ClockEnable,
  input  logic                    PortA_WriteEnable,
  input  logic [ADDRESS_BITS-1:0] PortA_Address,
  input  logic [DATA_BITS-1:0]    PortA_DataIn,
  output logic [DATA_BITS-1:0]    PortA_DataOut,

  input  logic                    PortB_Clock,
  input  logic                    PortB_ClockEnable,
  input  logic                    PortB_WriteEnable,
  input  logic [ADDRESS_BITS-1:0] PortB_Address,
  input  logic [DATA_BITS-1:0]    PortB_DataIn,
  output logic [DATA_BITS-1:0]    PortB_DataOut
);

  ocram_TrueDualPort_Simulation #(
    .ADDRESS_BITS(ADDRESS_BITS),
    .DATA_BITS   (DATA_BITS),
    .FILENAME    (FILENAME)
  ) sim_tdp (
    .PortA_Clock      (PortA_Clock),
    .PortA_ClockEnable(PortA_ClockEnable),
    .PortA_WriteEnable(PortA_WriteEnable),
    .PortA_Address    (PortA_Address),
    .PortA_DataIn     (PortA_DataIn),
    .PortA_DataOut    (PortA_DataOut),

    .PortB_Clock      (PortB_Clock),
    .PortB_ClockEnable(PortB_ClockEnable),
    .PortB_WriteEnable(PortB_WriteEnable),
    .PortB_Address    (PortB_Address),
    .PortB_DataIn     (PortB_DataIn),
    .PortB_DataOut    (PortB_DataOut)
  );

endmodule
