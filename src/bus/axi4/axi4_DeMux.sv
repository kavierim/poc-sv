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
module axi4_DeMux #(
  parameter int PORTS              = 2,
  parameter int ADDR_W             = 32,
  parameter int DATA_W             = 32,
  parameter int USER_W             = 1,
  parameter int ID_W               = 1,
  parameter int PIPELINE_IN        = 0,
  parameter int NUM_OUTSTANDING_READS  = 0,
  parameter int NUM_OUTSTANDING_WRITES = 0,
  parameter logic [ADDR_W-1:0] BASE_ADDRESS[PORTS] = '{default: '0},
  parameter logic [ADDR_W-1:0] BASE_ADDRESS_MASK[PORTS] = '{default: '0},
  parameter int PIPELINE_OUT[PORTS] = '{default: 0},
  parameter type m2s_t = axi4_full_types#(ADDR_W, DATA_W, USER_W, ID_W)::bus_m2s_t,
  parameter type s2m_t = axi4_full_types#(ADDR_W, DATA_W, USER_W, ID_W)::bus_s2m_t
) (
  input  logic Clock,
  input  logic Reset,

  input  m2s_t In_M2S,
  output s2m_t In_S2M,

  output m2s_t Out_M2S[PORTS],
  input  s2m_t Out_S2M[PORTS]
);
  import poc_axi4_full::*;
  import poc_axi4_common::*;
  import poc_axi4stream::*;
  import poc_utils::*;

  localparam int RESPONSE_FIFO_DEPTH = 16;
  localparam int IN_AW_ID_BITS       = downto_width(ID_W);
  localparam int OUT_AW_ID_BITS      = IN_AW_ID_BITS;
  localparam int OUT_AR_ID_BITS      = IN_AW_ID_BITS;
  localparam int ID_BITS             = IN_AW_ID_BITS;
  localparam int RESPONSE_BITS       = 2;
  localparam int PORT_BITS           = downto_width(log2ceilnz(PORTS));

  localparam int WR_NUM_IDX = (NUM_OUTSTANDING_WRITES == 0) ? (1 << OUT_AW_ID_BITS) : NUM_OUTSTANDING_WRITES;
  localparam int RD_NUM_IDX = (NUM_OUTSTANDING_READS == 0) ? (1 << OUT_AR_ID_BITS) : NUM_OUTSTANDING_READS;

  function automatic int demux_lssb_idx(logic [PORTS-1:0] arg);
    for (int i = 0; i < PORTS; i++)
      if (arg[i])
        return i;
    return 0;
  endfunction

  function automatic logic [PORTS-1:0] demux_lssb(logic [PORTS-1:0] arg);
    logic [PORTS-1:0] res;
    res = '0;
    for (int i = 0; i < PORTS; i++)
      if (arg[i]) begin
        res[i] = 1'b1;
        break;
      end
    return res;
  endfunction

  // Unpacked PIPELINE_OUT[i] is not a generate constant in Verilator 5.
  function static int pipeline_out_mask();
    int m = 0;
    for (int i = 0; i < PORTS; i++)
      if (PIPELINE_OUT[i] > 0)
        m |= (1 << i);
    return m;
  endfunction

  m2s_t In_M2S_g;
  s2m_t In_S2M_g;
  m2s_t In_M2S_write;
  s2m_t In_S2M_write;
  m2s_t In_M2S_read;
  s2m_t In_S2M_read;

  m2s_t Out_M2S_g[PORTS];
  s2m_t Out_S2M_g[PORTS];
  m2s_t Out_M2S_write[PORTS];
  s2m_t Out_S2M_write[PORTS];
  m2s_t Out_M2S_read[PORTS];
  s2m_t Out_S2M_read[PORTS];

  if (PIPELINE_IN > 0) begin : glue_in
    axi4_FIFO #(
      .ADDR_W(ADDR_W), .DATA_W(DATA_W), .USER_W(USER_W), .ID_W(ID_W),
      .FRAMES(PIPELINE_IN - 1)
    ) Glue_in (
      .Clock(Clock), .Reset(Reset),
      .In_M2S(In_M2S), .In_S2M(In_S2M),
      .Out_M2S(In_M2S_g), .Out_S2M(In_S2M_g)
    );
  end else begin : glue_in_bypass
    assign In_M2S_g = In_M2S;
    assign In_S2M   = In_S2M_g;
  end

  // Bit i set when PIPELINE_OUT[i] > 0 (matches VHDL glue_out_gen).
  localparam int PIPELINE_OUT_MASK = pipeline_out_mask();
  for (genvar gi = 0; gi < PORTS; gi++) begin : glue_out_loop
    if ((PIPELINE_OUT_MASK >> gi) & 1) begin : glue_out
      axi4_FIFO #(
        .ADDR_W(ADDR_W), .DATA_W(DATA_W), .USER_W(USER_W), .ID_W(ID_W),
        .FRAMES(PIPELINE_OUT[gi] - 1)
      ) Glue_out (
        .Clock(Clock), .Reset(Reset),
        .In_M2S(Out_M2S_g[gi]), .In_S2M(Out_S2M_g[gi]),
        .Out_M2S(Out_M2S[gi]), .Out_S2M(Out_S2M[gi])
      );
    end else begin : glue_out_bypass
      assign Out_M2S[gi]   = Out_M2S_g[gi];
      assign Out_S2M_g[gi] = Out_S2M[gi];
    end
  end

  // --- Write demux ---
  typedef enum logic [2:0] {
    ST_Idle,
    ST_Dataflow,
    ST_DataOnly,
    ST_AddressOnly,
    ST_DiscardData
  } wstate_t;

  wstate_t wState;
  wstate_t wNext;
  logic [PORT_BITS-1:0] wSelectIndex;

  logic [PORTS-1:0] Address_hit_wr;
  logic [PORTS-1:0] Put_wr;
  logic [PORTS-1:0] Full_wr;
  logic [downto_width(log2ceilnz(WR_NUM_IDX))-1:0] IndexOut_wr[PORTS];
  logic [PORTS-1:0] Got_wr;
  logic [IN_AW_ID_BITS-1:0] DataOut_wr[PORTS];

  localparam int B_MUX_W = RESPONSE_BITS + OUT_AW_ID_BITS + USER_W;
  typedef axi4stream_types#(B_MUX_W, 1, 1, 1, 1)::m2s_t b_mux_m2s_t;
  typedef axi4stream_types#(B_MUX_W, 1, 1, 1, 1)::s2m_t b_mux_s2m_t;

  b_mux_m2s_t WMux_In[PORTS+1];
  b_mux_s2m_t WMux_In_S2M[PORTS+1];
  b_mux_m2s_t WMux_Out;
  b_mux_s2m_t WMux_Out_S2M;

  logic Response_fifo_wr_put;
  logic Response_fifo_wr_ful;
  logic Response_fifo_wr_got;
  logic [ID_BITS-1:0] Response_fifo_wr_dout;
  logic Response_fifo_wr_vld;

  for (genvar wi = 0; wi < PORTS; wi++) begin : write_idx_gen
    logic [IN_AW_ID_BITS-1:0] DataIn_wr;

    assign Address_hit_wr[wi] =
        ((unsigned'(In_M2S_write.AWAddr) & ~unsigned'(BASE_ADDRESS_MASK[wi])) ==
         (unsigned'(BASE_ADDRESS[wi]) & ~unsigned'(BASE_ADDRESS_MASK[wi])));

    assign DataIn_wr = In_M2S_write.AWID;
    assign Got_wr[wi] = Out_S2M_write[wi].BValid & WMux_In_S2M[wi].Ready;

    assign WMux_In[wi].Valid = Out_S2M_write[wi].BValid;
    assign WMux_In[wi].Last  = 1'b1;
    assign WMux_In[wi].Keep  = 1'b1;
    assign WMux_In[wi].ID    = '0;
    assign WMux_In[wi].Dest  = '0;
    assign WMux_In[wi].User  = '0;
    assign WMux_In[wi].Data  = {Out_S2M_write[wi].BUser, DataOut_wr[wi], Out_S2M_write[wi].BResp};

    dstruct_OutOfOrderBuffer #(
      .DATA_BITS(IN_AW_ID_BITS),
      .NUM_INDEX(WR_NUM_IDX)
    ) Write_idx (
      .Clock(Clock), .Reset(Reset),
      .Put(Put_wr[wi]), .Full(Full_wr[wi]), .DataIn(DataIn_wr), .IndexOut(IndexOut_wr[wi]),
      .Got(Got_wr[wi]), .Valid(), .IndexIn(unsigned'(Out_S2M_write[wi].BID)), .DataOut(DataOut_wr[wi])
    );
  end

  axi4stream_Mux #(
    .PORTS(PORTS + 1), .DATA_BITS(B_MUX_W), .USER_BITS(1), .DEST_BITS(1), .ID_BITS(1), .KEEP_BITS(1)
  ) Write_Mux (
    .Clock(Clock), .Reset(Reset),
    .MuxControl('1),
    .In_M2S(WMux_In), .In_S2M(WMux_In_S2M),
    .Out_M2S(WMux_Out), .Out_S2M(WMux_Out_S2M)
  );
  assign WMux_Out_S2M.Ready = In_M2S_write.BReady;

  fifo_Shift #(
    .DATA_BITS(ID_BITS), .MIN_DEPTH(RESPONSE_FIFO_DEPTH)
  ) Response_fifo_wr (
    .Clock(Clock), .Reset(Reset), .FillLevel(),
    .Put(Response_fifo_wr_put), .DataIn(In_M2S_write.ARID), .Full(Response_fifo_wr_ful),
    .Got(Response_fifo_wr_got), .DataOut(Response_fifo_wr_dout), .Valid(Response_fifo_wr_vld)
  );

  assign WMux_In[PORTS].Valid = Response_fifo_wr_vld;
  assign WMux_In[PORTS].Last  = 1'b1;
  assign WMux_In[PORTS].Keep  = 1'b1;
  assign WMux_In[PORTS].ID    = '0;
  assign WMux_In[PORTS].Dest  = '0;
  assign WMux_In[PORTS].User  = '0;
  assign WMux_In[PORTS].Data  = {{USER_W{1'b0}}, Response_fifo_wr_dout, C_AXI4_RESPONSE_DECODE_ERROR};
  assign Response_fifo_wr_got = WMux_In_S2M[PORTS].Ready;

  /* verilator lint_off ALWCOMBORDER */
  always_comb begin
    int sel;
    m2s_t wr_template;

    wNext = wState;
    sel   = (wState == ST_Idle) ? demux_lssb_idx(Address_hit_wr) : int'(unsigned'(wSelectIndex));

    In_S2M_write = axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::initialize_bus_s2m(1'b0);
    wr_template  = In_M2S_write;
    for (int i = 0; i < PORTS; i++) begin
      Out_M2S_write[i] = wr_template;
      Out_M2S_write[i].AWValid = 1'b0;
      Out_M2S_write[i].WValid  = 1'b0;
      Out_M2S_write[i].AWID    = logic'(unsigned'(IndexOut_wr[i]));
    end

    Response_fifo_wr_put = 1'b0;
    Put_wr               = '0;

    case (wState)
      ST_Idle: begin
        if (In_M2S_write.AWValid) begin
          if (~|Address_hit_wr) begin
            Response_fifo_wr_put = 1'b1;
            In_S2M_write.AWReady = 1'b1;
            In_S2M_write.WReady  = 1'b1;
            if (~(In_M2S_write.WValid | In_M2S_write.WLast))
              wNext = ST_DiscardData;
          end else if (~Full_wr[sel]) begin
            In_S2M_write.AWReady = Out_S2M_write[sel].AWReady;
            In_S2M_write.WReady  = Out_S2M_write[sel].WReady;
            Out_M2S_write[sel].AWValid = In_M2S_write.AWValid;
            Out_M2S_write[sel].WValid  = In_M2S_write.WValid;
            Put_wr[sel]                = 1'b1;
            if (Out_S2M_write[sel].AWReady & In_M2S_write.WValid & In_M2S_write.WLast &
                Out_S2M_write[sel].WReady) begin
            end else if (Out_S2M_write[sel].AWReady)
              wNext = ST_DataOnly;
            else if (In_M2S_write.WValid & In_M2S_write.WLast & Out_S2M_write[sel].WReady)
              wNext = ST_AddressOnly;
            else
              wNext = ST_Dataflow;
          end
        end
      end
      ST_Dataflow: begin
        In_S2M_write.AWReady = Out_S2M_write[sel].AWReady;
        In_S2M_write.WReady  = Out_S2M_write[sel].WReady;
        Out_M2S_write[sel].AWValid = In_M2S_write.AWValid;
        Out_M2S_write[sel].WValid  = In_M2S_write.WValid;
        if (In_M2S_write.AWValid & Out_S2M_write[sel].AWReady & In_M2S_write.WValid &
            In_M2S_write.WLast & Out_S2M_write[sel].WReady)
          wNext = ST_Idle;
        else if (In_M2S_write.AWValid & Out_S2M_write[sel].AWReady)
          wNext = ST_DataOnly;
        else if (In_M2S_write.WValid & In_M2S_write.WLast & Out_S2M_write[sel].WReady)
          wNext = ST_AddressOnly;
      end
      ST_DataOnly: begin
        In_S2M_write.WReady = Out_S2M_write[sel].WReady;
        Out_M2S_write[sel].WValid = In_M2S_write.WValid;
        if (In_M2S_write.WValid & In_M2S_write.WLast & Out_S2M_write[sel].WReady)
          wNext = ST_Idle;
      end
      ST_AddressOnly: begin
        In_S2M_write.AWReady = Out_S2M_write[sel].AWReady;
        Out_M2S_write[sel].AWValid = In_M2S_write.AWValid;
        if (In_M2S_write.AWValid & Out_S2M_write[sel].AWReady)
          wNext = ST_Idle;
      end
      ST_DiscardData: begin
        In_S2M_write.WReady = 1'b1;
        if (In_M2S_write.WValid & In_M2S_write.WLast)
          wNext = ST_Idle;
      end
      default: wNext = ST_Idle;
    endcase

    In_S2M_write.BValid = WMux_Out.Valid;
    In_S2M_write.BResp  = WMux_Out.Data[0+:RESPONSE_BITS];
    In_S2M_write.BID    = WMux_Out.Data[RESPONSE_BITS+:OUT_AW_ID_BITS];
    In_S2M_write.BUser  = WMux_Out.Data[RESPONSE_BITS+OUT_AW_ID_BITS+:USER_W];
    for (int i = 0; i < PORTS; i++)
      Out_M2S_write[i].BReady = WMux_In_S2M[i].Ready;
  end
  /* verilator lint_on ALWCOMBORDER */

  always_ff @(posedge Clock) begin
    if (Reset)
      wState <= ST_Idle;
    else
      wState <= wNext;
  end

  always_ff @(posedge Clock) begin
    if (Reset)
      wSelectIndex <= '0;
    else if (wState == ST_Idle && In_M2S_write.AWValid && |Address_hit_wr)
      wSelectIndex <= PORT_BITS'(unsigned'(demux_lssb_idx(Address_hit_wr)));
  end

  // --- Read demux ---
  logic [PORTS-1:0] Address_hit_rd;
  logic [PORTS-1:0] DeMuxControl_rd;

  localparam int FWD_W = ADDR_W + 8 + 3 + 2 + ID_BITS + USER_W + 4 + 3 + 1 + 4 + 4;
  localparam int R_MUX_W = DATA_W + RESPONSE_BITS + ID_BITS + USER_W;

  typedef axi4stream_types#(FWD_W, 1, 1, 1, 1)::m2s_t fwd_m2s_t;
  typedef axi4stream_types#(FWD_W, 1, 1, 1, 1)::s2m_t fwd_s2m_t;
  typedef axi4stream_types#(R_MUX_W, 1, 1, 1, 1)::m2s_t r_mux_m2s_t;
  typedef axi4stream_types#(R_MUX_W, 1, 1, 1, 1)::s2m_t r_mux_s2m_t;

  fwd_m2s_t DeMux_In_M2S;
  fwd_s2m_t DeMux_In_S2M;
  fwd_m2s_t DeMux_Out_M2S[PORTS];
  fwd_s2m_t DeMux_Out_S2M[PORTS];

  r_mux_m2s_t RMux_In[PORTS+1];
  r_mux_s2m_t RMux_In_S2M[PORTS+1];
  r_mux_m2s_t RMux_Out;
  r_mux_s2m_t RMux_Out_S2M;

  logic Response_fifo_rd_put;
  logic Response_fifo_rd_ful;
  logic Response_fifo_rd_got;
  logic [ID_BITS-1:0] Response_fifo_rd_dout;
  logic Response_fifo_rd_vld;

  // VHDL read_blk FORWARD_BIT_VEC field order (low to high): Addr, Len, Size, Burst,
  // User, Cache, Protect, Lock, QoS, Region, ID.
  localparam int FWD_AR_LEN_LO    = ADDR_W;
  localparam int FWD_AR_SIZE_LO   = ADDR_W + 8;
  localparam int FWD_AR_BURST_LO  = ADDR_W + 8 + 3;
  localparam int FWD_AR_USER_LO   = ADDR_W + 8 + 3 + 2;
  localparam int FWD_AR_CACHE_LO  = FWD_AR_USER_LO + USER_W;
  localparam int FWD_AR_PROT_LO   = FWD_AR_CACHE_LO + 4;
  localparam int FWD_AR_LOCK_LO   = FWD_AR_PROT_LO + 3;
  localparam int FWD_AR_QOS_LO    = FWD_AR_LOCK_LO + 1;
  localparam int FWD_AR_REGION_LO = FWD_AR_QOS_LO + 4;
  localparam int FWD_AR_ID_LO     = FWD_AR_REGION_LO + 4;

  for (genvar ri = 0; ri < PORTS; ri++) begin : read_idx_gen
    logic Put_rd;
    logic Full_rd;
    logic [ID_BITS-1:0] DataIn_rd;
    logic [downto_width(log2ceilnz(RD_NUM_IDX))-1:0] IndexOut_rd;
    logic Got_rd;
    logic [ID_BITS-1:0] DataOut_rd;

    assign Address_hit_rd[ri] =
        ((unsigned'(In_M2S_read.ARAddr) & ~unsigned'(BASE_ADDRESS_MASK[ri])) ==
         (unsigned'(BASE_ADDRESS[ri]) & ~unsigned'(BASE_ADDRESS_MASK[ri])));

    assign DataIn_rd = DeMux_Out_M2S[ri].Data[FWD_AR_ID_LO+:ID_BITS];
    assign Put_rd = DeMux_Out_M2S[ri].Valid & Out_S2M_read[ri].ARReady & ~Full_rd;
    assign Got_rd = RMux_In_S2M[ri].Ready & Out_S2M_read[ri].RValid & Out_S2M_read[ri].RLast;
    assign DeMux_Out_S2M[ri].Ready = Out_S2M_read[ri].ARReady & ~Full_rd;

    assign Out_M2S_read[ri].ARID    = logic'(unsigned'(IndexOut_rd));
    assign Out_M2S_read[ri].ARValid = DeMux_Out_M2S[ri].Valid & ~Full_rd;
    assign Out_M2S_read[ri].ARAddr  = DeMux_Out_M2S[ri].Data[0+:ADDR_W];
    assign Out_M2S_read[ri].ARLen   = DeMux_Out_M2S[ri].Data[FWD_AR_LEN_LO+:8];
    assign Out_M2S_read[ri].ARSize  = DeMux_Out_M2S[ri].Data[FWD_AR_SIZE_LO+:3];
    assign Out_M2S_read[ri].ARBurst = DeMux_Out_M2S[ri].Data[FWD_AR_BURST_LO+:2];
    assign Out_M2S_read[ri].ARCache = DeMux_Out_M2S[ri].Data[FWD_AR_CACHE_LO+:4];
    assign Out_M2S_read[ri].ARProt  = DeMux_Out_M2S[ri].Data[FWD_AR_PROT_LO+:3];
    assign Out_M2S_read[ri].ARLock  = DeMux_Out_M2S[ri].Data[FWD_AR_LOCK_LO+:1];
    assign Out_M2S_read[ri].ARQOS   = DeMux_Out_M2S[ri].Data[FWD_AR_QOS_LO+:4];
    assign Out_M2S_read[ri].ARRegion= DeMux_Out_M2S[ri].Data[FWD_AR_REGION_LO+:4];
    assign Out_M2S_read[ri].ARUser  = DeMux_Out_M2S[ri].Data[FWD_AR_USER_LO+:USER_W];
    assign Out_M2S_read[ri].RReady  = RMux_In_S2M[ri].Ready;

    assign RMux_In[ri].Valid = Out_S2M_read[ri].RValid;
    assign RMux_In[ri].Last  = Out_S2M_read[ri].RLast;
    assign RMux_In[ri].Keep  = 1'b1;
    assign RMux_In[ri].ID    = '0;
    assign RMux_In[ri].Dest  = '0;
    assign RMux_In[ri].User  = '0;
    assign RMux_In[ri].Data  = {Out_S2M_read[ri].RUser, DataOut_rd, Out_S2M_read[ri].RResp,
                                Out_S2M_read[ri].RData};

    dstruct_OutOfOrderBuffer #(
      .DATA_BITS(ID_BITS),
      .NUM_INDEX(RD_NUM_IDX)
    ) Read_idx (
      .Clock(Clock), .Reset(Reset),
      .Put(Put_rd), .Full(Full_rd), .DataIn(DataIn_rd), .IndexOut(IndexOut_rd),
      .Got(Got_rd), .Valid(), .IndexIn(unsigned'(Out_S2M_read[ri].RID)), .DataOut(DataOut_rd)
    );
  end

  // Single-beat AR forward (Last always 1). Inline demux avoids a second
  // axi4stream_* instance alongside Write_Mux (Yosys/slang rtlil assert).
  always_comb begin
    DeMux_In_S2M = '0;
    for (int i = 0; i < PORTS; i++) begin
      DeMux_Out_M2S[i] = '0;
      if (DeMuxControl_rd[i]) begin
        DeMux_Out_M2S[i]       = DeMux_In_M2S;
        DeMux_In_S2M.Ready     = DeMux_In_S2M.Ready | DeMux_Out_S2M[i].Ready;
      end
    end
    if (~|DeMuxControl_rd)
      DeMux_In_S2M.Ready = 1'b1;
  end

  // Priority R-response merge (PORTS + DECERR). Same Yosys constraint as above.
  always_comb begin
    RMux_Out = '0;
    for (int i = 0; i < PORTS + 1; i++)
      RMux_In_S2M[i] = '0;
    for (int i = 0; i < PORTS + 1; i++) begin
      if (RMux_In[i].Valid) begin
        RMux_Out            = RMux_In[i];
        RMux_In_S2M[i].Ready = RMux_Out_S2M.Ready;
        break;
      end
    end
  end
  assign RMux_Out_S2M.Ready = In_M2S_read.RReady;

  fifo_Shift #(
    .DATA_BITS(ID_BITS), .MIN_DEPTH(RESPONSE_FIFO_DEPTH)
  ) Response_fifo_rd (
    .Clock(Clock), .Reset(Reset), .FillLevel(),
    .Put(Response_fifo_rd_put), .DataIn(In_M2S_read.ARID), .Full(Response_fifo_rd_ful),
    .Got(Response_fifo_rd_got), .DataOut(Response_fifo_rd_dout), .Valid(Response_fifo_rd_vld)
  );

  assign DeMuxControl_rd = demux_lssb(Address_hit_rd);
  assign DeMux_In_M2S.Valid = In_M2S_read.ARValid & ~Response_fifo_rd_ful;
  assign DeMux_In_M2S.Last  = 1'b1;
  assign DeMux_In_M2S.Keep  = 1'b1;
  assign DeMux_In_M2S.ID    = '0;
  assign DeMux_In_M2S.Dest  = '0;
  assign DeMux_In_M2S.User  = '0;
  assign DeMux_In_M2S.Data  = {In_M2S_read.ARID, In_M2S_read.ARRegion, In_M2S_read.ARQOS,
                               In_M2S_read.ARLock[0], In_M2S_read.ARProt, In_M2S_read.ARCache,
                               In_M2S_read.ARUser, In_M2S_read.ARBurst, In_M2S_read.ARSize,
                               In_M2S_read.ARLen, In_M2S_read.ARAddr};
  assign In_S2M_read.ARReady = DeMux_In_S2M.Ready & ~Response_fifo_rd_ful;
  assign Response_fifo_rd_put =
      (In_M2S_read.ARValid & DeMux_In_S2M.Ready) & ~(|Address_hit_rd);

  assign RMux_In[PORTS].Valid = Response_fifo_rd_vld;
  assign RMux_In[PORTS].Last  = 1'b1;
  assign RMux_In[PORTS].Keep  = 1'b1;
  assign RMux_In[PORTS].ID    = '0;
  assign RMux_In[PORTS].Dest  = '0;
  assign RMux_In[PORTS].User  = '0;
  assign RMux_In[PORTS].Data  = {{USER_W{1'b0}}, Response_fifo_rd_dout, C_AXI4_RESPONSE_DECODE_ERROR,
                                 {DATA_W{1'b0}}};
  assign Response_fifo_rd_got = RMux_In_S2M[PORTS].Ready;

  assign In_S2M_read.RValid = RMux_Out.Valid;
  assign In_S2M_read.RLast  = RMux_Out.Last;
  assign In_S2M_read.RData  = RMux_Out.Data[0+:DATA_W];
  assign In_S2M_read.RResp  = RMux_Out.Data[DATA_W+:RESPONSE_BITS];
  assign In_S2M_read.RID    = RMux_Out.Data[DATA_W+RESPONSE_BITS+:ID_BITS];
  assign In_S2M_read.RUser  = RMux_Out.Data[DATA_W+RESPONSE_BITS+ID_BITS+:USER_W];

  for (genvar pi = 0; pi < PORTS; pi++) begin : bus_join
    assign Out_S2M_write[pi] = Out_S2M_g[pi];
    assign Out_S2M_read[pi]  = Out_S2M_g[pi];

    assign Out_M2S_g[pi].AWID     = Out_M2S_write[pi].AWID;
    assign Out_M2S_g[pi].AWAddr   = Out_M2S_write[pi].AWAddr;
    assign Out_M2S_g[pi].AWLen    = Out_M2S_write[pi].AWLen;
    assign Out_M2S_g[pi].AWSize   = Out_M2S_write[pi].AWSize;
    assign Out_M2S_g[pi].AWBurst  = Out_M2S_write[pi].AWBurst;
    assign Out_M2S_g[pi].AWLock   = Out_M2S_write[pi].AWLock;
    assign Out_M2S_g[pi].AWQOS    = Out_M2S_write[pi].AWQOS;
    assign Out_M2S_g[pi].AWRegion = Out_M2S_write[pi].AWRegion;
    assign Out_M2S_g[pi].AWUser   = Out_M2S_write[pi].AWUser;
    assign Out_M2S_g[pi].AWValid  = Out_M2S_write[pi].AWValid;
    assign Out_M2S_g[pi].AWCache  = Out_M2S_write[pi].AWCache;
    assign Out_M2S_g[pi].AWProt   = Out_M2S_write[pi].AWProt;
    assign Out_M2S_g[pi].WValid   = Out_M2S_write[pi].WValid;
    assign Out_M2S_g[pi].WLast    = Out_M2S_write[pi].WLast;
    assign Out_M2S_g[pi].WUser    = Out_M2S_write[pi].WUser;
    assign Out_M2S_g[pi].WData    = Out_M2S_write[pi].WData;
    assign Out_M2S_g[pi].WStrb    = Out_M2S_write[pi].WStrb;
    assign Out_M2S_g[pi].BReady   = Out_M2S_write[pi].BReady;
    assign Out_M2S_g[pi].ARValid  = Out_M2S_read[pi].ARValid;
    assign Out_M2S_g[pi].ARAddr   = Out_M2S_read[pi].ARAddr;
    assign Out_M2S_g[pi].ARCache  = Out_M2S_read[pi].ARCache;
    assign Out_M2S_g[pi].ARProt   = Out_M2S_read[pi].ARProt;
    assign Out_M2S_g[pi].ARID     = Out_M2S_read[pi].ARID;
    assign Out_M2S_g[pi].ARLen    = Out_M2S_read[pi].ARLen;
    assign Out_M2S_g[pi].ARSize   = Out_M2S_read[pi].ARSize;
    assign Out_M2S_g[pi].ARBurst  = Out_M2S_read[pi].ARBurst;
    assign Out_M2S_g[pi].ARLock   = Out_M2S_read[pi].ARLock;
    assign Out_M2S_g[pi].ARQOS    = Out_M2S_read[pi].ARQOS;
    assign Out_M2S_g[pi].ARRegion = Out_M2S_read[pi].ARRegion;
    assign Out_M2S_g[pi].ARUser   = Out_M2S_read[pi].ARUser;
    assign Out_M2S_g[pi].RReady   = Out_M2S_read[pi].RReady;
  end

  assign In_M2S_write.AWID     = In_M2S_g.AWID;
  assign In_M2S_write.AWAddr   = In_M2S_g.AWAddr;
  assign In_M2S_write.AWLen    = In_M2S_g.AWLen;
  assign In_M2S_write.AWSize   = In_M2S_g.AWSize;
  assign In_M2S_write.AWBurst  = In_M2S_g.AWBurst;
  assign In_M2S_write.AWLock   = In_M2S_g.AWLock;
  assign In_M2S_write.AWQOS    = In_M2S_g.AWQOS;
  assign In_M2S_write.AWRegion = In_M2S_g.AWRegion;
  assign In_M2S_write.AWUser   = In_M2S_g.AWUser;
  assign In_M2S_write.AWValid  = In_M2S_g.AWValid;
  assign In_M2S_write.AWCache  = In_M2S_g.AWCache;
  assign In_M2S_write.AWProt   = In_M2S_g.AWProt;
  assign In_M2S_write.WValid   = In_M2S_g.WValid;
  assign In_M2S_write.WLast    = In_M2S_g.WLast;
  assign In_M2S_write.WUser    = In_M2S_g.WUser;
  assign In_M2S_write.WData    = In_M2S_g.WData;
  assign In_M2S_write.WStrb    = In_M2S_g.WStrb;
  assign In_M2S_write.BReady   = In_M2S_g.BReady;
  assign In_M2S_read.ARValid   = In_M2S_g.ARValid;
  assign In_M2S_read.ARAddr    = In_M2S_g.ARAddr;
  assign In_M2S_read.ARCache   = In_M2S_g.ARCache;
  assign In_M2S_read.ARProt    = In_M2S_g.ARProt;
  assign In_M2S_read.ARID      = In_M2S_g.ARID;
  assign In_M2S_read.ARLen     = In_M2S_g.ARLen;
  assign In_M2S_read.ARSize    = In_M2S_g.ARSize;
  assign In_M2S_read.ARBurst   = In_M2S_g.ARBurst;
  assign In_M2S_read.ARLock    = In_M2S_g.ARLock;
  assign In_M2S_read.ARQOS     = In_M2S_g.ARQOS;
  assign In_M2S_read.ARRegion  = In_M2S_g.ARRegion;
  assign In_M2S_read.ARUser    = In_M2S_g.ARUser;
  assign In_M2S_read.RReady    = In_M2S_g.RReady;

  assign In_S2M_g.AWReady = In_S2M_write.AWReady;
  assign In_S2M_g.WReady  = In_S2M_write.WReady;
  assign In_S2M_g.BValid  = In_S2M_write.BValid;
  assign In_S2M_g.BResp   = In_S2M_write.BResp;
  assign In_S2M_g.BID     = In_S2M_write.BID;
  assign In_S2M_g.BUser   = In_S2M_write.BUser;
  assign In_S2M_g.ARReady = In_S2M_read.ARReady;
  assign In_S2M_g.RValid  = In_S2M_read.RValid;
  assign In_S2M_g.RData   = In_S2M_read.RData;
  assign In_S2M_g.RResp   = In_S2M_read.RResp;
  assign In_S2M_g.RID     = In_S2M_read.RID;
  assign In_S2M_g.RLast   = In_S2M_read.RLast;
  assign In_S2M_g.RUser   = In_S2M_read.RUser;

endmodule
