// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

package poc_utils;

  localparam bit SIMULATION =
`ifdef VERILATOR
      1'b1;
`else
      1'b0;
`endif

  localparam int INTEGER_BITS = 32;

  typedef int natural_vector[];
  typedef int positive_vector[];

  typedef enum logic [1:0] {
    IPSTYLE_UNKNOWN,
    IPSTYLE_HARD,
    IPSTYLE_SOFT
  } ipstyle_t;

  typedef enum logic {
    LSB_FIRST,
    MSB_FIRST
  } bit_order_t;

  typedef enum logic {
    LITTLE_ENDIAN,
    BIG_ENDIAN
  } byte_order_t;

  typedef enum logic {
    HIGH_ACTIVE,
    LOW_ACTIVE
  } polarity_t;

  typedef enum logic {
    RISING_EDGE,
    FALLING_EDGE
  } clock_edge_t;

  typedef enum logic [2:0] {
    ROUND_TO_NEAREST,
    ROUND_TO_ZERO,
    ROUND_TO_INF,
    ROUND_UP,
    ROUND_DOWN
  } rounding_style_t;

  typedef logic [3:0] bcd_t;
  typedef bcd_t bcd_vector[];

  localparam bcd_t C_BCD_MINUS = 4'b1010;
  localparam bcd_t C_BCD_OFF   = 4'b1011;

  function automatic bcd_t bcd_minus();
    return C_BCD_MINUS;
  endfunction

  function automatic bcd_t bcd_off();
    return C_BCD_OFF;
  endfunction

  function automatic int div_ceil(input int a, input int b);
    if (b <= 0)
      return 0;
    return (a + (b - 1)) / b;
  endfunction

  function automatic int downto_width(input int n);
    if (n < 1)
      return 1;
    return n;
  endfunction

  function automatic int imin(input int arg1, input int arg2);
    if (arg1 < arg2)
      return arg1;
    return arg2;
  endfunction

  function automatic int imax(input int arg1, input int arg2);
    if (arg1 > arg2)
      return arg1;
    return arg2;
  endfunction

  function automatic int log2ceil(input int arg);
    int unsigned uarg;
    int          v_tmp;
    int          v_log;
    if (arg < 1)
      return 0;
    uarg  = arg;
    v_tmp = 1;
    v_log = 0;
    for (int i = 0; i < INTEGER_BITS - 1; i++) begin
      if (uarg <= v_tmp)
        return v_log;
      v_tmp = v_tmp << 1;
      v_log = v_log + 1;
    end
    return INTEGER_BITS - 1;
  endfunction

  function automatic int log2ceilnz(input int arg);
    return imax(1, log2ceil(arg));
  endfunction

  function automatic int log10ceil(input int arg);
    int tmp;
    int log;
    if (arg < 1)
      return 0;
    tmp = 10;
    log = 1;
    if (arg == 1)
      return 0;
    while (arg > tmp) begin
      tmp = tmp * 10;
      log = log + 1;
    end
    return log;
  endfunction

  function automatic int log10ceilnz(input int arg);
    if (arg == 0)
      return 1;
    return imax(1, log10ceil(arg));
  endfunction

  function automatic bit is_pow2(input int int_val);
    return ceil_pow2(int_val) == int_val;
  endfunction

  function automatic int ceil_pow2(input int int_val);
    if (int_val < 1)
      return 1;
    return 1 << log2ceil(int_val);
  endfunction

  function automatic int floor_pow2(input int int_val);
    logic [30:0] temp;
    if (int_val < 1)
      return 0;
    temp = int_val[30:0];
    for (int i = 30; i >= 0; i--) begin
      if (temp[i])
        return 1 << i;
    end
    return 0;
  endfunction

  function automatic int minimum(input int a, input int b);
    return imin(a, b);
  endfunction

  function automatic int maximum(input int a, input int b);
    return imax(a, b);
  endfunction

  function automatic bit ite_b(input bit cond, input bit v1, input bit v2);
    if (cond)
      return v1;
    return v2;
  endfunction

  function automatic int ite_i(input bit cond, input int v1, input int v2);
    if (cond)
      return v1;
    return v2;
  endfunction

  function automatic real ite_r(input bit cond, input real v1, input real v2);
    if (cond)
      return v1;
    return v2;
  endfunction

  function automatic logic ite_sl(input bit cond, input logic v1, input logic v2);
    if (cond)
      return v1;
    return v2;
  endfunction

  function automatic string ite_str(input bit cond, input string v1, input string v2);
    if (cond)
      return v1;
    return v2;
  endfunction

  function automatic byte ite_ch(input bit cond, input byte v1, input byte v2);
    if (cond)
      return v1;
    return v2;
  endfunction

  function automatic int inc_if(input bit cond, input int value, input int increment = 1);
    if (cond)
      return value + increment;
    return value;
  endfunction

  function automatic int dec_if(input bit cond, input int value, input int decrement = 1);
    if (cond)
      return value - decrement;
    return value;
  endfunction

  function automatic int imin_vec(input int vec[]);
    int result;
    if (vec.size() == 0)
      return 0;
    result = vec[0];
    for (int i = 1; i < vec.size(); i++)
      if (vec[i] < result)
        result = vec[i];
    return result;
  endfunction

  function automatic int imax_vec(input int vec[]);
    int result;
    if (vec.size() == 0)
      return 0;
    result = vec[0];
    for (int i = 1; i < vec.size(); i++)
      if (vec[i] > result)
        result = vec[i];
    return result;
  endfunction

  function automatic int isum_vec(input int vec[]);
    int result;
    result = 0;
    for (int i = 0; i < vec.size(); i++)
      result = result + vec[i];
    return result;
  endfunction

  function automatic int indexof_int(input int vec[], input int comp, input int false_num = -1);
    for (int i = 0; i < vec.size(); i++)
      if (vec[i] == comp)
        return i;
    return false_num;
  endfunction

  function automatic int to_int_b(input bit bool, input int zero = 0, input int one = 1);
    return ite_i(bool, one, zero);
  endfunction

  function automatic int to_int_sl(input logic sl, input int zero = 0, input int one = 1);
    if (sl === 1'b1)
      return one;
    return zero;
  endfunction

  function automatic logic to_sl_b(input bit value);
    return value;
  endfunction

  function automatic logic to_sl_ch(input byte value);
    case (value)
      "U": return 1'bx;
      "0": return 1'b0;
      "1": return 1'b1;
      "Z": return 1'bz;
      "W": return 1'b0;
      "L": return 1'b0;
      "H": return 1'b1;
      "-": return 1'b0;
      default: return 1'bx;
    endcase
  endfunction

  function automatic bcd_t to_bcd_i(input int digit);
    return bcd_t'(digit & 15);
  endfunction

  function automatic bcd_t to_bcd_ch(input byte digit);
    return to_bcd_i(int'(digit) - 48);
  endfunction

  function automatic int bound(input int index, input int lower_bound, input int upper_bound);
    if (index < lower_bound)
      return lower_bound;
    if (upper_bound < index)
      return upper_bound;
    return index;
  endfunction

  function automatic bit is_sl(input byte c);
    case (c)
      "U", "X", "0", "1", "Z", "W", "L", "H", "-": return 1'b1;
      default: return 1'b0;
    endcase
  endfunction

  class bits #(parameter int W_REQ = 1);
    localparam int W = (W_REQ < 1) ? 1 : W_REQ;

    static function automatic logic [W-1:0] to_slv_nat(input int value);
      logic [W-1:0] res;
      res = '0;
      for (int i = 0; i < W; i++)
        res[i] = value[i];
      return res;
    endfunction

    static function automatic int to_index(input logic [W-1:0] slv, input int max = 0);
      int res;
      res = int'(unsigned'(slv));
      if (SIMULATION && max > 0)
        res = imin(res, max);
      return res;
    endfunction

    static function automatic logic slv_or(input logic [W-1:0] vec);
      return |vec;
    endfunction

    static function automatic logic slv_nor(input logic [W-1:0] vec);
      return ~(|vec);
    endfunction

    static function automatic logic slv_and(input logic [W-1:0] vec);
      return &vec;
    endfunction

    static function automatic logic slv_nand(input logic [W-1:0] vec);
      return ~(&vec);
    endfunction

    static function automatic logic slv_xor(input logic [W-1:0] vec);
      return ^vec;
    endfunction

    static function automatic int hamming_weight(input logic [W-1:0] v);
      return int'($countones(v));
    endfunction

    static function automatic logic [W-1:0] reverse(input logic [W-1:0] vec);
      logic [W-1:0] res;
      for (int i = 0; i < W; i++)
        res[i] = vec[W - 1 - i];
      return res;
    endfunction

    static function automatic logic [W-1:0] resize_vec(
      input logic [W-1:0] vec,
      input int           length,
      input logic         fill = 1'b0
    );
      logic [W-1:0] res;
      int           hi;
      int           cp;
      hi = imin(W, length) - 1;
      if (hi < 0)
        return '0;
      res = {W{fill}};
      cp  = imin(W - 1, hi);
      for (int i = 0; i <= cp; i++)
        res[i] = vec[i];
      return res;
    endfunction

    static function automatic logic [W-1:0] movez(input logic [W-1:0] vec);
      return vec;
    endfunction

    static function automatic logic [W-1:0] descend(input logic [W-1:0] vec);
      return vec;
    endfunction

    static function automatic logic [W-1:0] lssb(input logic [W-1:0] arg);
      logic [W-1:0] temp;
      temp = '0;
      for (int i = 0; i < W; i++) begin
        if (arg[i] === 1'b1) begin
          temp[i] = 1'b1;
          break;
        end
      end
      return temp;
    endfunction

    static function automatic logic [W-1:0] mssb(input logic [W-1:0] arg);
      logic [W-1:0] temp;
      temp = '0;
      for (int i = W - 1; i >= 0; i--) begin
        if (arg[i] === 1'b1) begin
          temp[i] = 1'b1;
          break;
        end
      end
      return temp;
    endfunction

    static function automatic int lssb_idx(input logic [W-1:0] arg);
      for (int i = 0; i < W; i++)
        if (arg[i] === 1'b1)
          return i;
      return 0;
    endfunction

    static function automatic int mssb_idx(input logic [W-1:0] arg);
      for (int i = W - 1; i >= 0; i--)
        if (arg[i] === 1'b1)
          return i;
      return W - 1;
    endfunction

    static function automatic logic [W-1:0] swap(input logic [W-1:0] slv, input int size);
      logic [W-1:0] result;
      int           seg_cnt;
      if (size < 1)
        return slv;
      seg_cnt = W / size;
      result  = '0;
      for (int i = 0; i < seg_cnt; i++) begin
        int from_l;
        int to_l;
        from_l = i * size;
        to_l   = (seg_cnt - i - 1) * size;
        for (int b = 0; b < size; b++)
          result[to_l + b] = slv[from_l + b];
      end
      return result;
    endfunction

    static function automatic logic [W-1:0] genmask_high(input int n_mask_bits, input int mask_length);
      logic [W-1:0] res;
      int           hi;
      int           use_len;
      use_len = imin(W, mask_length);
      hi      = use_len - 1;
      if (n_mask_bits == 0)
        return '0;
      res = '0;
      for (int i = 0; i < n_mask_bits && i < use_len; i++)
        res[hi - i] = 1'b1;
      return res;
    endfunction

    static function automatic logic [W-1:0] genmask_low(input int n_mask_bits, input int mask_length);
      logic [W-1:0] res;
      int           use_len;
      use_len = imin(W, mask_length);
      if (n_mask_bits == 0)
        return '0;
      res = '0;
      for (int i = 0; i < n_mask_bits && i < use_len; i++)
        res[i] = 1'b1;
      return res;
    endfunction

    static function automatic logic [W-1:0] genmask_alternate(input int len, input logic lsb = 1'b0);
      logic [W-1:0] res;
      logic         curr;
      int           use_len;
      use_len = imin(W, len);
      curr    = lsb;
      res     = '0;
      for (int i = 0; i < use_len; i++) begin
        res[i] = curr;
        curr   = ~curr;
      end
      return res;
    endfunction

    static function automatic logic [W-1:0] gray2bin(input logic [W-1:0] gray_val);
      logic [W:0] tmp;
      logic [W-1:0] res;
      tmp[W] = 1'b0;
      tmp[W-1:0] = gray_val;
      for (int i = W - 1; i >= 0; i--)
        tmp[i] = tmp[i + 1] ^ tmp[i];
      res = tmp[W-1:0];
      return res;
    endfunction

    static function automatic logic [W-1:0] bin2gray(input logic [W-1:0] value);
      return value ^ (value >> 1);
    endfunction

    static function automatic logic [W-1:0] bin2onehot(input logic [W-1:0] binary, input int out_width = 0);
      logic [W-1:0] result;
      int           idx;
      int           ow;
      idx    = int'(unsigned'(binary));
      result = '0;
      if (idx < W)
        result[idx] = 1'b1;
      ow = (out_width == 0) ? W : imin(out_width, W);
      for (int i = ow; i < W; i++)
        result[i] = 1'b0;
      return result;
    endfunction

    static function automatic logic [W-1:0] bin2onecold(input logic [W-1:0] value);
      return ~bin2onehot(value);
    endfunction

    static function automatic logic [W-1:0] onehot2bin(input logic [W-1:0] onehot, input int empty_val = -1);
      logic [W-1:0] res;
      int           chk;
      res = '0;
      if (empty_val > 0 && onehot == '0)
        return empty_val[W-1:0];
      chk = 0;
      for (int i = 0; i < W; i++) begin
        if (onehot[i] === 1'b1) begin
          res = res | W'(i);
          chk = chk + 1;
        end
      end
      if (SIMULATION && chk != 1 && (chk > 1 || empty_val < 0))
        res = 'x;
      return res;
    endfunction

    static function automatic logic [W-1:0] if_sel(
      input bit           cond,
      input logic [W-1:0] pos_case,
      input logic [W-1:0] neg_case
    );
      if (cond)
        return pos_case;
      return neg_case;
    endfunction
  endclass

  function automatic int scale_int(
    input int              value,
    input int              min_val,
    input int              max_val,
    input rounding_style_t rounding_style = ROUND_TO_NEAREST
  );
    real result;
    if (max_val < min_val)
      return 0;
    result = real'(value) * ((real'(max_val) + 0.5) - (real'(min_val) - 0.5)) + (real'(min_val) - 0.5);
    case (rounding_style)
      ROUND_TO_NEAREST: return int'($rtoi(result));
      ROUND_UP: return int'($ceil(result));
      ROUND_DOWN: return int'($floor(result));
      default: return 0;
    endcase
  endfunction

  function automatic bit_order_t bit_order_not(input bit_order_t left);
    return bit_order_t'(~(left));
  endfunction

  function automatic byte_order_t byte_order_not(input byte_order_t left);
    return byte_order_t'(~(left));
  endfunction

  function automatic polarity_t polarity_not(input polarity_t left);
    return polarity_t'(~(left));
  endfunction

  function automatic clock_edge_t clock_edge_not(input clock_edge_t left);
    return clock_edge_t'(~(left));
  endfunction

  function automatic logic polarity_xor_sl(input polarity_t left, input logic right);
    if (left == HIGH_ACTIVE)
      return right;
    return ~right;
  endfunction

endpackage
