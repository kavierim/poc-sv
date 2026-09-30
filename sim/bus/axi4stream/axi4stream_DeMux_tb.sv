// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Self-checking Verilator testbench for axi4stream_DeMux.

`timescale 1ns/1ps

module axi4stream_DeMux_tb;
  import poc_axi4stream::*;

  localparam int DATA_W = 8;
  localparam int USER_W = 1;
  localparam int DEST_W = 1;
  localparam int ID_W   = 1;
  localparam int PORTS  = 2;

  typedef axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::m2s_t m2s_t;
  typedef axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::s2m_t s2m_t;

  logic Clock = 1'b0;
  logic Reset = 1'b1;
  logic [PORTS-1:0] DeMuxControl = 2'b10;

  m2s_t In_M2S;
  s2m_t In_S2M;
  m2s_t Out_M2S[PORTS];
  s2m_t Out_S2M[PORTS];

  always #5 Clock = ~Clock;

  axi4stream_DeMux #(
    .PORTS     (PORTS),
    .DATA_BITS (DATA_W),
    .USER_BITS (USER_W),
    .DEST_BITS (DEST_W),
    .ID_BITS   (ID_W)
  ) dut (
    .Clock        (Clock),
    .Reset        (Reset),
    .DeMuxControl (DeMuxControl),
    .In_M2S       (In_M2S),
    .In_S2M       (In_S2M),
    .Out_M2S      (Out_M2S),
    .Out_S2M      (Out_S2M)
  );

  initial begin
    int p;
    In_M2S = axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::initialize_m2s(0);
    for (p = 0; p < PORTS; p++) begin
      Out_S2M[p].Ready = 1'b1;
      Out_S2M[p].User  = '0;
    end

    repeat (4) @(posedge Clock);
    Reset = 1'b0;

    In_M2S.Valid = 1'b1;
    In_M2S.Data  = 8'h3C;
    In_M2S.Last  = 1'b1;
    In_M2S.Keep  = '1;
    @(posedge Clock);
    while (1) begin
      if ($time > 500_000)
        $fatal(1, "axi4stream_DeMux_tb: timeout waiting handshake");
      if (In_S2M.Ready && Out_M2S[1].Valid) begin
        if (Out_M2S[1].Data !== 8'h3C || Out_M2S[1].Last !== 1'b1)
          $fatal(1, "DeMux port 1 mismatch");
        if (Out_M2S[1].Keep !== '1)
          $fatal(1, "DeMux port 1 Keep expected all-1");
        if (Out_M2S[0].Valid)
          $fatal(1, "DeMux port 0 should stay idle");
        break;
      end
      @(posedge Clock);
    end
    In_M2S.Valid = 1'b0;
    @(posedge Clock);

    $display("axi4stream_DeMux_tb: PASS");
    $finish;
  end

  initial begin
    #100us;
    $fatal(1, "axi4stream_DeMux_tb watchdog");
  end
endmodule
