// SPDX-FileCopyrightText: 2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Baseline extracted from src/ on 2026-09-30.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Fifo_fifo_ic_got {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_Fifo::*;

    @ArtifactTrace {
        rtlPath = "src/fifo/fifo_ic_got.sv";
        verifPath = "sim/fifo/fifo_ic_got_tb.sv";
        fvPath = "";
    }
    part def fifo_ic_got {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute DATA_BITS : Integer = 8;
        attribute MIN_DEPTH : Integer = 4;
        attribute DATA_REG : Boolean = false;
        attribute OUTPUT_REG : Boolean = false;
        attribute EMPTY_STATE_BITS : Integer = 0;
        attribute FILL_STATE_BITS : Integer = 0;

        in item Write_Clock;
        in item Write_Reset;
        in item Write_Put;
        in item Write_DataIn;
        attribute Write_DataIn_sv : String = "logic [DATA_BITS-1:0] Write_DataIn";
        out item Write_Full;
        out item Write_EmptyState;
        attribute Write_EmptyState_sv : String = "logic [poc_utils::imax(1, EMPTY_STATE_BITS)-1:0] Write_EmptyState";
        in item Read_Clock;
        in item Read_Reset;
        out item Read_Valid;
        out item Read_DataOut;
        attribute Read_DataOut_sv : String = "logic [DATA_BITS-1:0] Read_DataOut";
        in item Read_Got;
        out item Read_FillState;
        attribute Read_FillState_sv : String = "logic [poc_utils::imax(1, FILL_STATE_BITS)-1:0] Read_FillState";
        satisfy requirement REQ_fifo_ic_got_001;
        satisfy requirement REQ_fifo_ic_got_002;

    }

    part fifo_ic_gotUse : fifo_ic_got;
}
