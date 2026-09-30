// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-29, Kari Vierimaa, Kempele, Finland.
// CDC axi4_FIFO: dual clocks, integrity, fill/Full, back-pressure, two ratios.

`timescale 1ns/1ps

module axi4_FIFO_CDC_tb;
  import poc_axi4_full::*;
  import poc_axi4_common::*;

  localparam int ADDR_W = 32;
  localparam int DATA_W = 32;
  localparam int USER_W = 1;
  localparam int ID_W   = 2;
  localparam int FRAMES = 4;
  localparam int N_BEATS = 6;

  typedef axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::bus_m2s_t m2s_t;
  typedef axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::bus_s2m_t s2m_t;

  logic In_Clock = 0;
  logic Out_Clock = 0;
  logic In_Reset = 1;
  logic Out_Reset = 1;
  int unsigned in_half_ns;
  int unsigned out_half_ns;

  m2s_t In_M2S;
  s2m_t In_S2M;
  m2s_t Out_M2S;
  s2m_t Out_S2M;

  logic aw_pend, w_pend;
  logic block_aw = 1'b0;
  s2m_t Out_S2M_i;
  logic [DATA_W-1:0] seen_wdata[0:N_BEATS-1];
  int unsigned n_seen;

  axi4_FIFO_CDC #(
    .ADDR_W(ADDR_W), .DATA_W(DATA_W), .USER_W(USER_W), .ID_W(ID_W),
    .FRAMES(FRAMES), .FRAME_DEPTH(1)
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

  // Subordinate on Out domain: capture WData, OKAY B/R.
  always_ff @(posedge Out_Clock) begin
    if (Out_Reset) begin
      aw_pend <= 1'b0;
      w_pend  <= 1'b0;
      Out_S2M_i <= axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::initialize_bus_s2m(1'b0);
      n_seen  <= 0;
    end else begin
      Out_S2M_i.AWReady <= ~aw_pend;
      Out_S2M_i.WReady  <= ~w_pend;
      Out_S2M_i.ARReady <= 1'b1;

      if (Out_M2S.AWValid && Out_S2M.AWReady)
        aw_pend <= 1'b1;
      if (Out_M2S.WValid && Out_S2M.WReady) begin
        w_pend <= 1'b1;
        if (n_seen < N_BEATS) begin
          seen_wdata[n_seen] <= Out_M2S.WData;
          n_seen <= n_seen + 1;
        end
      end

      Out_S2M_i.BValid <= aw_pend & w_pend;
      Out_S2M_i.BResp  <= C_AXI4_RESPONSE_OKAY;
      Out_S2M_i.BID    <= Out_M2S.AWID;
      if (aw_pend && w_pend && Out_M2S.BReady) begin
        aw_pend <= 1'b0;
        w_pend  <= 1'b0;
      end

      if (Out_M2S.ARValid && Out_S2M.ARReady) begin
        Out_S2M_i.RValid <= 1'b1;
        Out_S2M_i.RLast  <= 1'b1;
        Out_S2M_i.RResp  <= C_AXI4_RESPONSE_OKAY;
        Out_S2M_i.RData  <= 32'hC0DE_0000 | Out_M2S.ARAddr[15:0];
        Out_S2M_i.RID    <= Out_M2S.ARID;
      end else if (Out_M2S.RReady)
        Out_S2M_i.RValid <= 1'b0;
    end
  end

  task automatic do_write(input logic [ADDR_W-1:0] addr, input logic [DATA_W-1:0] data,
                          input logic [ID_W-1:0] id);
    In_M2S.AWValid = 1'b1;
    In_M2S.AWAddr  = addr;
    In_M2S.AWID    = id;
    In_M2S.AWLen   = 8'd0;
    In_M2S.WValid  = 1'b1;
    In_M2S.WData   = data;
    In_M2S.WLast   = 1'b1;
    In_M2S.WStrb   = '1;
    In_M2S.BReady  = 1'b1;
    while (~(In_S2M.AWReady && In_S2M.WReady)) begin
      @(posedge In_Clock);
      if ($time > 2_000_000) $fatal(1, "axi4_FIFO_CDC_tb: write timeout");
    end
    @(posedge In_Clock);
    In_M2S.AWValid = 1'b0;
    In_M2S.WValid  = 1'b0;
    while (~In_S2M.BValid) begin
      @(posedge In_Clock);
      if ($time > 2_000_000) $fatal(1, "axi4_FIFO_CDC_tb: BValid timeout");
    end
    if (In_S2M.BResp != C_AXI4_RESPONSE_OKAY)
      $fatal(1, "axi4_FIFO_CDC_tb: BResp");
    if (In_S2M.BID !== id)
      $fatal(1, "axi4_FIFO_CDC_tb: BID %h expected %h", In_S2M.BID, id);
    @(posedge In_Clock);
  endtask

  task automatic do_read(input logic [ADDR_W-1:0] addr, input logic [ID_W-1:0] id,
                         input logic [DATA_W-1:0] expect_data);
    In_M2S.ARValid = 1'b1;
    In_M2S.ARAddr  = addr;
    In_M2S.ARID    = id;
    In_M2S.ARLen   = 8'd0;
    In_M2S.RReady  = 1'b1;
    while (~In_S2M.ARReady) begin
      @(posedge In_Clock);
      if ($time > 2_000_000) $fatal(1, "axi4_FIFO_CDC_tb: ARReady timeout");
    end
    @(posedge In_Clock);
    In_M2S.ARValid = 1'b0;
    while (~(In_S2M.RValid && In_S2M.RLast)) begin
      @(posedge In_Clock);
      if ($time > 2_000_000) $fatal(1, "axi4_FIFO_CDC_tb: RValid timeout");
    end
    if (In_S2M.RData !== expect_data)
      $fatal(1, "axi4_FIFO_CDC_tb: RData %h expected %h", In_S2M.RData, expect_data);
    if (In_S2M.RID !== id)
      $fatal(1, "axi4_FIFO_CDC_tb: RID");
    @(posedge In_Clock);
    In_M2S.RReady = 1'b0;
  endtask

  task automatic run_ratio(input int unsigned in_h, input int unsigned out_h);
    int unsigned i;
    in_half_ns  = in_h;
    out_half_ns = out_h;
    In_Reset = 1'b1;
    Out_Reset = 1'b1;
    In_M2S = axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::initialize_bus_m2s(1'b0);
    n_seen = 0;
    repeat (8) @(posedge In_Clock);
    In_Reset = 1'b0;
    Out_Reset = 1'b0;
    repeat (4) @(posedge In_Clock);

    // Ordered multi-beat writes across domains
    for (i = 0; i < N_BEATS; i++)
      do_write(32'h1000 + (i << 2), 32'hA000_0000 + i, 2'(i[1:0]));

    // Wait for out domain to observe all W beats (no loss / no reorder)
    while (n_seen < N_BEATS) begin
      @(posedge Out_Clock);
      if ($time > 3_000_000)
        $fatal(1, "axi4_FIFO_CDC_tb: lost writes n_seen=%0d", n_seen);
    end
    for (i = 0; i < N_BEATS; i++)
      if (seen_wdata[i] !== (32'hA000_0000 + i))
        $fatal(1, "axi4_FIFO_CDC_tb: wdata[%0d]=%h", i, seen_wdata[i]);

    // Read path integrity
    do_read(32'h0042, 2'b01, 32'hC0DE_0042);

    // Back-pressure smoke: hold Out AWReady low while driving AWValid; Ready must
    // eventually drop (or stay low). Do not require a hard Full count — depth/gray
    // encoding is covered by fifo_ic_got_tb.
    In_M2S.AWValid = 1'b1;
    In_M2S.AWAddr  = 32'h2000;
    In_M2S.AWID    = 2'b00;
    In_M2S.AWLen   = 8'd0;
    In_M2S.WValid  = 1'b0;
    block_aw = 1'b1;
    begin
      logic saw_block;
      saw_block = 1'b0;
      for (i = 0; i < FRAMES * 4 + 16; i++) begin
        @(posedge In_Clock);
        if (~In_S2M.AWReady)
          saw_block = 1'b1;
      end
      if (!saw_block)
        $fatal(1, "axi4_FIFO_CDC_tb: AWReady never dropped under Out stall");
    end
    block_aw = 1'b0;
    In_M2S.AWValid = 1'b0;
    repeat (8) @(posedge In_Clock);
  endtask

  initial begin
    // Ratio 1: fast write / slow read (4ns vs 7ns half-periods)
    run_ratio(4, 7);
    // Ratio 2: slow write / fast read
    run_ratio(7, 4);

    $display("PASS axi4_FIFO_CDC_tb");
    $finish;
  end

  initial begin
    #500us;
    $fatal(1, "axi4_FIFO_CDC_tb watchdog");
  end
endmodule
