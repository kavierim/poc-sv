// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2008-2015 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Mem_ocram_SimpleDualPort_WriteFirst {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_SyncMem::*;

    @ArtifactTrace {
        rtlPath = "src/mem/ocram/ocram_SimpleDualPort_WriteFirst.sv";
        verifPath = "";
        fvPath = "";
    }
    part def ocram_SimpleDualPort_WriteFirst {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute ADDRESS_BITS : Integer = 8;
        attribute DATA_BITS : Integer = 8;
        attribute FILENAME : String = "";

        in item Clock;
        in item ClockEnable;
        in item Write_Enable;
        in item Write_Address;
        attribute Write_Address_sv : String = "logic [ADDRESS_BITS-1:0] Write_Address";
        in item Write_DataIn;
        attribute Write_DataIn_sv : String = "logic [DATA_BITS-1:0] Write_DataIn";
        in item Read_Address;
        attribute Read_Address_sv : String = "logic [ADDRESS_BITS-1:0] Read_Address";
        out item Read_DataOut;
        attribute Read_DataOut_sv : String = "logic [DATA_BITS-1:0] Read_DataOut";

        satisfy requirement REQ_ocram_SimpleDualPort_WriteFirst_001;
    }

    part ocram_SimpleDualPort_WriteFirstUse : ocram_SimpleDualPort_WriteFirst;
}
