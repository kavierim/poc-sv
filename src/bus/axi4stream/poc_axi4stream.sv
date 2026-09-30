// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273
// VHDL: PoC/src/bus/axi4stream/axi4stream.pkg.vhdl

`timescale 1ns/1ps

package poc_axi4stream;

  import poc_utils::div_ceil;
  import poc_utils::downto_width;

  class axi4stream_sized #(
    parameter int DATA_BITS     = 32,
    parameter int USER_BITS     = 1,
    parameter int DEST_BITS     = 1,
    parameter int ID_BITS       = 1,
    parameter int KEEP_BITS     = 0,
    parameter int REV_USER_BITS = 1
  );
    localparam int KEEP_W     = (KEEP_BITS > 0) ? KEEP_BITS : div_ceil(DATA_BITS, 8);
    localparam int REV_USER_W = downto_width(REV_USER_BITS);
    localparam int TOTAL_SER_W = DATA_BITS + 1 + USER_BITS + DEST_BITS + ID_BITS + KEEP_W;

    typedef struct packed {
      logic        Valid;
      logic [DATA_BITS-1:0] Data;
      logic [KEEP_W-1:0] Keep;
      logic        Last;
      logic [USER_BITS-1:0] User;
      logic [DEST_BITS-1:0] Dest;
      logic [ID_BITS-1:0] ID;
    } m2s_t;

    typedef struct packed {
      logic        Ready;
      logic [REV_USER_W-1:0] User;
    } s2m_t;

    typedef m2s_t m2s_vector_t[];
    typedef s2m_t s2m_vector_t[];

    typedef m2s_t T_axi4stream_M2S;
    typedef s2m_t T_axi4stream_S2M;
    typedef m2s_vector_t T_axi4stream_M2S_VECTOR;
    typedef s2m_vector_t T_axi4stream_S2M_VECTOR;

    typedef m2s_t Sized_M2S;
    typedef s2m_t Sized_S2M;
    typedef m2s_vector_t Sized_M2S_Vector;
    typedef s2m_vector_t Sized_S2M_Vector;

    static function automatic m2s_t initialize_m2s(input logic value = 1'b0);
      m2s_t init;
      init.Valid = value;
      init.Data  = {DATA_BITS{value}};
      init.Keep  = {KEEP_W{value}};
      init.Last  = value;
      init.Dest  = {DEST_BITS{value}};
      init.ID    = {ID_BITS{value}};
      init.User  = {USER_BITS{value}};
      return init;
    endfunction

    static function automatic s2m_t initialize_s2m(input logic value = 1'b0);
      s2m_t init;
      init.Ready = value;
      init.User  = {REV_USER_W{value}};
      return init;
    endfunction

    static function automatic m2s_t enable_transaction_m2s(input logic enable_transaction, input m2s_t in_m2s);
      m2s_t temp;
      temp       = in_m2s;
      temp.Valid = in_m2s.Valid & ~enable_transaction;
      return temp;
    endfunction

    static function automatic s2m_t enable_transaction_s2m(input logic enable_transaction, input s2m_t in_s2m);
      s2m_t temp;
      temp       = in_s2m;
      temp.Ready = in_s2m.Ready & ~enable_transaction;
      return temp;
    endfunction

    static function automatic int get_total_data_bits(input m2s_t in_m2s);
      return TOTAL_SER_W;
    endfunction

    static function automatic logic [TOTAL_SER_W-1:0] serialize(input m2s_t in_m2s);
      return {in_m2s.ID, in_m2s.Dest, in_m2s.User, in_m2s.Last, in_m2s.Keep, in_m2s.Data};
    endfunction

    static function automatic logic get_last_from_serialized(
      input logic [TOTAL_SER_W-1:0] serialized,
      input m2s_t                 in_m2s
    );
      if (TOTAL_SER_W != get_total_data_bits(in_m2s))
        $fatal(1, "axi4stream.get_LastFromSerialized: size mismatch");
      return serialized[DATA_BITS + KEEP_W];
    endfunction

    static function automatic logic [DATA_BITS-1:0] get_data_from_serialized(
      input logic [TOTAL_SER_W-1:0] serialized,
      input m2s_t                 in_m2s
    );
      if (TOTAL_SER_W != get_total_data_bits(in_m2s))
        $fatal(1, "axi4stream.get_DataFromSerialized: size mismatch");
      return serialized[DATA_BITS-1:0];
    endfunction

    static function automatic logic [KEEP_W-1:0] get_keep_from_serialized(
      input logic [TOTAL_SER_W-1:0] serialized,
      input m2s_t                 in_m2s
    );
      if (TOTAL_SER_W != get_total_data_bits(in_m2s))
        $fatal(1, "axi4stream.get_KeepFromSerialized: size mismatch");
      return serialized[DATA_BITS+KEEP_W-1:DATA_BITS];
    endfunction

    static function automatic logic [USER_BITS-1:0] get_user_from_serialized(
      input logic [TOTAL_SER_W-1:0] serialized,
      input m2s_t                 in_m2s
    );
      if (TOTAL_SER_W != get_total_data_bits(in_m2s))
        $fatal(1, "axi4stream.get_UserFromSerialized: size mismatch");
      return serialized[DATA_BITS+KEEP_W+USER_BITS:DATA_BITS+KEEP_W+1];
    endfunction

    static function automatic logic [DEST_BITS-1:0] get_dest_from_serialized(
      input logic [TOTAL_SER_W-1:0] serialized,
      input m2s_t                 in_m2s
    );
      if (TOTAL_SER_W != get_total_data_bits(in_m2s))
        $fatal(1, "axi4stream.get_DestFromSerialized: size mismatch");
      return serialized[DATA_BITS+KEEP_W+1+USER_BITS+DEST_BITS-1:DATA_BITS+KEEP_W+1+USER_BITS];
    endfunction

    static function automatic logic [ID_BITS-1:0] get_id_from_serialized(
      input logic [TOTAL_SER_W-1:0] serialized,
      input m2s_t                 in_m2s
    );
      if (TOTAL_SER_W != get_total_data_bits(in_m2s))
        $fatal(1, "axi4stream.get_IDFromSerialized: size mismatch");
      return serialized[TOTAL_SER_W-1:DATA_BITS+KEEP_W+1+USER_BITS+DEST_BITS];
    endfunction
  endclass

endpackage
