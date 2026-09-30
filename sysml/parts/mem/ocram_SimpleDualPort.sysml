// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2008-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Mem_ocram_SimpleDualPort {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_SyncMem::*;

    @ArtifactTrace {
        rtlPath = "src/mem/ocram/ocram_SimpleDualPort.sv";
        verifPath = "sim/mem/ocram_SimpleDualPort_tb.sv";
        fvPath = "";
    }
    part def ocram_SimpleDualPort {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute RAM_TYPE : String = "poc_mem::RAM_TYPE_AUTO";
        attribute ADDRESS_BITS : Integer = 8;
        attribute DATA_BITS : Integer = 8;
        attribute FILENAME : String = "";

        in item Write_Clock;
        in item Write_ClockEnable;
        in item Write_WriteEnable;
        in item Write_Address;
        attribute Write_Address_sv : String = "logic [ADDRESS_BITS-1:0] Write_Address";
        in item Write_DataIn;
        attribute Write_DataIn_sv : String = "logic [DATA_BITS-1:0] Write_DataIn";
        in item Read_Clock;
        in item Read_ClockEnable;
        in item Read_Address;
        attribute Read_Address_sv : String = "logic [ADDRESS_BITS-1:0] Read_Address";
        out item Read_DataOut;
        attribute Read_DataOut_sv : String = "logic [DATA_BITS-1:0] Read_DataOut";

        satisfy requirement REQ_ocram_SimpleDualPort_001;
        satisfy requirement REQ_ocram_SimpleDualPort_002;
        satisfy requirement REQ_ocram_SimpleDualPort_003;
    }

    part ocram_SimpleDualPortUse : ocram_SimpleDualPort;
}
