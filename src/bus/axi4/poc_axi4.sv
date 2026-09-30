// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273
// VHDL: PoC/src/bus/axi4/axi4.pkg.vhdl

`timescale 1ns/1ps

package poc_axi4;

  import poc_axi4_common::*;
  import poc_axi4_full::*;
  import poc_axi4lite::*;
  import poc_axi4stream::*;
  import poc_utils::*;

  class axi4_convert #(
    parameter int ADDR_W  = 32,
    parameter int DATA_W  = 32,
    parameter int ID_W    = 1,
    parameter int USER_W  = 1
  );
    localparam int FULL_WSTRB = div_ceil(DATA_W, 8);

    typedef axi4_full_types#(ADDR_W, DATA_W, USER_W, ID_W)::bus_m2s_t full_m2s_t;
    typedef axi4_full_types#(ADDR_W, DATA_W, USER_W, ID_W)::bus_s2m_t full_s2m_t;
    typedef axi4lite_types#(ADDR_W, DATA_W)::bus_m2s_t               lite_m2s_t;
    typedef axi4lite_types#(ADDR_W, DATA_W)::bus_s2m_t               lite_s2m_t;

    static function automatic logic [DATA_W-1:0] resize_data(
      input logic [DATA_W-1:0] v,
      input int                dst_w
    );
      logic [DATA_W-1:0] res = '0;
      int                cp  = imin(dst_w, DATA_W);
      for (int i = 0; i < cp; i++)
        res[i] = v[i];
      return res;
    endfunction

    static function automatic logic [FULL_WSTRB-1:0] resize_wstrb(
      input logic [FULL_WSTRB-1:0] v,
      input int                    dst_w
    );
      logic [FULL_WSTRB-1:0] res = '0;
      int                    cp  = imin(dst_w, FULL_WSTRB);
      for (int i = 0; i < cp; i++)
        res[i] = v[i];
      return res;
    endfunction

    static function automatic lite_m2s_t to_AXI4LITE_BUS_M2S(
      input full_m2s_t full,
      input int        databit = 0
    );
      int         databit_i;
      int         lite_wstrb;
      lite_m2s_t  temp;
      databit_i  = (databit == 0) ? DATA_W : databit;
      lite_wstrb = div_ceil(databit_i, 8);
      temp.AWValid = full.AWValid;
      temp.AWAddr  = full.AWAddr;
      temp.AWCache = full.AWCache;
      temp.AWProt  = full.AWProt;
      temp.WValid  = full.WValid;
      temp.WData   = resize_data(full.WData, databit_i);
      temp.WStrb   = resize_wstrb(full.WStrb, lite_wstrb);
      temp.BReady  = full.BReady;
      temp.ARValid = full.ARValid;
      temp.ARAddr  = full.ARAddr;
      temp.ARCache = full.ARCache;
      temp.ARProt  = full.ARProt;
      temp.RReady  = full.RReady;
      return temp;
    endfunction

    static function automatic lite_s2m_t to_AXI4LITE_BUS_S2M(
      input full_s2m_t full,
      input int        databit = 0
    );
      int         databit_i;
      lite_s2m_t  temp;
      databit_i = (databit == 0) ? DATA_W : databit;
      temp.WReady  = full.WReady;
      temp.BValid  = full.BValid;
      temp.BResp   = full.BResp;
      temp.ARReady = full.ARReady;
      temp.AWReady = full.AWReady;
      temp.RValid  = full.RValid;
      temp.RData   = resize_data(full.RData, databit_i);
      temp.RResp   = full.RResp;
      return temp;
    endfunction

    static function automatic full_m2s_t to_AXI4_BUS_M2S(
      input lite_m2s_t lite,
      input int        databit = 0,
      input int        id_bits = 1,
      input int        user_bits = 1
    );
      int         databit_i;
      int         size_val;
      full_m2s_t  temp;
      databit_i = (databit == 0) ? DATA_W : databit;
      size_val  = log2ceil((databit_i >= DATA_W) ? (DATA_W / 8) : (databit / 8));
      temp.AWAddr   = lite.AWAddr;
      temp.AWValid  = lite.AWValid;
      temp.WValid   = lite.WValid;
      temp.WLast    = 1'b1;
      temp.WData    = resize_data(lite.WData, databit_i);
      temp.WStrb    = resize_wstrb(lite.WStrb, div_ceil(databit_i, 8));
      temp.BReady   = lite.BReady;
      temp.ARValid  = lite.ARValid;
      temp.ARAddr   = lite.ARAddr;
      temp.RReady   = lite.RReady;
      temp.AWCache  = lite.AWCache;
      temp.AWProt   = lite.AWProt;
      temp.ARCache  = lite.ARCache;
      temp.ARProt   = lite.ARProt;
      temp.ARLen    = '0;
      temp.AWLen    = '0;
      temp.ARLock   = '0;
      temp.AWLock   = '0;
      temp.ARQOS    = '0;
      temp.ARRegion = '0;
      temp.AWQOS    = '0;
      temp.AWRegion = '0;
      temp.AWBurst  = C_AXI4_BURST_FIXED;
      temp.ARBurst  = C_AXI4_BURST_FIXED;
      temp.ARSize   = T_AXI4_Size'(size_val[2:0]);
      temp.AWSize   = T_AXI4_Size'(size_val[2:0]);
      temp.ARUser   = '0;
      temp.WUser    = '0;
      temp.AWUser   = '0;
      temp.AWID     = '0;
      temp.ARID     = '0;
      return temp;
    endfunction

    static function automatic full_s2m_t to_AXI4_BUS_S2M(
      input lite_s2m_t lite,
      input int        databit = 0,
      input int        id_bits = 1,
      input int        user_bits = 1
    );
      int         databit_i;
      full_s2m_t  temp;
      databit_i = (databit == 0) ? DATA_W : databit;
      temp.AWReady = lite.AWReady;
      temp.WReady  = lite.WReady;
      temp.BValid  = lite.BValid;
      temp.BResp   = lite.BResp;
      temp.ARReady = lite.ARReady;
      temp.RValid  = lite.RValid;
      temp.RData   = resize_data(lite.RData, databit_i);
      temp.RResp   = lite.RResp;
      temp.RLast   = 1'b1;
      temp.BID     = '0;
      temp.BUser   = '0;
      temp.RID     = '0;
      temp.RUser   = '0;
      return temp;
    endfunction
  endclass

endpackage
