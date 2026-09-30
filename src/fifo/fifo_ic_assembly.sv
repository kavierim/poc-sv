// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

// verilator lint_off MULTITOP
module fifo_ic_assembly #(
  parameter int D_BITS = 8,
  parameter int A_BITS = 8,
  parameter int G_BITS = 2
) (
  input  logic                 clk_wr,
  input  logic                 rst_wr,

  output logic [A_BITS-1:0]    base,
  output logic                 failed,

  input  logic [A_BITS-1:0]    addr,
  input  logic [D_BITS-1:0]    din,
  input  logic                 put,

  input  logic                 clk_rd,
  input  logic                 rst_rd,

  output logic [D_BITS-1:0]    dout,
  output logic                 vld,
  input  logic                 got
);
  import poc_utils::*;

  localparam int AN = A_BITS - G_BITS;
  localparam int DN = G_BITS + D_BITS;

  logic [AN-1:0]          wa;
  logic                 we;
  logic [DN-1:0]        di;

  logic [AN-1:0]          ra;
  logic [DN-1:0]        do_ram;

  logic [A_BITS-1:0]    OPgray = '0;

  logic [AN:0]          InitCnt = '0;
  logic [A_BITS-1:0]    OPmeta  = '0;
  logic [A_BITS-1:0]    OPsync  = '0;
  logic [A_BITS-1:0]    OPbin   = {1'b1, {(A_BITS-1){1'b0}}};
  logic                 Fail    = 1'b0;

  always_ff @(posedge clk_wr) begin
    if (rst_wr) begin
      InitCnt <= '0;
      OPmeta  <= '0;
      OPsync  <= '0;
      OPbin   <= {1'b1, {(A_BITS-1){1'b0}}};
      Fail    <= 1'b0;
    end else begin
      OPmeta <= OPgray;
      OPsync <= OPmeta;
      if (!InitCnt[AN])
        InitCnt <= InitCnt + 1;
      else
        OPbin <= poc_utils::bits#(A_BITS)::gray2bin(OPsync);
      if (put && ((addr - OPbin) >> AN) != '0)
        Fail <= 1'b1;
    end
  end

  assign wa = InitCnt[AN] ? unsigned'(addr[AN-1:0]) : InitCnt[AN-1:0];
  assign di = InitCnt[AN] ? {poc_utils::bits#(G_BITS)::genmask_alternate(G_BITS) ^ {G_BITS{addr[AN]}},
                             din} :
                            {{G_BITS{1'b1}}, {D_BITS{1'b1}}};
  assign we = put | ~InitCnt[AN];

  assign base   = OPbin;
  assign failed = Fail;

  logic [1:0]           InitDelay = '0;
  logic [A_BITS-1:0]    OP        = '0;
  logic [A_BITS-1:0]    OPnxt;
  logic                 vldi;

  always_ff @(posedge clk_rd) begin
    if (rst_rd) begin
      InitDelay <= '0;
      OP        <= '0;
      OPgray    <= '0;
    end else begin
      if (!InitDelay[1])
        InitDelay <= InitDelay + 1;
      OP     <= OPnxt;
      OPgray <= poc_utils::bits#(A_BITS)::bin2gray(OP);
    end
  end

  assign OPnxt = (vldi && got) ? OP + 1 : OP;
  assign ra    = OPnxt[AN-1:0];

  always_comb begin
    logic [G_BITS-1:0] op_tag;
    op_tag = poc_utils::bits#(G_BITS)::genmask_alternate(G_BITS) ^ {G_BITS{OP[AN]}};
    if (!InitDelay[1])
      vldi = 1'b0;
    else if (poc_ocram::to_x01_sl(|do_ram[DN-1:D_BITS]) === 1'bx)
      vldi = 1'bx;
    else if (do_ram[DN-1:D_BITS] == op_tag)
      vldi = 1'b1;
    else
      vldi = 1'b0;
  end

  assign dout = do_ram[D_BITS-1:0];
  assign vld  = vldi;

  logic [DN-1:0] assembly_mem[0:(1 << AN)-1];

  always_ff @(posedge clk_wr) begin
    if (we)
      assembly_mem[wa] <= di;
  end

  always_ff @(posedge clk_rd) begin
    do_ram <= assembly_mem[ra];
  end

endmodule
