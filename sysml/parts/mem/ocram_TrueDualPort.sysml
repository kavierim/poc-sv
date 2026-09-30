// SPDX-FileCopyrightText: 2008-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Mem_ocram_TrueDualPort {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_SyncMem::*;

    @ArtifactTrace {
        rtlPath = "src/mem/ocram/ocram_TrueDualPort.sv";
        verifPath = "";
        fvPath = "";
    }
    part def ocram_TrueDualPort {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute ADDRESS_BITS : Integer = 8;
        attribute DATA_BITS : Integer = 8;
        attribute FILENAME : String = "";

        in item PortA_Clock;
        in item PortA_ClockEnable;
        in item PortA_WriteEnable;
        in item PortA_Address;
        attribute PortA_Address_sv : String = "logic [ADDRESS_BITS-1:0] PortA_Address";
        in item PortA_DataIn;
        attribute PortA_DataIn_sv : String = "logic [DATA_BITS-1:0] PortA_DataIn";
        out item PortA_DataOut;
        attribute PortA_DataOut_sv : String = "logic [DATA_BITS-1:0] PortA_DataOut";
        in item PortB_Clock;
        in item PortB_ClockEnable;
        in item PortB_WriteEnable;
        in item PortB_Address;
        attribute PortB_Address_sv : String = "logic [ADDRESS_BITS-1:0] PortB_Address";
        in item PortB_DataIn;
        attribute PortB_DataIn_sv : String = "logic [DATA_BITS-1:0] PortB_DataIn";
        out item PortB_DataOut;
        attribute PortB_DataOut_sv : String = "logic [DATA_BITS-1:0] PortB_DataOut";

        satisfy requirement REQ_ocram_TrueDualPort_001;
    }

    part ocram_TrueDualPortUse : ocram_TrueDualPort;
}
