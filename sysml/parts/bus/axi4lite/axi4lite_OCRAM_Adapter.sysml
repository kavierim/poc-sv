// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.

package PoC_Bus_Axi4Lite_axi4lite_OCRAM_Adapter {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Types_Axi4Lite::*;
    private import PoC_Requirements_Bus::*;

    @ArtifactTrace {
        rtlPath = "src/bus/axi4lite/axi4lite_OCRAM_Adapter.sv";
        verifPath = "sim/bus/axi4lite/axi4lite_OCRAM_Adapter_tb.sv";
        fvPath = "";
    }
    part def axi4lite_OCRAM_Adapter {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute OCRAM_ADDRESS_BITS : Integer = 10;
        attribute OCRAM_DATA_BITS : Integer = 32;
        attribute PREFFERED_READ_ACCESS : Boolean = true;
        attribute INPUT_STAGES : Integer = 0;
        attribute ADD_READ_DELAY : Boolean = false;
        attribute ADDR_W : Integer = 32;
        attribute DATA_W : Integer = 32;

        in item Clock;
        in item Reset;
        in item AXI4Lite_m2s : axi4lite_m2s;
        out item AXI4Lite_s2m : axi4lite_s2m;
        out item OCRAM_Address;
        out item OCRAM_WriteEnable;
        out item OCRAM_ByteEnable;
        in item OCRAM_DataIn;
        out item OCRAM_DataOut;
        satisfy requirement REQ_axi4lite_OCRAM_Adapter_001;
        satisfy requirement REQ_axi4lite_OCRAM_Adapter_002;

    }

    part axi4lite_OCRAM_AdapterUse : axi4lite_OCRAM_Adapter;
}
