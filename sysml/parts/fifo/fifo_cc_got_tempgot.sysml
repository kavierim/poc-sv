// SPDX-FileCopyrightText: 2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Baseline extracted from src/ on 2026-09-30.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Fifo_fifo_cc_got_tempgot {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_Fifo::*;

    @ArtifactTrace {
        rtlPath = "src/fifo/fifo_cc_got_tempgot.sv";
        verifPath = "";
        fvPath = "";
    }
    part def fifo_cc_got_tempgot {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute RAM_TYPE : String = "poc_mem::RAM_TYPE_OPTIMIZED";
        attribute DATA_BITS : Integer = 8;
        attribute MIN_DEPTH : Integer = 4;
        attribute DATA_REG : Boolean = false;
        attribute STATE_REG : Boolean = false;
        attribute OUTPUT_REG : Boolean = false;
        attribute EMPTY_STATE_BITS : Integer = 0;
        attribute FILL_STATE_BITS : Integer = 0;

        in item Clock;
        in item Reset;
        in item Put;
        in item DataIn;
        attribute DataIn_sv : String = "logic [DATA_BITS-1:0] DataIn";
        out item Full;
        out item EmptyState;
        attribute EmptyState_sv : String = "logic [poc_utils::imax(1, EMPTY_STATE_BITS)-1:0] EmptyState";
        in item Got;
        out item DataOut;
        attribute DataOut_sv : String = "logic [DATA_BITS-1:0] DataOut";
        out item Valid;
        out item FillState;
        attribute FillState_sv : String = "logic [poc_utils::imax(1, FILL_STATE_BITS)-1:0] FillState";
        in item Commit;
        in item Rollback;
        satisfy requirement REQ_fifo_cc_got_tempgot_001;

    }

    part fifo_cc_got_tempgotUse : fifo_cc_got_tempgot;
}
