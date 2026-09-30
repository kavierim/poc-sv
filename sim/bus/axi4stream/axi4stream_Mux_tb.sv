// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-29, Kari Vierimaa, Kempele, Finland.
// Self-checking Verilator testbench for axi4stream_Mux (payload, multi-beat, back-pressure).

`timescale 1ns/1ps

module axi4stream_Mux_tb;
  import poc_axi4stream::*;

  localparam int DATA_W  = 8;
  localparam int USER_W  = 1;
  localparam int DEST_W  = 1;
  localparam int ID_W    = 1;
  localparam int PORTS   = 2;

  typedef axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::m2s_t m2s_t;
  typedef axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::s2m_t s2m_t;

  logic Clock = 1'b0;
  logic Reset = 1'b1;

  m2s_t In_M2S[PORTS];
  s2m_t In_S2M[PORTS];
  m2s_t Out_M2S;
  s2m_t Out_S2M;

  always #5 Clock = ~Clock;

  axi4stream_Mux #(
    .PORTS     (PORTS),
    .DATA_BITS (DATA_W),
    .USER_BITS (USER_W),
    .DEST_BITS (DEST_W),
    .ID_BITS   (ID_W)
  ) dut (
    .Clock      (Clock),
    .Reset      (Reset),
    .MuxControl ('1),
    .In_M2S     (In_M2S),
    .In_S2M     (In_S2M),
    .Out_M2S    (Out_M2S),
    .Out_S2M    (Out_S2M)
  );

  task automatic expect_out_beat(
    input logic [DATA_W-1:0] data,
    input logic last
  );
    while (1) begin
      @(posedge Clock);
      if ($time > 500_000)
        $fatal(1, "axi4stream_Mux_tb: timeout waiting Out beat");
      if (Out_M2S.Valid && Out_S2M.Ready) begin
        if (Out_M2S.Data !== data)
          $fatal(1, "axi4stream_Mux_tb: Out Data %h expected %h", Out_M2S.Data, data);
        if (Out_M2S.Last !== last)
          $fatal(1, "axi4stream_Mux_tb: Out Last %b expected %b", Out_M2S.Last, last);
        if (Out_M2S.Keep !== '1)
          $fatal(1, "axi4stream_Mux_tb: Out Keep %b expected all-1", Out_M2S.Keep);
        break;
      end
    end
  endtask

  task automatic drive_beat(input int port, input logic [DATA_W-1:0] data, input logic last);
    In_M2S[port].Valid = 1'b1;
    In_M2S[port].Data  = data;
    In_M2S[port].Last  = last;
    In_M2S[port].Keep  = '1;
    In_M2S[port].User  = '0;
    In_M2S[port].Dest  = '0;
    In_M2S[port].ID    = '0;
    @(posedge Clock);
    while (~In_S2M[port].Ready) begin
      @(posedge Clock);
      if ($time > 500_000)
        $fatal(1, "axi4stream_Mux_tb: timeout waiting In_S2M[%0d].Ready", port);
    end
    In_M2S[port].Valid = 1'b0;
    @(posedge Clock);
  endtask

  initial begin
    int p;
    for (p = 0; p < PORTS; p++)
      In_M2S[p] = axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::initialize_m2s(0);
    Out_S2M.Ready = 1'b1;
    Out_S2M.User  = '0;

    repeat (4) @(posedge Clock);
    Reset = 1'b0;

    // Two single-beat packets from alternating ports.
    fork
      begin
        expect_out_beat(8'hA1, 1'b1);
        expect_out_beat(8'hB2, 1'b1);
      end
      begin
        drive_beat(0, 8'hA1, 1'b1);
        drive_beat(1, 8'hB2, 1'b1);
      end
    join

    // Multi-beat packet on port 0 with output back-pressure mid-packet.
    Out_S2M.Ready = 1'b0;
    fork
      begin
        Out_S2M.Ready = 1'b0;
        repeat (3) @(posedge Clock);
        Out_S2M.Ready = 1'b1;
        expect_out_beat(8'h10, 1'b0);
        expect_out_beat(8'h20, 1'b0);
        expect_out_beat(8'h30, 1'b1);
      end
      begin
        drive_beat(0, 8'h10, 1'b0);
        drive_beat(0, 8'h20, 1'b0);
        drive_beat(0, 8'h30, 1'b1);
      end
    join

    $display("axi4stream_Mux_tb: PASS");
    $finish;
  end

  initial begin
    #100us;
    $fatal(1, "axi4stream_Mux_tb watchdog");
  end
endmodule
