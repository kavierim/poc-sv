// SPDX-FileCopyrightText: 2008-2015 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

module ocram_SinglePort #(
  parameter int    ADDRESS_BITS = 8,
  parameter int    DATA_BITS    = 8,
  parameter string FILENAME     = ""
) (
  input  logic                       Clock,
  input  logic                       ClockEnable,
  input  logic                       WriteEnable,
  input  logic [ADDRESS_BITS-1:0]    Address,
  input  logic [DATA_BITS-1:0]     DataIn,
  output logic [DATA_BITS-1:0]     DataOut
);

  localparam int WORDS = 1 << ADDRESS_BITS;

  logic [DATA_BITS-1:0] ram[0:WORDS-1];
  logic [ADDRESS_BITS-1:0] a_reg;

  initial begin
`ifdef SYNTHESIS
    for (int i = 0; i < WORDS; i++)
      ram[i] = '0;
`else
    poc_mem::ram_init#(WORDS, DATA_BITS)::init_words(ram, FILENAME);
`endif
  end

  always_ff @(posedge Clock) begin
    if (ClockEnable) begin
      if (WriteEnable)
        ram[Address] <= DataIn;
      a_reg <= Address;
    end
  end

  assign DataOut = ram[a_reg];

endmodule
