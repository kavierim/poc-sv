// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

module arith_Divider #(
  parameter int  DIVIDEND_BITS  = 32,
  parameter int  DIVISOR_BITS   = 16,
  parameter int  RADIX_EXPONENT = 1,
  parameter bit  PIPELINED      = 1'b0
) (
  input  logic                    Clock,
  input  logic                    Reset,
  input  logic                    Start,
  output logic                    Ready,
  input  logic [DIVIDEND_BITS-1:0]  Dividend,
  input  logic [DIVISOR_BITS-1:0]   Divisor,
  output logic [DIVIDEND_BITS-1:0]  Quotient,
  output logic [DIVISOR_BITS-1:0]   Remainder,
  output logic                    DivisionByZero
);
  import poc_utils::*;

  localparam int STEPS       = (DIVIDEND_BITS + RADIX_EXPONENT - 1) / RADIX_EXPONENT;
  localparam int DEPTH       = PIPELINED ? STEPS : 0;
  localparam int TRUNK_BITS  = (STEPS - 1) * RADIX_EXPONENT;
  localparam int ACTIVE_BITS = DIVISOR_BITS + RADIX_EXPONENT;
  localparam int RES_W       = ACTIVE_BITS + TRUNK_BITS;

  typedef logic [RES_W-1:0] t_residue;
  typedef logic [DIVISOR_BITS-1:0] t_divisor;

  function automatic t_residue div_step(t_residue av, t_divisor dv);
    t_residue res;
    logic [DIVISOR_BITS-1:0] win;
    logic [DIVISOR_BITS:0]   dif;
    res = av;
    win = av[RES_W-1:RES_W-DIVISOR_BITS];
    for (int i = RADIX_EXPONENT - 1; i >= 0; i--) begin
      dif = {win, av[TRUNK_BITS + i]} - dv;
      if (dif[DIVISOR_BITS] == 1'b0)
        win = dif[DIVISOR_BITS-1:0];
      else
        win = {win[DIVISOR_BITS-2:0], av[TRUNK_BITS + i]};
      res[i] = ~dif[DIVISOR_BITS];
    end
    res[RES_W-1:RADIX_EXPONENT] = {win, av[TRUNK_BITS-1:0]};
    return res;
  endfunction

  t_residue AR[DEPTH+1];
  logic     ZR;
  logic     exec;

  if (!PIPELINED) begin : genPipeN
    localparam int EXEC_BITS = log2ceil(STEPS) + 1;
    logic signed [EXEC_BITS-1:0] CntExec;
    localparam logic signed [EXEC_BITS-1:0] EXEC_IDLE = 0;

    always_ff @(posedge Clock) begin
      if (Reset)
        CntExec <= EXEC_IDLE;
      else if (Start)
        CntExec <= EXEC_BITS'(-STEPS);
      else if (CntExec[EXEC_BITS-1])
        CntExec <= CntExec + 1;
    end
    assign exec  = CntExec[EXEC_BITS-1];
    assign Ready = ~exec;
  end else begin : genPipeY
    logic [STEPS:0] Vld;
    always_ff @(posedge Clock) begin
      if (Reset)
        Vld <= '0;
      else
        Vld <= {Start, Vld[STEPS-1:0]};
    end
    assign Ready = Vld[STEPS];
    assign exec  = 1'b0;
  end

  always_ff @(posedge Clock) begin
    t_residue an;
    t_divisor dn;
    if (Reset) begin
      for (int i = 0; i <= DEPTH; i++) begin
        AR[i] <= 'x;
      end
      ZR <= 1'bx;
    end else begin
      an = {{RES_W - DIVIDEND_BITS{1'b0}}, Dividend};
      dn = Divisor;
      /* verilator lint_off BLKSEQ */
      for (int i = 0; i <= imax(0, DEPTH - 1); i++) begin
        AR[i] = an;
        an = div_step(an, dn);
      end
      if (PIPELINED || (!Start && exec)) begin
        AR[DEPTH] = an;
        if (dn == '0)
          ZR <= 1'b1;
        else
          ZR <= 1'b0;
      end
      /* verilator lint_on BLKSEQ */
    end
  end

  assign Quotient       = AR[DEPTH][DIVIDEND_BITS-1:0];
  assign Remainder      = AR[DEPTH][STEPS * RADIX_EXPONENT + DIVISOR_BITS - 1 : STEPS * RADIX_EXPONENT];
  assign DivisionByZero = ZR;
endmodule
