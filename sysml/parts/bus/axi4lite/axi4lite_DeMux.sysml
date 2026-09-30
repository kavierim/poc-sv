// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.

package PoC_Bus_Axi4Lite_axi4lite_DeMux {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Types_Axi4Lite::*;
    private import PoC_Requirements_Bus::*;

    @ArtifactTrace {
        rtlPath = "src/bus/axi4lite/axi4lite_DeMux.sv";
        verifPath = "sim/bus/axi4lite/axi4lite_DeMux_tb.sv";
        fvPath = "";
    }
    part def axi4lite_DeMux {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute NUM_PORTS : Integer = 1;
        attribute BASE_ADDRESS : String = "'{32'h0}";
        attribute BASE_ADDRESS_MASK : String = "'{32'hFFFF_FFFF}";
        attribute PIPELINE_IN : Integer = 0;
        attribute PIPELINE_OUT : String = "'{default: 0}";
        attribute ADDR_W : Integer = 32;
        attribute DATA_W : Integer = 32;
        attribute ID_W : Integer = 1;
        attribute USER_W : Integer = 1;

        in item Clock;
        in item Reset;
        in item In_M2S : axi4lite_m2s;
        out item In_S2M : axi4lite_s2m;
        out item Out_M2S : axi4lite_m2s;
        in item Out_S2M : axi4lite_s2m;
        satisfy requirement REQ_axi4lite_DeMux_001;
        satisfy requirement REQ_axi4lite_DeMux_002;
        satisfy requirement REQ_axi4lite_DeMux_003;
        satisfy requirement REQ_axi4lite_DeMux_004;

    }

    part axi4lite_DeMuxUse : axi4lite_DeMux;
}
