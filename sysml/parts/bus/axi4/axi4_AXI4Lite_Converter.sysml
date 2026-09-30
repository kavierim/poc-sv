// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.

package PoC_Bus_Axi4_axi4_AXI4Lite_Converter {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Types_Axi4::*;
    private import PoC_Types_Axi4Lite::*;
    private import PoC_Requirements_Bus::*;

    @ArtifactTrace {
        rtlPath = "src/bus/axi4/axi4_AXI4Lite_Converter.sv";
        verifPath = "sim/bus/axi4/axi4_AXI4Lite_Converter_tb.sv";
        fvPath = "";
    }
    part def axi4_AXI4Lite_Converter {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute ADDR_W : Integer = 32;
        attribute DATA_W : Integer = 32;
        attribute USER_W : Integer = 1;
        attribute ID_W : Integer = 1;
        attribute LITE_ADDR_W : String = "ADDR_W";
        attribute LITE_DATA_W : String = "DATA_W";
        attribute RESPONSE_FIFO_DEPTH : Integer = 16;
        attribute full_m2s_t : String = "axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::bus_m2s_t";
        attribute full_s2m_t : String = "axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::bus_s2m_t";
        attribute lite_m2s_t : String = "axi4lite_sized#(LITE_ADDR_W, LITE_DATA_W)::bus_m2s_t";
        attribute lite_s2m_t : String = "axi4lite_sized#(LITE_ADDR_W, LITE_DATA_W)::bus_s2m_t";

        in item Clock;
        in item Reset;
        in item In_M2S : axi4_m2s;
        out item In_S2M : axi4_s2m;
        out item Out_M2S : axi4lite_m2s;
        in item Out_S2M : axi4lite_s2m;
        satisfy requirement REQ_axi4_AXI4Lite_Converter_001;
        satisfy requirement REQ_axi4_AXI4Lite_Converter_002;

    }

    part axi4_AXI4Lite_ConverterUse : axi4_AXI4Lite_Converter;
}
