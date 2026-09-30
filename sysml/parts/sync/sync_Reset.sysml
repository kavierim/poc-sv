// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Sync_sync_Reset {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_SyncMem::*;

    @ArtifactTrace {
        rtlPath = "src/sync/sync_Reset.sv";
        verifPath = "sim/sync/sync_Reset_tb.sv";
        fvPath = "";
    }
    part def sync_Reset {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute SYNC_DEPTH : String = "poc_sync::SYNC_DEPTH_MIN";

        in item Clock;
        in item Input;
        in item D;
        out item Output;

        satisfy requirement REQ_sync_Reset_001;
        satisfy requirement REQ_sync_Reset_002;
    }

    part sync_ResetUse : sync_Reset;
}
