// SPDX-FileCopyrightText: 2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Baseline extracted from src/ on 2026-09-30.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Fifo_fifo_Stage {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_Fifo::*;

    @ArtifactTrace {
        rtlPath = "src/fifo/fifo_Stage.sv";
        verifPath = "sim/fifo/fifo_Stage_tb.sv";
        fvPath = "";
    }
    part def fifo_Stage {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute DATA_BITS : Integer = 8;
        attribute STAGES : Integer = 1;
        attribute LIGHT_WEIGHT : Boolean = false;

        in item Clock;
        in item Reset;
        in item Put;
        in item DataIn;
        attribute DataIn_sv : String = "logic [DATA_BITS-1:0] DataIn";
        out item Full;
        out item Valid;
        out item DataOut;
        attribute DataOut_sv : String = "logic [DATA_BITS-1:0] DataOut";
        in item Got;
        satisfy requirement REQ_fifo_Stage_001;
        satisfy requirement REQ_fifo_Stage_002;

    }

    part fifo_StageUse : fifo_Stage;
}
