// SPDX-FileCopyrightText: 2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

// verilator lint_off MULTITOP
module dstruct_OutOfOrderBuffer #(
  parameter int DATA_BITS = 8,
  parameter int NUM_INDEX = 4
) (
  input  logic                            Clock,
  input  logic                            Reset,

  input  logic                            Put,
  input  logic [DATA_BITS-1:0]            DataIn,
  output logic                            Full,
  output logic [poc_utils::downto_width(poc_utils::log2ceilnz(NUM_INDEX))-1:0] IndexOut,

  input  logic                            Got,
  input  logic [poc_utils::downto_width(poc_utils::log2ceilnz(NUM_INDEX))-1:0] IndexIn,
  output logic [DATA_BITS-1:0]            DataOut,
  output logic                            Valid
);
  import poc_utils::*;

  localparam int INDEX_W = downto_width(log2ceilnz(NUM_INDEX));

  function automatic logic [NUM_INDEX-1:0] ooo_bin2onehot(logic [INDEX_W-1:0] idx);
    if (NUM_INDEX <= 1)
      return 1'b1;
    return logic'(1'b1 << idx);
  endfunction

  function automatic logic [NUM_INDEX-1:0] ooo_reverse(logic [NUM_INDEX-1:0] vec);
    logic [NUM_INDEX-1:0] r = '0;
    for (int i = 0; i < NUM_INDEX; i++)
      r[i] = vec[NUM_INDEX - 1 - i];
    return r;
  endfunction

  logic [NUM_INDEX-1:0]                IndexValid = '0;
  logic [DATA_BITS-1:0]                DataBuffer[0:NUM_INDEX-1];

  logic [INDEX_W-1:0] NextIndex    = '0;
  logic [INDEX_W-1:0] NextIndex_i;
  logic               full_i       = 1'b0;
  logic               full_next;

  function automatic logic [INDEX_W-1:0] get_next_Index(
    logic [NUM_INDEX-1:0] Used,
    logic [INDEX_W-1:0]   CurNext
  );
    for (int i = 0; i < NUM_INDEX; i++) begin
      if (!Used[i] && i != int'(CurNext))
        return INDEX_W'(i);
    end
    return '0;
  endfunction

  assign IndexOut  = NextIndex;
  assign Full      = full_i;

  always_comb begin
    logic [NUM_INDEX-1:0] valid_u;
    logic [NUM_INDEX-1:0] onehot_next;
    logic [NUM_INDEX-1:0] rev_onehot;
    for (int i = 0; i < NUM_INDEX; i++)
      valid_u[i] = IndexValid[i];
    onehot_next = ooo_bin2onehot(NextIndex);
    rev_onehot  = ooo_reverse(onehot_next);
    full_next   = ((valid_u | rev_onehot) == {NUM_INDEX{1'b1}});
  end

  assign NextIndex_i = get_next_Index(IndexValid, NextIndex);

  always_comb begin
    DataOut = '0;
    Valid   = 1'b0;
    if (int'(IndexIn) < NUM_INDEX) begin
      DataOut = DataBuffer[int'(IndexIn)];
      Valid   = IndexValid[int'(IndexIn)];
    end
  end

  always_ff @(posedge Clock) begin
    if (Reset) begin
      IndexValid <= '0;
      NextIndex  <= '0;
      full_i     <= 1'b0;
    end else begin
      if (!full_i && Put) begin
        IndexValid[int'(NextIndex)] <= 1'b1;
        DataBuffer[int'(NextIndex)] <= DataIn;
        NextIndex                  <= NextIndex_i;
        full_i                     <= full_next;
      end

      if (int'(IndexIn) < NUM_INDEX) begin
        if (Got && IndexValid[int'(IndexIn)]) begin
          IndexValid[int'(IndexIn)] <= 1'b0;
          full_i                    <= 1'b0;
          if (full_next)
            NextIndex <= IndexIn;
        end
      end
    end
  end

endmodule
