// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-28, Kari Vierimaa, Kempele, Finland.
// Self-checking Verilator smoke test for axi4stream_FIFO_TempPut.

`timescale 1ns/1ps

module axi4stream_FIFO_TempPut_tb;
  import poc_axi4stream::*;

  localparam int DATA_W = 8;
  localparam int USER_W = 1;
  localparam int DEST_W = 1;
  localparam int ID_W   = 1;

  typedef axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::m2s_t m2s_t;
  typedef axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::s2m_t s2m_t;

  logic Clock = 1'b0;
  logic Reset = 1'b1;
  logic In_Commit   = 1'b0;
  logic In_Rollback = 1'b0;

  m2s_t In_M2S;
  s2m_t In_S2M;
  m2s_t Out_M2S;
  s2m_t Out_S2M;

  always #5 Clock = ~Clock;

  axi4stream_FIFO_TempPut #(
    .FRAMES          (2),
    .MAX_PACKET_DEPTH(2),
    .USER_IS_DYNAMIC (1'b0),
    .DATA_BITS       (DATA_W),
    .USER_BITS       (USER_W),
    .DEST_BITS       (DEST_W),
    .ID_BITS         (ID_W)
  ) dut (
    .Clock       (Clock),
    .Reset       (Reset),
    .In_M2S      (In_M2S),
    .In_S2M      (In_S2M),
    .In_Commit   (In_Commit),
    .In_Rollback (In_Rollback),
    .EmptyState  (),
    .Out_M2S     (Out_M2S),
    .Out_S2M     (Out_S2M),
    .FillState   ()
  );

  task automatic send_beat(input logic [DATA_W-1:0] data, input logic last);
    In_M2S.Valid = 1'b1;
    In_M2S.Data  = data;
    In_M2S.Last  = last;
    In_M2S.Keep  = '1;
    In_M2S.User  = '0;
    In_M2S.Dest  = '0;
    In_M2S.ID    = '0;
    @(posedge Clock);
    while (~In_S2M.Ready) @(posedge Clock);
    if (~last) begin
      In_M2S.Valid = 1'b0;
      @(posedge Clock);
    end
  endtask

  task automatic pulse_commit();
    In_Commit = 1'b1;
    @(posedge Clock);
    In_Commit = 1'b0;
  endtask

  task automatic expect_beats(input logic [DATA_W-1:0] b0, input logic [DATA_W-1:0] b1);
    int i;
    logic [DATA_W-1:0] gold[0:1];
    gold[0] = b0;
    gold[1] = b1;
    for (i = 0; i < 2; i++) begin
      while (~Out_M2S.Valid) @(posedge Clock);
      if (Out_M2S.Data !== gold[i] || Out_M2S.Last !== (i == 1))
        $fatal(1, "TempPut beat %0d mismatch data=%h last=%b", i, Out_M2S.Data, Out_M2S.Last);
      Out_S2M.Ready = 1'b1;
      @(posedge Clock);
      Out_S2M.Ready = 1'b0;
      @(posedge Clock);
    end
  endtask

  initial begin
    In_M2S  = axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::initialize_m2s(0);
    Out_S2M = axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::initialize_s2m(0);

    repeat (4) @(posedge Clock);
    Reset = 1'b0;
    repeat (2) @(posedge Clock);

    send_beat(8'h11, 1'b0);
    send_beat(8'h22, 1'b1);
    In_M2S.Valid = 1'b0;
    repeat (3) @(posedge Clock);
    if (Out_M2S.Valid)
      $fatal(1, "TempPut: data visible before In_Commit");

    pulse_commit();
    expect_beats(8'h11, 8'h22);

    send_beat(8'h33, 1'b1);
    In_M2S.Valid = 1'b0;
    @(posedge Clock);
    In_Rollback = 1'b1;
    @(posedge Clock);
    In_Rollback = 1'b0;
    pulse_commit();
    repeat (4) @(posedge Clock);
    if (Out_M2S.Valid)
      $fatal(1, "TempPut: rolled-back beat became visible");

    $display("axi4stream_FIFO_TempPut_tb: PASS");
    $finish;
  end
endmodule
