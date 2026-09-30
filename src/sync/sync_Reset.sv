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
module sync_Reset #(
  parameter int SYNC_DEPTH = poc_sync::SYNC_DEPTH_MIN
) (
  input  logic Clock,
  input  logic Input,
  input  logic D,
  output logic Output
);

  (* async_reg = "true" *) logic Data_async;
  (* async_reg = "true" *) logic Data_meta = 1'b1;
  (* async_reg = "true" *) logic [SYNC_DEPTH-1:0] Data_sync = '{default: 1'b1};

  assign Data_async = Input;

  always @(posedge Clock or posedge Data_async) begin
    if (Data_async) begin
      Data_meta <= 1'b1;
      Data_sync <= '{default: 1'b1};
    end else begin
      Data_meta <= D;
      Data_sync <= {Data_sync[SYNC_DEPTH-2:0], Data_meta};
    end
  end

  assign Output = Data_sync[SYNC_DEPTH-1];

endmodule
