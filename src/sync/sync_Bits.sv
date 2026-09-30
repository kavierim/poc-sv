// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

// verilator lint_off MULTITOP
module sync_Bits #(
  parameter int          BITS            = 1,
  parameter logic [31:0] INIT            = 32'h0000_0000,
  parameter int          SYNC_DEPTH      = poc_sync::SYNC_DEPTH_MIN,
  /* verilator lint_off UNUSEDPARAM */
  parameter bit          FALSE_PATH      = 1'b1,  // retained for upstream API; generic RTL ignores
  /* verilator lint_on UNUSEDPARAM */
  parameter bit          REGISTER_OUTPUT = 1'b0
) (
  input  logic              Clock,
  input  logic [BITS-1:0]   Input,
  output logic [BITS-1:0]   Output
);

  if ((SYNC_DEPTH < poc_sync::SYNC_DEPTH_MIN) || (SYNC_DEPTH > poc_sync::SYNC_DEPTH_MAX)) begin : gen_depth_check
`ifndef SYNTHESIS
    initial $error("sync_Bits: SYNC_DEPTH must be %0d..%0d", poc_sync::SYNC_DEPTH_MIN,
                   poc_sync::SYNC_DEPTH_MAX);
`endif
  end

  localparam logic [255:0] INIT_I_WIDE = poc_sync::init_resized(INIT, BITS);
  localparam logic [BITS-1:0] INIT_I   = INIT_I_WIDE[BITS-1:0];

  for (genvar i = 0; i < BITS; i++) begin : gen_bit
    logic Data_async;
    (* async_reg = "true" *) logic Data_meta = INIT_I[i];
    (* async_reg = "true" *) logic [SYNC_DEPTH-1:1] Data_sync = '{default: INIT_I[i]};

    assign Data_async = Input[i];

    always_ff @(posedge Clock) begin
      Data_meta <= Data_async;
      if (SYNC_DEPTH > 2) begin
        for (int s = SYNC_DEPTH - 1; s >= 2; s--)
          Data_sync[s] <= Data_sync[s-1];
      end
      Data_sync[1] <= Data_meta;
    end

    if (REGISTER_OUTPUT) begin : reg_out
      always_ff @(posedge Clock) Output[i] <= Data_sync[SYNC_DEPTH-1];
    end else begin : comb_out
      assign Output[i] = Data_sync[SYNC_DEPTH-1];
    end
  end

endmodule
