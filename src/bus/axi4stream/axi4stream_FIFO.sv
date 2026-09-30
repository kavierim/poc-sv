// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273
// VHDL: PoC/src/bus/axi4stream/axi4stream_FIFO.vhdl

`timescale 1ns/1ps

import poc_axi4stream::*;

// verilator lint_off MULTITOP
module axi4stream_FIFO #(
  parameter int  FRAMES              = 2,
  parameter int  MAX_PACKET_DEPTH      = 8,
  parameter poc_mem::ram_type_t RAM_TYPE = poc_mem::RAM_TYPE_OPTIMIZED,
  parameter bit  METADATA_IS_DYNAMIC   = 1'b1,
  parameter int  DATA_BITS             = 32,
  parameter int  USER_BITS             = 1,
  parameter int  DEST_BITS             = 1,
  parameter int  ID_BITS               = 1,
  parameter int  KEEP_BITS             = 0,
  parameter type m2s_t = axi4stream_types#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::m2s_t,
  parameter type s2m_t = axi4stream_types#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::s2m_t
) (
  input  logic Clock,
  input  logic Reset,

  input  m2s_t In_m2s,
  output s2m_t In_s2m,

  output m2s_t Out_m2s,
  input  s2m_t Out_s2m
);
  import poc_utils::*;
  import poc_vectors::*;
  import poc_mem::*;
  import poc_axi4stream::*;

  localparam int KEEP_W        = (KEEP_BITS > 0) ? KEEP_BITS : div_ceil(DATA_BITS, 8);
  localparam bit INCLUDE_META  = METADATA_IS_DYNAMIC & (USER_BITS > 0);

  typedef enum logic {ST_IDLE, ST_FRAME} writer_state_t;
  typedef enum logic {ST_R_IDLE, ST_R_FRAME} reader_state_t;

  writer_state_t Writer_State     = ST_IDLE;
  writer_state_t Writer_NextState;
  reader_state_t Reader_State     = ST_R_IDLE;
  reader_state_t Reader_NextState;

  localparam int Data_Pos = 0;
  localparam int Keep_Pos = 1;
  localparam int Last_Pos = 2;
  localparam int User_Pos = 3;

  localparam int Data_Bits_Vec[0:3] = '{DATA_BITS, KEEP_W, 1, USER_BITS};
  localparam int DATA_FIFO_W_FULL   = DATA_BITS + KEEP_W + 1 + USER_BITS;
  localparam int DATA_FIFO_W_NOMETA = DATA_BITS + KEEP_W + 1;
  localparam int PACK_DATA_LO = 0;
  localparam int PACK_DATA_HI = DATA_BITS - 1;
  localparam int PACK_KEEP_LO = DATA_BITS;
  localparam int PACK_KEEP_HI = DATA_BITS + KEEP_W - 1;
  localparam int PACK_LAST_BIT = DATA_BITS + KEEP_W;
  localparam int PACK_USER_LO = DATA_BITS + KEEP_W + 1;
  localparam int PACK_USER_HI = DATA_BITS + KEEP_W + USER_BITS;
  localparam int DATA_FIFO_W        = INCLUDE_META ? DATA_FIFO_W_FULL : DATA_FIFO_W_NOMETA;

  logic DataFIFO_put;
  logic [DATA_FIFO_W_FULL-1:0] DataFIFO_DataIn;
  logic DataFIFO_Full;
  logic MetaFIFO_put;
  logic MetaFIFO_Full;

  logic DataFIFO_got;
  logic [DATA_FIFO_W_FULL-1:0] DataFIFO_DataOut;
  logic DataFIFO_Valid;
  logic data_fifo_empty_st;
  logic data_fifo_fill_st;
  logic meta_fifo_empty_st;
  logic meta_fifo_fill_st;

  m2s_t Out_M2S_i;

  always_ff @(posedge Clock) begin
    if (Reset) begin
      Writer_State <= ST_IDLE;
      Reader_State <= ST_R_IDLE;
    end else begin
      Writer_State <= Writer_NextState;
      Reader_State <= Reader_NextState;
    end
  end

  always_comb begin
    Writer_NextState = Writer_State;
    In_s2m.Ready     = 1'b0;
    DataFIFO_put     = 1'b0;
    MetaFIFO_put     = 1'b0;

    DataFIFO_DataIn[PACK_DATA_HI:PACK_DATA_LO] = In_m2s.Data;
    DataFIFO_DataIn[PACK_LAST_BIT]             = In_m2s.Last;
    DataFIFO_DataIn[PACK_KEEP_HI:PACK_KEEP_LO] = In_m2s.Keep;
    if (METADATA_IS_DYNAMIC && (USER_BITS > 0))
      DataFIFO_DataIn[PACK_USER_HI:PACK_USER_LO] = In_m2s.User;

    unique case (Writer_State)
      ST_IDLE: begin
        In_s2m.Ready = ~DataFIFO_Full & ~MetaFIFO_Full;
        DataFIFO_put = In_m2s.Valid & ~MetaFIFO_Full;
        MetaFIFO_put = In_m2s.Valid & ~DataFIFO_Full;
        if (In_m2s.Valid & ~In_m2s.Last & ~MetaFIFO_Full & ~DataFIFO_Full)
          Writer_NextState = ST_FRAME;
      end
      ST_FRAME: begin
        In_s2m.Ready = ~DataFIFO_Full;
        DataFIFO_put = In_m2s.Valid;
        if (In_m2s.Valid & In_m2s.Last & ~DataFIFO_Full)
          Writer_NextState = ST_IDLE;
      end
      default: Writer_NextState = ST_IDLE;
    endcase
  end

  always_comb begin
    Reader_NextState = Reader_State;
    Out_M2S_i.Valid  = 1'b0;
    DataFIFO_got     = 1'b0;

    Out_M2S_i.Data = DataFIFO_DataOut[PACK_DATA_HI:PACK_DATA_LO];
    Out_M2S_i.Last = DataFIFO_DataOut[PACK_LAST_BIT];
    Out_M2S_i.Keep = DataFIFO_DataOut[PACK_KEEP_HI:PACK_KEEP_LO];
    if (METADATA_IS_DYNAMIC && (USER_BITS > 0))
      Out_M2S_i.User = DataFIFO_DataOut[PACK_USER_HI:PACK_USER_LO];

    unique case (Reader_State)
      ST_R_IDLE: begin
        Out_M2S_i.Valid = DataFIFO_Valid;
        DataFIFO_got    = Out_s2m.Ready;
        if (DataFIFO_Valid & ~DataFIFO_DataOut[PACK_LAST_BIT] & Out_s2m.Ready)
          Reader_NextState = ST_R_FRAME;
      end
      ST_R_FRAME: begin
        Out_M2S_i.Valid = DataFIFO_Valid;
        DataFIFO_got    = Out_s2m.Ready;
        if (DataFIFO_Valid & DataFIFO_DataOut[PACK_LAST_BIT] & Out_s2m.Ready)
          Reader_NextState = ST_R_IDLE;
      end
      default: Reader_NextState = ST_R_IDLE;
    endcase
  end

  assign Out_m2s = Out_M2S_i;

  if ((FRAMES > 2) || (MAX_PACKET_DEPTH > 2)) begin : gen_deep_fifo
    fifo_cc_got #(
      .DATA_BITS       (DATA_FIFO_W),
      .MIN_DEPTH       (MAX_PACKET_DEPTH * FRAMES),
      .RAM_TYPE        (RAM_TYPE),
      .DATA_REG        ((MAX_PACKET_DEPTH * FRAMES) <= 128),
      .STATE_REG       (1'b1),
      .OUTPUT_REG      (1'b0),
      .EMPTY_STATE_BITS(0),
      .FILL_STATE_BITS (0)
    ) DataFifo (
      .Clock     (Clock),
      .Reset     (Reset),
      .Put       (DataFIFO_put),
      .DataIn    (DataFIFO_DataIn[DATA_FIFO_W-1:0]),
      .Full      (DataFIFO_Full),
      .EmptyState(data_fifo_empty_st),
      .Got       (DataFIFO_got),
      .DataOut   (DataFIFO_DataOut[DATA_FIFO_W-1:0]),
      .Valid     (DataFIFO_Valid),
      .FillState (data_fifo_fill_st)
    );
  end else begin : gen_stage_fifo
    fifo_Stage #(
      .DATA_BITS(DATA_FIFO_W),
      .STAGES   (FRAMES)
    ) Stage (
      .Clock  (Clock),
      .Reset  (Reset),
      .Put    (DataFIFO_put),
      .DataIn (DataFIFO_DataIn[DATA_FIFO_W-1:0]),
      .Full   (DataFIFO_Full),
      .Valid  (DataFIFO_Valid),
      .DataOut(DataFIFO_DataOut[DATA_FIFO_W-1:0]),
      .Got    (DataFIFO_got)
    );
  end

  if (((!METADATA_IS_DYNAMIC) && (USER_BITS > 0)) || (DEST_BITS > 0) || (ID_BITS > 0)) begin : genMeta
    localparam int Dest_Pos = 0;
    localparam int ID_Pos   = 1;
    localparam int MetaUser_Pos = 2;
    localparam int Meta_Bits_Vec[0:2] = '{DEST_BITS, ID_BITS, USER_BITS};
    localparam int META_W = METADATA_IS_DYNAMIC ? (DEST_BITS + ID_BITS) : (DEST_BITS + ID_BITS + USER_BITS);

    logic [META_W-1:0] Meta_In;
    logic [META_W-1:0] Meta_Out;

    localparam int META_DEST_HI = DEST_BITS - 1;
    localparam int META_ID_LO   = DEST_BITS;
    localparam int META_ID_HI   = DEST_BITS + ID_BITS - 1;
    localparam int META_USER_LO = DEST_BITS + ID_BITS;
    localparam int META_USER_HI = DEST_BITS + ID_BITS + USER_BITS - 1;

    assign Meta_In[META_DEST_HI:0]        = In_m2s.Dest;
    assign Meta_In[META_ID_HI:META_ID_LO] = In_m2s.ID;
    assign Out_M2S_i.Dest = Meta_Out[META_DEST_HI:0];
    assign Out_M2S_i.ID   = Meta_Out[META_ID_HI:META_ID_LO];

    if (!METADATA_IS_DYNAMIC) begin : data_gen
      assign Meta_In[META_USER_HI:META_USER_LO] = In_m2s.User;
      assign Out_M2S_i.User = Meta_Out[META_USER_HI:META_USER_LO];
    end

    logic MetaFIFO_Valid_unused;

    fifo_cc_got #(
      .DATA_BITS       (META_W),
      .MIN_DEPTH       (imax(FRAMES, 16)),
      .RAM_TYPE        (RAM_TYPE),
      .DATA_REG        ((META_W * imax(FRAMES, 16)) <= 128),
      .STATE_REG       (1'b1),
      .OUTPUT_REG      (1'b0),
      .EMPTY_STATE_BITS(0),
      .FILL_STATE_BITS (0)
    ) MetaFIFO (
      .Clock     (Clock),
      .Reset     (Reset),
      .Put       (MetaFIFO_put),
      .DataIn    (Meta_In),
      .Full      (MetaFIFO_Full),
      .EmptyState(meta_fifo_empty_st),
      .Got       (Out_M2S_i.Valid & Out_M2S_i.Last & Out_s2m.Ready),
      .DataOut   (Meta_Out),
      .Valid     (MetaFIFO_Valid_unused),
      .FillState (meta_fifo_fill_st)
    );
  end else begin : genNoMeta
    assign MetaFIFO_Full = 1'b0;
  end

endmodule
