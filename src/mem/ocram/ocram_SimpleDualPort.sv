// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2008-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

module ocram_SimpleDualPort #(
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

  localparam int WORDS = 1 << ADDRESS_BITS;

  logic [DATA_BITS-1:0] ram[0:WORDS-1];

  initial begin
    assert (RAM_TYPE inside {
      poc_mem::RAM_TYPE_AUTO,
      poc_mem::RAM_TYPE_OPTIMIZED,
      poc_mem::RAM_TYPE_LUT_RAM,
      poc_mem::RAM_TYPE_BLOCK_RAM,
      poc_mem::RAM_TYPE_ULTRA_RAM
    });
    for (int i = 0; i < WORDS; i++)
      ram[i] = '0;
    if (FILENAME != "")
      void'($readmemh(FILENAME, ram));
  end

  always_ff @(posedge Write_Clock) begin
    if (Write_ClockEnable && Write_WriteEnable)
      ram[int'(unsigned'(Write_Address))] <= Write_DataIn;
  end

  always_ff @(posedge Read_Clock) begin
    if (Read_ClockEnable)
      Read_DataOut <= ram[int'(unsigned'(Read_Address))];
  end

endmodule
