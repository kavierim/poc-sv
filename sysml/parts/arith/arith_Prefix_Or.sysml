// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Baseline extracted from src/ on 2026-09-27.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Arith_arith_Prefix_Or {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_Arith::*;

    @ArtifactTrace {
        rtlPath = "src/arith/arith_Prefix_Or.sv";
        verifPath = "sim/arith/arith_Prefix_Or_tb.sv";
        fvPath = "";
    }
    part def arith_Prefix_Or {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute BITS : Integer = 8;

        in item x;
        attribute x_sv : String = "logic [BITS-1:0] x";
        out item y;
        attribute y_sv : String = "logic [BITS-1:0] y";

        satisfy requirement REQ_arith_Prefix_Or_001;
        satisfy requirement REQ_arith_Prefix_Or_002;
    }

    part arith_Prefix_OrUse : arith_Prefix_Or;
}
