// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

package poc_arith;
  import poc_utils::*;

  typedef enum logic [1:0] {
    AAM,
    CAI,
    CCA,
    PAI
  } t_adder_architecture_e;

  typedef enum logic [1:0] {
    DFLT,
    FIX,
    ASC,
    DESC
  } t_adder_blocking_scheme_e;

  typedef enum logic [1:0] {
    PLAIN,
    CCC,
    PPN_KS,
    PPN_BK
  } t_adder_carry_skip_scheme_e;

  function automatic int arith_DividerLatency(input int dividendBits, input int radixExponent);
    return (dividendBits + radixExponent - 1) / radixExponent;
  endfunction

  function automatic logic [167:0] arith_prbs_lfsr(input logic [167:0] value, int width);
    int taps[5];
    logic temp;
    case (width)
      3: taps = '{2, 0, 0, 0, 0};
      4: taps = '{3, 0, 0, 0, 0};
      5: taps = '{3, 0, 0, 0, 0};
      6: taps = '{5, 0, 0, 0, 0};
      7: taps = '{6, 0, 0, 0, 0};
      8: taps = '{6, 5, 4, 0, 0};
      9: taps = '{5, 0, 0, 0, 0};
      10: taps = '{7, 0, 0, 0, 0};
      11: taps = '{9, 0, 0, 0, 0};
      12: taps = '{6, 4, 1, 0, 0};
      13: taps = '{4, 3, 1, 0, 0};
      14: taps = '{5, 3, 1, 0, 0};
      15: taps = '{14, 0, 0, 0, 0};
      16: taps = '{15, 13, 4, 0, 0};
      17: taps = '{14, 0, 0, 0, 0};
      18: taps = '{11, 0, 0, 0, 0};
      19: taps = '{6, 2, 1, 0, 0};
      20: taps = '{17, 0, 0, 0, 0};
      21: taps = '{19, 0, 0, 0, 0};
      22: taps = '{21, 0, 0, 0, 0};
      23: taps = '{18, 0, 0, 0, 0};
      24: taps = '{23, 22, 17, 0, 0};
      25: taps = '{22, 0, 0, 0, 0};
      26: taps = '{6, 2, 1, 0, 0};
      27: taps = '{5, 2, 1, 0, 0};
      28: taps = '{25, 0, 0, 0, 0};
      29: taps = '{27, 0, 0, 0, 0};
      30: taps = '{6, 4, 1, 0, 0};
      31: taps = '{28, 0, 0, 0, 0};
      32: taps = '{22, 2, 1, 0, 0};
      33: taps = '{2, 0, 0, 0, 0};
      34: taps = '{27, 2, 1, 0, 0};
      35: taps = '{33, 0, 0, 0, 0};
      36: taps = '{25, 0, 0, 0, 0};
      37: taps = '{5, 4, 3, 2, 1};
      38: taps = '{6, 5, 1, 0, 0};
      39: taps = '{35, 0, 0, 0, 0};
      40: taps = '{38, 21, 19, 0, 0};
      41: taps = '{38, 0, 0, 0, 0};
      42: taps = '{41, 20, 19, 0, 0};
      43: taps = '{42, 38, 37, 0, 0};
      44: taps = '{43, 18, 17, 0, 0};
      45: taps = '{44, 42, 41, 0, 0};
      46: taps = '{45, 26, 25, 0, 0};
      47: taps = '{42, 0, 0, 0, 0};
      48: taps = '{47, 21, 20, 0, 0};
      49: taps = '{4, 0, 0, 0, 0};
      50: taps = '{49, 24, 23, 0, 0};
      51: taps = '{50, 36, 35, 0, 0};
      52: taps = '{49, 0, 0, 0, 0};
      53: taps = '{52, 38, 37, 0, 0};
      54: taps = '{53, 18, 17, 0, 0};
      55: taps = '{31, 0, 0, 0, 0};
      56: taps = '{55, 35, 34, 0, 0};
      57: taps = '{5, 0, 0, 0, 0};
      58: taps = '{39, 0, 0, 0, 0};
      59: taps = '{58, 38, 37, 0, 0};
      60: taps = '{59, 0, 0, 0, 0};
      61: taps = '{60, 46, 45, 0, 0};
      62: taps = '{61, 6, 5, 0, 0};
      63: taps = '{62, 0, 0, 0, 0};
      64: taps = '{63, 61, 60, 0, 0};
      65: taps = '{47, 0, 0, 0, 0};
      66: taps = '{65, 57, 56, 0, 0};
      67: taps = '{66, 58, 57, 0, 0};
      68: taps = '{59, 0, 0, 0, 0};
      69: taps = '{67, 42, 40, 0, 0};
      70: taps = '{69, 55, 54, 0, 0};
      71: taps = '{65, 0, 0, 0, 0};
      72: taps = '{66, 25, 19, 0, 0};
      73: taps = '{48, 0, 0, 0, 0};
      74: taps = '{73, 59, 58, 0, 0};
      75: taps = '{74, 65, 64, 0, 0};
      76: taps = '{75, 41, 40, 0, 0};
      77: taps = '{76, 47, 46, 0, 0};
      78: taps = '{77, 59, 58, 0, 0};
      79: taps = '{7, 0, 0, 0, 0};
      80: taps = '{79, 43, 42, 0, 0};
      81: taps = '{77, 0, 0, 0, 0};
      82: taps = '{79, 47, 44, 0, 0};
      83: taps = '{82, 38, 37, 0, 0};
      84: taps = '{71, 0, 0, 0, 0};
      85: taps = '{84, 58, 57, 0, 0};
      86: taps = '{85, 74, 73, 0, 0};
      87: taps = '{74, 0, 0, 0, 0};
      88: taps = '{87, 17, 16, 0, 0};
      89: taps = '{51, 0, 0, 0, 0};
      90: taps = '{89, 72, 71, 0, 0};
      91: taps = '{90, 8, 7, 0, 0};
      92: taps = '{91, 80, 79, 0, 0};
      93: taps = '{91, 0, 0, 0, 0};
      94: taps = '{73, 0, 0, 0, 0};
      95: taps = '{84, 0, 0, 0, 0};
      96: taps = '{94, 49, 47, 0, 0};
      97: taps = '{91, 0, 0, 0, 0};
      98: taps = '{87, 0, 0, 0, 0};
      99: taps = '{97, 54, 52, 0, 0};
      100: taps = '{63, 0, 0, 0, 0};
      101: taps = '{100, 95, 94, 0, 0};
      102: taps = '{101, 36, 35, 0, 0};
      103: taps = '{94, 0, 0, 0, 0};
      104: taps = '{103, 94, 93, 0, 0};
      105: taps = '{89, 0, 0, 0, 0};
      106: taps = '{91, 0, 0, 0, 0};
      107: taps = '{105, 44, 42, 0, 0};
      108: taps = '{77, 0, 0, 0, 0};
      109: taps = '{108, 103, 102, 0, 0};
      110: taps = '{109, 98, 97, 0, 0};
      111: taps = '{101, 0, 0, 0, 0};
      112: taps = '{110, 69, 67, 0, 0};
      113: taps = '{104, 0, 0, 0, 0};
      114: taps = '{113, 33, 32, 0, 0};
      115: taps = '{114, 101, 100, 0, 0};
      116: taps = '{115, 46, 45, 0, 0};
      117: taps = '{115, 99, 97, 0, 0};
      118: taps = '{85, 0, 0, 0, 0};
      119: taps = '{111, 0, 0, 0, 0};
      120: taps = '{113, 9, 2, 0, 0};
      121: taps = '{103, 0, 0, 0, 0};
      122: taps = '{121, 63, 62, 0, 0};
      123: taps = '{121, 0, 0, 0, 0};
      124: taps = '{87, 0, 0, 0, 0};
      125: taps = '{124, 18, 17, 0, 0};
      126: taps = '{125, 90, 89, 0, 0};
      127: taps = '{126, 0, 0, 0, 0};
      128: taps = '{126, 101, 99, 0, 0};
      129: taps = '{124, 0, 0, 0, 0};
      130: taps = '{127, 0, 0, 0, 0};
      131: taps = '{130, 84, 83, 0, 0};
      132: taps = '{103, 0, 0, 0, 0};
      133: taps = '{132, 82, 81, 0, 0};
      134: taps = '{77, 0, 0, 0, 0};
      135: taps = '{124, 0, 0, 0, 0};
      136: taps = '{135, 11, 10, 0, 0};
      137: taps = '{116, 0, 0, 0, 0};
      138: taps = '{137, 131, 130, 0, 0};
      139: taps = '{136, 134, 131, 0, 0};
      140: taps = '{111, 0, 0, 0, 0};
      141: taps = '{140, 110, 109, 0, 0};
      142: taps = '{121, 0, 0, 0, 0};
      143: taps = '{142, 123, 122, 0, 0};
      144: taps = '{143, 75, 74, 0, 0};
      145: taps = '{93, 0, 0, 0, 0};
      146: taps = '{145, 87, 86, 0, 0};
      147: taps = '{146, 110, 109, 0, 0};
      148: taps = '{121, 0, 0, 0, 0};
      149: taps = '{148, 40, 39, 0, 0};
      150: taps = '{97, 0, 0, 0, 0};
      151: taps = '{148, 0, 0, 0, 0};
      152: taps = '{151, 87, 86, 0, 0};
      153: taps = '{152, 0, 0, 0, 0};
      154: taps = '{152, 27, 25, 0, 0};
      155: taps = '{154, 124, 123, 0, 0};
      156: taps = '{155, 41, 40, 0, 0};
      157: taps = '{156, 131, 130, 0, 0};
      158: taps = '{157, 132, 131, 0, 0};
      159: taps = '{128, 0, 0, 0, 0};
      160: taps = '{159, 142, 141, 0, 0};
      161: taps = '{143, 0, 0, 0, 0};
      162: taps = '{161, 75, 74, 0, 0};
      163: taps = '{162, 104, 103, 0, 0};
      164: taps = '{163, 151, 150, 0, 0};
      165: taps = '{164, 135, 134, 0, 0};
      166: taps = '{165, 128, 127, 0, 0};
      167: taps = '{161, 0, 0, 0, 0};
      168: taps = '{166, 153, 151, 0, 0};
      default: begin
        $fatal(1, "arith_prbs_lfsr: width %0d not yet supported (3..168)", width);
        taps = '{default: 0};
      end
    endcase
    temp = value[width - 1];
    for (int i = 0; i < 5; i++) begin
      if (taps[i] > 0)
        temp = temp ~^ value[taps[i] - 1];
    end
    value[width - 1] = temp;
    for (int k = width; k < 168; k++)
      value[k] = 1'b0;
    return value;
  endfunction

endpackage
