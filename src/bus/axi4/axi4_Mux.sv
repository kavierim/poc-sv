// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

import poc_axi4_full::*;

// verilator lint_off MULTITOP
module axi4_Mux #(
  parameter int PORTS              = 2,
  parameter int ADDR_W             = 32,
  parameter int DATA_W             = 32,
  parameter int USER_W             = 1,
  parameter int ID_W               = 1,
  parameter int PIPELINE_OUT       = 0,
  parameter int NUM_OUTSTANDING_READS  = 0,
  parameter int NUM_OUTSTANDING_WRITES = 0,
  parameter int PIPELINE_IN[PORTS] = '{default: 0},
  parameter type m2s_t = axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::bus_m2s_t,
  parameter type s2m_t = axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::bus_s2m_t
) (
  input  logic Clock,
  input  logic Reset,

  input  m2s_t In_M2S[PORTS],
  output s2m_t In_S2M[PORTS],

  output m2s_t Out_M2S,
  input  s2m_t Out_S2M
);
  import poc_axi4_full::*;
  import poc_axi4_common::*;
  import poc_vectors::*;
  import poc_utils::*;
  import poc_axi4stream::*;

  localparam int PORT_BITS    = log2ceilnz(PORTS);
  localparam int IN_AW_ID_BITS  = downto_width(ID_W);
  localparam int OUT_AW_ID_BITS = downto_width(ID_W);
  localparam int IN_AR_ID_BITS  = IN_AW_ID_BITS;
  localparam int OUT_AR_ID_BITS = OUT_AW_ID_BITS;

  m2s_t In_M2S_g[PORTS];
  s2m_t In_S2M_g[PORTS];
  m2s_t In_M2S_write[PORTS];
  s2m_t In_S2M_write[PORTS];
  m2s_t In_M2S_read[PORTS];
  s2m_t In_S2M_read[PORTS];

  m2s_t Out_M2S_g;
  s2m_t Out_S2M_g;
  m2s_t Out_M2S_write;
  s2m_t Out_S2M_write;
  m2s_t Out_M2S_read;
  s2m_t Out_S2M_read;

  // Input FIFO glue: unpacked PIPELINE_IN[gi] is not a generate constant in Verilator 5.
  // PIPELINE_IN_MASK: bit i set when PIPELINE_IN[i] > 0 (matches VHDL glue_in_gen).
  // S2M bypass is only the else branch, so a live input FIFO is the sole driver of In_S2M.
  function static int pipeline_in_mask();
    int m = 0;
    for (int i = 0; i < PORTS; i++)
      if (PIPELINE_IN[i] > 0)
        m |= (1 << i);
    return m;
  endfunction

  localparam int PIPELINE_IN_MASK = pipeline_in_mask();
  for (genvar gi = 0; gi < PORTS; gi++) begin : glue_in_loop
    if ((PIPELINE_IN_MASK >> gi) & 1) begin : glue_in
      axi4_FIFO #(
        .ADDR_W(ADDR_W), .DATA_W(DATA_W), .USER_W(USER_W), .ID_W(ID_W),
        .FRAMES(PIPELINE_IN[gi] - 1)
      ) Glue_in (
        .Clock(Clock), .Reset(Reset),
        .In_M2S(In_M2S[gi]), .In_S2M(In_S2M[gi]),
        .Out_M2S(In_M2S_g[gi]), .Out_S2M(In_S2M_g[gi])
      );
    end else begin : glue_in_bypass
      assign In_S2M[gi] = In_S2M_g[gi];
    end
  end

  if (PIPELINE_OUT > 0) begin : glue_out
    axi4_FIFO #(
      .ADDR_W(ADDR_W), .DATA_W(DATA_W), .USER_W(USER_W), .ID_W(ID_W),
      .FRAMES(PIPELINE_OUT - 1)
    ) Glue_out (
      .Clock(Clock), .Reset(Reset),
      .In_M2S(Out_M2S_g), .In_S2M(Out_S2M_g),
      .Out_M2S(Out_M2S), .Out_S2M(Out_S2M)
    );
  end else begin : glue_out_bypass
    assign Out_M2S   = Out_M2S_g;
    assign Out_S2M_g = Out_S2M;
  end

  assign Out_S2M_write.AWReady = Out_S2M_g.AWReady;
  assign Out_S2M_write.WReady  = Out_S2M_g.WReady;
  assign Out_S2M_write.BValid  = Out_S2M_g.BValid;
  assign Out_S2M_write.BResp   = Out_S2M_g.BResp;
  assign Out_S2M_write.BID     = Out_S2M_g.BID;
  assign Out_S2M_write.BUser   = Out_S2M_g.BUser;
  assign Out_S2M_read.ARReady  = Out_S2M_g.ARReady;
  assign Out_S2M_read.RValid   = Out_S2M_g.RValid;
  assign Out_S2M_read.RData    = Out_S2M_g.RData;
  assign Out_S2M_read.RResp    = Out_S2M_g.RResp;
  assign Out_S2M_read.RID      = Out_S2M_g.RID;
  assign Out_S2M_read.RLast    = Out_S2M_g.RLast;
  assign Out_S2M_read.RUser    = Out_S2M_g.RUser;

  // --- Write merge ---
  typedef enum logic [1:0] { ST_Idle, ST_Dataflow, ST_DataOnly, ST_AddressOnly } wstate_t;
  wstate_t wState;
  wstate_t wNext;

  localparam int WR_NUM_IDX = (NUM_OUTSTANDING_WRITES == 0) ? (1 << OUT_AW_ID_BITS) : NUM_OUTSTANDING_WRITES;

  logic Put;
  logic Full;
  logic [PORT_BITS + IN_AW_ID_BITS-1:0] WrDataIn;
  logic [downto_width(log2ceilnz(WR_NUM_IDX))-1:0] WrIndexOut;
  logic Got;
  logic Valid;
  logic [PORT_BITS + IN_AW_ID_BITS-1:0] WrDataOut;

  logic Arbitrate;
  logic [PORTS-1:0] RequestVector;
  logic Arbitrated;
  logic [PORTS-1:0] GrantVector;
  logic [downto_width(log2ceilnz(PORTS))-1:0] GrantIndex;

  logic RequestWithSelf;
  logic RequestWithoutSelf;

  /* verilator lint_off ALWCOMBORDER */
  always_comb begin
    int writeResponseIndex;
    int readResponseIndex;
    int i;

    for (i = 0; i < PORTS; i++)
      if (!((PIPELINE_IN_MASK >> i) & 1))
        In_M2S_g[i] = In_M2S[i];

    for (i = 0; i < PORTS; i++)
      RequestVector[i] = In_M2S_g[i].AWValid & In_M2S_g[i].WValid;
    RequestWithSelf    = |RequestVector;
    RequestWithoutSelf = |(RequestVector & ~GrantVector);

    wNext = wState;
    for (int i = 0; i < PORTS; i++)
      In_S2M_write[i] = axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::initialize_bus_s2m(1'b0);
    Out_M2S_write = axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::initialize_bus_m2s(1'b0);
    Arbitrate = 1'b0;
    Put       = 1'b0;
    WrDataIn  = '0;
    Got       = 1'b0;

    case (wState)
      ST_Idle: begin
        if (RequestWithSelf & ~Full) begin
          Arbitrate = 1'b1;
          wNext     = ST_Dataflow;
        end
      end
      ST_Dataflow: begin
        Out_M2S_write = axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::id_resize_m2s(
            In_M2S_g[int'(GrantIndex)], OUT_AW_ID_BITS, OUT_AR_ID_BITS);
        In_S2M_write[int'(GrantIndex)] = axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::id_resize_s2m(
            Out_S2M_write, IN_AW_ID_BITS, IN_AR_ID_BITS);
        WrDataIn[IN_AW_ID_BITS-1:0] = In_M2S_g[int'(GrantIndex)].AWID;
        WrDataIn[PORT_BITS+IN_AW_ID_BITS-1:IN_AW_ID_BITS] = GrantIndex;
        if (Out_S2M_write.AWReady & In_M2S_g[int'(GrantIndex)].WValid &
            In_M2S_g[int'(GrantIndex)].WLast & Out_S2M_write.WReady) begin
          Put   = 1'b1;
          wNext = ST_Idle;
        end else if (Out_S2M_write.AWReady) begin
          Put   = 1'b1;
          wNext = ST_DataOnly;
        end else if (In_M2S_g[int'(GrantIndex)].WValid & In_M2S_g[int'(GrantIndex)].WLast &
                     Out_S2M_write.WReady) begin
          wNext = ST_AddressOnly;
        end
      end
      ST_DataOnly: begin
        Out_M2S_write = axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::id_resize_m2s(
            In_M2S_g[int'(GrantIndex)], OUT_AW_ID_BITS, OUT_AR_ID_BITS);
        Out_M2S_write.AWValid = 1'b0;
        In_S2M_write[int'(GrantIndex)] = axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::id_resize_s2m(
            Out_S2M_write, IN_AW_ID_BITS, IN_AR_ID_BITS);
        In_S2M_write[int'(GrantIndex)].AWReady = 1'b0;
        if (In_M2S_g[int'(GrantIndex)].WValid & In_M2S_g[int'(GrantIndex)].WLast &
            Out_S2M_write.WReady) begin
          if (RequestWithoutSelf & ~Full)
            Arbitrate = 1'b1;
          wNext = RequestWithoutSelf & ~Full ? ST_Dataflow : ST_Idle;
        end
      end
      ST_AddressOnly: begin
        Out_M2S_write = axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::id_resize_m2s(
            In_M2S_g[int'(GrantIndex)], OUT_AW_ID_BITS, OUT_AR_ID_BITS);
        Out_M2S_write.WValid = 1'b0;
        In_S2M_write[int'(GrantIndex)] = axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::id_resize_s2m(
            Out_S2M_write, IN_AW_ID_BITS, IN_AR_ID_BITS);
        In_S2M_write[int'(GrantIndex)].WReady = 1'b0;
        WrDataIn[IN_AW_ID_BITS-1:0] = In_M2S_g[int'(GrantIndex)].AWID;
        WrDataIn[PORT_BITS+IN_AW_ID_BITS-1:IN_AW_ID_BITS] = GrantIndex;
        if (Out_S2M_write.AWReady) begin
          Put   = 1'b1;
          wNext = ST_Idle;
        end
      end
      default: wNext = ST_Idle;
    endcase

    Out_M2S_write.AWID = logic'(unsigned'(WrIndexOut));
    writeResponseIndex = int'(unsigned'(WrDataOut[PORT_BITS+IN_AW_ID_BITS-1:IN_AW_ID_BITS]));
    for (int i = 0; i < PORTS; i++) begin
      In_S2M_write[i].BID    = WrDataOut[IN_AW_ID_BITS-1:0];
      In_S2M_write[i].BResp  = Out_S2M_g.BResp;
      In_S2M_write[i].BUser  = Out_S2M_g.BUser;
      In_S2M_write[i].BValid = 1'b0;
    end
    Out_M2S_write.BReady = 1'b0;
    if (writeResponseIndex < PORTS) begin
      In_S2M_write[writeResponseIndex].BValid = Out_S2M_g.BValid & Valid;
      Out_M2S_write.BReady                    = In_M2S_g[writeResponseIndex].BReady;
      Got = In_M2S_g[writeResponseIndex].BReady & Out_S2M_g.BValid;
    end

    for (i = 0; i < PORTS; i++)
      Mux_In_M2S[i].Valid = In_M2S_g[i].ARValid & ~RdFull;

    RdPut    = 1'b0;
    RdDataIn = '0;
    for (i = 0; i < PORTS; i++) begin
      if (Mux_In_M2S[i].Valid & Mux_In_S2M[i].Ready & ~RdFull) begin
        RdDataIn[IN_AR_ID_BITS-1:0] = In_M2S_g[i].ARID;
        RdDataIn[PORT_BITS+IN_AR_ID_BITS-1:IN_AR_ID_BITS] = logic'(unsigned'(i));
        RdPut = 1'b1;
      end
    end

    Out_M2S_read.ARValid = Mux_Out_M2S.Valid;
    Out_M2S_read.ARAddr  = Mux_Out_M2S.Data[0+:ADDR_W];
    Out_M2S_read.ARLen   = Mux_Out_M2S.Data[FWD_AR_LEN_LO+:8];
    Out_M2S_read.ARSize  = Mux_Out_M2S.Data[FWD_AR_SIZE_LO+:3];
    Out_M2S_read.ARBurst = Mux_Out_M2S.Data[FWD_AR_BURST_LO+:2];
    Out_M2S_read.ARID    = Mux_Out_M2S.Data[FWD_AR_ID_LO+:OUT_AR_ID_BITS];
    Out_M2S_read.ARUser  = Mux_Out_M2S.Data[FWD_AR_USER_LO+:USER_W];
    Out_M2S_read.ARCache = Mux_Out_M2S.Data[FWD_AR_CACHE_LO+:4];
    Out_M2S_read.ARProt  = Mux_Out_M2S.Data[FWD_AR_PROT_LO+:3];
    Out_M2S_read.ARLock  = Mux_Out_M2S.Data[FWD_AR_LOCK_LO+:1];
    Out_M2S_read.ARQOS   = Mux_Out_M2S.Data[FWD_AR_QOS_LO+:4];
    Out_M2S_read.ARRegion= Mux_Out_M2S.Data[FWD_AR_REGION_LO+:4];

    readResponseIndex = int'(unsigned'(RdDataOut[PORT_BITS+IN_AR_ID_BITS-1:IN_AR_ID_BITS]));
    if (readResponseIndex < PORTS) begin
      Out_M2S_read.RReady = In_M2S_g[readResponseIndex].RReady & RdValid;
      RdGot = In_M2S_g[readResponseIndex].RReady & RdValid & Out_S2M_g.RValid & Out_S2M_g.RLast;
    end else begin
      Out_M2S_read.RReady = 1'b0;
      RdGot               = 1'b0;
    end

  end
  /* verilator lint_on ALWCOMBORDER */

  assign Out_M2S_g.AWID     = Out_M2S_write.AWID;
  assign Out_M2S_g.AWAddr   = Out_M2S_write.AWAddr;
  assign Out_M2S_g.AWLen    = Out_M2S_write.AWLen;
  assign Out_M2S_g.AWSize   = Out_M2S_write.AWSize;
  assign Out_M2S_g.AWBurst  = Out_M2S_write.AWBurst;
  assign Out_M2S_g.AWLock   = Out_M2S_write.AWLock;
  assign Out_M2S_g.AWQOS    = Out_M2S_write.AWQOS;
  assign Out_M2S_g.AWRegion = Out_M2S_write.AWRegion;
  assign Out_M2S_g.AWUser   = Out_M2S_write.AWUser;
  assign Out_M2S_g.AWValid  = Out_M2S_write.AWValid;
  assign Out_M2S_g.AWCache  = Out_M2S_write.AWCache;
  assign Out_M2S_g.AWProt   = Out_M2S_write.AWProt;
  assign Out_M2S_g.WValid   = Out_M2S_write.WValid;
  assign Out_M2S_g.WLast    = Out_M2S_write.WLast;
  assign Out_M2S_g.WUser    = Out_M2S_write.WUser;
  assign Out_M2S_g.WData    = Out_M2S_write.WData;
  assign Out_M2S_g.WStrb    = Out_M2S_write.WStrb;
  assign Out_M2S_g.BReady   = Out_M2S_write.BReady;
  assign Out_M2S_g.ARValid  = Out_M2S_read.ARValid;
  assign Out_M2S_g.ARAddr   = Out_M2S_read.ARAddr;
  assign Out_M2S_g.ARCache  = Out_M2S_read.ARCache;
  assign Out_M2S_g.ARProt   = Out_M2S_read.ARProt;
  assign Out_M2S_g.ARID     = Out_M2S_read.ARID;
  assign Out_M2S_g.ARLen    = Out_M2S_read.ARLen;
  assign Out_M2S_g.ARSize   = Out_M2S_read.ARSize;
  assign Out_M2S_g.ARBurst  = Out_M2S_read.ARBurst;
  assign Out_M2S_g.ARLock   = Out_M2S_read.ARLock;
  assign Out_M2S_g.ARQOS    = Out_M2S_read.ARQOS;
  assign Out_M2S_g.ARRegion = Out_M2S_read.ARRegion;
  assign Out_M2S_g.ARUser   = Out_M2S_read.ARUser;
  assign Out_M2S_g.RReady   = Out_M2S_read.RReady;

  always_ff @(posedge Clock) begin
    if (Reset)
      wState <= ST_Idle;
    else
      wState <= wNext;
  end

  dstruct_OutOfOrderBuffer #(
    .DATA_BITS(PORT_BITS + IN_AW_ID_BITS),
    .NUM_INDEX(WR_NUM_IDX)
  ) Write_idx (
    .Clock(Clock), .Reset(Reset),
    .Put(Put), .Full(Full), .DataIn(WrDataIn), .IndexOut(WrIndexOut),
    .Got(Got), .Valid(Valid), .IndexIn(unsigned'(Out_S2M_g.BID)), .DataOut(WrDataOut)
  );

  bus_Arbiter #(
    .STRATEGY("RR"), .PORTS(PORTS), .OUTPUT_REG(1'b1)
  ) Arbiter (
    .Clock(Clock), .Reset(Reset),
    .Arbitrate(Arbitrate), .RequestVector(RequestVector),
    .Arbitrated(Arbitrated), .GrantVector(GrantVector), .GrantIndex(GrantIndex)
  );

  // --- Read merge (AXI-Stream shim) ---
  localparam int FWD_W = ADDR_W + 8 + 3 + 2 + OUT_AR_ID_BITS + USER_W + 4 + 3 + 1 + 4 + 4;

  typedef axi4stream_sized#(FWD_W, 1, 1, 1, 1)::m2s_t fwd_m2s_t;
  typedef axi4stream_sized#(FWD_W, 1, 1, 1, 1)::s2m_t fwd_s2m_t;

  fwd_m2s_t Mux_In_M2S[PORTS];
  fwd_s2m_t Mux_In_S2M[PORTS];
  fwd_m2s_t Mux_Out_M2S;
  fwd_s2m_t Mux_Out_S2M;

  localparam int RD_NUM_IDX = (NUM_OUTSTANDING_READS == 0) ? (1 << OUT_AR_ID_BITS) : NUM_OUTSTANDING_READS;

  logic RdPut;
  logic RdFull;
  logic [PORT_BITS + IN_AR_ID_BITS-1:0] RdDataIn;
  logic [downto_width(log2ceilnz(RD_NUM_IDX))-1:0] RdIndexOut;
  logic RdGot;
  logic RdValid;
  logic [PORT_BITS + IN_AR_ID_BITS-1:0] RdDataOut;

  localparam int AR_ADDR_POS = 0;
  localparam int AR_LEN_POS  = 1;
  localparam int AR_SIZE_POS = 2;
  localparam int AR_BURST_POS = 3;
  localparam int AR_ID_POS = 4;
  localparam int AR_USER_POS = 5;
  localparam int AR_CACHE_POS = 6;
  localparam int AR_PROT_POS = 7;
  localparam int AR_LOCK_POS = 8;
  localparam int AR_QOS_POS = 9;
  localparam int AR_REGION_POS = 10;
  localparam int FWD_LENS[11] = '{
    ADDR_W, 8, 3, 2, OUT_AR_ID_BITS, USER_W, 4, 3, 1, 4, 4
  };
  localparam int FWD_AR_LEN_LO   = ADDR_W;
  localparam int FWD_AR_SIZE_LO  = ADDR_W + 8;
  localparam int FWD_AR_BURST_LO = ADDR_W + 8 + 3;
  localparam int FWD_AR_ID_LO    = ADDR_W + 8 + 3 + 2;
  localparam int FWD_AR_USER_LO  = FWD_AR_ID_LO + OUT_AR_ID_BITS;
  localparam int FWD_AR_CACHE_LO = FWD_AR_USER_LO + USER_W;
  localparam int FWD_AR_PROT_LO  = FWD_AR_CACHE_LO + 4;
  localparam int FWD_AR_LOCK_LO  = FWD_AR_PROT_LO + 3;
  localparam int FWD_AR_QOS_LO   = FWD_AR_LOCK_LO + 1;
  localparam int FWD_AR_REGION_LO = FWD_AR_QOS_LO + 4;

  for (genvar ri = 0; ri < PORTS; ri++) begin : rd_map
    logic [FWD_W-1:0] ForwardDataIn;
    always_comb begin
      int p = 0;
      ForwardDataIn[p+:ADDR_W] = In_M2S_read[ri].ARAddr; p += ADDR_W;
      ForwardDataIn[p+:8] = In_M2S_read[ri].ARLen; p += 8;
      ForwardDataIn[p+:3] = In_M2S_read[ri].ARSize; p += 3;
      ForwardDataIn[p+:2] = In_M2S_read[ri].ARBurst; p += 2;
      ForwardDataIn[p+:OUT_AR_ID_BITS] = logic'(unsigned'(RdIndexOut)); p += OUT_AR_ID_BITS;
      ForwardDataIn[p+:USER_W] = In_M2S_read[ri].ARUser; p += USER_W;
      ForwardDataIn[p+:4] = In_M2S_read[ri].ARCache; p += 4;
      ForwardDataIn[p+:3] = In_M2S_read[ri].ARProt; p += 3;
      ForwardDataIn[p+:1] = In_M2S_read[ri].ARLock[0]; p += 1;
      ForwardDataIn[p+:4] = In_M2S_read[ri].ARQOS; p += 4;
      ForwardDataIn[p+:4] = In_M2S_read[ri].ARRegion;
    end
    assign Mux_In_M2S[ri].Data  = ForwardDataIn;
    assign Mux_In_M2S[ri].Last  = 1'b1;
    assign Mux_In_M2S[ri].Keep  = 1'b1;
    assign Mux_In_M2S[ri].Dest  = '0;
    assign Mux_In_M2S[ri].ID    = '0;
    assign Mux_In_M2S[ri].User  = '0;
    assign In_S2M_read[ri].ARReady = Mux_In_S2M[ri].Ready & ~RdFull;
    assign In_S2M_read[ri].RLast  = Out_S2M_g.RLast;
    assign In_S2M_read[ri].RData  = Out_S2M_g.RData;
    assign In_S2M_read[ri].RResp  = Out_S2M_g.RResp;
    assign In_S2M_read[ri].RUser  = Out_S2M_g.RUser;
    assign In_S2M_read[ri].RID    = RdDataOut[IN_AR_ID_BITS-1:0];
    assign In_S2M_read[ri].RValid = Out_S2M_g.RValid & RdValid &
                                    (unsigned'(RdDataOut[PORT_BITS+IN_AR_ID_BITS-1:IN_AR_ID_BITS]) == ri);
  end

  dstruct_OutOfOrderBuffer #(
    .DATA_BITS(PORT_BITS + IN_AR_ID_BITS),
    .NUM_INDEX(RD_NUM_IDX)
  ) Read_idx (
    .Clock(Clock), .Reset(Reset),
    .Put(RdPut), .Full(RdFull), .DataIn(RdDataIn), .IndexOut(RdIndexOut),
    .Got(RdGot), .Valid(RdValid), .IndexIn(unsigned'(Out_S2M_g.RID)), .DataOut(RdDataOut)
  );

  axi4stream_Mux #(
    .PORTS(PORTS), .DATA_BITS(FWD_W), .USER_BITS(1), .DEST_BITS(1), .ID_BITS(1), .KEEP_BITS(1)
  ) Read_mux (
    .Clock(Clock), .Reset(Reset),
    .MuxControl('1),
    .In_M2S(Mux_In_M2S), .In_S2M(Mux_In_S2M),
    .Out_M2S(Mux_Out_M2S), .Out_S2M(Mux_Out_S2M)
  );
  assign Mux_Out_S2M.Ready = Out_S2M_g.ARReady;

  for (genvar pi = 0; pi < PORTS; pi++) begin : bus_join
    assign In_M2S_write[pi] = In_M2S_g[pi];
    assign In_M2S_read[pi]  = In_M2S_g[pi];
    assign In_S2M_g[pi].AWReady = In_S2M_write[pi].AWReady;
    assign In_S2M_g[pi].WReady  = In_S2M_write[pi].WReady;
    assign In_S2M_g[pi].BValid  = In_S2M_write[pi].BValid;
    assign In_S2M_g[pi].BResp   = In_S2M_write[pi].BResp;
    assign In_S2M_g[pi].BID     = In_S2M_write[pi].BID;
    assign In_S2M_g[pi].BUser   = In_S2M_write[pi].BUser;
    assign In_S2M_g[pi].ARReady = In_S2M_read[pi].ARReady;
    assign In_S2M_g[pi].RValid  = In_S2M_read[pi].RValid;
    assign In_S2M_g[pi].RData   = In_S2M_read[pi].RData;
    assign In_S2M_g[pi].RResp   = In_S2M_read[pi].RResp;
    assign In_S2M_g[pi].RID     = In_S2M_read[pi].RID;
    assign In_S2M_g[pi].RLast   = In_S2M_read[pi].RLast;
    assign In_S2M_g[pi].RUser   = In_S2M_read[pi].RUser;
  end

endmodule
