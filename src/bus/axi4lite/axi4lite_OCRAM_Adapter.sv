// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273
// VHDL: PoC/src/bus/axi4lite/axi4lite_OCRAM_Adapter.vhdl

`timescale 1ns/1ps

module axi4lite_OCRAM_Adapter #(
  parameter int  OCRAM_ADDRESS_BITS    = 10,
  parameter int  OCRAM_DATA_BITS       = 32,
  parameter bit  PREFFERED_READ_ACCESS = 1'b1,
  parameter int  INPUT_STAGES          = 0,
  parameter bit  ADD_READ_DELAY        = 1'b0,
  parameter int  ADDR_W                = 32,
  parameter int  DATA_W                = 32
) (
  input  logic                                    Clock,
  input  logic                                    Reset,
  input  poc_axi4lite::T_AXI4Lite_Bus_M2S AXI4Lite_m2s,
  output poc_axi4lite::T_AXI4Lite_Bus_S2M AXI4Lite_s2m,
  output logic [OCRAM_ADDRESS_BITS-1:0]         OCRAM_Address,
  output logic                                    OCRAM_WriteEnable,
  output logic [OCRAM_DATA_BITS/8-1:0]            OCRAM_ByteEnable,
  input  logic [OCRAM_DATA_BITS-1:0]              OCRAM_DataIn,
  output logic [OCRAM_DATA_BITS-1:0]              OCRAM_DataOut
);
  import poc_axi4_common::*;
  import poc_axi4lite::*;
  import poc_utils::*;
  import poc_axi4_full::vec_resize;

  localparam int ADDR_LSB = log2ceil(DATA_W) - 3;
  localparam int OCRAM_BYTE_ENABLE_W = OCRAM_DATA_BITS / 8;

  typedef enum logic [3:0] {
    st_idle,
    st_await_write_address,
    st_await_write_data,
    st_write_address_data,
    st_read_data_ack,
    st_write_response_wait,
    st_read_response_wait,
    st_read_response_wait_delay,
    st_error
  } t_state;

  logic [OCRAM_ADDRESS_BITS-1:0] nextAddress;
  logic                          axi_awready;
  logic                          axi_wready;
  logic [1:0]                    axi_bresp;
  logic                          axi_bvalid;
  logic                          axi_arready;
  logic [1:0]                    axi_rresp;
  logic                          axi_rvalid;
  poc_axi4lite::T_AXI4Lite_Bus_M2S AXI4L_m2s_int;
  poc_axi4lite::T_AXI4Lite_Bus_S2M AXI4L_s2m_int;

  t_state currentState;
  t_state nextState;

  initial begin
`ifndef SYNTHESIS
    if ((ADDR_W - ADDR_LSB) < OCRAM_ADDRESS_BITS)
      $fatal(1, "PoC.axi4lite_OCRAM_Adapter: not enough AXI address bits for OCRAM");
    if (DATA_W < OCRAM_DATA_BITS)
      $fatal(1, "PoC.axi4lite_OCRAM_Adapter: not enough AXI data bits for OCRAM");
