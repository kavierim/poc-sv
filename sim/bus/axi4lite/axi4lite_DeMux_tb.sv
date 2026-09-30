// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-29, Kari Vierimaa, Kempele, Finland.
// Self-checking Verilator testbench: routing, RData, overlap → lowest port, DECERR.

`timescale 1ns/1ps

module axi4lite_DeMux_tb;
  import poc_axi4_common::*;
  import poc_axi4lite::*;

  localparam int PORTS = 2;
  // Port 0: 0x1000–0x1FFF; port 1: 0x1400–0x1BFF (overlap 0x1400–0x1BFF → lowest index).
  localparam logic [31:0] BASE_ADDR[PORTS] = '{32'h0000_1000, 32'h0000_1400};
  localparam logic [31:0] BASE_MASK[PORTS] = '{32'h0000_0FFF, 32'h0000_07FF};
  localparam int PIPE_OUT[PORTS] = '{0, 0};
  localparam logic [31:0] PORT_RDATA[PORTS] = '{32'hA11C_E001, 32'hB22D_F002};

  logic clk = 1'b0;
  logic reset = 1'b1;

  T_AXI4Lite_Bus_M2S in_m2s;
  T_AXI4Lite_Bus_S2M in_s2m;
  T_AXI4Lite_Bus_M2S out_m2s[PORTS];
  T_AXI4Lite_Bus_S2M out_s2m[PORTS];

  logic aw_pend[PORTS];
  logic w_pend[PORTS];
  logic ar_pend[PORTS];

  always #5 clk = ~clk;

  axi4lite_DeMux #(
    .NUM_PORTS         (PORTS),
    .BASE_ADDRESS      (BASE_ADDR),
    .BASE_ADDRESS_MASK (BASE_MASK),
    .PIPELINE_OUT      (PIPE_OUT)
  ) dut (
    .Clock   (clk),
    .Reset   (reset),
    .In_M2S  (in_m2s),
    .In_S2M  (in_s2m),
    .Out_M2S (out_m2s),
    .Out_S2M (out_s2m)
  );

  // Per-port subordinate: unique RData; OKAY on mapped hits.
  genvar gi;
  generate
    for (gi = 0; gi < PORTS; gi++) begin : slaves
      always_ff @(posedge clk) begin
        if (reset) begin
          aw_pend[gi] <= 1'b0;
          w_pend[gi]  <= 1'b0;
          ar_pend[gi] <= 1'b0;
          out_s2m[gi] <= initialize_axi4lite_bus_s2m(1'b0);
        end else begin
          out_s2m[gi].AWReady <= ~aw_pend[gi];
          out_s2m[gi].WReady  <= ~w_pend[gi];
          out_s2m[gi].ARReady <= ~ar_pend[gi];

          if (out_m2s[gi].AWValid && out_s2m[gi].AWReady)
            aw_pend[gi] <= 1'b1;
          if (out_m2s[gi].WValid && out_s2m[gi].WReady)
            w_pend[gi] <= 1'b1;

          out_s2m[gi].BValid <= aw_pend[gi] & w_pend[gi];
          out_s2m[gi].BResp  <= C_AXI4_RESPONSE_OKAY;
          if (aw_pend[gi] && w_pend[gi] && out_m2s[gi].BReady) begin
            aw_pend[gi] <= 1'b0;
            w_pend[gi]  <= 1'b0;
          end

          if (out_m2s[gi].ARValid && out_s2m[gi].ARReady)
            ar_pend[gi] <= 1'b1;

          out_s2m[gi].RValid <= ar_pend[gi];
          out_s2m[gi].RResp  <= C_AXI4_RESPONSE_OKAY;
          out_s2m[gi].RData  <= PORT_RDATA[gi];
          if (ar_pend[gi] && out_m2s[gi].RReady)
            ar_pend[gi] <= 1'b0;
        end
      end
    end
  endgenerate

  task automatic axi_write(
    input logic [31:0] addr,
    input logic [31:0] data,
    input int expect_port,
    input bit expect_decerr = 1'b0
  );
    logic saw_wdata;
    saw_wdata = 1'b0;
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
        if (expect_port >= 0 &&
            out_m2s[expect_port].WValid && out_s2m[expect_port].WReady) begin
          if (out_m2s[expect_port].WData !== data)
            $fatal(1, "write WData 0x%h on port%0d expected 0x%h",
                   out_m2s[expect_port].WData, expect_port, data);
          saw_wdata = 1'b1;
        end
      end
    join_none
    while (!(in_s2m.AWReady && in_s2m.WReady)) begin
      @(posedge clk);
      if ($time > 80_000)
        $fatal(1, "timeout AW/W ready @ 0x%h", addr);
    end
    @(posedge clk);
    in_m2s.AWValid = 1'b0;
    in_m2s.WValid  = 1'b0;
    while (!in_s2m.BValid) begin
      @(posedge clk);
      if ($time > 80_000)
        $fatal(1, "timeout BValid @ 0x%h", addr);
    end
    if (expect_decerr) begin
      if (in_s2m.BResp != C_AXI4_RESPONSE_DECODE_ERROR)
        $fatal(1, "write expected DECERR at 0x%h got %0d", addr, in_s2m.BResp);
    end else begin
      if (in_s2m.BResp != C_AXI4_RESPONSE_OKAY)
        $fatal(1, "write BResp at 0x%h", addr);
      if (expect_port >= 0 && !saw_wdata)
        $fatal(1, "write WData never seen on port%0d @ 0x%h", expect_port, addr);
    end
    @(posedge clk);
    in_m2s.BReady = 1'b0;
    disable fork;
  endtask

  task automatic axi_read(
    input logic [31:0] addr,
    input logic [31:0] expect_data,
    input bit expect_decerr = 1'b0
  );
    in_m2s.ARValid = 1'b1;
    in_m2s.RReady  = 1'b1;
    in_m2s.ARAddr  = addr;
    while (!in_s2m.ARReady) begin
      @(posedge clk);
      if ($time > 80_000)
        $fatal(1, "timeout ARReady @ 0x%h", addr);
    end
    @(posedge clk);
    in_m2s.ARValid = 1'b0;
    while (!in_s2m.RValid) begin
      @(posedge clk);
      if ($time > 80_000)
        $fatal(1, "timeout RValid @ 0x%h", addr);
    end
    if (expect_decerr) begin
      if (in_s2m.RResp != C_AXI4_RESPONSE_DECODE_ERROR)
        $fatal(1, "read expected DECERR at 0x%h got %0d", addr, in_s2m.RResp);
    end else begin
      if (in_s2m.RResp != C_AXI4_RESPONSE_OKAY)
        $fatal(1, "read RResp at 0x%h", addr);
      if (in_s2m.RData !== expect_data)
        $fatal(1, "read RData 0x%h expected 0x%h at 0x%h",
               in_s2m.RData, expect_data, addr);
    end
    @(posedge clk);
    in_m2s.RReady = 1'b0;
  endtask

  initial begin
    in_m2s = initialize_axi4lite_bus_m2s(1'b0);

    repeat (4) @(posedge clk);
    reset = 1'b0;
    repeat (2) @(posedge clk);

    // Exclusive port0 window
    axi_write(32'h0000_1004, 32'h55AA55AA, 0);
    axi_read(32'h0000_1008, PORT_RDATA[0]);

    // Port0-only upper window
    axi_write(32'h0000_1C04, 32'h11112222, 0);
    // Overlap 0x1400–0x17FF → lowest index (port 0), not port 1
    axi_write(32'h0000_1404, 32'hDEADBEEF, 0);
    axi_read(32'h0000_1408, PORT_RDATA[0]);

    // Unmapped → DECERR
    axi_write(32'h0000_3000, 32'h0, -1, 1'b1);
    axi_read(32'h0000_3000, 32'h0, 1'b1);

    $display("PASS axi4lite_DeMux_tb");
    $finish;
  end

  initial begin
    #100us;
    $fatal(1, "axi4lite_DeMux_tb watchdog");
  end
endmodule
