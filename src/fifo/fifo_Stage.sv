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
module fifo_Stage #(
  parameter int  DATA_BITS    = 8,
  parameter int  STAGES       = 1,
  parameter bit  LIGHT_WEIGHT = 1'b0
) (
  input  logic                 Clock,
  input  logic                 Reset,

  input  logic                 Put,
  input  logic [DATA_BITS-1:0] DataIn,
  output logic                 Full,

  output logic                 Valid,
  output logic [DATA_BITS-1:0] DataOut,
  input  logic                 Got
);

  if (STAGES > 0) begin : gen_pipeline
    logic [DATA_BITS-1:0] di_v[0:STAGES-1];
    logic [DATA_BITS-1:0] do_v[0:STAGES-1];
    logic [0:STAGES-1]    Avail_v;
    logic [0:STAGES-1]    Full_v;
    logic [0:STAGES-1]    put_v;
    logic [0:STAGES-1]    got_v;

    assign Full    = Full_v[0];
    assign Valid   = Avail_v[STAGES-1];
    assign DataOut = do_v[STAGES-1];
    assign di_v[0] = DataIn;
    assign put_v[0] = Put;
    assign got_v[STAGES-1] = Got;

    for (genvar i = 1; i < STAGES; i++) begin : connect_gen
      assign di_v[i]      = do_v[i-1];
      assign got_v[i-1]   = ~Full_v[i];
      assign put_v[i]     = Avail_v[i-1];
    end

    if (!LIGHT_WEIGHT) begin : gen_full_stage
      for (genvar i = 0; i < STAGES; i++) begin : genStage
        logic [DATA_BITS-1:0] A;
        logic [DATA_BITS-1:0] B;
        logic                 Avail;
        logic                 Full_i;

        always_ff @(posedge Clock) begin
          if (Reset) begin
            Full_i <= 1'b0;
            Avail  <= 1'b0;
          end else begin
            Avail <= put_v[i] | (Avail & ~got_v[i]) | Full_i;
            Full_i <= Avail & ~got_v[i] & (Full_i | put_v[i]);
          end
        end

        always_ff @(posedge Clock) begin
          if (!Full_i)
            A <= di_v[i];
          if (got_v[i] || !Avail) begin
            if (Full_i)
              B <= A;
            else
              B <= di_v[i];
          end
        end

        assign Full_v[i]  = Full_i;
        assign Avail_v[i] = Avail;
        assign do_v[i]    = B;
      end
    end else begin : gen_light_stage
      for (genvar i = 0; i < STAGES; i++) begin : genStage
        logic [DATA_BITS-1:0] B;
        logic                 Avail;

        always_ff @(posedge Clock) begin
          if (Reset)
            Avail <= 1'b0;
          else if (Avail)
            Avail <= ~got_v[i];
          else
            Avail <= put_v[i];
        end

        always_ff @(posedge Clock) begin
          if (!Avail)
            B <= di_v[i];
        end

        assign Full_v[i]  = Avail;
        assign Avail_v[i] = Avail;
        assign do_v[i]    = B;
      end
    end
  end else begin : gen_passthrough
    assign Full    = ~Got;
    assign Valid   = Put;
    assign DataOut = DataIn;
  end

endmodule
