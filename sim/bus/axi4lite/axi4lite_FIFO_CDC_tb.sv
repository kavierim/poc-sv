// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-29, Kari Vierimaa, Kempele, Finland.
// CDC axi4lite_FIFO: dual clocks, W/R integrity, Full under stall, two ratios.

`timescale 1ns/1ps

module axi4lite_FIFO_CDC_tb;
  import poc_axi4_common::*;
  import poc_axi4lite::*;

  localparam int N = 5;
  localparam int TRANSACTIONS = 4;

  logic In_Clock = 0;
  logic Out_Clock = 0;
  logic In_Reset = 1;
  logic Out_Reset = 1;
  int unsigned in_half_ns;
  int unsigned out_half_ns;

  T_AXI4Lite_Bus_M2S In_M2S;
  T_AXI4Lite_Bus_S2M In_S2M;
  T_AXI4Lite_Bus_M2S Out_M2S;
  T_AXI4Lite_Bus_S2M Out_S2M;

  logic aw_pend, w_pend, ar_pend;
  logic block_aw = 1'b0;
  T_AXI4Lite_Bus_S2M Out_S2M_i;
  logic [31:0] seen_w[0:N-1];
  int unsigned n_seen;

  axi4lite_FIFO_CDC #(
    .TRANSACTIONS(TRANSACTIONS),
    .ADDR_W(32), .DATA_W(32)
  ) dut (
    .In_Clock(In_Clock), .In_Reset(In_Reset),
    .Out_Clock(Out_Clock), .Out_Reset(Out_Reset),
    .In_M2S(In_M2S), .In_S2M(In_S2M),
    .Out_M2S(Out_M2S), .Out_S2M(Out_S2M)
  );

  always_comb begin
    Out_S2M = Out_S2M_i;
    if (block_aw)
      Out_S2M.AWReady = 1'b0;
  end

  always #(in_half_ns)  In_Clock  = ~In_Clock;
  always #(out_half_ns) Out_Clock = ~Out_Clock;

  always_ff @(posedge Out_Clock) begin
    if (Out_Reset) begin
      aw_pend <= 1'b0;
      w_pend  <= 1'b0;
      ar_pend <= 1'b0;
      Out_S2M_i <= initialize_axi4lite_bus_s2m(1'b0);
      n_seen  <= 0;
    end else begin
      Out_S2M_i.AWReady <= ~aw_pend;
      Out_S2M_i.WReady  <= ~w_pend;
      Out_S2M_i.ARReady <= ~ar_pend;

      if (Out_M2S.AWValid && Out_S2M.AWReady)
        aw_pend <= 1'b1;
      if (Out_M2S.WValid && Out_S2M.WReady) begin
        w_pend <= 1'b1;
        if (n_seen < N) begin
          seen_w[n_seen] <= Out_M2S.WData;
          n_seen <= n_seen + 1;
        end
      end
      Out_S2M_i.BValid <= aw_pend & w_pend;
      Out_S2M_i.BResp  <= C_AXI4_RESPONSE_OKAY;
      if (aw_pend && w_pend && Out_M2S.BReady) begin
        aw_pend <= 1'b0;
        w_pend  <= 1'b0;
      end

      if (Out_M2S.ARValid && Out_S2M.ARReady)
        ar_pend <= 1'b1;
      Out_S2M_i.RValid <= ar_pend;
      Out_S2M_i.RResp  <= C_AXI4_RESPONSE_OKAY;
      Out_S2M_i.RData  <= 32'hFACE_0000 | Out_M2S.ARAddr[15:0];
      if (ar_pend && Out_M2S.RReady)
        ar_pend <= 1'b0;
    end
  end

  task automatic do_write(input logic [31:0] addr, input logic [31:0] data);
    In_M2S = initialize_axi4lite_bus_m2s(1'b0);
    In_M2S.AWValid = 1'b1;
    In_M2S.WValid  = 1'b1;
    In_M2S.BReady  = 1'b1;
    In_M2S.AWAddr  = addr;
    In_M2S.WData   = data;
    In_M2S.WStrb   = '1;
    while (~(In_S2M.AWReady && In_S2M.WReady)) begin
      @(posedge In_Clock);
      if ($time > 2_000_000) $fatal(1, "axi4lite_FIFO_CDC_tb: write ready timeout");
    end
    @(posedge In_Clock);
    In_M2S.AWValid = 1'b0;
    In_M2S.WValid  = 1'b0;
    while (~In_S2M.BValid) begin
      @(posedge In_Clock);
      if ($time > 2_000_000) $fatal(1, "axi4lite_FIFO_CDC_tb: BValid timeout");
    end
    if (In_S2M.BResp != C_AXI4_RESPONSE_OKAY)
      $fatal(1, "axi4lite_FIFO_CDC_tb: BResp");
    @(posedge In_Clock);
  endtask

  task automatic do_read(input logic [31:0] addr, input logic [31:0] expect_data);
    In_M2S.ARValid = 1'b1;
    In_M2S.RReady  = 1'b1;
    In_M2S.ARAddr  = addr;
    while (~In_S2M.ARReady) begin
      @(posedge In_Clock);
      if ($time > 2_000_000) $fatal(1, "axi4lite_FIFO_CDC_tb: ARReady timeout");
    end
    @(posedge In_Clock);
    In_M2S.ARValid = 1'b0;
    while (~In_S2M.RValid) begin
      @(posedge In_Clock);
      if ($time > 2_000_000) $fatal(1, "axi4lite_FIFO_CDC_tb: RValid timeout");
    end
    if (In_S2M.RData !== expect_data)
      $fatal(1, "axi4lite_FIFO_CDC_tb: RData %h expected %h", In_S2M.RData, expect_data);
    @(posedge In_Clock);
    In_M2S.RReady = 1'b0;
  endtask

  task automatic run_ratio(input int unsigned in_h, input int unsigned out_h);
    int unsigned i;
    in_half_ns  = in_h;
    out_half_ns = out_h;
    In_Reset = 1'b1;
    Out_Reset = 1'b1;
    In_M2S = initialize_axi4lite_bus_m2s(1'b0);
    n_seen = 0;
    repeat (8) @(posedge In_Clock);
    In_Reset = 1'b0;
    Out_Reset = 1'b0;
    repeat (4) @(posedge In_Clock);

    for (i = 0; i < N; i++)
      do_write(32'h10 + (i << 2), 32'hB100_0000 + i);

    while (n_seen < N) begin
      @(posedge Out_Clock);
      if ($time > 3_000_000)
        $fatal(1, "axi4lite_FIFO_CDC_tb: lost writes n_seen=%0d", n_seen);
    end
    for (i = 0; i < N; i++)
      if (seen_w[i] !== (32'hB100_0000 + i))
        $fatal(1, "axi4lite_FIFO_CDC_tb: w[%0d]=%h", i, seen_w[i]);

    do_read(32'h55, 32'hFACE_0055);

    block_aw = 1'b1;
    In_M2S = initialize_axi4lite_bus_m2s(1'b0);
    In_M2S.AWValid = 1'b1;
    In_M2S.AWAddr  = 32'h80;
    begin
      logic saw_block;
      int unsigned i;
      saw_block = 1'b0;
      for (i = 0; i < TRANSACTIONS * 4 + 16; i++) begin
        @(posedge In_Clock);
        if (~In_S2M.AWReady)
          saw_block = 1'b1;
      end
      if (!saw_block)
        $fatal(1, "axi4lite_FIFO_CDC_tb: AWReady never dropped under Out stall");
    end
    block_aw = 1'b0;
    In_M2S.AWValid = 1'b0;
    repeat (8) @(posedge In_Clock);
  endtask

  initial begin
    run_ratio(5, 9);
    run_ratio(9, 5);
    $display("PASS axi4lite_FIFO_CDC_tb");
    $finish;
  end

  initial begin
    #500us;
    $fatal(1, "axi4lite_FIFO_CDC_tb watchdog");
  end
endmodule
