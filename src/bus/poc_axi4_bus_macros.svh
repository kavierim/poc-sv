// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
//
// Ancillary include (not Covered Source). RTL is under Apache-2.0; see NOTICE.
//
// Width-parameterized PoC AXI record typedefs. Macro arguments must not contain commas.

`define POC_AXI4_FULL_BUS_M2S_T(td_name, addr_w, data_w, user_w, id_w) \
  typedef poc_axi4_full::axi4_full_types#(addr_w, data_w, user_w, id_w)::bus_m2s_t td_name

`define POC_AXI4_FULL_BUS_S2M_T(td_name, addr_w, data_w, user_w, id_w) \
  typedef poc_axi4_full::axi4_full_types#(addr_w, data_w, user_w, id_w)::bus_s2m_t td_name

`define POC_AXI4_FULL_BUS_T(td_name, addr_w, data_w, user_w, id_w) \
  typedef poc_axi4_full::axi4_full_types#(addr_w, data_w, user_w, id_w)::bus_t td_name

`define POC_AXI4LITE_BUS_M2S_T(td_name, addr_w, data_w) \
  typedef poc_axi4lite::axi4lite_types#(addr_w, data_w)::bus_m2s_t td_name

`define POC_AXI4LITE_BUS_S2M_T(td_name, addr_w, data_w) \
  typedef poc_axi4lite::axi4lite_types#(addr_w, data_w)::bus_s2m_t td_name

`define POC_AXI4LITE_BUS_T(td_name, addr_w, data_w) \
  typedef poc_axi4lite::axi4lite_types#(addr_w, data_w)::bus_t td_name

`define POC_AXI4STREAM_M2S_T(td_name, data_w, user_w, dest_w, id_w, keep_w) \
  typedef poc_axi4stream::axi4stream_types#(data_w, user_w, dest_w, id_w, keep_w)::m2s_t td_name

`define POC_AXI4STREAM_S2M_T(td_name, data_w, user_w, dest_w, id_w, keep_w, rev_user_w) \
  typedef poc_axi4stream::axi4stream_types#(data_w, user_w, dest_w, id_w, keep_w, rev_user_w)::s2m_t td_name
