// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

package poc_vectors;

  import poc_config::C_POC_NUL;
  import poc_strings::slv_to_str;
  import poc_strings::str_trim;
  import poc_strings::to_char_sl;
  import poc_utils::div_ceil;

  typedef logic [1:0]  slv_2_t;
  typedef logic [3:0]  slv_4_t;
  typedef logic [7:0]  slv_8_t;
  typedef logic [15:0] slv_16_t;
  typedef logic [31:0] slv_32_t;
  typedef logic [63:0] slv_64_t;

  function automatic int low_len(input int lenvec[], input int index);
    int pos;
    pos = 0;
    for (int i = 0; i < index; i++)
      pos = pos + lenvec[i];
    return pos;
  endfunction

  function automatic int high_len(input int lenvec[], input int index);
    int pos;
    pos = 0;
    for (int i = 0; i <= index; i++)
      pos = pos + lenvec[i];
    return pos - 1;
  endfunction

  class vec_gen #(parameter int W = 8);
    static function automatic logic [W-1:0] gen_vector_const(input logic const_val);
      logic [W-1:0] slv;
      for (int i = 0; i < W; i++)
        slv[i] = const_val;
      return slv;
    endfunction
  endclass

  // VHDL T_SLM: use slm#(ROWS, COLS)::matrix_t for Verilator-friendly fixed shapes.
  class slm #(parameter int ROWS = 1, parameter int COLS = 1);
    typedef logic matrix_t[ROWS][COLS];

    static function automatic logic [ROWS*COLS-1:0] to_slv_flat(input matrix_t m);
      logic [ROWS*COLS-1:0] slv;
      for (int i = 0; i < ROWS; i++)
        for (int j = 0; j < COLS; j++)
          slv[i * COLS + j] = m[i][j];
      return slv;
    endfunction

    static function automatic matrix_t from_slv_flat(input logic [ROWS*COLS-1:0] slv);
      matrix_t m;
      for (int i = 0; i < ROWS; i++)
        for (int j = 0; j < COLS; j++)
          m[i][j] = slv[i * COLS + j];
      return m;
    endfunction

    static function automatic matrix_t slm_not(input matrix_t a);
      matrix_t res;
      for (int i = 0; i < ROWS; i++)
        for (int j = 0; j < COLS; j++)
          res[i][j] = ~a[i][j];
      return res;
    endfunction

    static function automatic matrix_t slm_and(input matrix_t a, input matrix_t b);
      matrix_t res;
      for (int i = 0; i < ROWS; i++)
        for (int j = 0; j < COLS; j++)
          res[i][j] = a[i][j] & b[i][j];
      return res;
    endfunction

    static function automatic logic [COLS-1:0] get_row(input matrix_t m, input int row_index);
      return m[row_index];
    endfunction
  endclass

  class slvv #(parameter int W = 8, parameter int N = 1);
    static function automatic logic [W*N-1:0] to_slv_flat(input logic [W-1:0] lanes[N]);
      logic [W*N-1:0] slv;
      for (int i = 0; i < N; i++)
        slv[((i + 1) * W) - 1 -: W] = lanes[i];
      return slv;
    endfunction
  endclass

  class slvv_fmt #(parameter int W = 8, parameter int N = 1);
    static function automatic string to_string(input logic [W-1:0] lanes[N], input byte sep = ":");
      string result;
      result = "";
      for (int i = 0; i < N; i++) begin
        if (i > 0 && sep != C_POC_NUL)
          result = {result, sep};
        result = {result, slv_to_str#(W)::to_string(lanes[i], "h")};
      end
      return result;
    endfunction
  endclass

  class slm_fmt #(parameter int ROWS = 1, parameter int COLS = 1);
    static function automatic string to_string(
      input slm#(ROWS, COLS)::matrix_t m,
      input int                    groups = 4,
      input byte                   format = "b"
    );
      string result;
      if (format != "b")
        return "Format not supported.";
      result = "\n";
      for (int i = 0; i < ROWS; i++) begin
        for (int j = 0; j < COLS; j++) begin
          result = {result, to_char_sl(m[i][j])};
          if (((j + 1) % groups) == 0)
            result = {result, " "};
        end
        result = {result, "\n"};
      end
      return str_trim(result);
    endfunction
  endclass

endpackage
