// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2015 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

// verilator lint_off MULTITOP
module sync_Command #(
  parameter int          BITS       = 8,
  parameter logic [31:0] INIT       = 32'h0000_0000,
  parameter int          SYNC_DEPTH = poc_sync::SYNC_DEPTH_MIN
) (
  input  logic              Clock1,
  input  logic              Clock2,
  input  logic [BITS-1:0]   Input,
  output logic [BITS-1:0]   Output,
  output logic              Busy,
  output logic              Changed
);

  localparam logic [255:0] INIT_I_WIDE = poc_sync::init_resized(INIT, BITS);
  localparam logic [BITS-1:0] INIT_I   = INIT_I_WIDE[BITS-1:0];

  logic              D0 = 1'b0;
  logic [BITS-1:0]   D1 = INIT_I;
  logic              T2 = 1'b0;
  logic              D3 = 1'b0;
  logic              D4 = 1'b0;
  logic [BITS-1:0]   D5 = INIT_I;

  logic IsCommand_Clk1;
  logic Changed_Clk1;
  logic Changed_Clk2;
  logic Busy_i;

  logic syncClk1_In;
  logic syncClk1_Out;
  logic syncClk2_In;
  logic syncClk2_Out;

  always_ff @(posedge Clock1) begin
    if (Busy_i == 1'b0) begin
      D0 <= IsCommand_Clk1;
      D1 <= Input;
      T2 <= T2 ^ Changed_Clk1;
    end
  end

  always_ff @(posedge Clock2) begin
    D3 <= syncClk2_Out;
    D4 <= Changed_Clk2;
    if (D4)
      D5 <= INIT_I;
    else if (Changed_Clk2)
      D5 <= D1;
  end

  assign syncClk2_In    = T2;
  assign syncClk1_In    = D3;
  assign IsCommand_Clk1 = (Input != INIT_I);
  assign Changed_Clk1   = ~D0 & IsCommand_Clk1;
  assign Changed_Clk2   = syncClk2_Out ^ D3;
  assign Busy_i         = T2 ^ syncClk1_Out;

  assign Output  = D5;
  assign Busy    = Busy_i;
  assign Changed = D4;

  sync_Bits #(
    .BITS            (1),
    .SYNC_DEPTH      (SYNC_DEPTH),
    .REGISTER_OUTPUT (1'b0)
  ) syncClk2 (
    .Clock  (Clock2),
    .Input  ({syncClk2_In}),
    .Output ({syncClk2_Out})
  );

  sync_Bits #(
    .BITS            (1),
    .SYNC_DEPTH      (SYNC_DEPTH),
    .REGISTER_OUTPUT (1'b0)
  ) syncClk1 (
    .Clock  (Clock1),
    .Input  ({syncClk1_In}),
    .Output ({syncClk1_Out})
  );

endmodule
