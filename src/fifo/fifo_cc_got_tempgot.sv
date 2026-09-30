// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2014 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

// verilator lint_off MULTITOP
module fifo_cc_got_tempgot #(
  parameter poc_mem::ram_type_t RAM_TYPE         = poc_mem::RAM_TYPE_OPTIMIZED,
  parameter int                 DATA_BITS        = 8,
  parameter int                 MIN_DEPTH        = 4,
  parameter bit                 DATA_REG         = 1'b0,
  /* verilator lint_off UNUSEDPARAM */
  parameter bit                 STATE_REG        = 1'b0,
  /* verilator lint_on UNUSEDPARAM */
  parameter bit                 OUTPUT_REG       = 1'b0,
  parameter int                 EMPTY_STATE_BITS = 0,
  parameter int                 FILL_STATE_BITS  = 0
) (
  input  logic                            Clock,
  input  logic                            Reset,

  input  logic                            Put,
  input  logic [DATA_BITS-1:0]            DataIn,
  output logic                            Full,
  output logic [poc_utils::imax(1, EMPTY_STATE_BITS)-1:0] EmptyState,

  input  logic                            Got,
  output logic [DATA_BITS-1:0]            DataOut,
  output logic                            Valid,
  output logic [poc_utils::imax(1, FILL_STATE_BITS)-1:0] FillState,

  input  logic                            Commit,
  input  logic                            Rollback
);
  import poc_utils::*;

  localparam int ADDRESS_BITS = log2ceil(MIN_DEPTH);

  logic [ADDRESS_BITS-1:0] IP0 = '0;
  logic [ADDRESS_BITS-1:0] OP0 = '0;
  logic [ADDRESS_BITS-1:0] IP1;
  logic [ADDRESS_BITS-1:0] OP1;
  logic [ADDRESS_BITS-1:0] OPm = '0;

  logic [ADDRESS_BITS-1:0] wa;
  logic                  we;
  logic [ADDRESS_BITS-1:0] ra;
  logic                  re;

  logic fulli;
  logic empti;

  logic [ADDRESS_BITS-1:0] IP0_slv;
  logic [ADDRESS_BITS-1:0] IP1_slv;
  logic [ADDRESS_BITS-1:0] OP0_slv;
  logic [ADDRESS_BITS-1:0] OP1_slv;

  assign IP0_slv = IP0;
  assign OP0_slv = OP0;

  arith_CarryChain_inc #(.BITS(ADDRESS_BITS)) incIP (.A(IP0_slv), .CarryIn(1'b1), .Sum(IP1_slv));
  arith_CarryChain_inc #(.BITS(ADDRESS_BITS)) incOP (.A(OP0_slv), .CarryIn(1'b1), .Sum(OP1_slv));

  assign IP1 = IP1_slv;
  assign OP1 = OP1_slv;

  always_ff @(posedge Clock) begin
    if (Reset) begin
      IP0 <= '0;
      OP0 <= '0;
      OPm <= '0;
    end else begin
      if (we)
        IP0 <= IP1;
      if (Rollback)
        OP0 <= OPm;
      else if (re)
        OP0 <= OP1;
      if (Commit)
        OPm <= re ? OP1 : OP0;
    end
  end

  assign wa = IP0;
  assign ra = OP0;

  if (EMPTY_STATE_BITS > 0) begin : gen_empty_state
    always_comb begin
      logic [ADDRESS_BITS-1:0] d;
      if (fulli)
        d = '1;
      else
        d = IP0 - OPm;
      EmptyState = ~d[ADDRESS_BITS-1 -: EMPTY_STATE_BITS];
    end
  end else begin : gen_empty_state_off
    assign EmptyState = 'x;
  end

  if (FILL_STATE_BITS > 0) begin : gen_fill_state
    always_comb begin
      logic [ADDRESS_BITS-1:0] d;
      if (fulli)
        d = '1;
      else
        d = IP0 - OP0;
      FillState = d[ADDRESS_BITS-1 -: FILL_STATE_BITS];
    end
  end else begin : gen_fill_state_off
    assign FillState = 'x;
  end

  logic Ful;
  logic Pnd;
  logic Avl;

  always_ff @(posedge Clock) begin
    if (Reset) begin
      Ful <= 1'b0;
      Pnd <= 1'b0;
      Avl <= 1'b0;
    end else begin
      if (Commit || Rollback)
        Pnd <= 1'b0;
      else if (re)
        Pnd <= 1'b1;
      if (Commit && (re || Pnd))
        Ful <= 1'b0;
      else if (we && (IP1 == OPm))
        Ful <= 1'b1;
      if (we || (Rollback && Pnd))
        Avl <= 1'b1;
      else if (re && !we && (OP1 == IP0))
        Avl <= 1'b0;
    end
  end

  assign fulli = Ful;
  assign empti = ~Avl;

  assign Full = fulli;
  assign we   = Put && !fulli;

  if (!DATA_REG) begin : gen_large
    logic [DATA_BITS-1:0] do_ram;

    ocram_SimpleDualPort_Optimized #(
      .ADDRESS_BITS(ADDRESS_BITS),
      .DATA_BITS   (DATA_BITS),
      .RAM_TYPE    (RAM_TYPE)
    ) ram (
      .Write_Clock      (Clock),
      .Read_Clock       (Clock),
      .Write_ClockEnable(1'b1),
      .Write_Address    (wa),
      .Write_WriteEnable(we),
      .Write_DataIn     (DataIn),
      .Read_Address     (ra),
      .Read_ClockEnable (re),
      .Read_DataOut     (do_ram)
    );

    if (!OUTPUT_REG) begin : gen_output_cmb
      logic Vld;
      always_ff @(posedge Clock) begin
        if (Reset)
          Vld <= 1'b0;
        else
          Vld <= (Vld && !Got) || !empti;
      end
      assign re      = (!Vld || Got) && !empti;
      assign DataOut = do_ram;
      assign Valid   = Vld;
    end else begin : gen_output_reg
      logic [DATA_BITS-1:0] Buf;
      logic [1:0]           Vld;
      always_ff @(posedge Clock) begin
        if (Reset) begin
          Buf <= '0;
          Vld <= '0;
        end else begin
          Vld[0] <= (Vld[0] && Vld[1] && !Got) || !empti;
          Vld[1] <= (Vld[1] && !Got) || Vld[0];
          if (!Vld[1] || Got)
            Buf <= do_ram;
        end
      end
      assign re      = (!Vld[0] || !Vld[1] || Got) && !empti;
      assign DataOut = Buf;
      assign Valid   = Vld[1];
    end
  end else begin : gen_small
    logic [DATA_BITS-1:0] regfile[0:(1 << ADDRESS_BITS)-1];
    always_ff @(posedge Clock) begin
      if (SIMULATION && Reset) begin
        for (int i = 0; i < (1 << ADDRESS_BITS); i++)
          regfile[i] <= '0;
      end else if (we)
        regfile[wa] <= DataIn;
    end
    assign re      = Got && !empti;
    assign DataOut = poc_ocram::address_cmp#(ADDRESS_BITS)::is_x_addr(ra) ? 'x : regfile[ra];
    assign Valid   = !empti;
  end

endmodule
