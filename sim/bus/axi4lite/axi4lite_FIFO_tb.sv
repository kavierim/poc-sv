// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-29, Kari Vierimaa, Kempele, Finland.
// Self-checking Verilator testbench for axi4lite_FIFO (payload through + back-pressure).

`timescale 1ns/1ps

module axi4lite_FIFO_tb;
  import poc_axi4_common::*;
  import poc_axi4lite::*;

  logic clk = 1'b0;
  logic reset = 1'b1;

  T_AXI4Lite_Bus_M2S in_m2s;
  T_AXI4Lite_Bus_S2M in_s2m;
  T_AXI4Lite_Bus_M2S out_m2s;
  T_AXI4Lite_Bus_S2M out_s2m;

  logic aw_pend, w_pend, ar_pend;
  logic block_out;

  always #5 clk = ~clk;

  axi4lite_FIFO #(
    .TRANSACTIONS(2),
    .ADDR_W(32),
    .DATA_W(32)
  ) dut (
    .Clock  (clk),
    .Reset  (reset),
    .In_M2S (in_m2s),
    .In_S2M (in_s2m),
    .Out_M2S(out_m2s),
    .Out_S2M(out_s2m)
  );

  // Subordinate with unique RData; optional AW stall for back-pressure.
  always_ff @(posedge clk) begin
    if (reset) begin
      aw_pend  <= 1'b0;
      w_pend   <= 1'b0;
      ar_pend  <= 1'b0;
      out_s2m  <= initialize_axi4lite_bus_s2m(1'b0);
    end else begin
      out_s2m.AWReady <= ~aw_pend & ~block_out;
      out_s2m.WReady  <= ~w_pend;
      out_s2m.ARReady <= ~ar_pend;

      if (out_m2s.AWValid && out_s2m.AWReady)
        aw_pend <= 1'b1;
      if (out_m2s.WValid && out_s2m.WReady)
        w_pend <= 1'b1;

      out_s2m.BValid <= aw_pend & w_pend;
      out_s2m.BResp  <= C_AXI4_RESPONSE_OKAY;
      if (aw_pend && w_pend && out_m2s.BReady) begin
        aw_pend <= 1'b0;
        w_pend  <= 1'b0;
      end

      if (out_m2s.ARValid && out_s2m.ARReady)
        ar_pend <= 1'b1;
      out_s2m.RValid <= ar_pend;
      out_s2m.RResp  <= C_AXI4_RESPONSE_OKAY;
      out_s2m.RData  <= 32'hF00D_CAFE;
      if (ar_pend && out_m2s.RReady)
        ar_pend <= 1'b0;
    end
  end

  task automatic axi_write(input logic [31:0] addr, input logic [31:0] data);
    logic saw;
    saw = 1'b0;
    in_m2s = initialize_axi4lite_bus_m2s(1'b0);
    in_m2s.AWValid = 1'b1;
    in_m2s.WValid  = 1'b1;
    in_m2s.BReady  = 1'b1;
    in_m2s.AWAddr  = addr;
    in_m2s.WData   = data;
    in_m2s.WStrb   = '1;
    fork
      forever begin
        @(posedge clk);
        if (out_m2s.WValid && out_s2m.WReady) begin
          if (out_m2s.WData !== data)
            $fatal(1, "axi4lite_FIFO_tb: Out WData %h expected %h", out_m2s.WData, data);
          if (out_m2s.AWValid && out_s2m.AWReady && out_m2s.AWAddr !== addr)
            $fatal(1, "axi4lite_FIFO_tb: Out AWAddr %h expected %h", out_m2s.AWAddr, addr);
          saw = 1'b1;
        end
      end
    join_none
    while (!(in_s2m.AWReady && in_s2m.WReady)) begin
      @(posedge clk);
      if ($time > 80_000)
        $fatal(1, "axi4lite_FIFO_tb: timeout AW/W ready");
    end
    @(posedge clk);
    in_m2s.AWValid = 1'b0;
    in_m2s.WValid  = 1'b0;
    while (!in_s2m.BValid) begin
      @(posedge clk);
      if ($time > 80_000)
        $fatal(1, "axi4lite_FIFO_tb: timeout BValid");
    end
    if (in_s2m.BResp != C_AXI4_RESPONSE_OKAY)
      $fatal(1, "axi4lite_FIFO_tb: BResp %0d", in_s2m.BResp);
    if (!saw)
      $fatal(1, "axi4lite_FIFO_tb: write never observed on Out");
    @(posedge clk);
    disable fork;
  endtask

  task automatic axi_read(input logic [31:0] addr, input logic [31:0] expect_data);
    in_m2s.ARValid = 1'b1;
    in_m2s.RReady  = 1'b1;
    in_m2s.ARAddr  = addr;
    while (!in_s2m.ARReady) begin
      @(posedge clk);
      if ($time > 80_000)
        $fatal(1, "axi4lite_FIFO_tb: timeout ARReady");
    end
    @(posedge clk);
    in_m2s.ARValid = 1'b0;
    while (!in_s2m.RValid) begin
      @(posedge clk);
      if ($time > 80_000)
        $fatal(1, "axi4lite_FIFO_tb: timeout RValid");
    end
    if (in_s2m.RResp != C_AXI4_RESPONSE_OKAY)
      $fatal(1, "axi4lite_FIFO_tb: RResp %0d", in_s2m.RResp);
    if (in_s2m.RData !== expect_data)
      $fatal(1, "axi4lite_FIFO_tb: RData %h expected %h", in_s2m.RData, expect_data);
    @(posedge clk);
    in_m2s.RReady = 1'b0;
  endtask

  initial begin
    in_m2s   = initialize_axi4lite_bus_m2s(1'b0);
    block_out = 1'b0;

    repeat (4) @(posedge clk);
    reset = 1'b0;
    repeat (2) @(posedge clk);

    axi_write(32'h0000_0100, 32'h11223344);
    axi_read(32'h0000_0200, 32'hF00D_CAFE);

    // Back-pressure: stall Out AW, fill TRANSACTIONS, expect In AWReady drop.
    block_out = 1'b1;
    in_m2s = initialize_axi4lite_bus_m2s(1'b0);
    in_m2s.AWValid = 1'b1;
    in_m2s.AWAddr  = 32'h30;
    in_m2s.WValid  = 1'b0;
    repeat (8) @(posedge clk);
    if (in_s2m.AWReady)
      $fatal(1, "axi4lite_FIFO_tb: expected AWReady low under Out stall");
    block_out = 1'b0;
    in_m2s.AWValid = 1'b0;
    repeat (4) @(posedge clk);

    $display("PASS axi4lite_FIFO_tb");
    $finish;
  end

  initial begin
    #100us;
    $fatal(1, "axi4lite_FIFO_tb watchdog");
  end
endmodule
