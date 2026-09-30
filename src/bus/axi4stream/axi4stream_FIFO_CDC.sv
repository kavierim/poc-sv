// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273
// VHDL: PoC/src/bus/axi4stream/axi4stream_FIFO_CDC.vhdl

`timescale 1ns/1ps

import poc_axi4stream::*;

// verilator lint_off MULTITOP
module axi4stream_FIFO_CDC #(
  parameter int  FRAMES           = 2,
  parameter int  MAX_PACKET_DEPTH   = 8,
  parameter bit  USER_IS_DYNAMIC    = 1'b1,
  parameter bit  NO_META_FIFO       = 1'b0,
  parameter int  DATA_BITS          = 32,
  parameter int  USER_BITS          = 1,
  parameter int  DEST_BITS          = 1,
  parameter int  ID_BITS            = 1,
  parameter int  KEEP_BITS          = 0,
  parameter type m2s_t = axi4stream_types#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::m2s_t,
  parameter type s2m_t = axi4stream_types#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::s2m_t
) (
  input  logic In_Clock,
  input  logic In_Reset,
  input  m2s_t In_M2S,
  output s2m_t In_S2M,

  input  logic Out_Clock,
  input  logic Out_Reset,
  output m2s_t Out_M2S,
  input  s2m_t Out_S2M
);
  import poc_utils::*;
  import poc_vectors::*;
  import poc_axi4stream::*;

  localparam int KEEP_W = (KEEP_BITS > 0) ? KEEP_BITS : div_ceil(DATA_BITS, 8);

  typedef enum logic [1:0] {ST_IDLE, ST_FRAME} writer_state_t;

  writer_state_t Writer_State     = ST_IDLE;
  writer_state_t Writer_NextState;

  localparam int DATA_POS  = 0;
  localparam int LAST_POS  = 1;
  localparam int KEEP_POS  = 2;
  localparam int USER_POS  = 3;

  localparam int FIFO_BIT_VEC[0:3] = '{DATA_BITS, 1, KEEP_W, USER_BITS};
  localparam int DATA_FIFO_W_FULL  = DATA_BITS + 1 + KEEP_W + USER_BITS;
  localparam int DATA_FIFO_W       = USER_IS_DYNAMIC ? DATA_FIFO_W_FULL : (DATA_FIFO_W_FULL - USER_BITS);
  localparam int PACK_DATA_LO = 0;
  localparam int PACK_DATA_HI = DATA_BITS - 1;
  localparam int PACK_LAST_BIT = DATA_BITS;
  localparam int PACK_KEEP_LO = DATA_BITS + 1;
  localparam int PACK_KEEP_HI = DATA_BITS + KEEP_W;
  localparam int PACK_USER_LO = DATA_BITS + 1 + KEEP_W;
  localparam int PACK_USER_HI = DATA_BITS + KEEP_W + USER_BITS;

  logic DataFIFO_put;
  logic [DATA_FIFO_W_FULL-1:0] DataFIFO_DataIn;
  logic DataFIFO_Full;
  logic MetaFIFO_put;
  logic MetaFIFO_Full;

  logic DataFIFO_got;
  logic [DATA_FIFO_W_FULL-1:0] DataFIFO_DataOut;
  logic DataFIFO_Valid;
  logic data_wr_empty_st;
  logic data_rd_fill_st;

  always_ff @(posedge In_Clock) begin
    if (In_Reset)
      Writer_State <= ST_IDLE;
    else
      Writer_State <= Writer_NextState;
  end

  /* verilator lint_off ALWCOMBORDER */
  always_comb begin
    logic put_data;
    logic put_meta;

    Writer_NextState = Writer_State;
    In_S2M.Ready     = 1'b0;
    DataFIFO_put     = 1'b0;
    MetaFIFO_put     = 1'b0;

    DataFIFO_DataIn[PACK_DATA_HI:PACK_DATA_LO] = In_M2S.Data;
    DataFIFO_DataIn[PACK_LAST_BIT]             = In_M2S.Last;
    DataFIFO_DataIn[PACK_KEEP_HI:PACK_KEEP_LO] = In_M2S.Keep;
    if (USER_IS_DYNAMIC && (USER_BITS > 0))
      DataFIFO_DataIn[PACK_USER_HI:PACK_USER_LO] = In_M2S.User;

    case (Writer_State)
      ST_IDLE: begin
        put_data     = In_M2S.Valid & ~MetaFIFO_Full;
        put_meta     = In_M2S.Valid & ~DataFIFO_Full;
        DataFIFO_put = put_data;
        MetaFIFO_put = put_meta;
        In_S2M.Ready = ~DataFIFO_Full & ~MetaFIFO_Full;
        if (In_M2S.Valid & ~In_M2S.Last & ~MetaFIFO_Full & ~DataFIFO_Full)
          Writer_NextState = ST_FRAME;
      end
      ST_FRAME: begin
        put_data     = In_M2S.Valid;
        DataFIFO_put = put_data;
        In_S2M.Ready = ~DataFIFO_Full & (~In_M2S.Valid | put_data);
        if (In_M2S.Valid & In_M2S.Last & ~DataFIFO_Full)
          Writer_NextState = ST_IDLE;
      end
      default: Writer_NextState = ST_IDLE;
    endcase
  end
  /* verilator lint_on ALWCOMBORDER */

  // VHDL Read_proc — drive Out_M2S fields directly (Verilator does not propagate `assign Out_M2S = Out_M2S_i`).
  always_comb begin
    Out_M2S.Valid = DataFIFO_Valid;
    DataFIFO_got  = Out_S2M.Ready;
    Out_M2S.Data  = DataFIFO_DataOut[PACK_DATA_HI:PACK_DATA_LO];
    Out_M2S.Last  = DataFIFO_DataOut[PACK_LAST_BIT];
    Out_M2S.Keep  = DataFIFO_DataOut[PACK_KEEP_HI:PACK_KEEP_LO];
    if (USER_IS_DYNAMIC && (USER_BITS > 0))
      Out_M2S.User = DataFIFO_DataOut[PACK_USER_HI:PACK_USER_LO];
  end

  fifo_ic_got #(
    .DATA_BITS       (DATA_FIFO_W),
    .MIN_DEPTH       (MAX_PACKET_DEPTH * FRAMES),
    .DATA_REG        ((MAX_PACKET_DEPTH * FRAMES) <= 128),
    .OUTPUT_REG      (1'b0),
    .EMPTY_STATE_BITS(0),
    .FILL_STATE_BITS (0)
  ) DataFIFO (
    .Write_Clock     (In_Clock),
    .Write_Reset     (In_Reset),
    .Write_Put       (DataFIFO_put),
    .Write_DataIn    (DataFIFO_DataIn[DATA_FIFO_W-1:0]),
    .Write_Full      (DataFIFO_Full),
    .Write_EmptyState(data_wr_empty_st),
    .Read_Clock      (Out_Clock),
    .Read_Reset      (Out_Reset),
    .Read_Got        (DataFIFO_got),
    .Read_DataOut    (DataFIFO_DataOut[DATA_FIFO_W-1:0]),
    .Read_Valid      (DataFIFO_Valid),
    .Read_FillState  (data_rd_fill_st)
  );

  if (((!USER_IS_DYNAMIC) && (USER_BITS > 0)) || (DEST_BITS > 0) || (ID_BITS > 0)) begin : genMeta
    localparam int Dest_Pos     = 0;
    localparam int ID_Pos       = 1;
    localparam int MetaUser_Pos = 2;
    localparam int Meta_Bits_Vec[0:2] = '{DEST_BITS, ID_BITS, USER_BITS};
    localparam int META_W = USER_IS_DYNAMIC ? (DEST_BITS + ID_BITS) : (DEST_BITS + ID_BITS + USER_BITS);

    logic [META_W-1:0] Meta_In;
    logic [META_W-1:0] Meta_Out;

    localparam int META_DEST_HI = DEST_BITS - 1;
    localparam int META_ID_LO   = DEST_BITS;
    localparam int META_ID_HI   = DEST_BITS + ID_BITS - 1;
    localparam int META_USER_LO = DEST_BITS + ID_BITS;
    localparam int META_USER_HI = DEST_BITS + ID_BITS + USER_BITS - 1;

    assign Meta_In[META_DEST_HI:0]        = In_M2S.Dest;
    assign Meta_In[META_ID_HI:META_ID_LO] = In_M2S.ID;
    assign Out_M2S.Dest = Meta_Out[META_DEST_HI:0];
    assign Out_M2S.ID   = Meta_Out[META_ID_HI:META_ID_LO];

    if (!USER_IS_DYNAMIC) begin : data_gen
      assign Meta_In[META_USER_HI:META_USER_LO] = In_M2S.User;
      assign Out_M2S.User = Meta_Out[META_USER_HI:META_USER_LO];
    end

    if (!NO_META_FIFO) begin : meta_fifo
      logic MetaFIFO_Valid_unused;
      logic meta_wr_empty_st;
      logic meta_rd_fill_st;

      fifo_ic_got #(
        .DATA_BITS       (META_W),
        .MIN_DEPTH       (imax(FRAMES, 16)),
        .DATA_REG        ((META_W * imax(FRAMES, 16)) <= 128),
        .OUTPUT_REG      (1'b0),
        .EMPTY_STATE_BITS(0),
        .FILL_STATE_BITS (0)
      ) MetaFIFO (
        .Write_Clock     (In_Clock),
        .Write_Reset     (In_Reset),
        .Write_Put       (MetaFIFO_put),
        .Write_DataIn    (Meta_In),
        .Write_Full      (MetaFIFO_Full),
        .Write_EmptyState(meta_wr_empty_st),
        .Read_Clock      (Out_Clock),
        .Read_Reset      (Out_Reset),
        .Read_Got        (Out_M2S.Valid & Out_M2S.Last & Out_S2M.Ready),
        .Read_DataOut    (Meta_Out),
        .Read_Valid      (MetaFIFO_Valid_unused),
        .Read_FillState  (meta_rd_fill_st)
      );
    end else begin : no_meta_fifo
      assign MetaFIFO_Full = 1'b0;
      assign Meta_Out      = '0;
    end
  end else begin : genNoMeta
    assign MetaFIFO_Full = 1'b0;
  end

endmodule
