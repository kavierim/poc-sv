// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

module arith_Scaler #(
  parameter int MUL_COUNT = 1,
  parameter int DIV_COUNT = 1,
  parameter int MUL0      = 1,
  parameter int MUL1      = 1,
  parameter int MUL2      = 1,
  parameter int MUL3      = 1,
  parameter int DIV0      = 1,
  parameter int DIV1      = 1,
  parameter int DIV2      = 1,
  parameter int DIV3      = 1,
  parameter int BITS      = 32
) (
  input  logic             Clock,
  input  logic             Reset,
  input  logic             Start,
  input  logic [BITS-1:0]    Operand,
  input  logic [($clog2(MUL_COUNT) > 0 ? $clog2(MUL_COUNT) : 1)-1:0] MultiplierSelect,
  input  logic [($clog2(DIV_COUNT) > 0 ? $clog2(DIV_COUNT) : 1)-1:0]    DivisorSelect,
  output logic [BITS-1:0]    Result,
  output logic             Done
);
  import poc_utils::*;

  function automatic int pick_mul(int idx);
    case (idx)
      0: return MUL0;
      1: return MUL1;
      2: return MUL2;
      default: return MUL3;
    endcase
  endfunction

  function automatic int pick_div(int idx);
    case (idx)
      0: return DIV0;
      1: return DIV1;
      2: return DIV2;
      default: return DIV3;
    endcase
  endfunction

  function automatic int max_mul_val();
    int m;
    m = MUL0;
    if (MUL_COUNT > 1)
      m = imax(m, MUL1);
    if (MUL_COUNT > 2)
      m = imax(m, MUL2);
    if (MUL_COUNT > 3)
      m = imax(m, MUL3);
    return m;
  endfunction

  function automatic int max_div_val();
    int m;
    m = DIV0;
    if (DIV_COUNT > 1)
      m = imax(m, DIV1);
    if (DIV_COUNT > 2)
      m = imax(m, DIV2);
    if (DIV_COUNT > 3)
      m = imax(m, DIV3);
    return m;
  endfunction

  localparam int X               = imax(1, log2ceil(imax(max_mul_val(), max_div_val() / 2 + 1)));
  localparam int R               = imax(1, log2ceil(max_div_val() + 1));
  localparam int MAX_MUL_STEPS   = BITS;
  localparam int MAX_DIV_STEPS   = BITS + X;
  localparam int MAX_ANY_STEPS   = imax(MAX_MUL_STEPS, MAX_DIV_STEPS);
  localparam int C_LOW_W         = log2ceil(MAX_ANY_STEPS);
  localparam int C_W             = 2 + C_LOW_W;
  localparam int MUL_CNT_INIT    = MAX_MUL_STEPS - 1;

  function automatic int div_steps(int d);
    return BITS + X - log2ceil(d + 1) + 1;
  endfunction

  function automatic int min_div_steps();
    int m;
    m = div_steps(DIV0);
    if (DIV_COUNT > 1)
      m = imin(m, div_steps(DIV1));
    if (DIV_COUNT > 2)
      m = imin(m, div_steps(DIV2));
    if (DIV_COUNT > 3)
      m = imin(m, div_steps(DIV3));
    return m;
  endfunction

  function automatic int div_align(int d, int steps);
    return d * (1 << (steps - min_div_steps()));
  endfunction

  function automatic logic [BITS-1:0] res_mask(int steps);
    if (steps >= BITS)
      return {BITS{1'b1}};
    return ({BITS{1'b1}} >> (BITS - steps));
  endfunction

  logic [X-1:0]              muloffset;
  logic [X:0]                multiplier;
  logic [R-1:0]              divisor;
  logic [C_LOW_W-1:0]        divcini;
  logic [BITS-1:0]           divmask;
  logic [C_W-1:0]            C;
  logic [X+BITS:0]           Q;
  logic [BITS-1:0]           Result_r;

  always_ff @(posedge Clock) begin
    int ms;
    int ds;
    int dval;
    int steps;
    ms = (MUL_COUNT > 1) ? int'(MultiplierSelect) : 0;
    ds = (DIV_COUNT > 1) ? int'(DivisorSelect) : 0;
    multiplier <= (X+1)'(pick_mul(ms));
    dval       = pick_div(ds);
    steps      = div_steps(dval);
    muloffset  <= X'(dval / 2);
    divisor    <= R'(div_align(dval, steps));
    divcini    <= C_LOW_W'(steps - 1);
    divmask    <= res_mask(steps);
  end

  always_ff @(posedge Clock) begin
    logic [C_W-1:0] cnxt;
    logic [R:0]     d;
    if (Reset) begin
      C        <= '0;
      Q        <= '0;
      Result_r <= '0;
    end else begin
      if (Start) begin
        C <= {2'b11, MUL_CNT_INIT[C_LOW_W-1:0]};
        Q <= {1'b0, muloffset, Operand};
      end else if (C[C_W-1]) begin
        cnxt = C - 1;
        if (C[C_W-2]) begin
          Q <= {2'b00, Q[X+BITS-1:1]};
          if (Q[0])
            Q[X+BITS-1:BITS-1] <= Q[X+BITS-1:BITS-1] + multiplier;
          if (!cnxt[C_W-2])
            cnxt[C_LOW_W-1:0] = divcini;
        end else begin
          d = (R+1)'(unsigned'(Q[X+BITS:X+BITS-R]) - unsigned'({{R{1'b0}}, divisor}));
          Q <= {Q[X+BITS-1:0], ~d[R]};
          if (!d[R])
            Q[X+BITS:X+BITS-R+1] <= d[R-1:0];
        end
        C <= cnxt;
      end
      Result_r <= (Q[BITS-1:0] & divmask[BITS-1:0]);
    end
  end

  assign Done   = ~C[C_W-1];
  assign Result = Result_r;
endmodule
