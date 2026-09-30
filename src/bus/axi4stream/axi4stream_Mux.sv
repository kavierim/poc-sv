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
module axi4stream_Mux #(
  parameter bit  USE_CONTROL_VECTOR = 1'b0,
  parameter bit  APPEND_DEST_BITS   = 1'b0,
  parameter int  PORTS              = 2,
  parameter int  DATA_BITS          = 32,
  parameter int  USER_BITS          = 1,
  parameter int  DEST_BITS          = 1,
  parameter int  ID_BITS            = 1,
  parameter int  KEEP_BITS          = 0,
  parameter type m2s_t = axi4stream_sized#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::m2s_t,
  parameter type s2m_t = axi4stream_sized#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::s2m_t
) (
  input  logic Clock,
  input  logic Reset,

  input  logic [PORTS-1:0] MuxControl,

  input  m2s_t In_M2S[PORTS],
  output s2m_t In_S2M[PORTS],

  output m2s_t Out_M2S,
  input  s2m_t Out_S2M
);
  import poc_utils::*;

  localparam int PORT_IDX_W = downto_width(log2ceilnz(PORTS));

  function automatic logic [PORT_IDX_W-1:0] mux_onehot2bin(logic [PORTS-1:0] oh);
    for (int i = 0; i < PORTS; i++)
      if (oh[i])
        return logic'(unsigned'(i));
    return '0;
  endfunction

  typedef enum logic [1:0] {
    ST_IDLE,
    ST_DATAFLOW
  } state_t;

  state_t State     = ST_IDLE;
  state_t NextState;

  logic [PORTS-1:0] RequestVector;
  logic             RequestWithSelf;
  logic             RequestWithoutSelf;

  logic             ChannelPointer_en;
  logic [PORTS-1:0] ChannelPointer;
  logic [PORTS-1:0] ChannelPointer_d   = (1'b1 << (PORTS - 1));
  logic [PORTS-1:0] ChannelPointer_nxt;
  logic [PORT_IDX_W-1:0] ChannelPointer_bin;

  int               idx;
  logic             Out_Last_i;
  logic             FSM_Dataflow_en;

  always_ff @(posedge Clock) begin
    if (Reset)
      State <= ST_IDLE;
    else
      State <= NextState;
  end

  always_ff @(posedge Clock) begin
    if (Reset)
      ChannelPointer_d <= (1'b1 << (PORTS - 1));
    else if (ChannelPointer_en)
      ChannelPointer_d <= ChannelPointer_nxt;
  end

  // Single comb region matches VHDL process(all) + concurrent RR selects; lint_off for Out_Last_i order.
  /* verilator lint_off ALWCOMBORDER */
  always_comb begin
    m2s_t out_m2s;
    int   i;
    logic [PORTS-1:0] request_left;
    logic [PORTS-1:0] select_left;
    logic [PORTS-1:0] select_right;

    NextState         = State;
    FSM_Dataflow_en   = 1'b0;
    ChannelPointer_en = 1'b0;
    ChannelPointer    = ChannelPointer_d;

    for (i = 0; i < PORTS; i++)
      RequestVector[i] = In_M2S[i].Valid & (MuxControl[i] | ~USE_CONTROL_VECTOR);

    RequestWithSelf    = |RequestVector;
    RequestWithoutSelf = |(RequestVector & ~ChannelPointer_d);

    request_left = (~((unsigned'(ChannelPointer_d) - 1) | unsigned'(ChannelPointer_d))) &
                   unsigned'(RequestVector);
    select_left  = (unsigned'(~request_left) + 1) & unsigned'(request_left);
    select_right = (unsigned'(~RequestVector) + 1) & unsigned'(RequestVector);
    ChannelPointer_nxt = (request_left == '0) ? select_right : select_left;

    ChannelPointer_bin = mux_onehot2bin(ChannelPointer);
    idx                = int'(unsigned'(ChannelPointer_bin));
    Out_Last_i         = 1'b0;
    for (i = 0; i < PORTS; i++)
      if (ChannelPointer[i])
        Out_Last_i = In_M2S[i].Last;

    case (State)
      ST_IDLE: begin
        if (RequestWithSelf) begin
          ChannelPointer_en = 1'b1;
          NextState         = ST_DATAFLOW;
        end
      end
      ST_DATAFLOW: begin
        FSM_Dataflow_en = 1'b1;
        if (Out_S2M.Ready & Out_Last_i) begin
          if (~RequestWithoutSelf)
            NextState = ST_IDLE;
          else
            ChannelPointer_en = 1'b1;
        end
      end
      default: NextState = ST_IDLE;
    endcase

    out_m2s = axi4stream_sized#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::initialize_m2s(0);
    for (i = 0; i < PORTS; i++) begin
      if (ChannelPointer[i]) begin
        out_m2s.Data  = In_M2S[i].Data;
        out_m2s.User  = In_M2S[i].User;
        out_m2s.Keep  = In_M2S[i].Keep;
        out_m2s.ID    = In_M2S[i].ID;
        out_m2s.Dest  = APPEND_DEST_BITS ? {ChannelPointer_bin, In_M2S[i].Dest} : In_M2S[i].Dest;
        out_m2s.Valid = In_M2S[i].Valid & FSM_Dataflow_en;
        out_m2s.Last  = Out_Last_i;
      end
    end
    Out_M2S = out_m2s;

    for (i = 0; i < PORTS; i++) begin
      In_S2M[i].Ready = Out_S2M.Ready & FSM_Dataflow_en & ChannelPointer[i];
      In_S2M[i].User  = Out_S2M.User;
    end
  end
  /* verilator lint_on ALWCOMBORDER */

endmodule
