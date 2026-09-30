// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Self-checking Verilator testbench for axi4stream_Pause.

`timescale 1ns/1ps

module axi4stream_Pause_tb;
  import poc_axi4stream::*;

  localparam int DATA_W = 8;
  localparam int USER_W = 1;
  localparam int DEST_W = 1;
  localparam int ID_W   = 1;

  typedef axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::m2s_t m2s_t;
  typedef axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::s2m_t s2m_t;

  logic Clock = 1'b0;
  logic Reset = 1'b1;
  logic Pause = 1'b0;

  m2s_t In_M2S;
  s2m_t In_S2M;
  m2s_t Out_M2S;
  s2m_t Out_S2M;

  always #5 Clock = ~Clock;

  axi4stream_Pause #(
    .PACKET_MODE(1'b0),
    .DATA_BITS  (DATA_W),
    .USER_BITS  (USER_W),
    .DEST_BITS  (DEST_W),
    .ID_BITS    (ID_W)
  ) dut (
    .Clock   (Clock),
    .Reset   (Reset),
    .Pause   (Pause),
    .In_Packet(),
    .Data_Available(),
    .Data_Blocked(),
    .In_M2S  (In_M2S),
    .In_S2M  (In_S2M),
    .Out_M2S (Out_M2S),
    .Out_S2M (Out_S2M)
  );

  initial begin
    In_M2S  = axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::initialize_m2s(0);
    Out_S2M = axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::initialize_s2m(0);
    Out_S2M.Ready = 1'b1;

    repeat (4) @(posedge Clock);
    Reset = 1'b0;
    repeat (2) @(posedge Clock);

    In_M2S.Valid = 1'b1;
    In_M2S.Data  = 8'hA5;
    In_M2S.Last  = 1'b1;
    In_M2S.Keep  = '1;
    @(posedge Clock);
    if (~Out_M2S.Valid || Out_M2S.Data !== 8'hA5)
      $fatal(1, "Pause off: beat should pass through");

    Pause = 1'b1;
    In_M2S.Data = 8'h5A;
    @(posedge Clock);
    if (Out_M2S.Valid)
      $fatal(1, "Pause on: Valid should be suppressed");
    if (In_S2M.Ready)
      $fatal(1, "Pause on: upstream Ready should be low");

    Pause = 1'b0;
    @(posedge Clock);
    if (~Out_M2S.Valid || Out_M2S.Data !== 8'h5A)
      $fatal(1, "Pause released: beat should pass through");

    In_M2S.Valid = 1'b0;
    $display("axi4stream_Pause_tb: PASS");
    $finish;
  end
endmodule
