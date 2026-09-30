// SPDX-FileCopyrightText: 2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Baseline extracted from src/ on 2026-09-30.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Dstruct_dstruct_OutOfOrderBuffer {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_Fifo::*;

    @ArtifactTrace {
        rtlPath = "src/dstruct/dstruct_OutOfOrderBuffer.sv";
        verifPath = "";
        fvPath = "";
    }
    part def dstruct_OutOfOrderBuffer {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute DATA_BITS : Integer = 8;
        attribute NUM_INDEX : Integer = 4;

        in item Clock;
        in item Reset;
        in item Put;
        in item DataIn;
        attribute DataIn_sv : String = "logic [DATA_BITS-1:0] DataIn";
        out item Full;
        out item IndexOut;
        attribute IndexOut_sv : String = "logic [poc_utils::downto_width(poc_utils::log2ceilnz(NUM_INDEX))-1:0] IndexOut";
        in item Got;
        in item IndexIn;
        attribute IndexIn_sv : String = "logic [poc_utils::downto_width(poc_utils::log2ceilnz(NUM_INDEX))-1:0] IndexIn";
        out item DataOut;
        attribute DataOut_sv : String = "logic [DATA_BITS-1:0] DataOut";
        out item Valid;
        satisfy requirement REQ_dstruct_OutOfOrderBuffer_001;
        satisfy requirement REQ_dstruct_OutOfOrderBuffer_002;

    }

    part dstruct_OutOfOrderBufferUse : dstruct_OutOfOrderBuffer;
}
