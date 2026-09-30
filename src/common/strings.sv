// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2015 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

package poc_strings;

  localparam byte C_POC_NUL = poc_config::C_POC_NUL;
  import poc_utils::div_ceil;
  import poc_utils::imax;
  import poc_utils::imin;
  import poc_utils::ipstyle_t;
  import poc_utils::IPSTYLE_HARD;
  import poc_utils::IPSTYLE_SOFT;
  import poc_utils::IPSTYLE_UNKNOWN;

  typedef logic [7:0] rawchar_t;
  typedef rawchar_t   rawstring_t[];

  function automatic int str_low(string str);
    if (str.len() > 0)
      return 0;
    return 0;
  endfunction

  function automatic string str_normalize(string str);
    return str;
  endfunction

  function automatic ipstyle_t to_ipstyle(string str);
    if (str_imatch(str, "IPSTYLE_HARD"))
      return IPSTYLE_HARD;
    if (str_imatch(str, "IPSTYLE_SOFT"))
      return IPSTYLE_SOFT;
    if (str_imatch(str, "HARD"))
      return IPSTYLE_HARD;
    if (str_imatch(str, "SOFT"))
      return IPSTYLE_SOFT;
`ifndef SYNTHESIS
    $fatal(1, "Unknown IPStyle: '%s'", str);
`endif
    return IPSTYLE_UNKNOWN;
  endfunction

  function automatic byte to_char_sl(input logic value);
    case (value)
      1'b0: return "0";
      1'b1: return "1";
      default: return "?";
    endcase
  endfunction

  function automatic byte to_char_raw(input rawchar_t rawchar);
    return rawchar;
  endfunction

  function automatic byte to_hex_char(input int value);
    string hex;
    hex = "0123456789ABCDEF";
    if (value < 16)
      return hex[value];
    return "X";
  endfunction

  function automatic bit chr_is_digit(input byte chr);
    return (chr >= "0" && chr <= "9");
  endfunction

  function automatic bit chr_is_lower_hex_digit(input byte chr);
    return (chr >= "a" && chr <= "f");
  endfunction

  function automatic bit chr_is_upper_hex_digit(input byte chr);
    return (chr >= "A" && chr <= "F");
  endfunction

  function automatic bit chr_is_hex_digit(input byte chr);
    return chr_is_digit(chr) || chr_is_lower_hex_digit(chr) || chr_is_upper_hex_digit(chr);
  endfunction

  function automatic bit chr_is_lower_alpha(input byte chr);
    return (chr >= "a" && chr <= "z");
  endfunction

  function automatic bit chr_is_upper_alpha(input byte chr);
    return (chr >= "A" && chr <= "Z");
  endfunction

  function automatic bit chr_is_alpha(input byte chr);
    return chr_is_lower_alpha(chr) || chr_is_upper_alpha(chr);
  endfunction

  function automatic string raw_format_bool_bin(input bit value);
    return value ? "1" : "0";
  endfunction

  // --- synthesis stubs / simulation string helpers ---
`ifdef SYNTHESIS
  function automatic string raw_format_bool_str(input bit value);
    return value ? "TRUE" : "FALSE";
  endfunction
  function automatic string raw_format_nat_dec(input int value);
    return "";
  endfunction
  function automatic string to_string_bool(input bit value);
    return raw_format_bool_str(value);
  endfunction
  function automatic string to_string_int(input int value, input int base = 10);
    return "";
  endfunction
  function automatic int str_length(string str);
    return 0;
  endfunction
  function automatic bit str_equal(string str1, string str2);
    return 1'b0;
  endfunction
  function automatic string str_to_lower(string str);
    return "";
  endfunction
  function automatic string str_to_upper(string str);
    return "";
  endfunction
  function automatic bit str_match(string str1, string str2);
    return 1'b0;
  endfunction
  function automatic bit str_imatch(string str1, string str2);
    return 1'b0;
  endfunction
  function automatic int str_pos(string str, input byte chr, input int start = 0);
    return -1;
  endfunction
  function automatic bit str_find(string str, input byte chr);
    return 1'b0;
  endfunction
  function automatic string str_trim(string str);
    return "";
  endfunction
  function automatic string normalize_path(string path);
    return "";
  endfunction
  function automatic string resize(string str, input int size, input byte fill_char = C_POC_NUL);
    return "";
  endfunction
  class slv_fmt #(parameter int W = 32);
    static function automatic string raw_format_slv_bin(input logic [W-1:0] slv);
      return "";
    endfunction
    static function automatic string raw_format_slv_hex(input logic [W-1:0] slv);
      return "";
    endfunction
  endclass
  class slv_to_str #(parameter int W = 32);
    static function automatic string to_string(
      input logic [W-1:0] slv,
      input byte          format = "h",
      input int           length = 0,
      input byte          fill   = "0"
    );
      return "";
    endfunction
  endclass
`else
  function automatic string raw_format_bool_str(input bit value);
    return value ? "TRUE" : "FALSE";
  endfunction

  class slv_fmt #(parameter int W = 32);
    static function automatic string raw_format_slv_bin(input logic [W-1:0] slv);
      string result;
      result = "";
      for (int j = W - 1; j >= 0; j--)
        result = {string'(to_char_sl(slv[j])), result};
      return result;
    endfunction

    static function automatic string raw_format_slv_hex(input logic [W-1:0] slv);
      string result;
      int    n_hex;
      n_hex = div_ceil(W, 4);
      result = "";
      for (int j = 0; j < n_hex; j++) begin
        logic [3:0] digit;
        int         lo;
        lo = j * 4;
        for (int k = 0; k < 4; k++) begin
          int bit_idx;
          bit_idx = lo + k;
          digit[k] = (bit_idx < W) ? slv[bit_idx] : 1'b0;
        end
        result = {string'(to_hex_char(int'(digit))), result};
      end
      return result;
    endfunction
  endclass

  function automatic string raw_format_nat_dec(input int value);
    return $sformatf("%0d", value);
  endfunction

  function automatic string to_string_bool(input bit value);
    return raw_format_bool_str(value);
  endfunction

  function automatic string to_string_int(input int value, input int base = 10);
    if (base == 10)
      return $sformatf("%0d", value);
