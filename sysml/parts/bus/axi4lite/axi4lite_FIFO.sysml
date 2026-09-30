// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.

package PoC_Bus_Axi4Lite_axi4lite_FIFO {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Types_Axi4Lite::*;
    private import PoC_Requirements_Bus::*;

    @ArtifactTrace {
        rtlPath = "src/bus/axi4lite/axi4lite_FIFO.sv";
        verifPath = "sim/bus/axi4lite/axi4lite_FIFO_tb.sv";
        fvPath = "";
    }
    part def axi4lite_FIFO {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute TRANSACTIONS : Integer = 2;
        attribute ADDR_W : Integer = 32;
        attribute DATA_W : Integer = 32;

        in item Clock;
        in item Reset;
        in item In_M2S : axi4lite_m2s;
        out item In_S2M : axi4lite_s2m;
        out item Out_M2S : axi4lite_m2s;
        in item Out_S2M : axi4lite_s2m;
        satisfy requirement REQ_axi4lite_FIFO_001;
        satisfy requirement REQ_axi4lite_FIFO_002;
        satisfy requirement REQ_axi4lite_FIFO_003;

    }

    part axi4lite_FIFOUse : axi4lite_FIFO;
}
