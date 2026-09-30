// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.

package PoC_Bus_Axi4_axi4_Termination_Subordinate {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Types_Axi4::*;
    private import PoC_Requirements_Bus::*;

    @ArtifactTrace {
        rtlPath = "src/bus/axi4/axi4_Termination_Subordinate.sv";
        verifPath = "";
        fvPath = "";
    }
    part def axi4_Termination_Subordinate {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute ADDR_W : Integer = 32;
        attribute DATA_W : Integer = 32;
        attribute USER_W : Integer = 1;
        attribute ID_W : Integer = 1;
        attribute RESPONSE_CODE : String = "poc_axi4_common::C_AXI4_RESPONSE_SLAVE_ERROR";
        attribute m2s_t : String = "axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::bus_m2s_t";
        attribute s2m_t : String = "axi4_full_sized#(ADDR_W, DATA_W, USER_W, ID_W)::bus_s2m_t";

        in item Clock;
        in item Reset;
        in item AXI4_M2S : axi4_m2s;
        out item AXI4_S2M : axi4_s2m;
        satisfy requirement REQ_axi4_Termination_Subordinate_001;

    }

    part axi4_Termination_SubordinateUse : axi4_Termination_Subordinate;
}