`endif
  end

  generate
    if (INPUT_STAGES > 0) begin : pipeline_in
    axi4lite_FIFO #(
      .TRANSACTIONS (INPUT_STAGES),
      .ADDR_W       (ADDR_W),
      .DATA_W       (DATA_W)
    ) pipeline (
      .Clock   (Clock),
      .Reset   (Reset),
      .In_M2S  (AXI4Lite_m2s),
      .In_S2M  (AXI4Lite_s2m),
      .Out_M2S (AXI4L_m2s_int),
      .Out_S2M (AXI4L_s2m_int)
    );
    end else begin : passthrough
    assign AXI4L_m2s_int = AXI4Lite_m2s;
    assign AXI4Lite_s2m  = AXI4L_s2m_int;
    end
  endgenerate

  assign AXI4L_s2m_int.AWReady = axi_awready;
  assign AXI4L_s2m_int.WReady  = axi_wready;
  assign AXI4L_s2m_int.BResp   = axi_bresp;
  assign AXI4L_s2m_int.BValid  = axi_bvalid;
  assign AXI4L_s2m_int.ARReady = axi_arready;
  assign AXI4L_s2m_int.RData   = vec_resize#(DATA_W, OCRAM_DATA_BITS)::resize(OCRAM_DataIn);
  assign AXI4L_s2m_int.RResp   = axi_rresp;
  assign AXI4L_s2m_int.RValid  = axi_rvalid;

  assign OCRAM_DataOut    = vec_resize#(OCRAM_DATA_BITS, DATA_W)::resize(AXI4L_m2s_int.WData);
  assign OCRAM_ByteEnable = AXI4L_m2s_int.WStrb[OCRAM_BYTE_ENABLE_W-1:0];

  always_ff @(posedge Clock) begin
    if (Reset)
      currentState <= st_idle;
    else
      currentState <= nextState;
  end

  always_ff @(posedge Clock)
    OCRAM_Address <= nextAddress;

  always_comb begin
    nextState         = currentState;
    nextAddress       = OCRAM_Address;
    OCRAM_WriteEnable = 1'b0;
    axi_awready       = 1'b0;
    axi_wready        = 1'b0;
    axi_arready       = 1'b0;
    axi_rvalid        = 1'b0;
    axi_bvalid        = 1'b0;
    axi_bresp         = C_AXI4_RESPONSE_OKAY;
    axi_rresp         = C_AXI4_RESPONSE_OKAY;

    unique case (currentState)
      st_idle: begin
        unique case ({AXI4L_m2s_int.WValid, AXI4L_m2s_int.AWValid, AXI4L_m2s_int.ARValid})
          3'b000: ;
          3'b001: begin
            nextAddress = AXI4L_m2s_int.ARAddr[OCRAM_ADDRESS_BITS+ADDR_LSB-1:ADDR_LSB];
            nextState   = st_read_data_ack;
          end
          3'b010: begin
            nextAddress = AXI4L_m2s_int.AWAddr[OCRAM_ADDRESS_BITS+ADDR_LSB-1:ADDR_LSB];
            nextState   = st_await_write_data;
          end
          3'b011, 3'b101, 3'b111: begin
            if (PREFFERED_READ_ACCESS) begin
              nextAddress = AXI4L_m2s_int.ARAddr[OCRAM_ADDRESS_BITS+ADDR_LSB-1:ADDR_LSB];
              nextState   = st_read_data_ack;
            end else if ({AXI4L_m2s_int.WValid, AXI4L_m2s_int.AWValid, AXI4L_m2s_int.ARValid} == 3'b011) begin
              nextAddress = AXI4L_m2s_int.AWAddr[OCRAM_ADDRESS_BITS+ADDR_LSB-1:ADDR_LSB];
              nextState   = st_await_write_data;
            end else if ({AXI4L_m2s_int.WValid, AXI4L_m2s_int.AWValid, AXI4L_m2s_int.ARValid} == 3'b101) begin
              nextState = st_await_write_address;
            end else begin
              nextAddress = AXI4L_m2s_int.AWAddr[OCRAM_ADDRESS_BITS+ADDR_LSB-1:ADDR_LSB];
              nextState   = st_write_address_data;
            end
          end
          3'b100: nextState = st_await_write_address;
          3'b110: begin
            nextAddress = AXI4L_m2s_int.AWAddr[OCRAM_ADDRESS_BITS+ADDR_LSB-1:ADDR_LSB];
            nextState   = st_write_address_data;
          end
          default: nextState = st_error;
        endcase
      end

      st_await_write_address: begin
        if (AXI4L_m2s_int.AWValid) begin
          nextAddress = AXI4L_m2s_int.AWAddr[OCRAM_ADDRESS_BITS+ADDR_LSB-1:ADDR_LSB];
          nextState   = st_write_address_data;
        end
      end

      st_await_write_data: begin
        if (AXI4L_m2s_int.WValid) begin
          axi_awready       = 1'b1;
          axi_wready        = 1'b1;
          axi_bvalid        = 1'b1;
          OCRAM_WriteEnable = 1'b1;
          nextState         = AXI4L_m2s_int.BReady ? st_idle : st_write_response_wait;
        end
      end

      st_write_address_data: begin
        axi_awready       = 1'b1;
        axi_wready        = 1'b1;
        axi_bvalid        = 1'b1;
        OCRAM_WriteEnable = 1'b1;
        nextState         = AXI4L_m2s_int.BReady ? st_idle : st_write_response_wait;
      end

      st_read_data_ack: begin
        nextState = ADD_READ_DELAY ? st_read_response_wait_delay : st_read_response_wait;
      end

      st_read_response_wait_delay: begin
        axi_arready = 1'b1;
        nextState   = st_read_response_wait;
      end

      st_write_response_wait: begin
        axi_bvalid = 1'b1;
        if (AXI4L_m2s_int.BReady)
          nextState = st_idle;
      end

      st_read_response_wait: begin
        if (!ADD_READ_DELAY)
          axi_arready = 1'b1;
        axi_rvalid = 1'b1;
        if (AXI4L_m2s_int.RReady)
          nextState = st_idle;
      end

      st_error: nextState = st_idle;
      default: nextState = st_error;
    endcase
  end

endmodule
