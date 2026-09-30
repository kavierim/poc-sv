// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Sync_sync_Bits {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_SyncMem::*;

    @ArtifactTrace {
        rtlPath = "src/sync/sync_Bits.sv";
        verifPath = "sim/sync/sync_Bits_tb.sv";
        fvPath = "";
    }
    part def sync_Bits {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute BITS : Integer = 1;
        attribute INIT : String = "32'h0000_0000";
        attribute SYNC_DEPTH : String = "poc_sync::SYNC_DEPTH_MIN";
        attribute FALSE_PATH : Boolean = true;
        attribute REGISTER_OUTPUT : Boolean = false;

        in item Clock;
        in item Input;
        attribute Input_sv : String = "logic [BITS-1:0] Input";
        out item Output;
        attribute Output_sv : String = "logic [BITS-1:0] Output";

        satisfy requirement REQ_sync_Bits_001;
        satisfy requirement REQ_sync_Bits_002;
    }

    part sync_BitsUse : sync_Bits;
}
