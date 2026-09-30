// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Self-checking Verilator smoke test for axi4stream_FIFO_TempGot.

`timescale 1ns/1ps

module axi4stream_FIFO_TempGot_tb;
  import poc_axi4stream::*;

  localparam int DATA_W = 8;
  localparam int USER_W = 1;
  localparam int DEST_W = 1;
  localparam int ID_W   = 1;

  typedef axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::m2s_t m2s_t;
  typedef axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::s2m_t s2m_t;

  logic Clock = 1'b0;
  logic Reset = 1'b1;
  logic Out_Commit   = 1'b0;
  logic Out_Rollback = 1'b0;

  m2s_t In_m2s;
  s2m_t In_s2m;
  m2s_t Out_m2s;
  s2m_t Out_s2m;

  always #5 Clock = ~Clock;

  axi4stream_FIFO_TempGot #(
    .FRAMES            (2),
    .MAX_PACKET_DEPTH  (2),
    .METADATA_IS_DYNAMIC(1'b0),
    .DATA_BITS         (DATA_W),
    .USER_BITS         (USER_W),
    .DEST_BITS         (DEST_W),
    .ID_BITS           (ID_W)
  ) dut (
    .Clock        (Clock),
    .Reset        (Reset),
    .In_m2s       (In_m2s),
    .In_s2m       (In_s2m),
    .Out_m2s      (Out_m2s),
    .Out_s2m      (Out_s2m),
    .Out_Commit   (Out_Commit),
    .Out_Rollback (Out_Rollback)
  );

  task automatic send_beat(input logic [DATA_W-1:0] data, input logic last);
    In_m2s.Valid = 1'b1;
    In_m2s.Data  = data;
    In_m2s.Last  = last;
    In_m2s.Keep  = '1;
    In_m2s.User  = '0;
    In_m2s.Dest  = '0;
    In_m2s.ID    = '0;
    @(posedge Clock);
    while (~In_s2m.Ready) @(posedge Clock);
    if (~last) begin
      In_m2s.Valid = 1'b0;
      @(posedge Clock);
    end
  endtask

  initial begin
    logic [DATA_W-1:0] gold[0:1];
    int i;

    In_m2s  = axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::initialize_m2s(0);
    Out_s2m = axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::initialize_s2m(0);
    gold[0] = 8'h10;
    gold[1] = 8'h20;

    repeat (4) @(posedge Clock);
    Reset = 1'b0;

    send_beat(gold[0], 1'b0);
    send_beat(gold[1], 1'b1);
    In_m2s.Valid = 1'b0;
    repeat (4) @(posedge Clock);

    for (i = 0; i < 2; i++) begin
      while (~Out_m2s.Valid) @(posedge Clock);
      if (Out_m2s.Data !== gold[i] || Out_m2s.Last !== (i == 1))
        $fatal(1, "TempGot beat %0d mismatch", i);
      Out_s2m.Ready = 1'b1;
      @(posedge Clock);
      Out_s2m.Ready = 1'b0;
      @(posedge Clock);
    end

    Out_Commit = 1'b1;
    @(posedge Clock);
    Out_Commit = 1'b0;

    $display("axi4stream_FIFO_TempGot_tb: PASS");
    $finish;
  end
endmodule
