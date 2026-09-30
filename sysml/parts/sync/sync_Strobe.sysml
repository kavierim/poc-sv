// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2015 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Sync_sync_Strobe {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_SyncMem::*;

    @ArtifactTrace {
        rtlPath = "src/sync/sync_Strobe.sv";
        verifPath = "";
        fvPath = "";
    }
    part def sync_Strobe {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute BITS : Integer = 1;
        attribute GATED_INPUT_BY_BUSY : Boolean = true;
        attribute SYNC_DEPTH : String = "poc_sync::SYNC_DEPTH_MIN";

        in item Clock1;
        in item Clock2;
        in item Input;
        attribute Input_sv : String = "logic [BITS-1:0] Input";
        out item Output;
        attribute Output_sv : String = "logic [BITS-1:0] Output";
        out item Busy;
        attribute Busy_sv : String = "logic [BITS-1:0] Busy";

        satisfy requirement REQ_sync_Strobe_001;
    }

    part sync_StrobeUse : sync_Strobe;
}
