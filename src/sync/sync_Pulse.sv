// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

// verilator lint_off MULTITOP
module sync_Pulse #(
  parameter int BITS       = 1,
  parameter int SYNC_DEPTH = poc_sync::SYNC_DEPTH_MIN
) (
  input  logic              Clock,
  input  logic [BITS-1:0]   Input,
  output logic [BITS-1:0]   Output
);

  for (genvar i = 0; i < BITS; i++) begin : gen_bit
    logic Data_async = 1'b0;
    (* async_reg = "true" *) logic Data_meta = 1'b0;
    (* async_reg = "true" *) logic [SYNC_DEPTH-1:1] Data_sync = '0;

    logic sync_out;
    logic Input_prev = 1'b0;

    assign sync_out = Data_sync[SYNC_DEPTH-1];

    always @(Input[i], sync_out) begin
      if (!Input[i] && sync_out)
        Data_async <= 1'b0;
      else if (Input[i] && !Input_prev)
        Data_async <= 1'b1;
      Input_prev <= Input[i];
    end

    always_ff @(posedge Clock) begin
      Data_meta <= Data_async;
      if (SYNC_DEPTH > 2) begin
        for (int s = SYNC_DEPTH - 1; s >= 2; s--)
          Data_sync[s] <= Data_sync[s-1];
      end
      Data_sync[1] <= Data_meta;
    end

    assign Output[i] = sync_out;
  end

endmodule
