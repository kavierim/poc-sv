// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.

package PoC_Bus_Axi4Lite_axi4lite_Termination_Subordinate {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Types_Axi4Lite::*;
    private import PoC_Requirements_Bus::*;

    @ArtifactTrace {
        rtlPath = "src/bus/axi4lite/axi4lite_Termination_Subordinate.sv";
        verifPath = "";
        fvPath = "";
    }
    part def axi4lite_Termination_Subordinate {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute ADDR_W : Integer = 32;
        attribute DATA_W : Integer = 32;
        attribute RESPONSE_CODE : String = "poc_axi4_common::C_AXI4_RESPONSE_SLAVE_ERROR";

        in item Clock;
        in item Reset;
        in item AXI4Lite_M2S : axi4lite_m2s;
        out item AXI4Lite_S2M : axi4lite_s2m;
        satisfy requirement REQ_axi4lite_Termination_Subordinate_001;

    }

    part axi4lite_Termination_SubordinateUse : axi4lite_Termination_Subordinate;
}
