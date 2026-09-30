// SPDX-FileCopyrightText: 2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Baseline extracted from src/ on 2026-09-30.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Fifo_fifo_Shift {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_Fifo::*;

    @ArtifactTrace {
        rtlPath = "src/fifo/fifo_Shift.sv";
        verifPath = "";
        fvPath = "";
    }
    part def fifo_Shift {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute DATA_BITS : Integer = 8;
        attribute MIN_DEPTH : Integer = 4;

        in item Clock;
        in item Reset;
        out item FillLevel;
        attribute FillLevel_sv : String = "logic [poc_utils::log2ceilnz(MIN_DEPTH):0] FillLevel";
        in item Put;
        in item DataIn;
        attribute DataIn_sv : String = "logic [DATA_BITS-1:0] DataIn";
        out item Full;
        in item Got;
        out item DataOut;
        attribute DataOut_sv : String = "logic [DATA_BITS-1:0] DataOut";
        out item Valid;
        satisfy requirement REQ_fifo_Shift_001;

    }

    part fifo_ShiftUse : fifo_Shift;
}
