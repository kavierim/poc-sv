// SPDX-FileCopyrightText: 2007-2014 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Baseline extracted from src/ on 2026-09-27.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Arith_arith_SquareRoot {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_Arith::*;

    @ArtifactTrace {
        rtlPath = "src/arith/arith_SquareRoot.sv";
        verifPath = "";
        fvPath = "";
    }
    part def arith_SquareRoot {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute BITS : Integer = 16;

        in item Clock;
        in item Reset;
        in item Radicand;
        attribute Radicand_sv : String = "logic [BITS-1:0] Radicand";
        in item Start;
        out item Result;
        attribute Result_sv : String = "logic [(BITS-1)/2:0] Result";
        out item Ready;

        satisfy requirement REQ_arith_SquareRoot_001;
    }

    part arith_SquareRootUse : arith_SquareRoot;
}
