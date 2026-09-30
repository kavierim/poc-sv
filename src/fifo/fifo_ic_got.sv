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
module fifo_ic_got #(
  parameter int DATA_BITS         = 8,
  parameter int MIN_DEPTH         = 4,
  parameter bit DATA_REG          = 1'b0,
  parameter bit OUTPUT_REG        = 1'b0,
  parameter int EMPTY_STATE_BITS  = 0,
  parameter int FILL_STATE_BITS   = 0
) (
  input  logic                            Write_Clock,
  input  logic                            Write_Reset,
  input  logic                            Write_Put,
  input  logic [DATA_BITS-1:0]            Write_DataIn,
  output logic                            Write_Full,
  output logic [poc_utils::imax(1, EMPTY_STATE_BITS)-1:0] Write_EmptyState,

  input  logic                            Read_Clock,
  input  logic                            Read_Reset,
  output logic                            Read_Valid,
  output logic [DATA_BITS-1:0]            Read_DataOut,
  input  logic                            Read_Got,
  output logic [poc_utils::imax(1, FILL_STATE_BITS)-1:0] Read_FillState
);
  import poc_utils::*;

  localparam int ADDRESS_BITS = log2ceilnz(MIN_DEPTH);
  localparam int AN           = ADDRESS_BITS + 1;

  logic [AN-1:0] IP1;
  logic [AN-1:0] IP0 = '0;
  logic [AN-1:0] IP0_d = '0;
  logic [AN-1:0] OPc = '0;
  logic          Ful = 1'b0;

  logic [AN-1:0] OP1;
  logic [AN-1:0] OP0 = '0;
  logic [AN-1:0] OP0_d = '0;
  logic [AN-1:0] IPc = '0;
  logic          Avl = 1'b0;
  logic          Vld = 1'b0;

  logic [ADDRESS_BITS-1:0] wa;
  logic [DATA_BITS-1:0]    di;
  logic                    puti;

  logic [ADDRESS_BITS-1:0] ra;
  logic [DATA_BITS-1:0]    do_ram;
  logic                    geti;
  logic                    goti;

  logic [AN-1:0] wr_cnt;

  always_ff @(posedge Write_Clock) begin
    if (Write_Reset)
      wr_cnt <= 1;
    else if (puti)
      wr_cnt <= wr_cnt + 1;
  end

  assign IP1 = {wr_cnt[ADDRESS_BITS], wr_cnt[ADDRESS_BITS-1:0] ^ {1'b0, wr_cnt[ADDRESS_BITS-1:1]}};

  always_ff @(posedge Write_Clock) begin
    if (Write_Reset) begin
      IP0 <= '0;
      Ful <= 1'b0;
    end else begin
      if (puti) begin
        IP0 <= IP1;
        Ful <= (IP1[ADDRESS_BITS-1:0] == OPc[ADDRESS_BITS-1:0]);
      end
      if (Ful) begin
        if (IP0 == {~OPc[ADDRESS_BITS], OPc[ADDRESS_BITS-1:0]})
          Ful <= 1'b1;
        else
          Ful <= 1'b0;
      end
    end
  end

  assign puti       = Write_Put && !Ful;
  assign Write_Full = Ful;
  assign di         = Write_DataIn;
  assign wa         = unsigned'(IP0[ADDRESS_BITS-1:0]);

  always_ff @(posedge Write_Clock)
    IP0_d <= IP0;

  sync_Bits #(
    .BITS           (AN),
    .REGISTER_OUTPUT(1'b0)
  ) read_pointer_sync (
    .Clock (Read_Clock),
    .Input (IP0_d),
    .Output(IPc)
  );

  logic [AN-1:0] rd_cnt = 1;

  always_ff @(posedge Read_Clock) begin
    if (Read_Reset)
      rd_cnt <= 1;
    else if (geti)
      rd_cnt <= rd_cnt + 1;
  end

  assign OP1 = {rd_cnt[ADDRESS_BITS], rd_cnt[ADDRESS_BITS-1:0] ^ {1'b0, rd_cnt[ADDRESS_BITS-1:1]}};

  always_ff @(posedge Read_Clock) begin
    if (Read_Reset) begin
      OP0 <= '0;
      Avl <= 1'b0;
      Vld <= 1'b0;
    end else begin
      if (geti) begin
        OP0 <= OP1;
        Avl <= (OP1[ADDRESS_BITS-1:0] != IPc[ADDRESS_BITS-1:0]);
        Vld <= 1'b1;
      end else if (goti)
        Vld <= 1'b0;
      if (!Avl)
        Avl <= (OP0 != IPc);
    end
  end

  assign geti = (!Vld || goti) && Avl;
  assign ra   = unsigned'(OP0[ADDRESS_BITS-1:0]);

  always_ff @(posedge Read_Clock)
    OP0_d <= OP0;

  sync_Bits #(
    .BITS           (AN),
    .REGISTER_OUTPUT(1'b0)
  ) write_pointer_sync (
    .Clock (Write_Clock),
    .Input (OP0_d),
    .Output(OPc)
  );

  if (DATA_REG || !OUTPUT_REG) begin : gen_reg_n
    assign goti         = Read_Got;
    assign Read_DataOut = do_ram;
    assign Read_Valid   = Vld;
  end else begin : gen_reg_y
    logic [DATA_BITS-1:0] Buf;
    logic               VldB;

    always_ff @(posedge Read_Clock) begin
      if (Read_Reset) begin
        Buf  <= '0;
        VldB <= 1'b0;
      end else if (goti) begin
        Buf  <= do_ram;
        VldB <= Vld;
      end
    end

    assign goti         = !VldB || Read_Got;
    assign Read_DataOut = Buf;
    assign Read_Valid   = VldB;
  end

  if (EMPTY_STATE_BITS == 0) begin : g_empty_state_off
    assign Write_EmptyState = 'x;
  end else begin : g_empty_state
    logic [ADDRESS_BITS-1:0] d;
    assign d = poc_utils::bits#(ADDRESS_BITS)::gray2bin(OPc[ADDRESS_BITS-1:0]) +
               ~poc_utils::bits#(ADDRESS_BITS)::gray2bin(IP0[ADDRESS_BITS-1:0]);
    assign Write_EmptyState = Ful ? '0 : d[ADDRESS_BITS-1 -: EMPTY_STATE_BITS];
  end

  if (FILL_STATE_BITS == 0) begin : g_fill_state_off
    assign Read_FillState = 'x;
  end else begin : g_fill_state
    logic [ADDRESS_BITS-1:0] d;
    assign d = poc_utils::bits#(ADDRESS_BITS)::gray2bin(IPc[ADDRESS_BITS-1:0]) +
               ~poc_utils::bits#(ADDRESS_BITS)::gray2bin(OP0[ADDRESS_BITS-1:0]);
    assign Read_FillState = Avl ? d[ADDRESS_BITS-1 -: FILL_STATE_BITS] : '0;
  end

  if (!DATA_REG) begin : g_large
    logic [DATA_BITS-1:0] ic_mem[0:(1 << ADDRESS_BITS)-1];

    always_ff @(posedge Write_Clock) begin
      if (puti)
        ic_mem[wa] <= di;
    end

    always_ff @(posedge Read_Clock) begin
      if (geti)
        do_ram <= ic_mem[ra];
    end
  end else begin : g_small
    logic [DATA_BITS-1:0] regfile[0:(1 << ADDRESS_BITS)-1];

    always_ff @(posedge Write_Clock) begin
      if (SIMULATION && Write_Reset) begin
        for (int i = 0; i < (1 << ADDRESS_BITS); i++)
          regfile[i] <= '0;
      end else if (puti)
        regfile[wa] <= di;
    end

    always_ff @(posedge Read_Clock) begin
      if (SIMULATION && Read_Reset)
        do_ram <= '0;
      else if (geti)
        do_ram <= poc_ocram::address_cmp#(ADDRESS_BITS)::is_x_addr(ra) ? 'x : regfile[ra];
    end
  end

endmodule
