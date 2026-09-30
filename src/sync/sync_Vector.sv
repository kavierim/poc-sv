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
module sync_Vector #(
  parameter int          MASTER_BITS = 8,
  parameter int          SLAVE_BITS  = 0,
  parameter logic [31:0] INIT        = 32'h0000_0000,
  parameter int          SYNC_DEPTH  = poc_sync::SYNC_DEPTH_MIN
) (
  input  logic Clock1,
  input  logic Clock2,

  input  logic [(SLAVE_BITS + MASTER_BITS)-1:0] Input,
  output logic                                  Busy,
  /* verilator lint_off UNUSEDSIGNAL */
  input  logic                                  Strobe,
  /* verilator lint_on UNUSEDSIGNAL */

  output logic [(SLAVE_BITS + MASTER_BITS)-1:0] Output,
  output logic                                  Changed
);

  localparam int TOTAL_BITS = MASTER_BITS + SLAVE_BITS;
  localparam logic [255:0] INIT_I_WIDE = poc_sync::init_resized(INIT, TOTAL_BITS);
  localparam logic [TOTAL_BITS-1:0] INIT_I = INIT_I_WIDE[TOTAL_BITS-1:0];

  logic [TOTAL_BITS-1:0] D0 = INIT_I;
  logic                  T1 = 1'b0;
  logic                  D2 = 1'b0;
  logic                  D3 = 1'b0;
  logic [TOTAL_BITS-1:0] D4 = INIT_I;

  logic Changed_Clk1;
  logic Changed_Clk2;
  logic Busy_i;

  logic syncClk1_In;
  logic syncClk1_Out;
  logic syncClk2_In;
  logic syncClk2_Out;

  always_ff @(posedge Clock1) begin
    if (Busy_i == 1'b0) begin
      D0 <= Input;
      T1 <= T1 ^ Changed_Clk1;
    end
  end

  always_ff @(posedge Clock2) begin
    D2 <= syncClk2_Out;
    D3 <= Changed_Clk2;
    if (Changed_Clk2)
      D4 <= D0;
  end

  assign syncClk2_In = T1;
  assign syncClk1_In = D2;

  assign Changed_Clk2 = syncClk2_Out ^ D2;
  assign Busy_i       = T1 ^ syncClk1_Out;

  if (MASTER_BITS > 0) begin : gen_change
    assign Changed_Clk1 =
        (D0[MASTER_BITS-1:0] == Input[MASTER_BITS-1:0]) ? 1'b0 : 1'b1;
  end else begin : gen_strobe
    assign Changed_Clk1 = Strobe;
  end

  assign Output  = D4;
  assign Busy    = Busy_i;
  assign Changed = D3;

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
