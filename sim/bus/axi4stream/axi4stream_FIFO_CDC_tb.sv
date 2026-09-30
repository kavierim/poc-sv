// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Self-checking Verilator testbench for axi4stream_FIFO_CDC.

`timescale 1ns/1ps

module axi4stream_FIFO_CDC_tb;
  import poc_axi4stream::*;

  localparam int DATA_W = 8;
  localparam int USER_W = 1;
  localparam int DEST_W = 1;
  localparam int ID_W   = 1;

  typedef axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::m2s_t m2s_t;
  typedef axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::s2m_t s2m_t;

  logic In_Clock  = 1'b0;
  logic Out_Clock = 1'b0;
  logic In_Reset  = 1'b1;
  logic Out_Reset = 1'b1;

  m2s_t In_M2S;
  s2m_t In_S2M;
  m2s_t Out_M2S;
  s2m_t Out_S2M;

  always #4 In_Clock  = ~In_Clock;
  always #6 Out_Clock = ~Out_Clock;

  axi4stream_FIFO_CDC #(
    .FRAMES          (2),
    .MAX_PACKET_DEPTH(8),
    .USER_IS_DYNAMIC (1'b0),
    .NO_META_FIFO    (1'b1),
    .DATA_BITS       (DATA_W),
    .USER_BITS       (USER_W),
    .DEST_BITS       (DEST_W),
    .ID_BITS         (ID_W)
  ) dut (
    .In_Clock  (In_Clock),
    .In_Reset  (In_Reset),
    .In_M2S    (In_M2S),
    .In_S2M    (In_S2M),
    .Out_Clock (Out_Clock),
    .Out_Reset (Out_Reset),
    .Out_M2S   (Out_M2S),
    .Out_S2M   (Out_S2M)
  );

  initial begin
    In_M2S = axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::initialize_m2s(0);
    Out_S2M.Ready = 1'b0;
    Out_S2M.User  = '0;

    repeat (8) @(posedge In_Clock);
    In_Reset  = 1'b0;
    Out_Reset = 1'b0;

    In_M2S.Valid = 1'b1;
    In_M2S.Data  = 8'h5A;
    In_M2S.Last  = 1'b1;
    In_M2S.Keep  = '1;
    In_M2S.User  = '0;
    In_M2S.Dest  = '0;
    In_M2S.ID    = '0;
    @(posedge In_Clock);
    while (~In_S2M.Ready) begin
      @(posedge In_Clock);
      if ($time > 500_000)
        $fatal(1, "axi4stream_FIFO_CDC_tb: timeout on write side");
    end
    In_M2S.Valid = 1'b0;

    repeat (64) @(posedge Out_Clock);
    Out_S2M.Ready = 1'b1;

    while (~Out_M2S.Valid) begin
      @(posedge Out_Clock);
      if ($time > 2_000_000)
        $fatal(1, "axi4stream_FIFO_CDC_tb: timeout on read side");
    end
    if (Out_M2S.Data !== 8'h5A || Out_M2S.Last !== 1'b1)
      $fatal(1, "CDC FIFO output mismatch");

    $display("axi4stream_FIFO_CDC_tb: PASS");
    $finish;
  end
endmodule
