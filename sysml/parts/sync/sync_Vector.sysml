// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2015 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Sync_sync_Vector {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_SyncMem::*;

    @ArtifactTrace {
        rtlPath = "src/sync/sync_Vector.sv";
        verifPath = "";
        fvPath = "";
    }
    part def sync_Vector {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute MASTER_BITS : Integer = 8;
        attribute SLAVE_BITS : Integer = 0;
        attribute INIT : String = "32'h0000_0000";
        attribute SYNC_DEPTH : String = "poc_sync::SYNC_DEPTH_MIN";

        in item Clock1;
        in item Clock2;
        in item Input;
        attribute Input_sv : String = "logic [(SLAVE_BITS + MASTER_BITS)-1:0] Input";
        out item Busy;
        in item Strobe;
        out item Output;
        attribute Output_sv : String = "logic [(SLAVE_BITS + MASTER_BITS)-1:0] Output";
        out item Changed;

        satisfy requirement REQ_sync_Vector_001;
    }

    part sync_VectorUse : sync_Vector;
}
