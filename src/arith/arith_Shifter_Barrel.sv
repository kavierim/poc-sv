// SPDX-FileCopyrightText: 2007-2015 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

/* verilator lint_off UNOPTFLAT */
/* verilator lint_off ALWCOMBORDER */

module arith_Shifter_Barrel #(
  parameter int BITS = 32
) (
  input  logic [BITS-1:0] Input,
  input  logic [($clog2(BITS) > 0 ? $clog2(BITS) : 1)-1:0] ShiftAmount,
  input  logic            ShiftRotate,
  input  logic            LeftRight,
  input  logic            ArithmeticLogic,
  output logic [BITS-1:0] Output
);
  import poc_utils::*;

  localparam int STAGES = log2ceilnz(BITS);

  logic [BITS-1:0] IntermediateResults[STAGES+1];

  assign IntermediateResults[0] = Input;
  assign Output                 = IntermediateResults[STAGES];

  for (genvar i = 0; i < STAGES; i++) begin : genStage
    localparam int SH = 1 << i;
    always_comb begin
      IntermediateResults[i + 1] = IntermediateResults[i];
      if (ShiftAmount[i] == 1'b0) begin
      end else if (ShiftRotate == 1'b0) begin
        if (LeftRight == 1'b0)
          IntermediateResults[i + 1] = {IntermediateResults[i][BITS-SH-1:0], {SH{1'b0}}};
        else if (ArithmeticLogic == 1'b0)
          IntermediateResults[i + 1] = {{SH{IntermediateResults[i][BITS-1]}}, IntermediateResults[i][BITS-1:SH]};
        else
          IntermediateResults[i + 1] = {{SH{1'b0}}, IntermediateResults[i][BITS-1:SH]};
      end else begin
        if (LeftRight == 1'b0)
          IntermediateResults[i + 1] = {IntermediateResults[i][BITS-SH-1:0],
                                        IntermediateResults[i][BITS-1:BITS-SH]};
        else
          IntermediateResults[i + 1] = {IntermediateResults[i][SH-1:0], IntermediateResults[i][BITS-1:SH]};
      end
    end
  end
endmodule

/* verilator lint_on ALWCOMBORDER */
/* verilator lint_on UNOPTFLAT */
