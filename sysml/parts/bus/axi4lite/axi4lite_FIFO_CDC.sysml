// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.

package PoC_Bus_Axi4Lite_axi4lite_FIFO_CDC {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Types_Axi4Lite::*;
    private import PoC_Requirements_Bus::*;

    @ArtifactTrace {
        rtlPath = "src/bus/axi4lite/axi4lite_FIFO_CDC.sv";
        verifPath = "sim/bus/axi4lite/axi4lite_FIFO_CDC_tb.sv";
        fvPath = "";
    }
    part def axi4lite_FIFO_CDC {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute TRANSACTIONS : Integer = 2;
        attribute DATA_REG : Boolean = false;
        attribute OUTPUT_REG : Boolean = false;
        attribute ADDR_W : Integer = 32;
        attribute DATA_W : Integer = 32;

        in item In_Clock;
        in item In_Reset;
        in item In_M2S : axi4lite_m2s;
        out item In_S2M : axi4lite_s2m;
        in item Out_Clock;
        in item Out_Reset;
        out item Out_M2S : axi4lite_m2s;
        in item Out_S2M : axi4lite_s2m;
        satisfy requirement REQ_axi4lite_FIFO_CDC_001;
        satisfy requirement REQ_axi4lite_FIFO_CDC_002;
        satisfy requirement REQ_axi4lite_FIFO_CDC_003;
        satisfy requirement REQ_axi4lite_FIFO_CDC_004;

    }

    part axi4lite_FIFO_CDCUse : axi4lite_FIFO_CDC;
}
