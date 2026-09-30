// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.

package PoC_Bus_Axi4_axi4_Mux {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Types_Axi4::*;
    private import PoC_Requirements_Bus::*;

    @ArtifactTrace {
        rtlPath = "src/bus/axi4/axi4_Mux.sv";
        verifPath = "sim/bus/axi4/axi4_Mux_tb.sv";
        fvPath = "";
    }
    part def axi4_Mux {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute PORTS : Integer = 2;
        attribute ADDR_W : Integer = 32;
        attribute DATA_W : Integer = 32;
        attribute USER_W : Integer = 1;
        attribute ID_W : Integer = 1;
        attribute PIPELINE_OUT : Integer = 0;
        attribute NUM_OUTSTANDING_READS : Integer = 0;
        attribute NUM_OUTSTANDING_WRITES : Integer = 0;
        attribute PIPELINE_IN : String = "'{default: 0}";
        attribute m2s_t : String = "axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::bus_m2s_t";
        attribute s2m_t : String = "axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::bus_s2m_t";

        in item Clock;
        in item Reset;
        in item In_M2S : axi4_m2s;
        out item In_S2M : axi4_s2m;
        out item Out_M2S : axi4_m2s;
        in item Out_S2M : axi4_s2m;
        satisfy requirement REQ_axi4_Mux_001;
        satisfy requirement REQ_axi4_Mux_002;
        satisfy requirement REQ_axi4_Mux_003;

    }

    part axi4_MuxUse : axi4_Mux;
}
