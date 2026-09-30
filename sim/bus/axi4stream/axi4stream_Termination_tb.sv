// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-28, Kari Vierimaa, Kempele, Finland.
// Self-checking Verilator smoke test for AXI4-Stream terminations.

`timescale 1ns/1ps

module axi4stream_Termination_tb;
  import poc_axi4stream::*;

  localparam int DATA_W = 8;
  localparam int USER_W = 1;
  localparam int DEST_W = 1;
  localparam int ID_W   = 1;

  typedef axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::m2s_t m2s_t;
  typedef axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::s2m_t s2m_t;

  m2s_t tx0_m2s;
  s2m_t tx0_s2m;
  m2s_t rx0_m2s;
  s2m_t rx0_s2m;
  m2s_t tx1_m2s;
  s2m_t unused_s2m;
  m2s_t unused_m2s;
  s2m_t rx1_s2m;

  axi4stream_Termination_Transmitter #(
    .VALUE(1'b0), .DATA_BITS(DATA_W), .USER_BITS(USER_W), .DEST_BITS(DEST_W), .ID_BITS(ID_W)
  ) tx0 (
    .Out_M2S(tx0_m2s),
    .Out_S2M(tx0_s2m)
  );

  axi4stream_Termination_Receiver #(
    .VALUE(1'b0), .DATA_BITS(DATA_W), .USER_BITS(USER_W), .DEST_BITS(DEST_W), .ID_BITS(ID_W)
  ) rx0 (
    .In_M2S(rx0_m2s),
    .In_S2M(rx0_s2m)
  );

  axi4stream_Termination_Transmitter #(
    .VALUE(1'b1), .DATA_BITS(DATA_W), .USER_BITS(USER_W), .DEST_BITS(DEST_W), .ID_BITS(ID_W)
  ) tx1 (
    .Out_M2S(tx1_m2s),
    .Out_S2M(unused_s2m)
  );

  axi4stream_Termination_Receiver #(
    .VALUE(1'b1), .DATA_BITS(DATA_W), .USER_BITS(USER_W), .DEST_BITS(DEST_W), .ID_BITS(ID_W)
  ) rx1 (
    .In_M2S(unused_m2s),
    .In_S2M(rx1_s2m)
  );

  initial begin
    tx0_s2m    = axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::initialize_s2m(0);
    rx0_m2s    = axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::initialize_m2s(0);
    unused_s2m = axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::initialize_s2m(0);
    unused_m2s = axi4stream_sized#(DATA_W, USER_W, DEST_W, ID_W, 0)::initialize_m2s(0);
    #1;

    if (tx0_m2s.Valid !== 1'b0 || tx0_m2s.Data !== '0 || tx0_m2s.Last !== 1'b0)
      $fatal(1, "transmitter VALUE=0 did not idle the master");
    if (rx0_s2m.Ready !== 1'b0)
      $fatal(1, "receiver VALUE=0 did not deassert Ready");
    if (tx1_m2s.Valid !== 1'b1 || tx1_m2s.Data !== {DATA_W{1'b1}} || tx1_m2s.Last !== 1'b1)
      $fatal(1, "transmitter VALUE=1 did not fill the master");
    if (rx1_s2m.Ready !== 1'b1)
      $fatal(1, "receiver VALUE=1 did not assert Ready");

    $display("axi4stream_Termination_tb: PASS");
    $finish;
  end
endmodule
