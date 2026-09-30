// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273
// VHDL: PoC/src/bus/axi4/axi4_Full.pkg.vhdl

`timescale 1ns/1ps

package poc_axi4_full;

  import poc_axi4_common::*;
  import poc_utils::*;
  typedef enum logic [1:0] {
    AddressTranslateCmd_None,
    AddressTranslateCmd_Increase,
    AddressTranslateCmd_Decrease,
    AddressTranslateCmd_Hold
  } T_Address_Translate_Command;

  class vec_resize #(parameter int SRC_W, parameter int DST_W);
    static function automatic logic [DST_W-1:0] resize(input logic [SRC_W-1:0] v);
      logic [DST_W-1:0] res;
      int               cp;
      res = '0;
      cp  = imin(SRC_W, DST_W);
      for (int i = 0; i < cp; i++)
        res[i] = v[i];
      return res;
    endfunction
  endclass

  class axi4_full_sized #(
    parameter int ADDRESS_BITS = 32,
    parameter int DATA_BITS    = 32,
    parameter int USER_BITS    = 1,
    parameter int ID_BITS      = 1
  );
    localparam int WSTRB_W = div_ceil(DATA_BITS, 8);
    localparam int ID_W    = downto_width(ID_BITS);
    localparam int USER_W  = downto_width(USER_BITS);

    typedef struct packed {
      logic        AWReady;
      logic        WReady;
      logic        BValid;
      T_AXI4_Response BResp;
      logic [ID_W-1:0] BID;
      logic [USER_W-1:0] BUser;
      logic        ARReady;
      logic        RValid;
      logic [DATA_BITS-1:0] RData;
      T_AXI4_Response RResp;
      logic [ID_W-1:0] RID;
      logic        RLast;
      logic [USER_W-1:0] RUser;
    } bus_s2m_t;

    typedef struct packed {
      logic [ID_W-1:0] AWID;
      logic [ADDRESS_BITS-1:0] AWAddr;
      logic [7:0]  AWLen;
      T_AXI4_Size  AWSize;
      T_AXI4_Burst AWBurst;
      logic [0:0]  AWLock;
      T_AXI4_QoS   AWQOS;
      T_AXI4_Region AWRegion;
      logic [USER_W-1:0] AWUser;
      logic        AWValid;
      T_AXI4_Cache AWCache;
      T_AXI4_Protect AWProt;
      logic        WValid;
      logic        WLast;
      logic [USER_W-1:0] WUser;
      logic [DATA_BITS-1:0] WData;
      logic [WSTRB_W-1:0] WStrb;
      logic        BReady;
      logic        ARValid;
      logic [ADDRESS_BITS-1:0] ARAddr;
      T_AXI4_Cache ARCache;
      T_AXI4_Protect ARProt;
      logic [ID_W-1:0] ARID;
      logic [7:0]  ARLen;
      T_AXI4_Size  ARSize;
      T_AXI4_Burst ARBurst;
      logic [0:0]  ARLock;
      T_AXI4_QoS   ARQOS;
      T_AXI4_Region ARRegion;
      logic [USER_W-1:0] ARUser;
      logic        RReady;
    } bus_m2s_t;

    typedef struct packed {
      bus_m2s_t M2S;
      bus_s2m_t S2M;
    } bus_t;

    typedef bus_s2m_t bus_s2m_vector_t[];
    typedef bus_m2s_t bus_m2s_vector_t[];

    typedef bus_s2m_t T_AXI4_Bus_S2M;
    typedef bus_m2s_t T_AXI4_Bus_M2S;
    typedef bus_t     T_AXI4_Bus;
    typedef bus_s2m_vector_t T_AXI4_Bus_S2M_VECTOR;
    typedef bus_m2s_vector_t T_AXI4_Bus_M2S_VECTOR;

    typedef bus_m2s_t Sized_M2S;
    typedef bus_s2m_t Sized_S2M;
    typedef bus_m2s_vector_t Sized_M2S_Vector;
    typedef bus_s2m_vector_t Sized_S2M_Vector;

    static function automatic bus_m2s_t enable_transaction_m2s(input bus_m2s_t in_bus, input logic enable);
      bus_m2s_t temp;
      temp        = in_bus;
      temp.AWValid = in_bus.AWValid & enable;
      temp.WValid  = in_bus.WValid & enable;
      temp.BReady  = in_bus.BReady & enable;
      temp.ARValid = in_bus.ARValid & enable;
      temp.RReady  = in_bus.RReady & enable;
      return temp;
    endfunction

    static function automatic bus_s2m_t enable_transaction_s2m(input bus_s2m_t in_bus, input logic enable);
      bus_s2m_t temp;
      temp         = in_bus;
      temp.AWReady = in_bus.AWReady & enable;
      temp.WReady  = in_bus.WReady & enable;
      temp.BValid  = in_bus.BValid & enable;
      temp.ARReady = in_bus.ARReady & enable;
      temp.RValid  = in_bus.RValid & enable;
      return temp;
    endfunction

    static function automatic bus_m2s_t disable_write_m2s(input bus_m2s_t in_bus);
      bus_m2s_t temp;
      temp         = in_bus;
      temp.AWID     = '0;
      temp.AWAddr   = '0;
      temp.AWLen    = '0;
      temp.AWSize   = '0;
      temp.AWBurst  = '0;
      temp.AWLock   = '0;
      temp.AWQOS    = '0;
      temp.AWRegion = '0;
      temp.AWUser   = '0;
      temp.AWCache  = '0;
      temp.AWProt   = '0;
      temp.WUser    = '0;
      temp.WData    = '0;
      temp.WStrb    = '0;
      temp.BReady   = 1'b0;
      temp.AWValid  = 1'b0;
      temp.WValid   = 1'b0;
      temp.WLast    = 1'b0;
      return temp;
    endfunction

    static function automatic bus_m2s_t disable_read_m2s(input bus_m2s_t in_bus);
      bus_m2s_t temp;
      temp        = in_bus;
      temp.ARValid  = 1'b0;
      temp.ARAddr   = '0;
      temp.ARCache  = '0;
      temp.ARProt   = '0;
      temp.ARID     = '0;
      temp.ARLen    = '0;
      temp.ARSize   = '0;
      temp.ARBurst  = '0;
      temp.ARLock   = '0;
      temp.ARQOS    = '0;
      temp.ARRegion = '0;
      temp.ARUser   = '0;
      temp.RReady   = 1'b0;
      return temp;
    endfunction

    static function automatic bus_s2m_t disable_write_s2m(input bus_s2m_t in_bus);
      bus_s2m_t temp;
      temp         = in_bus;
      temp.AWReady = 1'b0;
      temp.WReady  = 1'b0;
      temp.BValid  = 1'b0;
      temp.BResp   = '0;
      temp.BID     = '0;
      temp.BUser   = '0;
      return temp;
    endfunction

    static function automatic bus_s2m_t disable_read_s2m(input bus_s2m_t in_bus);
      bus_s2m_t temp;
      temp        = in_bus;
      temp.ARReady = 1'b0;
      temp.RValid  = 1'b0;
      temp.RLast   = 1'b0;
      temp.RData   = '0;
      temp.RResp   = '0;
      temp.RID     = '0;
      temp.RUser   = '0;
      return temp;
    endfunction

    static function automatic bus_m2s_t address_translate_m2s(
      input bus_m2s_t            in_bus,
      input logic signed [ADDRESS_BITS-1:0] offset
    );
      bus_m2s_t temp;
      temp        = in_bus;
      temp.AWAddr = logic'(unsigned'(in_bus.AWAddr) + unsigned'(offset));
      temp.ARAddr = logic'(unsigned'(in_bus.ARAddr) + unsigned'(offset));
      return temp;
    endfunction

    static function automatic bus_m2s_t address_mask_bits_m2s(
      input bus_m2s_t in_bus,
      input int       address_bits
    );
      logic [ADDRESS_BITS-1:0] mask;
      bus_m2s_t                temp;
      temp = in_bus;
      mask = '0;
      for (int i = 0; i < address_bits; i++)
        mask[i] = 1'b1;
      temp.AWAddr = in_bus.AWAddr & mask;
      temp.ARAddr = in_bus.ARAddr & mask;
      return temp;
    endfunction

    static function automatic bus_m2s_t address_mask_m2s(
      input bus_m2s_t              in_bus,
      input logic [ADDRESS_BITS-1:0] mask
    );
      bus_m2s_t temp;
      temp        = in_bus;
      temp.AWAddr = in_bus.AWAddr & mask;
      temp.ARAddr = in_bus.ARAddr & mask;
      return temp;
    endfunction

    static function automatic logic [ADDRESS_BITS-1:0] resize_addr_field(
      input logic [ADDRESS_BITS-1:0] v,
      input int                      out_bits
    );
      logic [ADDRESS_BITS-1:0] res;
      res = '0;
      for (int i = 0; i < ADDRESS_BITS; i++)
        if (i < out_bits)
          res[i] = v[i];
      return res;
    endfunction

    static function automatic logic [ID_W-1:0] resize_id_field(
      input logic [ID_W-1:0] v,
      input int              out_bits
    );
      logic [ID_W-1:0] res;
      res = '0;
      // Avoid per-bit indexing when ID_W==1 (tool C++ codegen limitation).
      if (ID_W == 1) begin
        if (out_bits > 0)
          res = v;
      end else begin
        for (int i = 0; i < ID_W; i++)
          if (i < out_bits)
            res[i] = v[i];
      end
      return res;
    endfunction

    static function automatic bus_m2s_t address_resize_m2s(input bus_m2s_t in_bus, input int address_bits);
      bus_m2s_t temp;
      temp        = in_bus;
      temp.AWAddr = resize_addr_field(in_bus.AWAddr, address_bits);
      temp.ARAddr = resize_addr_field(in_bus.ARAddr, address_bits);
      return temp;
    endfunction

    static function automatic bus_m2s_t id_resize_m2s(
      input bus_m2s_t in_bus,
      input int       awid_bits,
      input int       arid_bits
    );
      bus_m2s_t temp;
      temp      = in_bus;
      temp.AWID = resize_id_field(in_bus.AWID, awid_bits);
      temp.ARID = resize_id_field(in_bus.ARID, arid_bits);
      return temp;
    endfunction

    static function automatic bus_s2m_t id_resize_s2m(
      input bus_s2m_t in_bus,
      input int       rid_bits,
      input int       bid_bits
    );
      bus_s2m_t temp;
      temp     = in_bus;
      temp.BID = resize_id_field(in_bus.BID, bid_bits);
      temp.RID = resize_id_field(in_bus.RID, rid_bits);
      return temp;
    endfunction

    static function automatic bus_m2s_t initialize_bus_m2s(input logic value = 1'b0);
      bus_m2s_t init;
      init.AWValid  = value;
      init.AWCache  = {4{value}};
      init.AWAddr   = {ADDRESS_BITS{value}};
      init.AWProt   = {3{value}};
      init.AWID     = {ID_W{value}};
      init.AWLen    = {8{value}};
      init.AWSize   = {3{value}};
      init.AWBurst  = {2{value}};
      init.AWLock   = {1{value}};
      init.AWQOS    = {4{value}};
      init.AWRegion = {4{value}};
      init.AWUser   = {USER_W{value}};
      init.WValid   = value;
      init.WData    = {DATA_BITS{value}};
      init.WStrb    = {WSTRB_W{value}};
      init.WLast    = value;
      init.WUser    = {USER_W{value}};
      init.BReady   = value;
      init.ARValid  = value;
      init.ARCache  = {4{value}};
      init.ARAddr   = {ADDRESS_BITS{value}};
      init.ARProt   = {3{value}};
      init.ARID     = {ID_W{value}};
      init.ARLen    = {8{value}};
      init.ARSize   = {3{value}};
      init.ARBurst  = {2{value}};
      init.ARLock   = {1{value}};
      init.ARQOS    = {4{value}};
      init.ARRegion = {4{value}};
      init.ARUser   = {USER_W{value}};
      init.RReady   = value;
      return init;
    endfunction

    static function automatic bus_s2m_t initialize_bus_s2m(input logic value = 1'b0);
      bus_s2m_t init;
      init.AWReady = value;
      init.WReady  = value;
      init.BValid  = value;
      init.BResp   = {2{value}};
      init.BID     = {ID_W{value}};
      init.BUser   = {USER_W{value}};
      init.ARReady = value;
      init.RValid  = value;
      init.RData   = {DATA_BITS{value}};
      init.RResp   = {2{value}};
      init.RID     = {ID_W{value}};
      init.RLast   = value;
      init.RUser   = {USER_W{value}};
      return init;
    endfunction

    static function automatic bus_t initialize_bus();
      bus_t init;
      init.M2S = initialize_bus_m2s();
      init.S2M = initialize_bus_s2m();
      return init;
    endfunction

    static function automatic bus_s2m_t connect_s2m_from_out(
      input bus_s2m_t out_s2m,
      input string    info_prefix = ""
    );
      bus_s2m_t in_s2m;
      in_s2m         = out_s2m;
      in_s2m.RUser   = out_s2m.RUser;
      in_s2m.BUser   = out_s2m.BUser;
      in_s2m.BID     = out_s2m.BID;
      in_s2m.RID     = out_s2m.RID;
      in_s2m.AWReady = out_s2m.AWReady;
      in_s2m.WReady  = out_s2m.WReady;
      in_s2m.BValid  = out_s2m.BValid;
      in_s2m.BResp   = out_s2m.BResp;
      in_s2m.ARReady = out_s2m.ARReady;
      in_s2m.RValid  = out_s2m.RValid;
      in_s2m.RData   = out_s2m.RData;
      in_s2m.RResp   = out_s2m.RResp;
      in_s2m.RLast   = out_s2m.RLast;
      if (info_prefix != "")
        info_prefix = info_prefix;
      return in_s2m;
    endfunction

    static function automatic bus_m2s_t connect_m2s_from_in(
      input bus_m2s_t in_m2s,
      input string    info_prefix = ""
    );
      bus_m2s_t out_m2s;
      out_m2s         = in_m2s;
      out_m2s.ARID    = in_m2s.ARID;
      out_m2s.AWID    = in_m2s.AWID;
      out_m2s.AWAddr  = in_m2s.AWAddr;
      out_m2s.ARAddr  = in_m2s.ARAddr;
      out_m2s.ARUser  = in_m2s.ARUser;
      out_m2s.AWUser  = in_m2s.AWUser;
      out_m2s.WUser   = in_m2s.WUser;
      if (info_prefix != "")
        info_prefix = info_prefix;
      return out_m2s;
    endfunction

  endclass

endpackage
