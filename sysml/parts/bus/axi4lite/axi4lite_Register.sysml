// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.

package PoC_Bus_Axi4Lite_axi4lite_Register {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Types_Axi4Lite::*;
    private import PoC_Requirements_Bus::*;

    @ArtifactTrace {
        rtlPath = "src/bus/axi4lite/axi4lite_Register.sv";
        verifPath = "sim/bus/axi4lite/axi4lite_Register_tb.sv";
        fvPath = "";
    }
    part def axi4lite_Register {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute N_USER_CFG : Integer = 1;
        attribute ENABLE_INTERRUPT : Boolean = false;
        attribute N_IRQ_SLOTS : Integer = 0;
        attribute INTERRUPT_ENABLE_REGISTER_ADDRESS : String = "32'h0";
        attribute INTERRUPT_MATCH_REGISTER_ADDRESS : String = "32'h4";
        attribute INTERRUPT_IS_STROBE : Boolean = true;
        attribute INIT_ON_RESET : Boolean = true;
        attribute IGNORE_HIGH_ADDRESS : Boolean = true;
        attribute RESPONSE_ON_ERROR : String = "poc_axi4_common::C_AXI4_RESPONSE_DECODE_ERROR";
        attribute DISABLE_ADDRESS_CHECK : Boolean = false;
        attribute ADDR_W : Integer = 32;
        attribute DATA_W : Integer = 32;
        attribute SIM_READWRITE_CFG : Boolean = false;

        in item Clock;
        in item Reset;
        in item AXI4Lite_m2s : axi4lite_m2s;
        out item AXI4Lite_s2m : axi4lite_s2m;
        out item AXI4Lite_irq;
        out item RegisterFile_ReadPort;
        out item RegisterFile_ReadPort_hit;
        in item RegisterFile_WritePort;
        out item RegisterFile_WritePort_hit;
        in item RegisterFile_WritePort_strobe;
        satisfy requirement REQ_axi4lite_Register_001;
        satisfy requirement REQ_axi4lite_Register_002;

    }

    part axi4lite_RegisterUse : axi4lite_Register;
}