`ifndef SYNTHESIS
    $fatal(1, "to_string integer base %0d not fully implemented", base);
`endif
    return "";
  endfunction

  class slv_to_str #(parameter int W = 32);
    static function automatic string to_string(
      input logic [W-1:0] slv,
      input byte          format = "h",
      input int           length = 0,
      input byte          fill   = "0"
    );
      string result;
      int    len;
      if (format == "b") begin
        result = slv_fmt#(W)::raw_format_slv_bin(slv);
        len    = W;
      end else if (format == "d") begin
        result = $sformatf("%0d", slv);
        len    = result.len();
      end else if (format == "h") begin
        result = slv_fmt#(W)::raw_format_slv_hex(slv);
        len    = div_ceil(W, 4);
      end else begin
`ifndef SYNTHESIS
        $fatal(1, "Unknown format character: %c", format);
`endif
      end
      if (length > 0 && length > len) begin
        string pad;
        pad = "";
        for (int i = 0; i < length - len; i++)
          pad = {pad, string'(fill)};
        return {pad, result};
      end
      return result;
    endfunction
  endclass

  function automatic rawchar_t to_raw_char(input byte char);
    return char;
  endfunction

  function automatic int to_digit_dec(input byte chr);
    if (chr_is_digit(chr))
      return int'(chr) - 48;
    return -1;
  endfunction

  function automatic int to_digit_hex(input byte chr);
    if (chr_is_digit(chr))
      return int'(chr) - 48;
    if (chr_is_lower_hex_digit(chr))
      return int'(chr) - 97 + 10;
    if (chr_is_upper_hex_digit(chr))
      return int'(chr) - 65 + 10;
    return -1;
  endfunction

  function automatic int to_natural_dec(string str);
    int result;
    int digit;
    result = 0;
    for (int i = 0; i < str.len(); i++) begin
      digit = to_digit_dec(str[i]);
      if (digit != -1)
        result = result * 10 + digit;
      else
        return -1;
    end
    return result;
  endfunction

  function automatic int to_natural_hex(string str);
    int result;
    int digit;
    result = 0;
    for (int i = 0; i < str.len(); i++) begin
      digit = to_digit_hex(str[i]);
      if (digit != -1)
        result = result * 16 + digit;
      else
        return -1;
    end
    return result;
  endfunction

  function automatic string resize(string str, input int size, input byte fill_char = C_POC_NUL);
    string result;
    int    n;
    result = "";
    n      = imin(size, str.len());
    for (int i = 0; i < size; i++) begin
      if (i < n)
        result = {result, string'(str[i])};
      else
        result = {result, string'(fill_char)};
    end
    return result;
  endfunction

  function automatic byte chr_to_lower(input byte chr);
    if (chr_is_upper_alpha(chr))
      return chr - "A" + "a";
    return chr;
  endfunction

  function automatic byte chr_to_upper(input byte chr);
    if (chr_is_lower_alpha(chr))
      return chr - "a" + "A";
    return chr;
  endfunction

  function automatic int str_length(string str);
    for (int i = 0; i < str.len(); i++)
      if (str[i] == C_POC_NUL)
        return i;
    return str.len();
  endfunction

  function automatic bit str_equal(string str1, string str2);
    return str1 == str2;
  endfunction

  function automatic string str_to_lower(string str);
    string result;
    result = str;
    for (int i = 0; i < result.len(); i++)
      result[i] = chr_to_lower(result[i]);
    return result;
  endfunction

  function automatic string str_to_upper(string str);
    string result;
    result = str;
    for (int i = 0; i < result.len(); i++)
      result[i] = chr_to_upper(result[i]);
    return result;
  endfunction

  function automatic bit str_match(string str1, string str2);
    int len;
    len = imin(str1.len(), str2.len());
    if (str1.len() == 0 && str2.len() == 0)
      return 1'b1;
    for (int i = 0; i < len; i++) begin
      if (str1[i] != str2[i])
        return 1'b0;
      if (str1[i] == C_POC_NUL && str2[i] == C_POC_NUL)
        return 1'b1;
    end
    if (str1.len() == len && str2.len() == len)
      return 1'b1;
    if (str1.len() > len && str1[len] == C_POC_NUL)
      return 1'b1;
    if (str2.len() > len && str2[len] == C_POC_NUL)
      return 1'b1;
    return 1'b0;
  endfunction

  function automatic bit str_imatch(string str1, string str2);
    return str_match(str_to_lower(str1), str_to_lower(str2));
  endfunction

  function automatic int str_pos(string str, input byte chr, input int start = 0);
    for (int i = imax(0, start); i < str.len(); i++) begin
      if (str[i] == C_POC_NUL)
        break;
      if (str[i] == chr)
        return i;
    end
    return -1;
  endfunction

  function automatic bit str_find(string str, input byte chr);
    return str_pos(str, chr) >= 0;
  endfunction

  function automatic string str_trim(string str);
    int len;
    len = str_length(str);
    if (len <= 0)
      return "";
    return str.substr(0, len - 1);
  endfunction

  function automatic string normalize_path(string path);
    return poc_config::normalize_path(path);
  endfunction

`endif

endpackage
