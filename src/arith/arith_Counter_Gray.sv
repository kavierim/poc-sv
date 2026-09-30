// SPDX-FileCopyrightText: 2007-2014 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

module arith_Counter_Gray #(
  parameter int BITS = 8,
  parameter int INIT = 0
) (
  input  logic             Clock,
  input  logic             Reset,
  input  logic             Increment,
  input  logic             Decrement,
  output logic [BITS-1:0]  Value,
  output logic             CarryOut
);
  import poc_utils::*;

  function automatic logic parity_u(logic [BITS-1:0] val);
    logic res;
    res = 1'b0;
    for (int i = 0; i < BITS; i++)
      res = res ^ val[i];
    return res;
  endfunction

  localparam logic [BITS-1:0] INIT_BIN  = BITS'(INIT);
  localparam logic [BITS-1:0] INIT_GRAY = (BITS == 1) ? INIT_BIN : (INIT_BIN ^ (INIT_BIN >> 1));
  localparam logic            INIT_PAR  = parity_u(INIT_GRAY);

  logic [BITS-1:0] gray_cnt_r;
  logic [BITS-1:0] gray_cnt_nxt;
  logic            en;

  assign en = Increment ^ Decrement;

  always_ff @(posedge Clock) begin
    if (Reset)
      gray_cnt_r <= INIT_GRAY;
    else if (en)
      gray_cnt_r <= gray_cnt_nxt;
  end

  assign Value = gray_cnt_r;

  if (BITS == 1) begin : g1
    assign gray_cnt_nxt = ~gray_cnt_r;
    assign CarryOut     = gray_cnt_r[0] ^ Decrement;
  end else begin : g2
    logic par_r;
    logic par_nxt;

    always_ff @(posedge Clock) begin
      if (Reset)
        par_r <= INIT_PAR;
      else if (en)
        par_r <= par_nxt;
    end

    always_comb begin
      logic [BITS-1:0] x;
      logic [BITS-1:0] s;
      x         = {gray_cnt_r[BITS-2:0], par_r ~^ Decrement};
      x[BITS-1] = ~gray_cnt_r[BITS-1];
      s         = ~x + 1'b1;
      gray_cnt_nxt = {s[BITS-1], gray_cnt_r[BITS-2:0] ^ (s[BITS-2:0] & x[BITS-2:0])};
      par_nxt      = s[0] ^ Decrement;
    end

    assign CarryOut = (gray_cnt_r[BITS-1] ^ Decrement) & (gray_cnt_nxt[BITS-1] ~^ Decrement);
  end
endmodule
