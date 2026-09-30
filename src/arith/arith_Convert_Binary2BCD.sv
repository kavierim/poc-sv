// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

/* verilator lint_off UNOPTFLAT */

module arith_Convert_Binary2BCD #(
  parameter int  BITS            = 8,
  parameter int  DIGITS          = 3,
  parameter int  RADIX           = 2,
  parameter bit  REGISTER_OUTPUT = 1'b0
) (
  input  logic               Clock,
  input  logic               Reset,
  input  logic               Start,
  output logic               Busy,
  input  logic [BITS-1:0]    Binary,
  input  logic               IsSigned,
  output poc_utils::bcd_t  BCDDigits [DIGITS],
  output logic               Sign
);
  import poc_utils::*;

  localparam int RADIX_BITS    = log2ceil(RADIX);
  localparam int BINARY_SHIFTS = div_ceil(BITS, RADIX_BITS);
  localparam int BINARY_BITS   = BINARY_SHIFTS * RADIX_BITS;

  function automatic logic [4:0] nextBCD(logic [4:0] Value);
    if (Value > 9)
      return {1'b1, Value[3:0] - 4'd10};
    return Value;
  endfunction

  logic                    Digit_Shift_rst;
  logic                    Digit_Shift_en;
  logic [RADIX_BITS-1:0]   Digit_Shift_in [DIGITS+1];
  logic                    Binary_en;
  logic                    Binary_rl;
  logic [BINARY_BITS-1:0]  Binary_d;
  logic                    Sign_d;
  logic [BINARY_SHIFTS:0]  DelayShifter;

  assign Busy            = ~DelayShifter[BINARY_SHIFTS];
  assign Binary_en       = Start;
  assign Binary_rl       = ~Start & ~DelayShifter[BINARY_SHIFTS];
  assign Digit_Shift_rst = Start;
  assign Digit_Shift_en  = ~Start & ~DelayShifter[BINARY_SHIFTS];
  assign Sign            = Sign_d;

  always_ff @(posedge Clock) begin
    if (Reset)
      Binary_d <= '0;
    else if (Binary_en) begin
      if (IsSigned && Binary[BITS-1]) begin
        Binary_d[BITS-1:0] <= (-$signed(Binary));
        Sign_d             <= 1'b1;
      end else begin
        Binary_d[BITS-1:0] <= Binary;
        Sign_d             <= 1'b0;
      end
      DelayShifter <= {1'b1, {BINARY_SHIFTS{1'b0}}};
    end else if (Binary_rl) begin
      DelayShifter <= {DelayShifter[BINARY_SHIFTS-1:0], DelayShifter[BINARY_SHIFTS]};
      Binary_d     <= {Binary_d[BINARY_BITS-RADIX_BITS-1:0],
                     Binary_d[BINARY_BITS-1:BINARY_BITS-RADIX_BITS]};
    end
  end

  assign Digit_Shift_in[0] = Binary_d[BINARY_BITS-1:BINARY_BITS-RADIX_BITS];

  for (genvar i = 0; i < DIGITS; i++) begin : genDigits
    logic [3:0]            Digit_nxt;
    logic [RADIX_BITS-1:0] digit_carry;
    logic [3:0]            Digit_d;
    always_comb begin
      logic [3+RADIX_BITS:0] Temp;
      Temp = {1'b0, Digit_d};
      for (int j = RADIX_BITS - 1; j >= 0; j--)
        Temp = nextBCD({Temp[3:0], Digit_Shift_in[i][j]});
      Digit_nxt   = Temp[3:0];
      digit_carry = Temp[3+RADIX_BITS:4];
    end

    assign Digit_Shift_in[i+1] = digit_carry;

    always_ff @(posedge Clock) begin
      if (Reset || Digit_Shift_rst)
        Digit_d <= 4'h0;
      else if (Digit_Shift_en)
        Digit_d <= Digit_nxt[3:0];
    end

    if (!REGISTER_OUTPUT) begin : unstableOutput
      assign BCDDigits[i] = Digit_d;
    end else begin : regOut
      bcd_t BCDDigits_d;
      always_ff @(posedge Clock)
        if (!Busy)
          BCDDigits_d <= Digit_d;
      assign BCDDigits[i] = BCDDigits_d;
    end
  end
endmodule

/* verilator lint_on UNOPTFLAT */
