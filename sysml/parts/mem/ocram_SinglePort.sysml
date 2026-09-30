// SPDX-FileCopyrightText: 2008-2015 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Mem_ocram_SinglePort {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_SyncMem::*;

    @ArtifactTrace {
        rtlPath = "src/mem/ocram/ocram_SinglePort.sv";
        verifPath = "";
        fvPath = "";
    }
    part def ocram_SinglePort {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute ADDRESS_BITS : Integer = 8;
        attribute DATA_BITS : Integer = 8;
        attribute FILENAME : String = "";

        in item Clock;
        in item ClockEnable;
        in item WriteEnable;
        in item Address;
        attribute Address_sv : String = "logic [ADDRESS_BITS-1:0] Address";
        in item DataIn;
        attribute DataIn_sv : String = "logic [DATA_BITS-1:0] DataIn";
        out item DataOut;
        attribute DataOut_sv : String = "logic [DATA_BITS-1:0] DataOut";

        satisfy requirement REQ_ocram_SinglePort_001;
    }

    part ocram_SinglePortUse : ocram_SinglePort;
}
