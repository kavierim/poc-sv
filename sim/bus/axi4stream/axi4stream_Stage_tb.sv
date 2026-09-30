// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-29, Kari Vierimaa, Kempele, Finland.
// Self-checking Verilator testbench for axi4stream_Stage (order, sideband, stall).

`timescale 1ns/1ps

module axi4stream_Stage_tb;
  import poc_axi4stream::*;

  localparam int DATA_W = 8;
  localparam int USER_W = 1;
  localparam int DEST_W = 1;
  localparam int ID_W   = 1;
  localparam int STAGES = 2;

  typedef axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::m2s_t m2s_t;
  typedef axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::s2m_t s2m_t;

  logic Clock = 1'b0;
  logic Reset = 1'b1;

  m2s_t In_M2S;
  s2m_t In_S2M;
  m2s_t Out_M2S;
  s2m_t Out_S2M;

  always #5 Clock = ~Clock;

  axi4stream_Stage #(
    .DATA_BITS (DATA_W),
    .USER_BITS (USER_W),
    .DEST_BITS (DEST_W),
    .ID_BITS   (ID_W),
    .STAGES    (STAGES)
  ) dut (
    .Clock   (Clock),
    .Reset   (Reset),
    .In_M2S  (In_M2S),
    .In_S2M  (In_S2M),
    .Out_M2S (Out_M2S),
    .Out_S2M (Out_S2M)
  );

  task automatic send_beat(input logic [DATA_W-1:0] data, input logic last);
    In_M2S.Valid = 1'b1;
    In_M2S.Data  = data;
    In_M2S.Last  = last;
    In_M2S.Keep  = 1'b1;
    In_M2S.User  = 1'b1;
    In_M2S.Dest  = 1'b0;
    In_M2S.ID    = 1'b1;
    @(posedge Clock);
    while (~In_S2M.Ready) begin
      @(posedge Clock);
      if ($time > 500_000)
        $fatal(1, "axi4stream_Stage_tb: timeout In Ready");
    end
    if (~last) begin
      In_M2S.Valid = 1'b0;
      @(posedge Clock);
    end
  endtask

  initial begin
    logic [DATA_W-1:0] gold[0:2];
    int i;

    In_M2S = axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::initialize_m2s(0);
    Out_S2M.Ready = 1'b0;
    Out_S2M.User  = '0;
    gold[0] = 8'h11;
    gold[1] = 8'h22;
    gold[2] = 8'h33;

    repeat (4) @(posedge Clock);
    Reset = 1'b0;

    // Load three-beat packet while output is stalled.
    send_beat(gold[0], 1'b0);
    send_beat(gold[1], 1'b0);
    send_beat(gold[2], 1'b1);
    In_M2S.Valid = 1'b0;
    repeat (STAGES + 2) @(posedge Clock);

    // Stalled data must be visible on the output before Ready.
    if (~Out_M2S.Valid)
      $fatal(1, "axi4stream_Stage_tb: expected Valid while stalled");
    if (Out_M2S.Data !== gold[0])
      $fatal(1, "axi4stream_Stage_tb: stalled head %h expected %h", Out_M2S.Data, gold[0]);

    // Drain with intermittent Ready; check Data/Last/Keep/User/ID.
    for (i = 0; i < 3; i++) begin
      while (~Out_M2S.Valid) begin
        @(posedge Clock);
        if ($time > 500_000)
          $fatal(1, "axi4stream_Stage_tb: timeout beat %0d", i);
      end
      if (Out_M2S.Data !== gold[i] || Out_M2S.Last !== (i == 2))
        $fatal(1, "axi4stream_Stage_tb: beat %0d data=%h last=%b",
               i, Out_M2S.Data, Out_M2S.Last);
      if (Out_M2S.Keep !== 1'b1 || Out_M2S.User !== 1'b1 || Out_M2S.ID !== 1'b1)
        $fatal(1, "axi4stream_Stage_tb: sideband lost on beat %0d", i);
      Out_S2M.Ready = 1'b1;
      @(posedge Clock);
      Out_S2M.Ready = 1'b0;
      @(posedge Clock);
    end

    // Second packet through empty pipeline (load stalled, then drain).
    send_beat(8'hA5, 1'b0);
    send_beat(8'h5A, 1'b1);
    In_M2S.Valid = 1'b0;
    repeat (STAGES + 2) @(posedge Clock);

    for (i = 0; i < 2; i++) begin
      while (~Out_M2S.Valid) begin
        @(posedge Clock);
        if ($time > 500_000)
          $fatal(1, "axi4stream_Stage_tb: timeout packet2 beat %0d", i);
      end
      if (i == 0 && (Out_M2S.Data !== 8'hA5 || Out_M2S.Last !== 1'b0))
        $fatal(1, "axi4stream_Stage_tb: packet2 beat0 data=%h last=%b",
               Out_M2S.Data, Out_M2S.Last);
      if (i == 1 && (Out_M2S.Data !== 8'h5A || Out_M2S.Last !== 1'b1))
        $fatal(1, "axi4stream_Stage_tb: packet2 beat1 data=%h last=%b",
               Out_M2S.Data, Out_M2S.Last);
      Out_S2M.Ready = 1'b1;
      @(posedge Clock);
      Out_S2M.Ready = 1'b0;
      @(posedge Clock);
    end

    $display("PASS axi4stream_Stage_tb");
    $finish;
  end

  initial begin
    #100us;
    $fatal(1, "axi4stream_Stage_tb watchdog");
  end
endmodule
