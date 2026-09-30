// SPDX-FileCopyrightText: 2007-2015 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Baseline extracted from src/ on 2026-09-27.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Arith_arith_Counter_Free {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_Arith::*;

    @ArtifactTrace {
        rtlPath = "src/arith/arith_Counter_Free.sv";
        verifPath = "sim/arith/arith_Counter_Free_tb.sv";
        fvPath = "";
    }
    part def arith_Counter_Free {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute DIVIDER : Integer = 1;

        in item Clock;
        in item Reset;
        in item Increment;
        out item Strobe;

        satisfy requirement REQ_arith_Counter_Free_001;
        satisfy requirement REQ_arith_Counter_Free_002;
    }

    part arith_Counter_FreeUse : arith_Counter_Free;
}
