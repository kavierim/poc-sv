// SPDX-FileCopyrightText: 2024-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273
// VHDL: PoC/src/bus/axi4stream/axi4stream_Pause.vhdl

`timescale 1ns/1ps

import poc_axi4stream::*;

// verilator lint_off MULTITOP
module axi4stream_Pause #(
  parameter bit PACKET_MODE = 1'b0,
  parameter int DATA_BITS   = 32,
  parameter int USER_BITS   = 1,
  parameter int DEST_BITS   = 1,
  parameter int ID_BITS     = 1,
  parameter int KEEP_BITS   = 0,
  parameter type m2s_t = axi4stream_sized#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::m2s_t,
  parameter type s2m_t = axi4stream_sized#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::s2m_t
) (
  input  logic Clock,
  input  logic Reset,

  input  logic Pause,
  output logic In_Packet,
  output logic Data_Available,
  output logic Data_Blocked,

  input  m2s_t In_M2S,
  output s2m_t In_S2M,

  output m2s_t Out_M2S,
  input  s2m_t Out_S2M
);
  logic Pause_internal;

  if (PACKET_MODE) begin : gen_packet_mode
    typedef enum logic {ST_IDLE, ST_IN_PACKET} packet_state_t;

    packet_state_t pause_state     = ST_IDLE;
    packet_state_t pause_state_next;

    logic is_transaction;
    logic is_packet_end;

    assign is_transaction = In_M2S.Valid & In_S2M.Ready;
    assign is_packet_end  = In_M2S.Last;

    always_comb begin
      pause_state_next = pause_state;
      Pause_internal   = 1'b0;
      In_Packet        = 1'b0;
      unique case (pause_state)
        ST_IDLE: begin
          Pause_internal = Pause;
          if (is_transaction & ~is_packet_end) begin
            In_Packet        = 1'b1;
            pause_state_next = ST_IN_PACKET;
          end
        end
        ST_IN_PACKET: begin
          In_Packet = 1'b1;
          if (is_transaction & is_packet_end) begin
            In_Packet        = 1'b0;
            pause_state_next = ST_IDLE;
          end
        end
        default: pause_state_next = ST_IDLE;
      endcase
    end

    always_ff @(posedge Clock) begin
      if (Reset)
        pause_state <= ST_IDLE;
      else
        pause_state <= pause_state_next;
    end
  end else begin : gen_simple_pause
    assign Pause_internal = Pause;
    assign In_Packet      = 1'b0;
  end

  assign Data_Available = In_M2S.Valid;
  assign Data_Blocked   = Pause_internal;

  assign Out_M2S.Valid = In_M2S.Valid & ~Pause_internal;
  assign Out_M2S.Data  = In_M2S.Data;
  assign Out_M2S.Keep  = In_M2S.Keep;
  assign Out_M2S.Last  = In_M2S.Last;
  assign Out_M2S.User  = In_M2S.User;
  assign Out_M2S.Dest  = In_M2S.Dest;
  assign Out_M2S.ID    = In_M2S.ID;

  assign In_S2M.Ready = Out_S2M.Ready & ~Pause_internal;

endmodule
