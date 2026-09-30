// SPDX-FileCopyrightText: 2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

// Behavioral true dual-port RAM (colibri_sv memory pattern). Full VHDL X-propagation model deferred.

module ocram_TrueDualPort_Simulation #(
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

  localparam int WORDS = 1 << ADDRESS_BITS;

  // verilator lint_off MULTIDRIVEN
  logic [DATA_BITS-1:0] ram[0:WORDS-1];
  // verilator lint_on MULTIDRIVEN

  logic [ADDRESS_BITS-1:0] port_a_write_addr;
  logic                    port_a_wrote;
  logic [ADDRESS_BITS-1:0] port_b_write_addr;
  logic                    port_b_wrote;

  initial poc_mem::ram_init#(WORDS, DATA_BITS)::init_words(ram, FILENAME);

  always_ff @(posedge PortA_Clock) begin
    port_a_wrote <= 1'b0;
    if (PortA_ClockEnable) begin
      if (PortA_WriteEnable) begin
        ram[PortA_Address] <= PortA_DataIn;
        port_a_write_addr <= PortA_Address;
        port_a_wrote      <= 1'b1;
        PortA_DataOut     <= PortA_DataIn;
      end else begin
        if (port_b_wrote && (PortA_Address == port_b_write_addr))
          PortA_DataOut <= 'x;
        else
          PortA_DataOut <= ram[PortA_Address];
      end
    end
  end

  always_ff @(posedge PortB_Clock) begin
    port_b_wrote <= 1'b0;
    if (PortB_ClockEnable) begin
      if (PortB_WriteEnable) begin
        if (port_a_wrote && (PortB_Address == port_a_write_addr))
          ram[PortB_Address] <= 'x;
        else
          ram[PortB_Address] <= PortB_DataIn;
        port_b_write_addr <= PortB_Address;
        port_b_wrote      <= 1'b1;
        PortB_DataOut     <= PortB_DataIn;
      end else begin
        if (port_a_wrote && (PortB_Address == port_a_write_addr))
          PortB_DataOut <= 'x;
        else
          PortB_DataOut <= ram[PortB_Address];
      end
    end
  end

endmodule
