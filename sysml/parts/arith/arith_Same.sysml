// SPDX-FileCopyrightText: 2007-2015 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Baseline extracted from src/ on 2026-09-27.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Arith_arith_Same {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_Arith::*;

    @ArtifactTrace {
        rtlPath = "src/arith/arith_Same.sv";
        verifPath = "";
        fvPath = "";
    }
    part def arith_Same {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute BITS : Integer = 8;

        in item g;
        in item x;
        attribute x_sv : String = "logic [BITS-1:0] x";
        out item y;

        satisfy requirement REQ_arith_Same_001;
    }

    part arith_SameUse : arith_Same;
}
