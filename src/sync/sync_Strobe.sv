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
module sync_Strobe #(
  parameter int  BITS                = 1,
  parameter bit  GATED_INPUT_BY_BUSY = 1'b1,
  parameter int  SYNC_DEPTH          = poc_sync::SYNC_DEPTH_MIN
) (
  input  logic              Clock1,
  input  logic              Clock2,
  input  logic [BITS-1:0]   Input,
  output logic [BITS-1:0]   Output,
  output logic [BITS-1:0]   Busy
);

  logic [BITS-1:0] syncClk1_In;
  logic [BITS-1:0] syncClk1_Out;
  logic [BITS-1:0] syncClk2_In;
  logic [BITS-1:0] syncClk2_Out;

  for (genvar i = 0; i < BITS; i++) begin : gen_bit
    logic D0 = 1'b0;
    logic T1 = 1'b0;
    logic D2 = 1'b0;

    logic Changed_Clk1;
    logic Changed_Clk2;
    logic Busy_i;

    always_ff @(posedge Clock1) begin
      D0 <= Input[i];
      if (GATED_INPUT_BY_BUSY)
        T1 <= (Changed_Clk1 & ~Busy_i) ^ T1;
      else
        T1 <= Changed_Clk1 ^ T1;
    end

    always_ff @(posedge Clock2) D2 <= syncClk2_Out[i];

    assign syncClk2_In[i] = T1;
    assign syncClk1_In[i] = syncClk2_Out[i];

    assign Changed_Clk1 = ~D0 & Input[i];
    assign Changed_Clk2 = syncClk2_Out[i] ^ D2;
    assign Busy_i       = T1 ^ syncClk1_Out[i];

    assign Output[i] = Changed_Clk2;
    assign Busy[i]   = Busy_i;
  end

  sync_Bits #(
    .BITS            (BITS),
    .SYNC_DEPTH      (SYNC_DEPTH),
    .REGISTER_OUTPUT (1'b0)
  ) syncClk2 (
    .Clock  (Clock2),
    .Input  (syncClk2_In),
    .Output (syncClk2_Out)
  );

  sync_Bits #(
    .BITS            (BITS),
    .SYNC_DEPTH      (SYNC_DEPTH),
    .REGISTER_OUTPUT (1'b0)
  ) syncClk1 (
    .Clock  (Clock1),
    .Input  (syncClk1_In),
    .Output (syncClk1_Out)
  );

endmodule
