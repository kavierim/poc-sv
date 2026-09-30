// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

import poc_axi4stream::*;

// verilator lint_off MULTITOP
module axi4stream_DeMux #(
  parameter bit ADD_MIRROR_MODE     = 1'b0,
  parameter int OUTPUT_STAGES       = 0,
  parameter bit ENABLE_REVERSE_USER = 1'b0,
  parameter int PORTS               = 2,
  parameter int DATA_BITS           = 32,
  parameter int USER_BITS           = 1,
  parameter int DEST_BITS           = 1,
  parameter int ID_BITS             = 1,
  parameter int KEEP_BITS           = 0,
  parameter type m2s_t = axi4stream_types#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::m2s_t,
  parameter type s2m_t = axi4stream_types#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::s2m_t
) (
  input  logic Clock,
  input  logic Reset,

  input  logic [PORTS-1:0] DeMuxControl,

  input  m2s_t In_M2S,
  output s2m_t In_S2M,

  output m2s_t Out_M2S[PORTS],
  input  s2m_t Out_S2M[PORTS]
);
  import poc_utils::*;

  function automatic int strm_demux_lssb_idx(logic [PORTS-1:0] arg);
    for (int i = 0; i < PORTS; i++)
      if (arg[i])
        return i;
    return 0;
  endfunction

  typedef enum logic [1:0] {
    ST_IDLE,
    ST_DATAFLOW,
    ST_DISCARD_FRAME
  } state_t;

  state_t State     = ST_IDLE;
  state_t NextState;

  logic Is_EOF;
  logic In_Ack_i;
  logic Out_Valid_i;
  logic DiscardFrame;

  logic             ChannelPointer_en;
  logic [PORTS-1:0] ChannelPointer;
  logic [PORTS-1:0] ChannelPointer_d = '0;

  logic [PORTS-1:0] Out_Ready;
  // No variable initializer: gen_no_mirror drives with a continuous assign (CONTASSINIT).
  logic [PORTS-1:0] Valid_Mask_r;

  axi4stream_types#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::m2s_t Out_M2S_d[PORTS];
  axi4stream_types#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::s2m_t Out_S2M_d[PORTS];

  if (ADD_MIRROR_MODE) begin : gen_mirror
    always_ff @(posedge Clock) begin
      if (Reset | In_Ack_i)
        Valid_Mask_r <= '1;
      else if (Out_Valid_i)
        Valid_Mask_r <= Valid_Mask_r & ~Out_Ready;
    end
  end else begin : gen_no_mirror
    assign Valid_Mask_r = '1;
  end

  assign DiscardFrame = ~|DeMuxControl;
  assign Is_EOF       = In_M2S.Valid & In_M2S.Last;

  always_ff @(posedge Clock) begin
    if (Reset)
      State <= ST_IDLE;
    else
      State <= NextState;
  end

  always_ff @(posedge Clock) begin
    if (ChannelPointer_en)
      ChannelPointer_d <= DeMuxControl;
  end

  /* verilator lint_off ALWCOMBORDER */
  always_comb begin
    m2s_t out_d[PORTS];
    int   i;

    NextState         = State;
    ChannelPointer_en = 1'b0;
    ChannelPointer    = ChannelPointer_d;
    In_S2M.Ready      = 1'b0;
    Out_Valid_i       = 1'b0;

    for (i = 0; i < PORTS; i++)
      Out_Ready[i] = Out_S2M_d[i].Ready;

    if (ADD_MIRROR_MODE)
      In_Ack_i = &((~Valid_Mask_r) | (Out_Ready | (~ChannelPointer)));
    else
      In_Ack_i = |(Out_Ready & ChannelPointer);

    case (State)
      ST_IDLE: begin
        ChannelPointer = DeMuxControl;
        if (In_M2S.Valid) begin
          ChannelPointer_en = 1'b1;
          if (~DiscardFrame) begin
            In_S2M.Ready = In_Ack_i;
            Out_Valid_i  = 1'b1;
            if (Is_EOF & In_Ack_i)
              NextState = ST_IDLE;
            else
              NextState = ST_DATAFLOW;
          end else begin
            In_S2M.Ready = 1'b1;
            if (Is_EOF)
              NextState = ST_IDLE;
            else
              NextState = ST_DISCARD_FRAME;
          end
        end
      end
      ST_DATAFLOW: begin
        In_S2M.Ready = In_Ack_i;
        Out_Valid_i  = In_M2S.Valid;
        if (Is_EOF & In_Ack_i)
          NextState = ST_IDLE;
      end
      ST_DISCARD_FRAME: begin
        In_S2M.Ready = 1'b1;
        if (Is_EOF)
          NextState = ST_IDLE;
      end
      default: NextState = ST_IDLE;
    endcase

    for (i = 0; i < PORTS; i++) begin
      out_d[i] = axi4stream_sized#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::initialize_m2s(0);
      out_d[i].Valid = Out_Valid_i & ChannelPointer[i] & Valid_Mask_r[i];
      out_d[i].Data  = In_M2S.Data;
      out_d[i].Keep  = In_M2S.Keep;
      out_d[i].User  = In_M2S.User;
      out_d[i].Dest  = In_M2S.Dest;
      out_d[i].ID    = In_M2S.ID;
      out_d[i].Last  = In_M2S.Last;
      Out_M2S_d[i]   = out_d[i];
    end

    if (ENABLE_REVERSE_USER)
      In_S2M.User = Out_S2M_d[strm_demux_lssb_idx(ChannelPointer)].User;
    else
      In_S2M.User = '0;
  end
  /* verilator lint_on ALWCOMBORDER */

  for (genvar i = 0; i < PORTS; i++) begin : gen_output
    axi4stream_Stage #(
      .DATA_BITS(DATA_BITS),
      .USER_BITS(USER_BITS),
      .DEST_BITS(DEST_BITS),
      .ID_BITS  (ID_BITS),
      .KEEP_BITS(KEEP_BITS),
      .STAGES   (OUTPUT_STAGES)
    ) OutStage (
      .Clock  (Clock),
      .Reset  (Reset),
      .In_M2S (Out_M2S_d[i]),
      .In_S2M (Out_S2M_d[i]),
      .Out_M2S(Out_M2S[i]),
      .Out_S2M(Out_S2M[i])
    );
  end

endmodule
