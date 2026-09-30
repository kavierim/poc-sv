// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Baseline extracted from src/ on 2026-09-27.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Arith_arith_CarryChain_inc {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_Arith::*;

    @ArtifactTrace {
        rtlPath = "src/arith/arith_CarryChain_inc.sv";
        verifPath = "";
        fvPath = "";
    }
    part def arith_CarryChain_inc {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute BITS : Integer = 8;

        in item A;
        attribute A_sv : String = "logic [BITS-1:0] A";
        in item CarryIn;
        out item Sum;
        attribute Sum_sv : String = "logic [BITS-1:0] Sum";

        satisfy requirement REQ_arith_CarryChain_inc_001;
    }

    part arith_CarryChain_incUse : arith_CarryChain_inc;
}
