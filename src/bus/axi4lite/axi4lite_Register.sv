// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273
// VHDL: PoC/src/bus/axi4lite/axi4lite_Register.vhdl

`timescale 1ns/1ps

module axi4lite_Register #(
  parameter int  N_USER_CFG = 1,
  parameter bit  ENABLE_INTERRUPT = 1'b0,
  parameter int  N_IRQ_SLOTS = 0,
  parameter logic [31:0] INTERRUPT_ENABLE_REGISTER_ADDRESS  = 32'h0,
  parameter logic [31:0] INTERRUPT_MATCH_REGISTER_ADDRESS   = 32'h4,
  parameter bit  INTERRUPT_IS_STROBE = 1'b1,
  parameter bit  INIT_ON_RESET = 1'b1,
  parameter bit  IGNORE_HIGH_ADDRESS = 1'b1,
  parameter poc_axi4_common::T_AXI4_Response RESPONSE_ON_ERROR =
    poc_axi4_common::C_AXI4_RESPONSE_DECODE_ERROR,
  parameter bit  DISABLE_ADDRESS_CHECK = 1'b0,
  parameter int  ADDR_W = 32,
  parameter int  DATA_W = 32,
  parameter bit  SIM_READWRITE_CFG = 1'b0
) (
  input  logic                                    Clock,
  input  logic                                    Reset,
  input  poc_axi4lite::T_AXI4Lite_Bus_M2S AXI4Lite_m2s,
  output poc_axi4lite::T_AXI4Lite_Bus_S2M AXI4Lite_s2m,
  output logic                                    AXI4Lite_irq,
  output logic [31:0]                             RegisterFile_ReadPort[N_USER_CFG + 2],
  output logic [N_USER_CFG + 1:0]                 RegisterFile_ReadPort_hit,
  input  logic [31:0]                             RegisterFile_WritePort[N_USER_CFG + 2],
  output logic [N_USER_CFG + 1:0]                 RegisterFile_WritePort_hit,
  input  logic [N_USER_CFG + 1:0]                 RegisterFile_WritePort_strobe
);
  import poc_axi4_common::*;
  import poc_axi4lite::*;
  import poc_utils::*;

  localparam int DATA_BITS_intern = 32;
  localparam int ADDR_LSB       = log2ceil(DATA_BITS_intern) - 3;
  localparam int N_CFG_I        = N_USER_CFG + (ENABLE_INTERRUPT ? 2 : 0);
  localparam int NUMBER_INTERRUPT_REGISTERS = ENABLE_INTERRUPT ? N_IRQ_SLOTS : 0;

  function automatic T_axi4lite_RegisterModes cfg_mode(input int i);
    if (SIM_READWRITE_CFG && i < 5) begin
      unique case (i)
        0: return ConstantValue;
        1: return ReadOnly;
        2, 3, 4: return ReadWrite;
        default: return ReadWrite;
      endcase
    end
    if (!ENABLE_INTERRUPT)
      return ReadWrite;
    if (i == N_USER_CFG)
      return ReadWrite;
    return ReadOnly_NotRegistered;
  endfunction

  function automatic logic [31:0] cfg_address(input int i);
    if (SIM_READWRITE_CFG && i < 5) begin
      unique case (i)
        0: return 32'h00;
        1: return 32'h04;
        2: return 32'h08;
        3: return 32'h10;
        4: return 32'h14;
        default: return '0;
      endcase
    end
    if (!ENABLE_INTERRUPT)
      return '0;
    if (i == N_USER_CFG)
      return INTERRUPT_ENABLE_REGISTER_ADDRESS;
    return INTERRUPT_MATCH_REGISTER_ADDRESS;
  endfunction

  function automatic logic [31:0] cfg_init_value(input int i);
    if (SIM_READWRITE_CFG && i < 5) begin
      unique case (i)
        0: return 32'h12;
        1: return '0;
        2: return 32'hFF;
        3: return 32'h2;
        4: return 32'hA;
        default: return '0;
      endcase
    end
    return '0;
  endfunction

  function automatic logic [31:0] cfg_auto_clear_mask(input int i);
    return '0;
  endfunction

  function automatic bit cfg_is_interrupt(input int i);
    return 1'b0;
  endfunction

  localparam int REG_ADDRESS_BITS_f = 32;
  localparam int REG_ADDRESS_BITS   = (REG_ADDRESS_BITS_f < ADDR_LSB) ? ADDR_LSB : REG_ADDRESS_BITS_f;

  logic [ADDR_W-ADDR_LSB-1:0] axi_awaddr;
  logic                       axi_awready;
  logic                       axi_wready;
  logic [1:0]                 axi_bresp;
  logic                       axi_bvalid;
  logic [ADDR_W-ADDR_LSB-1:0] axi_araddr;
  logic                       axi_arready;
  logic [DATA_W-1:0]          axi_rdata;
  logic [31:0]                axi_rdata_mux[N_CFG_I];
  logic [1:0]                 axi_rresp;
  logic                       axi_rvalid;

  logic [N_CFG_I-1:0] hit_r;
  logic [N_CFG_I-1:0] hit_r_1;
  logic                 is_high_r;
  logic [N_CFG_I-1:0] is_address_w;
  logic [N_CFG_I-1:0] hit_w;
  logic [N_CFG_I-1:0] hit_w_1;
  logic                 is_high_w;

  logic [31:0] RegisterFile[N_CFG_I];
  logic [N_CFG_I-1:0] latched;
  logic [N_CFG_I-1:0] clear_latch_w;
  logic [N_CFG_I-1:0] clear_latch_r;
  logic               outstanding_read;
  logic               slv_reg_rden;
  logic               slv_reg_rden_d;
  logic               slv_reg_rden_re;
  logic               slv_reg_wren;

  logic [15:0] Is_Interrupt;
  logic [15:0] Is_Interrupt_d;
  logic [15:0] Is_Interrupt_re;

  initial begin
    if (DATA_W != 32)
      $fatal(1, "PoC.axi4lite_Register: only 32-bit DATA_W supported in this port");
    if (ADDR_W < REG_ADDRESS_BITS)
      $fatal(1, "PoC.axi4lite_Register: AXI address width too small for register map");
  end

  function automatic void init_register_file();
    for (int i = 0; i < N_CFG_I; i++)
      RegisterFile[i] = cfg_init_value(i);
  endfunction

  initial init_register_file();

  assign AXI4Lite_s2m.AWReady = axi_awready;
  assign AXI4Lite_s2m.WReady  = axi_wready;
  assign AXI4Lite_s2m.BResp   = axi_bresp;
  assign AXI4Lite_s2m.BValid  = axi_bvalid;
  assign AXI4Lite_s2m.ARReady = axi_arready;
  assign AXI4Lite_s2m.RData   = axi_rdata;
  assign AXI4Lite_s2m.RResp   = axi_rresp;
  assign AXI4Lite_s2m.RValid  = axi_rvalid;

  always_ff @(posedge Clock) begin
    if (Reset) begin
      axi_awready <= 1'b0;
      axi_awaddr  <= '0;
    end else if (!axi_awready && AXI4Lite_m2s.AWValid && AXI4Lite_m2s.WValid) begin
      axi_awready <= 1'b1;
      axi_awaddr  <= AXI4Lite_m2s.AWAddr[ADDR_W-1:ADDR_LSB];
    end else
      axi_awready <= 1'b0;
  end

  always_ff @(posedge Clock) begin
    if (Reset)
      axi_wready <= 1'b0;
    else if (!axi_wready && AXI4Lite_m2s.AWValid && AXI4Lite_m2s.WValid)
      axi_wready <= 1'b1;
    else
      axi_wready <= 1'b0;
  end

  logic [31:0] rf_next[N_CFG_I];
  logic [N_CFG_I-1:0] latched_next;

  always_comb begin
    rf_next    = RegisterFile;
    latched_next = latched;
    for (int i = 0; i < N_CFG_I; i++) begin
      unique case (cfg_mode(i))
        LatchValue_ClearOnWrite, LatchValue_ClearOnRead: begin
          if (!latched[i] && RegisterFile_WritePort_strobe[i]) begin
            rf_next[i] = RegisterFile_WritePort[i];
            if (RegisterFile_WritePort[i] != RegisterFile[i])
              latched_next[i] = 1'b1;
          end else if (clear_latch_w[i] || clear_latch_r[i]) begin
            latched_next[i] = 1'b0;
            rf_next[i]      = cfg_init_value(i);
          end
        end
        LatchHighBit_ClearOnWrite, LatchHighBit_ClearOnRead: begin
          if (RegisterFile_WritePort_strobe[i])
            rf_next[i] = RegisterFile[i] | RegisterFile_WritePort[i];
          if (clear_latch_w[i] || clear_latch_r[i]) begin
            rf_next[i] = RegisterFile_WritePort_strobe[i] ? RegisterFile_WritePort[i] : '0;
          end
        end
        LatchLowBit_ClearOnWrite, LatchLowBit_ClearOnRead: begin
          if (RegisterFile_WritePort_strobe[i])
            rf_next[i] = RegisterFile[i] & RegisterFile_WritePort[i];
          if (clear_latch_w[i] || clear_latch_r[i]) begin
            rf_next[i] = RegisterFile_WritePort_strobe[i] ? RegisterFile_WritePort[i] : '1;
          end
        end
        ReadWrite: begin
          if (i <= N_USER_CFG - 1) begin
            if (slv_reg_wren && hit_w[i]) begin
              for (int ii = 0; ii < 4; ii++)
                if (AXI4Lite_m2s.WStrb[ii])
                  rf_next[i][8*ii+:8] = AXI4Lite_m2s.WData[8*ii+:8];
            end else if (RegisterFile_WritePort_strobe[i])
              rf_next[i] = RegisterFile_WritePort[i];
            else
              rf_next[i] = RegisterFile[i] & ~cfg_auto_clear_mask(i);
          end else if (hit_w[i] && slv_reg_wren) begin
            for (int ii = 0; ii < 4; ii++)
              if (AXI4Lite_m2s.WStrb[ii])
                rf_next[i][8*ii+:8] = AXI4Lite_m2s.WData[8*ii+:8];
          end
        end
        ReadOnly, ReadOnly_NotRegistered, ConstantValue, ReadWrite_NotRegistered: begin
          if (RegisterFile_WritePort_strobe[i])
            rf_next[i] = RegisterFile_WritePort[i];
        end
        default: ;
      endcase
    end
  end

  always_ff @(posedge Clock) begin
    if (Reset) begin
      if (INIT_ON_RESET) begin
        for (int i = 0; i < N_CFG_I; i++)
          RegisterFile[i] <= cfg_init_value(i);
      end
      latched <= '0;
    end else begin
      RegisterFile <= rf_next;
      latched      <= latched_next;
    end
  end

  always_ff @(posedge Clock) begin
    if (Reset) begin
      axi_bvalid <= 1'b0;
      axi_bresp  <= C_AXI4_RESPONSE_OKAY;
    end else begin
      if (!axi_bvalid && slv_reg_wren) begin
        axi_bvalid <= 1'b1;
        axi_bresp  <= (|(hit_w | hit_w_1)) ? C_AXI4_RESPONSE_OKAY : RESPONSE_ON_ERROR;
      end else if (AXI4Lite_m2s.BReady && axi_bvalid)
        axi_bvalid <= 1'b0;
    end
  end

  assign slv_reg_wren   = axi_wready & axi_awready & AXI4Lite_m2s.AWValid & AXI4Lite_m2s.WValid;
  assign clear_latch_w  = {N_CFG_I{slv_reg_wren}} & (hit_w | hit_w_1);

  always_comb begin
    for (int i = 0; i < N_USER_CFG; i++) begin
      unique case (cfg_mode(i))
        ReadOnly_NotRegistered: RegisterFile_ReadPort[i] = RegisterFile_WritePort[i];
        ReadWrite_NotRegistered: RegisterFile_ReadPort[i] = AXI4Lite_m2s.WData;
        ConstantValue: RegisterFile_ReadPort[i] = cfg_init_value(i);
        default: RegisterFile_ReadPort[i] = RegisterFile[i];
      endcase
    end
    for (int i = N_USER_CFG; i < N_CFG_I; i++)
      RegisterFile_ReadPort[i] = RegisterFile[i];
  end

  always_ff @(posedge Clock)
    RegisterFile_ReadPort_hit <= {{(N_USER_CFG + 2 - N_CFG_I){1'b0}}, clear_latch_w};

  always_comb begin
    for (int i = 0; i < N_CFG_I; i++) begin
      if (i == N_CFG_I - 1 && ENABLE_INTERRUPT)
        axi_rdata_mux[i] = {16'b0, Is_Interrupt};
      else if (i < N_USER_CFG && cfg_mode(i) == ReadOnly_NotRegistered)
        axi_rdata_mux[i] = RegisterFile_WritePort[i];
      else if (i < N_USER_CFG && cfg_mode(i) == ReadWrite_NotRegistered)
        axi_rdata_mux[i] = RegisterFile_WritePort[i];
      else if (i < N_USER_CFG && cfg_mode(i) == ConstantValue)
        axi_rdata_mux[i] = cfg_init_value(i);
      else
        axi_rdata_mux[i] = RegisterFile[i];
    end
  end

  always_ff @(posedge Clock) begin
    if (Reset) begin
      axi_arready <= 1'b0;
      axi_araddr  <= '1;
    end else if (!axi_arready && AXI4Lite_m2s.ARValid && !outstanding_read) begin
      axi_arready <= 1'b1;
      axi_araddr  <= AXI4Lite_m2s.ARAddr[ADDR_W-1:ADDR_LSB];
    end else
      axi_arready <= 1'b0;
  end

  always_ff @(posedge Clock) begin
    if (Reset) begin
      axi_rvalid <= 1'b0;
      axi_rresp  <= C_AXI4_RESPONSE_OKAY;
    end else if (slv_reg_rden) begin
      axi_rvalid <= 1'b1;
      axi_rresp  <= |hit_r ? C_AXI4_RESPONSE_OKAY : RESPONSE_ON_ERROR;
    end else if (AXI4Lite_m2s.RReady)
      axi_rvalid <= 1'b0;
  end

  always_ff @(posedge Clock) begin
    if (Reset)
      outstanding_read <= 1'b0;
    else
      outstanding_read <= (outstanding_read | slv_reg_rden) & ~(Reset | AXI4Lite_m2s.RReady);
  end

  assign slv_reg_rden    = AXI4Lite_m2s.ARValid & axi_arready & ~axi_rvalid;
  always_ff @(posedge Clock)
    slv_reg_rden_d <= slv_reg_rden;
  assign slv_reg_rden_re = slv_reg_rden & ~slv_reg_rden_d;
  assign RegisterFile_WritePort_hit = {{(N_USER_CFG + 2 - N_CFG_I){1'b0}},
                                       {N_CFG_I{slv_reg_rden_re}} & (hit_r | hit_r_1)};

  function automatic int lssb_idx(input logic [N_CFG_I-1:0] slv);
    for (int i = 0; i < N_CFG_I; i++)
      if (slv[i])
        return i;
    return 0;
  endfunction

  always_ff @(posedge Clock) begin
    int idx;
    if (Reset)
      axi_rdata <= '0;
    else if (slv_reg_rden_re) begin
      idx = lssb_idx(hit_r);
      axi_rdata <= axi_rdata_mux[idx];
    end
  end

  generate
    if ((REG_ADDRESS_BITS >= ADDR_W) || IGNORE_HIGH_ADDRESS) begin : high_addr_ignore
      assign is_high_r = 1'b1;
      assign is_high_w = 1'b1;
    end else begin : high_addr_check
      assign is_high_r = axi_araddr[ADDR_W-ADDR_LSB-1:REG_ADDRESS_BITS-ADDR_LSB] == '0;
      assign is_high_w = axi_awaddr[ADDR_W-ADDR_LSB-1:REG_ADDRESS_BITS-ADDR_LSB] == '0;
    end
  endgenerate

  function automatic int irq_reg_index(input int slot);
    int pos;
    pos = 0;
    for (int i = 0; i < N_USER_CFG; i++)
      if (cfg_is_interrupt(i)) begin
        if (pos == slot)
          return i;
        pos++;
      end
    return 0;
  endfunction

  always_comb begin
    hit_r         = '0;
    hit_w         = '0;
    is_address_w  = '0;
    clear_latch_r = '0;
    for (int i = 0; i < N_CFG_I; i++) begin
      logic [REG_ADDRESS_BITS-1:ADDR_LSB] config_addr;
      logic [31:0]                        cfg_addr_full;
      T_axi4lite_RegisterModes mode;
      cfg_addr_full = cfg_address(i);
      config_addr   = cfg_addr_full[REG_ADDRESS_BITS-1:ADDR_LSB];
      mode          = cfg_mode(i);
      hit_r[i]    = (config_addr == axi_araddr[REG_ADDRESS_BITS-ADDR_LSB-1:0]) & is_high_r;
      clear_latch_r[i] = slv_reg_rden_re & (hit_r[i] | hit_r_1[i]) &
        ((mode == LatchValue_ClearOnRead) || (mode == LatchHighBit_ClearOnRead) ||
         (mode == LatchLowBit_ClearOnRead));
      is_address_w[i] = is_high_w && (config_addr == axi_awaddr[REG_ADDRESS_BITS-ADDR_LSB-1:0]);
      hit_w[i] = is_address_w[i] &&
                 ((mode == ReadWrite) || (mode == ReadWrite_NotRegistered) ||
                  (mode == LatchValue_ClearOnWrite) || (mode == LatchHighBit_ClearOnWrite) ||
                  (mode == LatchLowBit_ClearOnWrite));
    end
  end

  assign hit_w_1 = '0;
  assign hit_r_1 = '0;

  generate
    if (ENABLE_INTERRUPT && NUMBER_INTERRUPT_REGISTERS > 0) begin : Interrupt_Count
      always_ff @(posedge Clock) begin
        Is_Interrupt_d  <= Is_Interrupt;
        Is_Interrupt_re <= Is_Interrupt & ~Is_Interrupt_d;
      end
      assign AXI4Lite_irq = INTERRUPT_IS_STROBE ? |Is_Interrupt_re : |Is_Interrupt;
    end else begin
      assign AXI4Lite_irq = 1'b0;
    end
  endgenerate

  always_comb begin
    Is_Interrupt = '0;
    if (ENABLE_INTERRUPT && NUMBER_INTERRUPT_REGISTERS > 0) begin
      for (int gi = 0; gi < NUMBER_INTERRUPT_REGISTERS; gi++) begin
        int num;
        T_axi4lite_RegisterModes mode;
        num  = irq_reg_index(gi);
        mode = cfg_mode(num);
        unique case (mode)
          LatchValue_ClearOnRead, LatchValue_ClearOnWrite:
            Is_Interrupt[gi] = latched[num] & RegisterFile[N_USER_CFG + 1][gi] &
                               ~(clear_latch_w[num] | clear_latch_r[num]);
          LatchHighBit_ClearOnRead, LatchHighBit_ClearOnWrite:
            Is_Interrupt[gi] = (|RegisterFile[num]) & RegisterFile[N_USER_CFG + 1][gi] &
                               ~(clear_latch_w[num] | clear_latch_r[num]);
          LatchLowBit_ClearOnRead, LatchLowBit_ClearOnWrite:
            Is_Interrupt[gi] = ~(&RegisterFile[num]) & RegisterFile[N_USER_CFG + 1][gi] &
                               ~(clear_latch_w[num] | clear_latch_r[num]);
          ReadOnly:
            Is_Interrupt[gi] = (|RegisterFile[num]) & RegisterFile[N_USER_CFG + 1][gi] &
                               ~(slv_reg_rden_re & (hit_r[num] | hit_r_1[num]));
          ReadOnly_NotRegistered:
            Is_Interrupt[gi] = (|RegisterFile_WritePort[num]) & RegisterFile[N_USER_CFG + 1][gi] &
                               ~(slv_reg_rden_re & (hit_r[num] | hit_r_1[num]));
          default: Is_Interrupt[gi] = 1'b0;
        endcase
      end
    end
  end

endmodule
