// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

// verilator lint_off MULTITOP
module bus_Arbiter #(
  parameter string STRATEGY    = "RR",
  parameter int    PORTS       = 1,
  /* verilator lint_off UNUSEDPARAM */
  parameter int    WEIGHTS     = 1,
  /* verilator lint_on UNUSEDPARAM */
  parameter bit    OUTPUT_REG  = 1'b0
) (
  input  logic                    Clock,
  input  logic                    Reset,

  input  logic                    Arbitrate,
  input  logic [PORTS-1:0]        RequestVector,

  output logic                    Arbitrated,
  output logic [PORTS-1:0]        GrantVector,
  output logic [poc_utils::downto_width(poc_utils::log2ceilnz(PORTS))-1:0] GrantIndex
);
  import poc_utils::*;

  localparam int GRANT_IDX_W = downto_width(log2ceilnz(PORTS));

  if (STRATEGY == "RR") begin : gen_rr
    logic [PORTS-1:0] RequestLeft;
    logic [PORTS-1:0] SelectLeft;
    logic [PORTS-1:0] SelectRight;

    logic [PORTS-1:0] ChannelPointer_d   = 1;
    logic [PORTS-1:0] ChannelPointer_nxt;

    assign RequestLeft = (~((unsigned'(ChannelPointer_d) - 1) | unsigned'(ChannelPointer_d))) &
                         unsigned'(RequestVector);
    assign SelectLeft  = (unsigned'(~RequestLeft) + 1) & unsigned'(RequestLeft);
    assign SelectRight = (unsigned'(~RequestVector) + 1) & unsigned'(RequestVector);
    assign ChannelPointer_nxt = (RequestLeft == '0) ? SelectRight : SelectLeft;

    if (OUTPUT_REG) begin : gen_reg
      logic [GRANT_IDX_W-1:0] ChannelPointer_bin_d = '0;

      always_ff @(posedge Clock) begin
        Arbitrated <= 1'b0;
        if (Reset) begin
          ChannelPointer_d     <= 1;
          ChannelPointer_bin_d <= '0;
        end else if (Arbitrate) begin
          Arbitrated           <= 1'b1;
          ChannelPointer_d     <= ChannelPointer_nxt;
          ChannelPointer_bin_d <= poc_utils::bits#(PORTS)::onehot2bin(ChannelPointer_nxt);
        end
      end

      assign GrantVector = ChannelPointer_d;
      assign GrantIndex  = ChannelPointer_bin_d;
    end else begin : gen_comb
      always_ff @(posedge Clock) begin
        if (Reset)
          ChannelPointer_d <= 1;
        else if (Arbitrate)
          ChannelPointer_d <= ChannelPointer_nxt;
      end

      assign Arbitrated  = Arbitrate;
      assign GrantVector = ChannelPointer_nxt;
      assign GrantIndex  = poc_utils::bits#(PORTS)::onehot2bin(ChannelPointer_nxt);
    end
  end else begin : gen_unsupported
`ifndef SYNTHESIS
    initial $fatal(1, "PoC.bus_Arbiter: strategy '%s' not implemented", STRATEGY);
`endif
  end

endmodule
